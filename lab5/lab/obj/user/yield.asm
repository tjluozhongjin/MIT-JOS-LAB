
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 1e 80 00       	push   $0x801ea0
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 1b 0b 00 00       	call   800b75 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 1e 80 00       	push   $0x801ec0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ec 1e 80 00       	push   $0x801eec
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 ac 0a 00 00       	call   800b56 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 65 0e 00 00       	call   800f50 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 20 0a 00 00       	call   800b15 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 ae 09 00 00       	call   800ad8 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 1a 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 53 09 00 00       	call   800ad8 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 1b 1a 00 00       	call   801c10 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 08 1b 00 00       	call   801d40 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 15 1f 80 00 	movsbl 0x801f15(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 42 04 00 00    	je     8006e8 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 d0             	movzbl %al,%edx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 d3 03 00 00    	ja     8006cd <vprintfmt+0x443>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800322:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800325:	83 f9 09             	cmp    $0x9,%ecx
  800328:	77 3f                	ja     800369 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 40 04             	lea    0x4(%eax),%eax
  80033d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800343:	eb 2a                	jmp    80036f <vprintfmt+0xe5>
  800345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	0f 49 d0             	cmovns %eax,%edx
  800352:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	eb 89                	jmp    8002e3 <vprintfmt+0x59>
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800364:	e9 7a ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
  800369:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80036f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800373:	0f 89 6a ff ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800379:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	e9 58 ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800391:	e9 4d ff ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 78 04             	lea    0x4(%eax),%edi
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ad:	e9 fe fe ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 78 04             	lea    0x4(%eax),%edi
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 0f             	cmp    $0xf,%eax
  8003c2:	7f 0b                	jg     8003cf <vprintfmt+0x145>
  8003c4:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	75 1b                	jne    8003ea <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003cf:	50                   	push   %eax
  8003d0:	68 2d 1f 80 00       	push   $0x801f2d
  8003d5:	53                   	push   %ebx
  8003d6:	56                   	push   %esi
  8003d7:	e8 91 fe ff ff       	call   80026d <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003df:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e5:	e9 c6 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ea:	52                   	push   %edx
  8003eb:	68 f1 22 80 00       	push   $0x8022f1
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 76 fe ff ff       	call   80026d <printfmt>
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
  800400:	e9 ab fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	83 c0 04             	add    $0x4,%eax
  80040b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800413:	85 ff                	test   %edi,%edi
  800415:	b8 26 1f 80 00       	mov    $0x801f26,%eax
  80041a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 8e 94 00 00 00    	jle    8004bb <vprintfmt+0x231>
  800427:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042b:	0f 84 98 00 00 00    	je     8004c9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d0             	pushl  -0x30(%ebp)
  800437:	57                   	push   %edi
  800438:	e8 33 03 00 00       	call   800770 <strnlen>
  80043d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800440:	29 c1                	sub    %eax,%ecx
  800442:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800445:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800448:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800452:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	eb 0f                	jmp    800465 <vprintfmt+0x1db>
					putch(padc, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	53                   	push   %ebx
  80045a:	ff 75 e0             	pushl  -0x20(%ebp)
  80045d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ef 01             	sub    $0x1,%edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 ff                	test   %edi,%edi
  800467:	7f ed                	jg     800456 <vprintfmt+0x1cc>
  800469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046f:	85 c9                	test   %ecx,%ecx
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	0f 49 c1             	cmovns %ecx,%eax
  800479:	29 c1                	sub    %eax,%ecx
  80047b:	89 75 08             	mov    %esi,0x8(%ebp)
  80047e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800484:	89 cb                	mov    %ecx,%ebx
  800486:	eb 4d                	jmp    8004d5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800488:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048c:	74 1b                	je     8004a9 <vprintfmt+0x21f>
  80048e:	0f be c0             	movsbl %al,%eax
  800491:	83 e8 20             	sub    $0x20,%eax
  800494:	83 f8 5e             	cmp    $0x5e,%eax
  800497:	76 10                	jbe    8004a9 <vprintfmt+0x21f>
					putch('?', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	6a 3f                	push   $0x3f
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb 0d                	jmp    8004b6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 0c             	pushl  0xc(%ebp)
  8004af:	52                   	push   %edx
  8004b0:	ff 55 08             	call   *0x8(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b6:	83 eb 01             	sub    $0x1,%ebx
  8004b9:	eb 1a                	jmp    8004d5 <vprintfmt+0x24b>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	eb 0c                	jmp    8004d5 <vprintfmt+0x24b>
  8004c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	0f be d0             	movsbl %al,%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 23                	je     800506 <vprintfmt+0x27c>
  8004e3:	85 f6                	test   %esi,%esi
  8004e5:	78 a1                	js     800488 <vprintfmt+0x1fe>
  8004e7:	83 ee 01             	sub    $0x1,%esi
  8004ea:	79 9c                	jns    800488 <vprintfmt+0x1fe>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	eb 18                	jmp    80050e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	6a 20                	push   $0x20
  8004fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fe:	83 ef 01             	sub    $0x1,%edi
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	eb 08                	jmp    80050e <vprintfmt+0x284>
  800506:	89 df                	mov    %ebx,%edi
  800508:	8b 75 08             	mov    0x8(%ebp),%esi
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	85 ff                	test   %edi,%edi
  800510:	7f e4                	jg     8004f6 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800512:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051b:	e9 90 fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800520:	83 f9 01             	cmp    $0x1,%ecx
  800523:	7e 19                	jle    80053e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 50 04             	mov    0x4(%eax),%edx
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 40 08             	lea    0x8(%eax),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
  80053c:	eb 38                	jmp    800576 <vprintfmt+0x2ec>
	else if (lflag)
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	74 1b                	je     80055d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 c1                	mov    %eax,%ecx
  80054c:	c1 f9 1f             	sar    $0x1f,%ecx
  80054f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb 19                	jmp    800576 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800576:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800581:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800585:	0f 89 0e 01 00 00    	jns    800699 <vprintfmt+0x40f>
				putch('-', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 2d                	push   $0x2d
  800591:	ff d6                	call   *%esi
				num = -(long long) num;
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800599:	f7 da                	neg    %edx
  80059b:	83 d1 00             	adc    $0x0,%ecx
  80059e:	f7 d9                	neg    %ecx
  8005a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 ec 00 00 00       	jmp    800699 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ad:	83 f9 01             	cmp    $0x1,%ecx
  8005b0:	7e 18                	jle    8005ca <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ba:	8d 40 08             	lea    0x8(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 cf 00 00 00       	jmp    800699 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	74 1a                	je     8005e8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
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
  8005e3:	e9 b1 00 00 00       	jmp    800699 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fd:	e9 97 00 00 00       	jmp    800699 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 58                	push   $0x58
  800608:	ff d6                	call   *%esi
			putch('X', putdat);
  80060a:	83 c4 08             	add    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 58                	push   $0x58
  800610:	ff d6                	call   *%esi
			putch('X', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 58                	push   $0x58
  800618:	ff d6                	call   *%esi
			break;
  80061a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800620:	e9 8b fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064d:	eb 4a                	jmp    800699 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7e 15                	jle    800669 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	8b 48 04             	mov    0x4(%eax),%ecx
  80065c:	8d 40 08             	lea    0x8(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
  800667:	eb 30                	jmp    800699 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800669:	85 c9                	test   %ecx,%ecx
  80066b:	74 17                	je     800684 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 10                	mov    (%eax),%edx
  800672:	b9 00 00 00 00       	mov    $0x0,%ecx
  800677:	8d 40 04             	lea    0x4(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
  800682:	eb 15                	jmp    800699 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a0:	57                   	push   %edi
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	50                   	push   %eax
  8006a5:	51                   	push   %ecx
  8006a6:	52                   	push   %edx
  8006a7:	89 da                	mov    %ebx,%edx
  8006a9:	89 f0                	mov    %esi,%eax
  8006ab:	e8 f1 fa ff ff       	call   8001a1 <printnum>
			break;
  8006b0:	83 c4 20             	add    $0x20,%esp
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b6:	e9 f5 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	52                   	push   %edx
  8006c0:	ff d6                	call   *%esi
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c8:	e9 e3 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	eb 03                	jmp    8006dd <vprintfmt+0x453>
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e1:	75 f7                	jne    8006da <vprintfmt+0x450>
  8006e3:	e9 c8 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 18             	sub    $0x18,%esp
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800703:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800706:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 26                	je     800737 <vsnprintf+0x47>
  800711:	85 d2                	test   %edx,%edx
  800713:	7e 22                	jle    800737 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800715:	ff 75 14             	pushl  0x14(%ebp)
  800718:	ff 75 10             	pushl  0x10(%ebp)
  80071b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	68 50 02 80 00       	push   $0x800250
  800724:	e8 61 fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800729:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 05                	jmp    80073c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800747:	50                   	push   %eax
  800748:	ff 75 10             	pushl  0x10(%ebp)
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	ff 75 08             	pushl  0x8(%ebp)
  800751:	e8 9a ff ff ff       	call   8006f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 03                	jmp    800768 <strlen+0x10>
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800768:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076c:	75 f7                	jne    800765 <strlen+0xd>
		n++;
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	ba 00 00 00 00       	mov    $0x0,%edx
  80077e:	eb 03                	jmp    800783 <strnlen+0x13>
		n++;
  800780:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	39 c2                	cmp    %eax,%edx
  800785:	74 08                	je     80078f <strnlen+0x1f>
  800787:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078b:	75 f3                	jne    800780 <strnlen+0x10>
  80078d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007aa:	84 db                	test   %bl,%bl
  8007ac:	75 ef                	jne    80079d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b8:	53                   	push   %ebx
  8007b9:	e8 9a ff ff ff       	call   800758 <strlen>
  8007be:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	01 d8                	add    %ebx,%eax
  8007c6:	50                   	push   %eax
  8007c7:	e8 c5 ff ff ff       	call   800791 <strcpy>
	return dst;
}
  8007cc:	89 d8                	mov    %ebx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	89 f3                	mov    %esi,%ebx
  8007e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	89 f2                	mov    %esi,%edx
  8007e5:	eb 0f                	jmp    8007f6 <strncpy+0x23>
		*dst++ = *src;
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	39 da                	cmp    %ebx,%edx
  8007f8:	75 ed                	jne    8007e7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	8b 55 10             	mov    0x10(%ebp),%edx
  80080e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 d2                	test   %edx,%edx
  800812:	74 21                	je     800835 <strlcpy+0x35>
  800814:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800818:	89 f2                	mov    %esi,%edx
  80081a:	eb 09                	jmp    800825 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	83 c1 01             	add    $0x1,%ecx
  800822:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800825:	39 c2                	cmp    %eax,%edx
  800827:	74 09                	je     800832 <strlcpy+0x32>
  800829:	0f b6 19             	movzbl (%ecx),%ebx
  80082c:	84 db                	test   %bl,%bl
  80082e:	75 ec                	jne    80081c <strlcpy+0x1c>
  800830:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800832:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800835:	29 f0                	sub    %esi,%eax
}
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	eb 06                	jmp    80084c <strcmp+0x11>
		p++, q++;
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	84 c0                	test   %al,%al
  800851:	74 04                	je     800857 <strcmp+0x1c>
  800853:	3a 02                	cmp    (%edx),%al
  800855:	74 ef                	je     800846 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 c0             	movzbl %al,%eax
  80085a:	0f b6 12             	movzbl (%edx),%edx
  80085d:	29 d0                	sub    %edx,%eax
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800870:	eb 06                	jmp    800878 <strncmp+0x17>
		n--, p++, q++;
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800878:	39 d8                	cmp    %ebx,%eax
  80087a:	74 15                	je     800891 <strncmp+0x30>
  80087c:	0f b6 08             	movzbl (%eax),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 04                	je     800887 <strncmp+0x26>
  800883:	3a 0a                	cmp    (%edx),%cl
  800885:	74 eb                	je     800872 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb 05                	jmp    800896 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	eb 07                	jmp    8008ac <strchr+0x13>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 0f                	je     8008b8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f2                	jne    8008a5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 03                	jmp    8008c9 <strfind+0xf>
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 04                	je     8008d4 <strfind+0x1a>
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f2                	jne    8008c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e2:	85 c9                	test   %ecx,%ecx
  8008e4:	74 36                	je     80091c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ec:	75 28                	jne    800916 <memset+0x40>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	75 23                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f7:	89 d3                	mov    %edx,%ebx
  8008f9:	c1 e3 08             	shl    $0x8,%ebx
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	c1 e6 18             	shl    $0x18,%esi
  800901:	89 d0                	mov    %edx,%eax
  800903:	c1 e0 10             	shl    $0x10,%eax
  800906:	09 f0                	or     %esi,%eax
  800908:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	09 d0                	or     %edx,%eax
  80090e:	c1 e9 02             	shr    $0x2,%ecx
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 06                	jmp    80091c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	fc                   	cld    
  80091a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091c:	89 f8                	mov    %edi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800931:	39 c6                	cmp    %eax,%esi
  800933:	73 35                	jae    80096a <memmove+0x47>
  800935:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800938:	39 d0                	cmp    %edx,%eax
  80093a:	73 2e                	jae    80096a <memmove+0x47>
		s += n;
		d += n;
  80093c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	89 d6                	mov    %edx,%esi
  800941:	09 fe                	or     %edi,%esi
  800943:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800949:	75 13                	jne    80095e <memmove+0x3b>
  80094b:	f6 c1 03             	test   $0x3,%cl
  80094e:	75 0e                	jne    80095e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 09                	jmp    800967 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 1d                	jmp    800987 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	09 c2                	or     %eax,%edx
  80096e:	f6 c2 03             	test   $0x3,%dl
  800971:	75 0f                	jne    800982 <memmove+0x5f>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0a                	jne    800982 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 05                	jmp    800987 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 87 ff ff ff       	call   800923 <memmove>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	eb 1a                	jmp    8009ca <memcmp+0x2c>
		if (*s1 != *s2)
  8009b0:	0f b6 08             	movzbl (%eax),%ecx
  8009b3:	0f b6 1a             	movzbl (%edx),%ebx
  8009b6:	38 d9                	cmp    %bl,%cl
  8009b8:	74 0a                	je     8009c4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ba:	0f b6 c1             	movzbl %cl,%eax
  8009bd:	0f b6 db             	movzbl %bl,%ebx
  8009c0:	29 d8                	sub    %ebx,%eax
  8009c2:	eb 0f                	jmp    8009d3 <memcmp+0x35>
		s1++, s2++;
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ca:	39 f0                	cmp    %esi,%eax
  8009cc:	75 e2                	jne    8009b0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009de:	89 c1                	mov    %eax,%ecx
  8009e0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	eb 0a                	jmp    8009f3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	39 da                	cmp    %ebx,%edx
  8009ee:	74 07                	je     8009f7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	39 c8                	cmp    %ecx,%eax
  8009f5:	72 f2                	jb     8009e9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 03                	jmp    800a0b <strtol+0x11>
		s++;
  800a08:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	3c 20                	cmp    $0x20,%al
  800a10:	74 f6                	je     800a08 <strtol+0xe>
  800a12:	3c 09                	cmp    $0x9,%al
  800a14:	74 f2                	je     800a08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a16:	3c 2b                	cmp    $0x2b,%al
  800a18:	75 0a                	jne    800a24 <strtol+0x2a>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a22:	eb 11                	jmp    800a35 <strtol+0x3b>
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	75 08                	jne    800a35 <strtol+0x3b>
		s++, neg = 1;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 15                	jne    800a52 <strtol+0x58>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 10                	jne    800a52 <strtol+0x58>
  800a42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a46:	75 7c                	jne    800ac4 <strtol+0xca>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb 16                	jmp    800a68 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	75 12                	jne    800a68 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a56:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5e:	75 08                	jne    800a68 <strtol+0x6e>
		s++, base = 8;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 11             	movzbl (%ecx),%edx
  800a73:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0x8b>
			dig = *s - '0';
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 30             	sub    $0x30,%edx
  800a83:	eb 22                	jmp    800aa7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 57             	sub    $0x57,%edx
  800a95:	eb 10                	jmp    800aa7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a97:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 16                	ja     800ab7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaa:	7d 0b                	jge    800ab7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab5:	eb b9                	jmp    800a70 <strtol+0x76>

	if (endptr)
  800ab7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abb:	74 0d                	je     800aca <strtol+0xd0>
		*endptr = (char *) s;
  800abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac0:	89 0e                	mov    %ecx,(%esi)
  800ac2:	eb 06                	jmp    800aca <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac4:	85 db                	test   %ebx,%ebx
  800ac6:	74 98                	je     800a60 <strtol+0x66>
  800ac8:	eb 9e                	jmp    800a68 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aca:	89 c2                	mov    %eax,%edx
  800acc:	f7 da                	neg    %edx
  800ace:	85 ff                	test   %edi,%edi
  800ad0:	0f 45 c2             	cmovne %edx,%eax
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	89 c6                	mov    %eax,%esi
  800aef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 cb                	mov    %ecx,%ebx
  800b2d:	89 cf                	mov    %ecx,%edi
  800b2f:	89 ce                	mov    %ecx,%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 03                	push   $0x3
  800b3d:	68 1f 22 80 00       	push   $0x80221f
  800b42:	6a 23                	push   $0x23
  800b44:	68 3c 22 80 00       	push   $0x80223c
  800b49:	e8 27 0f 00 00       	call   801a75 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 02 00 00 00       	mov    $0x2,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_yield>:

void
sys_yield(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b85:	89 d1                	mov    %edx,%ecx
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	89 d7                	mov    %edx,%edi
  800b8b:	89 d6                	mov    %edx,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ba2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb0:	89 f7                	mov    %esi,%edi
  800bb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 17                	jle    800bcf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 04                	push   $0x4
  800bbe:	68 1f 22 80 00       	push   $0x80221f
  800bc3:	6a 23                	push   $0x23
  800bc5:	68 3c 22 80 00       	push   $0x80223c
  800bca:	e8 a6 0e 00 00       	call   801a75 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	b8 05 00 00 00       	mov    $0x5,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 05                	push   $0x5
  800c00:	68 1f 22 80 00       	push   $0x80221f
  800c05:	6a 23                	push   $0x23
  800c07:	68 3c 22 80 00       	push   $0x80223c
  800c0c:	e8 64 0e 00 00       	call   801a75 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c27:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	89 df                	mov    %ebx,%edi
  800c34:	89 de                	mov    %ebx,%esi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 06                	push   $0x6
  800c42:	68 1f 22 80 00       	push   $0x80221f
  800c47:	6a 23                	push   $0x23
  800c49:	68 3c 22 80 00       	push   $0x80223c
  800c4e:	e8 22 0e 00 00       	call   801a75 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 08                	push   $0x8
  800c84:	68 1f 22 80 00       	push   $0x80221f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 3c 22 80 00       	push   $0x80223c
  800c90:	e8 e0 0d 00 00       	call   801a75 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 09                	push   $0x9
  800cc6:	68 1f 22 80 00       	push   $0x80221f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 3c 22 80 00       	push   $0x80223c
  800cd2:	e8 9e 0d 00 00       	call   801a75 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0a                	push   $0xa
  800d08:	68 1f 22 80 00       	push   $0x80221f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 3c 22 80 00       	push   $0x80223c
  800d14:	e8 5c 0d 00 00       	call   801a75 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	be 00 00 00 00       	mov    $0x0,%esi
  800d2c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d52:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 cb                	mov    %ecx,%ebx
  800d5c:	89 cf                	mov    %ecx,%edi
  800d5e:	89 ce                	mov    %ecx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0d                	push   $0xd
  800d6c:	68 1f 22 80 00       	push   $0x80221f
  800d71:	6a 23                	push   $0x23
  800d73:	68 3c 22 80 00       	push   $0x80223c
  800d78:	e8 f8 0c 00 00       	call   801a75 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d90:	c1 e8 0c             	shr    $0xc,%eax
}
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	05 00 00 00 30       	add    $0x30000000,%eax
  800da0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	c1 ea 16             	shr    $0x16,%edx
  800dbc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc3:	f6 c2 01             	test   $0x1,%dl
  800dc6:	74 11                	je     800dd9 <fd_alloc+0x2d>
  800dc8:	89 c2                	mov    %eax,%edx
  800dca:	c1 ea 0c             	shr    $0xc,%edx
  800dcd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd4:	f6 c2 01             	test   $0x1,%dl
  800dd7:	75 09                	jne    800de2 <fd_alloc+0x36>
			*fd_store = fd;
  800dd9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  800de0:	eb 17                	jmp    800df9 <fd_alloc+0x4d>
  800de2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dec:	75 c9                	jne    800db7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e01:	83 f8 1f             	cmp    $0x1f,%eax
  800e04:	77 36                	ja     800e3c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e06:	c1 e0 0c             	shl    $0xc,%eax
  800e09:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	c1 ea 16             	shr    $0x16,%edx
  800e13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1a:	f6 c2 01             	test   $0x1,%dl
  800e1d:	74 24                	je     800e43 <fd_lookup+0x48>
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	c1 ea 0c             	shr    $0xc,%edx
  800e24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2b:	f6 c2 01             	test   $0x1,%dl
  800e2e:	74 1a                	je     800e4a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e33:	89 02                	mov    %eax,(%edx)
	return 0;
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3a:	eb 13                	jmp    800e4f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e41:	eb 0c                	jmp    800e4f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e48:	eb 05                	jmp    800e4f <fd_lookup+0x54>
  800e4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	ba c8 22 80 00       	mov    $0x8022c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5f:	eb 13                	jmp    800e74 <dev_lookup+0x23>
  800e61:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e64:	39 08                	cmp    %ecx,(%eax)
  800e66:	75 0c                	jne    800e74 <dev_lookup+0x23>
			*dev = devtab[i];
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e72:	eb 2e                	jmp    800ea2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e74:	8b 02                	mov    (%edx),%eax
  800e76:	85 c0                	test   %eax,%eax
  800e78:	75 e7                	jne    800e61 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e7f:	8b 40 48             	mov    0x48(%eax),%eax
  800e82:	83 ec 04             	sub    $0x4,%esp
  800e85:	51                   	push   %ecx
  800e86:	50                   	push   %eax
  800e87:	68 4c 22 80 00       	push   $0x80224c
  800e8c:	e8 fc f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 10             	sub    $0x10,%esp
  800eac:	8b 75 08             	mov    0x8(%ebp),%esi
  800eaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ebc:	c1 e8 0c             	shr    $0xc,%eax
  800ebf:	50                   	push   %eax
  800ec0:	e8 36 ff ff ff       	call   800dfb <fd_lookup>
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 05                	js     800ed1 <fd_close+0x2d>
	    || fd != fd2)
  800ecc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ecf:	74 0c                	je     800edd <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed1:	84 db                	test   %bl,%bl
  800ed3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed8:	0f 44 c2             	cmove  %edx,%eax
  800edb:	eb 41                	jmp    800f1e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee3:	50                   	push   %eax
  800ee4:	ff 36                	pushl  (%esi)
  800ee6:	e8 66 ff ff ff       	call   800e51 <dev_lookup>
  800eeb:	89 c3                	mov    %eax,%ebx
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 1a                	js     800f0e <fd_close+0x6a>
		if (dev->dev_close)
  800ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800efa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	74 0b                	je     800f0e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	56                   	push   %esi
  800f07:	ff d0                	call   *%eax
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f0e:	83 ec 08             	sub    $0x8,%esp
  800f11:	56                   	push   %esi
  800f12:	6a 00                	push   $0x0
  800f14:	e8 00 fd ff ff       	call   800c19 <sys_page_unmap>
	return r;
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	89 d8                	mov    %ebx,%eax
}
  800f1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2e:	50                   	push   %eax
  800f2f:	ff 75 08             	pushl  0x8(%ebp)
  800f32:	e8 c4 fe ff ff       	call   800dfb <fd_lookup>
  800f37:	83 c4 08             	add    $0x8,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 10                	js     800f4e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	6a 01                	push   $0x1
  800f43:	ff 75 f4             	pushl  -0xc(%ebp)
  800f46:	e8 59 ff ff ff       	call   800ea4 <fd_close>
  800f4b:	83 c4 10             	add    $0x10,%esp
}
  800f4e:	c9                   	leave  
  800f4f:	c3                   	ret    

00800f50 <close_all>:

void
close_all(void)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	53                   	push   %ebx
  800f54:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f57:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	53                   	push   %ebx
  800f60:	e8 c0 ff ff ff       	call   800f25 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f65:	83 c3 01             	add    $0x1,%ebx
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	83 fb 20             	cmp    $0x20,%ebx
  800f6e:	75 ec                	jne    800f5c <close_all+0xc>
		close(i);
}
  800f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 2c             	sub    $0x2c,%esp
  800f7e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f81:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f84:	50                   	push   %eax
  800f85:	ff 75 08             	pushl  0x8(%ebp)
  800f88:	e8 6e fe ff ff       	call   800dfb <fd_lookup>
  800f8d:	83 c4 08             	add    $0x8,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	0f 88 c1 00 00 00    	js     801059 <dup+0xe4>
		return r;
	close(newfdnum);
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	56                   	push   %esi
  800f9c:	e8 84 ff ff ff       	call   800f25 <close>

	newfd = INDEX2FD(newfdnum);
  800fa1:	89 f3                	mov    %esi,%ebx
  800fa3:	c1 e3 0c             	shl    $0xc,%ebx
  800fa6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fac:	83 c4 04             	add    $0x4,%esp
  800faf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb2:	e8 de fd ff ff       	call   800d95 <fd2data>
  800fb7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb9:	89 1c 24             	mov    %ebx,(%esp)
  800fbc:	e8 d4 fd ff ff       	call   800d95 <fd2data>
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc7:	89 f8                	mov    %edi,%eax
  800fc9:	c1 e8 16             	shr    $0x16,%eax
  800fcc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd3:	a8 01                	test   $0x1,%al
  800fd5:	74 37                	je     80100e <dup+0x99>
  800fd7:	89 f8                	mov    %edi,%eax
  800fd9:	c1 e8 0c             	shr    $0xc,%eax
  800fdc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe3:	f6 c2 01             	test   $0x1,%dl
  800fe6:	74 26                	je     80100e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff7:	50                   	push   %eax
  800ff8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffb:	6a 00                	push   $0x0
  800ffd:	57                   	push   %edi
  800ffe:	6a 00                	push   $0x0
  801000:	e8 d2 fb ff ff       	call   800bd7 <sys_page_map>
  801005:	89 c7                	mov    %eax,%edi
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 2e                	js     80103c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801011:	89 d0                	mov    %edx,%eax
  801013:	c1 e8 0c             	shr    $0xc,%eax
  801016:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	25 07 0e 00 00       	and    $0xe07,%eax
  801025:	50                   	push   %eax
  801026:	53                   	push   %ebx
  801027:	6a 00                	push   $0x0
  801029:	52                   	push   %edx
  80102a:	6a 00                	push   $0x0
  80102c:	e8 a6 fb ff ff       	call   800bd7 <sys_page_map>
  801031:	89 c7                	mov    %eax,%edi
  801033:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801036:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801038:	85 ff                	test   %edi,%edi
  80103a:	79 1d                	jns    801059 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	53                   	push   %ebx
  801040:	6a 00                	push   $0x0
  801042:	e8 d2 fb ff ff       	call   800c19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104d:	6a 00                	push   $0x0
  80104f:	e8 c5 fb ff ff       	call   800c19 <sys_page_unmap>
	return r;
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	89 f8                	mov    %edi,%eax
}
  801059:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	53                   	push   %ebx
  801065:	83 ec 14             	sub    $0x14,%esp
  801068:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80106b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106e:	50                   	push   %eax
  80106f:	53                   	push   %ebx
  801070:	e8 86 fd ff ff       	call   800dfb <fd_lookup>
  801075:	83 c4 08             	add    $0x8,%esp
  801078:	89 c2                	mov    %eax,%edx
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 6d                	js     8010eb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801084:	50                   	push   %eax
  801085:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801088:	ff 30                	pushl  (%eax)
  80108a:	e8 c2 fd ff ff       	call   800e51 <dev_lookup>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 4c                	js     8010e2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801096:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801099:	8b 42 08             	mov    0x8(%edx),%eax
  80109c:	83 e0 03             	and    $0x3,%eax
  80109f:	83 f8 01             	cmp    $0x1,%eax
  8010a2:	75 21                	jne    8010c5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a9:	8b 40 48             	mov    0x48(%eax),%eax
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	53                   	push   %ebx
  8010b0:	50                   	push   %eax
  8010b1:	68 8d 22 80 00       	push   $0x80228d
  8010b6:	e8 d2 f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c3:	eb 26                	jmp    8010eb <read+0x8a>
	}
	if (!dev->dev_read)
  8010c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c8:	8b 40 08             	mov    0x8(%eax),%eax
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	74 17                	je     8010e6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	ff 75 10             	pushl  0x10(%ebp)
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	52                   	push   %edx
  8010d9:	ff d0                	call   *%eax
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	eb 09                	jmp    8010eb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e2:	89 c2                	mov    %eax,%edx
  8010e4:	eb 05                	jmp    8010eb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010eb:	89 d0                	mov    %edx,%eax
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801101:	bb 00 00 00 00       	mov    $0x0,%ebx
  801106:	eb 21                	jmp    801129 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	89 f0                	mov    %esi,%eax
  80110d:	29 d8                	sub    %ebx,%eax
  80110f:	50                   	push   %eax
  801110:	89 d8                	mov    %ebx,%eax
  801112:	03 45 0c             	add    0xc(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	57                   	push   %edi
  801117:	e8 45 ff ff ff       	call   801061 <read>
		if (m < 0)
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 10                	js     801133 <readn+0x41>
			return m;
		if (m == 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	74 0a                	je     801131 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801127:	01 c3                	add    %eax,%ebx
  801129:	39 f3                	cmp    %esi,%ebx
  80112b:	72 db                	jb     801108 <readn+0x16>
  80112d:	89 d8                	mov    %ebx,%eax
  80112f:	eb 02                	jmp    801133 <readn+0x41>
  801131:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	53                   	push   %ebx
  80113f:	83 ec 14             	sub    $0x14,%esp
  801142:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801145:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	53                   	push   %ebx
  80114a:	e8 ac fc ff ff       	call   800dfb <fd_lookup>
  80114f:	83 c4 08             	add    $0x8,%esp
  801152:	89 c2                	mov    %eax,%edx
  801154:	85 c0                	test   %eax,%eax
  801156:	78 68                	js     8011c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115e:	50                   	push   %eax
  80115f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801162:	ff 30                	pushl  (%eax)
  801164:	e8 e8 fc ff ff       	call   800e51 <dev_lookup>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 47                	js     8011b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801173:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801177:	75 21                	jne    80119a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801179:	a1 04 40 80 00       	mov    0x804004,%eax
  80117e:	8b 40 48             	mov    0x48(%eax),%eax
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	53                   	push   %ebx
  801185:	50                   	push   %eax
  801186:	68 a9 22 80 00       	push   $0x8022a9
  80118b:	e8 fd ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801198:	eb 26                	jmp    8011c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80119a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119d:	8b 52 0c             	mov    0xc(%edx),%edx
  8011a0:	85 d2                	test   %edx,%edx
  8011a2:	74 17                	je     8011bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	ff 75 10             	pushl  0x10(%ebp)
  8011aa:	ff 75 0c             	pushl  0xc(%ebp)
  8011ad:	50                   	push   %eax
  8011ae:	ff d2                	call   *%edx
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	eb 09                	jmp    8011c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	eb 05                	jmp    8011c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011c0:	89 d0                	mov    %edx,%eax
  8011c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	ff 75 08             	pushl  0x8(%ebp)
  8011d4:	e8 22 fc ff ff       	call   800dfb <fd_lookup>
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 0e                	js     8011ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 14             	sub    $0x14,%esp
  8011f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	53                   	push   %ebx
  8011ff:	e8 f7 fb ff ff       	call   800dfb <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	89 c2                	mov    %eax,%edx
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 65                	js     801272 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801217:	ff 30                	pushl  (%eax)
  801219:	e8 33 fc ff ff       	call   800e51 <dev_lookup>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 44                	js     801269 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801228:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122c:	75 21                	jne    80124f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80122e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801233:	8b 40 48             	mov    0x48(%eax),%eax
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	53                   	push   %ebx
  80123a:	50                   	push   %eax
  80123b:	68 6c 22 80 00       	push   $0x80226c
  801240:	e8 48 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124d:	eb 23                	jmp    801272 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80124f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801252:	8b 52 18             	mov    0x18(%edx),%edx
  801255:	85 d2                	test   %edx,%edx
  801257:	74 14                	je     80126d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801259:	83 ec 08             	sub    $0x8,%esp
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	50                   	push   %eax
  801260:	ff d2                	call   *%edx
  801262:	89 c2                	mov    %eax,%edx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	eb 09                	jmp    801272 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 05                	jmp    801272 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80126d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801272:	89 d0                	mov    %edx,%eax
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	53                   	push   %ebx
  80127d:	83 ec 14             	sub    $0x14,%esp
  801280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801283:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	ff 75 08             	pushl  0x8(%ebp)
  80128a:	e8 6c fb ff ff       	call   800dfb <fd_lookup>
  80128f:	83 c4 08             	add    $0x8,%esp
  801292:	89 c2                	mov    %eax,%edx
  801294:	85 c0                	test   %eax,%eax
  801296:	78 58                	js     8012f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129e:	50                   	push   %eax
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	ff 30                	pushl  (%eax)
  8012a4:	e8 a8 fb ff ff       	call   800e51 <dev_lookup>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 37                	js     8012e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b7:	74 32                	je     8012eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c3:	00 00 00 
	stat->st_isdir = 0;
  8012c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012cd:	00 00 00 
	stat->st_dev = dev;
  8012d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	53                   	push   %ebx
  8012da:	ff 75 f0             	pushl  -0x10(%ebp)
  8012dd:	ff 50 14             	call   *0x14(%eax)
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	eb 09                	jmp    8012f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	eb 05                	jmp    8012f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012f0:	89 d0                	mov    %edx,%eax
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012fc:	83 ec 08             	sub    $0x8,%esp
  8012ff:	6a 00                	push   $0x0
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 e9 01 00 00       	call   8014f2 <open>
  801309:	89 c3                	mov    %eax,%ebx
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 1b                	js     80132d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	ff 75 0c             	pushl  0xc(%ebp)
  801318:	50                   	push   %eax
  801319:	e8 5b ff ff ff       	call   801279 <fstat>
  80131e:	89 c6                	mov    %eax,%esi
	close(fd);
  801320:	89 1c 24             	mov    %ebx,(%esp)
  801323:	e8 fd fb ff ff       	call   800f25 <close>
	return r;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	89 f0                	mov    %esi,%eax
}
  80132d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	89 c6                	mov    %eax,%esi
  80133b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80133d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801344:	75 12                	jne    801358 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	6a 01                	push   $0x1
  80134b:	e8 41 08 00 00       	call   801b91 <ipc_find_env>
  801350:	a3 00 40 80 00       	mov    %eax,0x804000
  801355:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801358:	6a 07                	push   $0x7
  80135a:	68 00 50 80 00       	push   $0x805000
  80135f:	56                   	push   %esi
  801360:	ff 35 00 40 80 00    	pushl  0x804000
  801366:	e8 d2 07 00 00       	call   801b3d <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80136b:	83 c4 0c             	add    $0xc,%esp
  80136e:	6a 00                	push   $0x0
  801370:	53                   	push   %ebx
  801371:	6a 00                	push   $0x0
  801373:	e8 43 07 00 00       	call   801abb <ipc_recv>
}
  801378:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801385:	8b 45 08             	mov    0x8(%ebp),%eax
  801388:	8b 40 0c             	mov    0xc(%eax),%eax
  80138b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801390:	8b 45 0c             	mov    0xc(%ebp),%eax
  801393:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801398:	ba 00 00 00 00       	mov    $0x0,%edx
  80139d:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a2:	e8 8d ff ff ff       	call   801334 <fsipc>
}
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c4:	e8 6b ff ff ff       	call   801334 <fsipc>
}
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 04             	sub    $0x4,%esp
  8013d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ea:	e8 45 ff ff ff       	call   801334 <fsipc>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 2c                	js     80141f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	68 00 50 80 00       	push   $0x805000
  8013fb:	53                   	push   %ebx
  8013fc:	e8 90 f3 ff ff       	call   800791 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801401:	a1 80 50 80 00       	mov    0x805080,%eax
  801406:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80140c:	a1 84 50 80 00       	mov    0x805084,%eax
  801411:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	8b 45 10             	mov    0x10(%ebp),%eax
  80142d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801432:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801437:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80143a:	8b 55 08             	mov    0x8(%ebp),%edx
  80143d:	8b 52 0c             	mov    0xc(%edx),%edx
  801440:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801446:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80144b:	50                   	push   %eax
  80144c:	ff 75 0c             	pushl  0xc(%ebp)
  80144f:	68 08 50 80 00       	push   $0x805008
  801454:	e8 ca f4 ff ff       	call   800923 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801459:	ba 00 00 00 00       	mov    $0x0,%edx
  80145e:	b8 04 00 00 00       	mov    $0x4,%eax
  801463:	e8 cc fe ff ff       	call   801334 <fsipc>
            return r;

    return r;
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801472:	8b 45 08             	mov    0x8(%ebp),%eax
  801475:	8b 40 0c             	mov    0xc(%eax),%eax
  801478:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80147d:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 03 00 00 00       	mov    $0x3,%eax
  80148d:	e8 a2 fe ff ff       	call   801334 <fsipc>
  801492:	89 c3                	mov    %eax,%ebx
  801494:	85 c0                	test   %eax,%eax
  801496:	78 51                	js     8014e9 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801498:	39 c6                	cmp    %eax,%esi
  80149a:	73 19                	jae    8014b5 <devfile_read+0x4b>
  80149c:	68 d8 22 80 00       	push   $0x8022d8
  8014a1:	68 df 22 80 00       	push   $0x8022df
  8014a6:	68 82 00 00 00       	push   $0x82
  8014ab:	68 f4 22 80 00       	push   $0x8022f4
  8014b0:	e8 c0 05 00 00       	call   801a75 <_panic>
	assert(r <= PGSIZE);
  8014b5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ba:	7e 19                	jle    8014d5 <devfile_read+0x6b>
  8014bc:	68 ff 22 80 00       	push   $0x8022ff
  8014c1:	68 df 22 80 00       	push   $0x8022df
  8014c6:	68 83 00 00 00       	push   $0x83
  8014cb:	68 f4 22 80 00       	push   $0x8022f4
  8014d0:	e8 a0 05 00 00       	call   801a75 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	50                   	push   %eax
  8014d9:	68 00 50 80 00       	push   $0x805000
  8014de:	ff 75 0c             	pushl  0xc(%ebp)
  8014e1:	e8 3d f4 ff ff       	call   800923 <memmove>
	return r;
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	89 d8                	mov    %ebx,%eax
  8014eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 20             	sub    $0x20,%esp
  8014f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014fc:	53                   	push   %ebx
  8014fd:	e8 56 f2 ff ff       	call   800758 <strlen>
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80150a:	7f 67                	jg     801573 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	e8 94 f8 ff ff       	call   800dac <fd_alloc>
  801518:	83 c4 10             	add    $0x10,%esp
		return r;
  80151b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 57                	js     801578 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	68 00 50 80 00       	push   $0x805000
  80152a:	e8 62 f2 ff ff       	call   800791 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80152f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801532:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801537:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153a:	b8 01 00 00 00       	mov    $0x1,%eax
  80153f:	e8 f0 fd ff ff       	call   801334 <fsipc>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	79 14                	jns    801561 <open+0x6f>
		fd_close(fd, 0);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	6a 00                	push   $0x0
  801552:	ff 75 f4             	pushl  -0xc(%ebp)
  801555:	e8 4a f9 ff ff       	call   800ea4 <fd_close>
		return r;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	89 da                	mov    %ebx,%edx
  80155f:	eb 17                	jmp    801578 <open+0x86>
	}

	return fd2num(fd);
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	ff 75 f4             	pushl  -0xc(%ebp)
  801567:	e8 19 f8 ff ff       	call   800d85 <fd2num>
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 05                	jmp    801578 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801573:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801578:	89 d0                	mov    %edx,%eax
  80157a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801585:	ba 00 00 00 00       	mov    $0x0,%edx
  80158a:	b8 08 00 00 00       	mov    $0x8,%eax
  80158f:	e8 a0 fd ff ff       	call   801334 <fsipc>
}
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
  80159b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 ec f7 ff ff       	call   800d95 <fd2data>
  8015a9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	68 0b 23 80 00       	push   $0x80230b
  8015b3:	53                   	push   %ebx
  8015b4:	e8 d8 f1 ff ff       	call   800791 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015b9:	8b 46 04             	mov    0x4(%esi),%eax
  8015bc:	2b 06                	sub    (%esi),%eax
  8015be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cb:	00 00 00 
	stat->st_dev = &devpipe;
  8015ce:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015d5:	30 80 00 
	return 0;
}
  8015d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015ee:	53                   	push   %ebx
  8015ef:	6a 00                	push   $0x0
  8015f1:	e8 23 f6 ff ff       	call   800c19 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 97 f7 ff ff       	call   800d95 <fd2data>
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	50                   	push   %eax
  801602:	6a 00                	push   $0x0
  801604:	e8 10 f6 ff ff       	call   800c19 <sys_page_unmap>
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 1c             	sub    $0x1c,%esp
  801617:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80161a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80161c:	a1 04 40 80 00       	mov    0x804004,%eax
  801621:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801624:	83 ec 0c             	sub    $0xc,%esp
  801627:	ff 75 e0             	pushl  -0x20(%ebp)
  80162a:	e8 9b 05 00 00       	call   801bca <pageref>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	89 3c 24             	mov    %edi,(%esp)
  801634:	e8 91 05 00 00       	call   801bca <pageref>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	39 c3                	cmp    %eax,%ebx
  80163e:	0f 94 c1             	sete   %cl
  801641:	0f b6 c9             	movzbl %cl,%ecx
  801644:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801647:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80164d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801650:	39 ce                	cmp    %ecx,%esi
  801652:	74 1b                	je     80166f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801654:	39 c3                	cmp    %eax,%ebx
  801656:	75 c4                	jne    80161c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801658:	8b 42 58             	mov    0x58(%edx),%eax
  80165b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165e:	50                   	push   %eax
  80165f:	56                   	push   %esi
  801660:	68 12 23 80 00       	push   $0x802312
  801665:	e8 23 eb ff ff       	call   80018d <cprintf>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	eb ad                	jmp    80161c <_pipeisclosed+0xe>
	}
}
  80166f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5f                   	pop    %edi
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 28             	sub    $0x28,%esp
  801683:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801686:	56                   	push   %esi
  801687:	e8 09 f7 ff ff       	call   800d95 <fd2data>
  80168c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	bf 00 00 00 00       	mov    $0x0,%edi
  801696:	eb 4b                	jmp    8016e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801698:	89 da                	mov    %ebx,%edx
  80169a:	89 f0                	mov    %esi,%eax
  80169c:	e8 6d ff ff ff       	call   80160e <_pipeisclosed>
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	75 48                	jne    8016ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016a5:	e8 cb f4 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ad:	8b 0b                	mov    (%ebx),%ecx
  8016af:	8d 51 20             	lea    0x20(%ecx),%edx
  8016b2:	39 d0                	cmp    %edx,%eax
  8016b4:	73 e2                	jae    801698 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	c1 fa 1f             	sar    $0x1f,%edx
  8016c5:	89 d1                	mov    %edx,%ecx
  8016c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8016ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016cd:	83 e2 1f             	and    $0x1f,%edx
  8016d0:	29 ca                	sub    %ecx,%edx
  8016d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016da:	83 c0 01             	add    $0x1,%eax
  8016dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e0:	83 c7 01             	add    $0x1,%edi
  8016e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016e6:	75 c2                	jne    8016aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8016eb:	eb 05                	jmp    8016f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 18             	sub    $0x18,%esp
  801703:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801706:	57                   	push   %edi
  801707:	e8 89 f6 ff ff       	call   800d95 <fd2data>
  80170c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	bb 00 00 00 00       	mov    $0x0,%ebx
  801716:	eb 3d                	jmp    801755 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801718:	85 db                	test   %ebx,%ebx
  80171a:	74 04                	je     801720 <devpipe_read+0x26>
				return i;
  80171c:	89 d8                	mov    %ebx,%eax
  80171e:	eb 44                	jmp    801764 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801720:	89 f2                	mov    %esi,%edx
  801722:	89 f8                	mov    %edi,%eax
  801724:	e8 e5 fe ff ff       	call   80160e <_pipeisclosed>
  801729:	85 c0                	test   %eax,%eax
  80172b:	75 32                	jne    80175f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80172d:	e8 43 f4 ff ff       	call   800b75 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801732:	8b 06                	mov    (%esi),%eax
  801734:	3b 46 04             	cmp    0x4(%esi),%eax
  801737:	74 df                	je     801718 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801739:	99                   	cltd   
  80173a:	c1 ea 1b             	shr    $0x1b,%edx
  80173d:	01 d0                	add    %edx,%eax
  80173f:	83 e0 1f             	and    $0x1f,%eax
  801742:	29 d0                	sub    %edx,%eax
  801744:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80174f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801752:	83 c3 01             	add    $0x1,%ebx
  801755:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801758:	75 d8                	jne    801732 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80175a:	8b 45 10             	mov    0x10(%ebp),%eax
  80175d:	eb 05                	jmp    801764 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5f                   	pop    %edi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	e8 2f f6 ff ff       	call   800dac <fd_alloc>
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	89 c2                	mov    %eax,%edx
  801782:	85 c0                	test   %eax,%eax
  801784:	0f 88 2c 01 00 00    	js     8018b6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	68 07 04 00 00       	push   $0x407
  801792:	ff 75 f4             	pushl  -0xc(%ebp)
  801795:	6a 00                	push   $0x0
  801797:	e8 f8 f3 ff ff       	call   800b94 <sys_page_alloc>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	0f 88 0d 01 00 00    	js     8018b6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017a9:	83 ec 0c             	sub    $0xc,%esp
  8017ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	e8 f7 f5 ff ff       	call   800dac <fd_alloc>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	0f 88 e2 00 00 00    	js     8018a4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	68 07 04 00 00       	push   $0x407
  8017ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 c0 f3 ff ff       	call   800b94 <sys_page_alloc>
  8017d4:	89 c3                	mov    %eax,%ebx
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	0f 88 c3 00 00 00    	js     8018a4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017e1:	83 ec 0c             	sub    $0xc,%esp
  8017e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e7:	e8 a9 f5 ff ff       	call   800d95 <fd2data>
  8017ec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ee:	83 c4 0c             	add    $0xc,%esp
  8017f1:	68 07 04 00 00       	push   $0x407
  8017f6:	50                   	push   %eax
  8017f7:	6a 00                	push   $0x0
  8017f9:	e8 96 f3 ff ff       	call   800b94 <sys_page_alloc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	0f 88 89 00 00 00    	js     801894 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180b:	83 ec 0c             	sub    $0xc,%esp
  80180e:	ff 75 f0             	pushl  -0x10(%ebp)
  801811:	e8 7f f5 ff ff       	call   800d95 <fd2data>
  801816:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80181d:	50                   	push   %eax
  80181e:	6a 00                	push   $0x0
  801820:	56                   	push   %esi
  801821:	6a 00                	push   $0x0
  801823:	e8 af f3 ff ff       	call   800bd7 <sys_page_map>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 20             	add    $0x20,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 55                	js     801886 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801831:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801846:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801854:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	ff 75 f4             	pushl  -0xc(%ebp)
  801861:	e8 1f f5 ff ff       	call   800d85 <fd2num>
  801866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801869:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80186b:	83 c4 04             	add    $0x4,%esp
  80186e:	ff 75 f0             	pushl  -0x10(%ebp)
  801871:	e8 0f f5 ff ff       	call   800d85 <fd2num>
  801876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801879:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	eb 30                	jmp    8018b6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	56                   	push   %esi
  80188a:	6a 00                	push   $0x0
  80188c:	e8 88 f3 ff ff       	call   800c19 <sys_page_unmap>
  801891:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	ff 75 f0             	pushl  -0x10(%ebp)
  80189a:	6a 00                	push   $0x0
  80189c:	e8 78 f3 ff ff       	call   800c19 <sys_page_unmap>
  8018a1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 68 f3 ff ff       	call   800c19 <sys_page_unmap>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018b6:	89 d0                	mov    %edx,%eax
  8018b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	ff 75 08             	pushl  0x8(%ebp)
  8018cc:	e8 2a f5 ff ff       	call   800dfb <fd_lookup>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 18                	js     8018f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	ff 75 f4             	pushl  -0xc(%ebp)
  8018de:	e8 b2 f4 ff ff       	call   800d95 <fd2data>
	return _pipeisclosed(fd, p);
  8018e3:	89 c2                	mov    %eax,%edx
  8018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e8:	e8 21 fd ff ff       	call   80160e <_pipeisclosed>
  8018ed:	83 c4 10             	add    $0x10,%esp
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801902:	68 2a 23 80 00       	push   $0x80232a
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	e8 82 ee ff ff       	call   800791 <strcpy>
	return 0;
}
  80190f:	b8 00 00 00 00       	mov    $0x0,%eax
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801922:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801927:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80192d:	eb 2d                	jmp    80195c <devcons_write+0x46>
		m = n - tot;
  80192f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801932:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801934:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801937:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80193c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	53                   	push   %ebx
  801943:	03 45 0c             	add    0xc(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	57                   	push   %edi
  801948:	e8 d6 ef ff ff       	call   800923 <memmove>
		sys_cputs(buf, m);
  80194d:	83 c4 08             	add    $0x8,%esp
  801950:	53                   	push   %ebx
  801951:	57                   	push   %edi
  801952:	e8 81 f1 ff ff       	call   800ad8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801957:	01 de                	add    %ebx,%esi
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	89 f0                	mov    %esi,%eax
  80195e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801961:	72 cc                	jb     80192f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801963:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5f                   	pop    %edi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801976:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80197a:	74 2a                	je     8019a6 <devcons_read+0x3b>
  80197c:	eb 05                	jmp    801983 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80197e:	e8 f2 f1 ff ff       	call   800b75 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801983:	e8 6e f1 ff ff       	call   800af6 <sys_cgetc>
  801988:	85 c0                	test   %eax,%eax
  80198a:	74 f2                	je     80197e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 16                	js     8019a6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801990:	83 f8 04             	cmp    $0x4,%eax
  801993:	74 0c                	je     8019a1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801995:	8b 55 0c             	mov    0xc(%ebp),%edx
  801998:	88 02                	mov    %al,(%edx)
	return 1;
  80199a:	b8 01 00 00 00       	mov    $0x1,%eax
  80199f:	eb 05                	jmp    8019a6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019b4:	6a 01                	push   $0x1
  8019b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019b9:	50                   	push   %eax
  8019ba:	e8 19 f1 ff ff       	call   800ad8 <sys_cputs>
}
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <getchar>:

int
getchar(void)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019ca:	6a 01                	push   $0x1
  8019cc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	6a 00                	push   $0x0
  8019d2:	e8 8a f6 ff ff       	call   801061 <read>
	if (r < 0)
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 0f                	js     8019ed <getchar+0x29>
		return r;
	if (r < 1)
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	7e 06                	jle    8019e8 <getchar+0x24>
		return -E_EOF;
	return c;
  8019e2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019e6:	eb 05                	jmp    8019ed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019e8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f8:	50                   	push   %eax
  8019f9:	ff 75 08             	pushl  0x8(%ebp)
  8019fc:	e8 fa f3 ff ff       	call   800dfb <fd_lookup>
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 11                	js     801a19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a11:	39 10                	cmp    %edx,(%eax)
  801a13:	0f 94 c0             	sete   %al
  801a16:	0f b6 c0             	movzbl %al,%eax
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <opencons>:

int
opencons(void)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a24:	50                   	push   %eax
  801a25:	e8 82 f3 ff ff       	call   800dac <fd_alloc>
  801a2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 3e                	js     801a71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a33:	83 ec 04             	sub    $0x4,%esp
  801a36:	68 07 04 00 00       	push   $0x407
  801a3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 4f f1 ff ff       	call   800b94 <sys_page_alloc>
  801a45:	83 c4 10             	add    $0x10,%esp
		return r;
  801a48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 23                	js     801a71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	50                   	push   %eax
  801a67:	e8 19 f3 ff ff       	call   800d85 <fd2num>
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	83 c4 10             	add    $0x10,%esp
}
  801a71:	89 d0                	mov    %edx,%eax
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a7a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a7d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a83:	e8 ce f0 ff ff       	call   800b56 <sys_getenvid>
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 0c             	pushl  0xc(%ebp)
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	56                   	push   %esi
  801a92:	50                   	push   %eax
  801a93:	68 38 23 80 00       	push   $0x802338
  801a98:	e8 f0 e6 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a9d:	83 c4 18             	add    $0x18,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	ff 75 10             	pushl  0x10(%ebp)
  801aa4:	e8 93 e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801aa9:	c7 04 24 23 23 80 00 	movl   $0x802323,(%esp)
  801ab0:	e8 d8 e6 ff ff       	call   80018d <cprintf>
  801ab5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ab8:	cc                   	int3   
  801ab9:	eb fd                	jmp    801ab8 <_panic+0x43>

00801abb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801acd:	85 f6                	test   %esi,%esi
  801acf:	74 06                	je     801ad7 <ipc_recv+0x1c>
		*from_env_store = 0;
  801ad1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801ad7:	85 db                	test   %ebx,%ebx
  801ad9:	74 06                	je     801ae1 <ipc_recv+0x26>
		*perm_store = 0;
  801adb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801ae1:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801ae3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ae8:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	50                   	push   %eax
  801aef:	e8 50 f2 ff ff       	call   800d44 <sys_ipc_recv>
  801af4:	89 c7                	mov    %eax,%edi
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	79 14                	jns    801b11 <ipc_recv+0x56>
		cprintf("im dead");
  801afd:	83 ec 0c             	sub    $0xc,%esp
  801b00:	68 5c 23 80 00       	push   $0x80235c
  801b05:	e8 83 e6 ff ff       	call   80018d <cprintf>
		return r;
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	89 f8                	mov    %edi,%eax
  801b0f:	eb 24                	jmp    801b35 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801b11:	85 f6                	test   %esi,%esi
  801b13:	74 0a                	je     801b1f <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801b15:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1a:	8b 40 74             	mov    0x74(%eax),%eax
  801b1d:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801b1f:	85 db                	test   %ebx,%ebx
  801b21:	74 0a                	je     801b2d <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801b23:	a1 04 40 80 00       	mov    0x804004,%eax
  801b28:	8b 40 78             	mov    0x78(%eax),%eax
  801b2b:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801b2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b32:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5f                   	pop    %edi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	57                   	push   %edi
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	83 ec 0c             	sub    $0xc,%esp
  801b46:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801b4f:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b56:	0f 44 d8             	cmove  %eax,%ebx
  801b59:	eb 1c                	jmp    801b77 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b5b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b5e:	74 12                	je     801b72 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b60:	50                   	push   %eax
  801b61:	68 64 23 80 00       	push   $0x802364
  801b66:	6a 4e                	push   $0x4e
  801b68:	68 71 23 80 00       	push   $0x802371
  801b6d:	e8 03 ff ff ff       	call   801a75 <_panic>
		sys_yield();
  801b72:	e8 fe ef ff ff       	call   800b75 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b77:	ff 75 14             	pushl  0x14(%ebp)
  801b7a:	53                   	push   %ebx
  801b7b:	56                   	push   %esi
  801b7c:	57                   	push   %edi
  801b7d:	e8 9f f1 ff ff       	call   800d21 <sys_ipc_try_send>
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 d2                	js     801b5b <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b9c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b9f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba5:	8b 52 50             	mov    0x50(%edx),%edx
  801ba8:	39 ca                	cmp    %ecx,%edx
  801baa:	75 0d                	jne    801bb9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801baf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb4:	8b 40 48             	mov    0x48(%eax),%eax
  801bb7:	eb 0f                	jmp    801bc8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bb9:	83 c0 01             	add    $0x1,%eax
  801bbc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc1:	75 d9                	jne    801b9c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd0:	89 d0                	mov    %edx,%eax
  801bd2:	c1 e8 16             	shr    $0x16,%eax
  801bd5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be1:	f6 c1 01             	test   $0x1,%cl
  801be4:	74 1d                	je     801c03 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801be6:	c1 ea 0c             	shr    $0xc,%edx
  801be9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf0:	f6 c2 01             	test   $0x1,%dl
  801bf3:	74 0e                	je     801c03 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf5:	c1 ea 0c             	shr    $0xc,%edx
  801bf8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bff:	ef 
  801c00:	0f b7 c0             	movzwl %ax,%eax
}
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
  801c05:	66 90                	xchg   %ax,%ax
  801c07:	66 90                	xchg   %ax,%ax
  801c09:	66 90                	xchg   %ax,%ax
  801c0b:	66 90                	xchg   %ax,%ax
  801c0d:	66 90                	xchg   %ax,%ax
  801c0f:	90                   	nop

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
