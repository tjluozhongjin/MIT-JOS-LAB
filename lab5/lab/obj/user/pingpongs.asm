
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 86 10 00 00       	call   8010c7 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 67 0b 00 00       	call   800bba <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 a0 22 80 00       	push   $0x8022a0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 50 0b 00 00       	call   800bba <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 ba 22 80 00       	push   $0x8022ba
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 dc 10 00 00       	call   801163 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 47 10 00 00       	call   8010e1 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 07 0b 00 00       	call   800bba <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 d0 22 80 00       	push   $0x8022d0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 79 10 00 00       	call   801163 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 ac 0a 00 00       	call   800bba <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 6c 12 00 00       	call   8013bb <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 20 0a 00 00       	call   800b79 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 ae 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 1a 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 53 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 a7 1d 00 00       	call   802000 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 94 1e 00 00       	call   802130 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 00 23 80 00 	movsbl 0x802300(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	eb 12                	jmp    800314 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800302:	85 c0                	test   %eax,%eax
  800304:	0f 84 42 04 00 00    	je     80074c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	53                   	push   %ebx
  80030e:	50                   	push   %eax
  80030f:	ff d6                	call   *%esi
  800311:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	83 c7 01             	add    $0x1,%edi
  800317:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031b:	83 f8 25             	cmp    $0x25,%eax
  80031e:	75 e2                	jne    800302 <vprintfmt+0x14>
  800320:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800324:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800332:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	eb 07                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8d 47 01             	lea    0x1(%edi),%eax
  80034a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034d:	0f b6 07             	movzbl (%edi),%eax
  800350:	0f b6 d0             	movzbl %al,%edx
  800353:	83 e8 23             	sub    $0x23,%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 d3 03 00 00    	ja     800731 <vprintfmt+0x443>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036f:	eb d6                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800383:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800386:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800389:	83 f9 09             	cmp    $0x9,%ecx
  80038c:	77 3f                	ja     8003cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800391:	eb e9                	jmp    80037c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 40 04             	lea    0x4(%eax),%eax
  8003a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a7:	eb 2a                	jmp    8003d3 <vprintfmt+0xe5>
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	0f 49 d0             	cmovns %eax,%edx
  8003b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bc:	eb 89                	jmp    800347 <vprintfmt+0x59>
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c8:	e9 7a ff ff ff       	jmp    800347 <vprintfmt+0x59>
  8003cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d7:	0f 89 6a ff ff ff    	jns    800347 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ea:	e9 58 ff ff ff       	jmp    800347 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f5:	e9 4d ff ff ff       	jmp    800347 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	53                   	push   %ebx
  800404:	ff 30                	pushl  (%eax)
  800406:	ff d6                	call   *%esi
			break;
  800408:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800411:	e9 fe fe ff ff       	jmp    800314 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 78 04             	lea    0x4(%eax),%edi
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	99                   	cltd   
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x145>
  800428:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 1b                	jne    80044e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800433:	50                   	push   %eax
  800434:	68 18 23 80 00       	push   $0x802318
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 91 fe ff ff       	call   8002d1 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800449:	e9 c6 fe ff ff       	jmp    800314 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044e:	52                   	push   %edx
  80044f:	68 c1 27 80 00       	push   $0x8027c1
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 76 fe ff ff       	call   8002d1 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800464:	e9 ab fe ff ff       	jmp    800314 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800477:	85 ff                	test   %edi,%edi
  800479:	b8 11 23 80 00       	mov    $0x802311,%eax
  80047e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	0f 8e 94 00 00 00    	jle    80051f <vprintfmt+0x231>
  80048b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048f:	0f 84 98 00 00 00    	je     80052d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 d0             	pushl  -0x30(%ebp)
  80049b:	57                   	push   %edi
  80049c:	e8 33 03 00 00       	call   8007d4 <strnlen>
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 c1                	sub    %eax,%ecx
  8004a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	eb 0f                	jmp    8004c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ef 01             	sub    $0x1,%edi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	7f ed                	jg     8004ba <vprintfmt+0x1cc>
  8004cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	0f 49 c1             	cmovns %ecx,%eax
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	89 cb                	mov    %ecx,%ebx
  8004ea:	eb 4d                	jmp    800539 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	74 1b                	je     80050d <vprintfmt+0x21f>
  8004f2:	0f be c0             	movsbl %al,%eax
  8004f5:	83 e8 20             	sub    $0x20,%eax
  8004f8:	83 f8 5e             	cmp    $0x5e,%eax
  8004fb:	76 10                	jbe    80050d <vprintfmt+0x21f>
					putch('?', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	6a 3f                	push   $0x3f
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 0d                	jmp    80051a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	52                   	push   %edx
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 eb 01             	sub    $0x1,%ebx
  80051d:	eb 1a                	jmp    800539 <vprintfmt+0x24b>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb 0c                	jmp    800539 <vprintfmt+0x24b>
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800540:	0f be d0             	movsbl %al,%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	74 23                	je     80056a <vprintfmt+0x27c>
  800547:	85 f6                	test   %esi,%esi
  800549:	78 a1                	js     8004ec <vprintfmt+0x1fe>
  80054b:	83 ee 01             	sub    $0x1,%esi
  80054e:	79 9c                	jns    8004ec <vprintfmt+0x1fe>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	eb 18                	jmp    800572 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	6a 20                	push   $0x20
  800560:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	83 ef 01             	sub    $0x1,%edi
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	eb 08                	jmp    800572 <vprintfmt+0x284>
  80056a:	89 df                	mov    %ebx,%edi
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	85 ff                	test   %edi,%edi
  800574:	7f e4                	jg     80055a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	e9 90 fd ff ff       	jmp    800314 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800584:	83 f9 01             	cmp    $0x1,%ecx
  800587:	7e 19                	jle    8005a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	eb 38                	jmp    8005da <vprintfmt+0x2ec>
	else if (lflag)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	74 1b                	je     8005c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	eb 19                	jmp    8005da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 c1                	mov    %eax,%ecx
  8005cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e9:	0f 89 0e 01 00 00    	jns    8006fd <vprintfmt+0x40f>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 ec 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7e 18                	jle    80062e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8b 48 04             	mov    0x4(%eax),%ecx
  80061e:	8d 40 08             	lea    0x8(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
  800629:	e9 cf 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	74 1a                	je     80064c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 b1 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 97 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	6a 58                	push   $0x58
  80066c:	ff d6                	call   *%esi
			putch('X', putdat);
  80066e:	83 c4 08             	add    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 58                	push   $0x58
  800674:	ff d6                	call   *%esi
			putch('X', putdat);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 58                	push   $0x58
  80067c:	ff d6                	call   *%esi
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800684:	e9 8b fc ff ff       	jmp    800314 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 30                	push   $0x30
  80068f:	ff d6                	call   *%esi
			putch('x', putdat);
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 78                	push   $0x78
  800697:	ff d6                	call   *%esi
			num = (unsigned long long)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b1:	eb 4a                	jmp    8006fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7e 15                	jle    8006cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	8d 40 08             	lea    0x8(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cb:	eb 30                	jmp    8006fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	74 17                	je     8006e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e6:	eb 15                	jmp    8006fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fd:	83 ec 0c             	sub    $0xc,%esp
  800700:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800704:	57                   	push   %edi
  800705:	ff 75 e0             	pushl  -0x20(%ebp)
  800708:	50                   	push   %eax
  800709:	51                   	push   %ecx
  80070a:	52                   	push   %edx
  80070b:	89 da                	mov    %ebx,%edx
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	e8 f1 fa ff ff       	call   800205 <printnum>
			break;
  800714:	83 c4 20             	add    $0x20,%esp
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	e9 f5 fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	52                   	push   %edx
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072c:	e9 e3 fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 03                	jmp    800741 <vprintfmt+0x453>
  80073e:	83 ef 01             	sub    $0x1,%edi
  800741:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800745:	75 f7                	jne    80073e <vprintfmt+0x450>
  800747:	e9 c8 fb ff ff       	jmp    800314 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 18             	sub    $0x18,%esp
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800760:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800763:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800767:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800771:	85 c0                	test   %eax,%eax
  800773:	74 26                	je     80079b <vsnprintf+0x47>
  800775:	85 d2                	test   %edx,%edx
  800777:	7e 22                	jle    80079b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800779:	ff 75 14             	pushl  0x14(%ebp)
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800782:	50                   	push   %eax
  800783:	68 b4 02 80 00       	push   $0x8002b4
  800788:	e8 61 fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800790:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 05                	jmp    8007a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 9a ff ff ff       	call   800754 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 03                	jmp    8007cc <strlen+0x10>
		n++;
  8007c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d0:	75 f7                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	eb 03                	jmp    8007e7 <strnlen+0x13>
		n++;
  8007e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	39 c2                	cmp    %eax,%edx
  8007e9:	74 08                	je     8007f3 <strnlen+0x1f>
  8007eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ef:	75 f3                	jne    8007e4 <strnlen+0x10>
  8007f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ef                	jne    800801 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081c:	53                   	push   %ebx
  80081d:	e8 9a ff ff ff       	call   8007bc <strlen>
  800822:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	01 d8                	add    %ebx,%eax
  80082a:	50                   	push   %eax
  80082b:	e8 c5 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  800830:	89 d8                	mov    %ebx,%eax
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 75 08             	mov    0x8(%ebp),%esi
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	89 f3                	mov    %esi,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 0f                	jmp    80085a <strncpy+0x23>
		*dst++ = *src;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800854:	80 39 01             	cmpb   $0x1,(%ecx)
  800857:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	39 da                	cmp    %ebx,%edx
  80085c:	75 ed                	jne    80084b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085e:	89 f0                	mov    %esi,%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	8b 55 10             	mov    0x10(%ebp),%edx
  800872:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800874:	85 d2                	test   %edx,%edx
  800876:	74 21                	je     800899 <strlcpy+0x35>
  800878:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 09                	jmp    800889 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c1 01             	add    $0x1,%ecx
  800886:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800889:	39 c2                	cmp    %eax,%edx
  80088b:	74 09                	je     800896 <strlcpy+0x32>
  80088d:	0f b6 19             	movzbl (%ecx),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	75 ec                	jne    800880 <strlcpy+0x1c>
  800894:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800896:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800899:	29 f0                	sub    %esi,%eax
}
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strcmp+0x11>
		p++, q++;
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b0:	0f b6 01             	movzbl (%ecx),%eax
  8008b3:	84 c0                	test   %al,%al
  8008b5:	74 04                	je     8008bb <strcmp+0x1c>
  8008b7:	3a 02                	cmp    (%edx),%al
  8008b9:	74 ef                	je     8008aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 c0             	movzbl %al,%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strncmp+0x17>
		n--, p++, q++;
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 15                	je     8008f5 <strncmp+0x30>
  8008e0:	0f b6 08             	movzbl (%eax),%ecx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	74 04                	je     8008eb <strncmp+0x26>
  8008e7:	3a 0a                	cmp    (%edx),%cl
  8008e9:	74 eb                	je     8008d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	eb 07                	jmp    800910 <strchr+0x13>
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 0f                	je     80091c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	eb 03                	jmp    80092d <strfind+0xf>
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 04                	je     800938 <strfind+0x1a>
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f2                	jne    80092a <strfind+0xc>
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800946:	85 c9                	test   %ecx,%ecx
  800948:	74 36                	je     800980 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800950:	75 28                	jne    80097a <memset+0x40>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 23                	jne    80097a <memset+0x40>
		c &= 0xFF;
  800957:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	89 d3                	mov    %edx,%ebx
  80095d:	c1 e3 08             	shl    $0x8,%ebx
  800960:	89 d6                	mov    %edx,%esi
  800962:	c1 e6 18             	shl    $0x18,%esi
  800965:	89 d0                	mov    %edx,%eax
  800967:	c1 e0 10             	shl    $0x10,%eax
  80096a:	09 f0                	or     %esi,%eax
  80096c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	09 d0                	or     %edx,%eax
  800972:	c1 e9 02             	shr    $0x2,%ecx
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 06                	jmp    800980 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 35                	jae    8009ce <memmove+0x47>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 d0                	cmp    %edx,%eax
  80099e:	73 2e                	jae    8009ce <memmove+0x47>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	09 fe                	or     %edi,%esi
  8009a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ad:	75 13                	jne    8009c2 <memmove+0x3b>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 0e                	jne    8009c2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b4:	83 ef 04             	sub    $0x4,%edi
  8009b7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	fd                   	std    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 09                	jmp    8009cb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c2:	83 ef 01             	sub    $0x1,%edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 1d                	jmp    8009eb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	75 0f                	jne    8009e6 <memmove+0x5f>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0a                	jne    8009e6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 05                	jmp    8009eb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	ff 75 08             	pushl  0x8(%ebp)
  8009fb:	e8 87 ff ff ff       	call   800987 <memmove>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	eb 1a                	jmp    800a2e <memcmp+0x2c>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	74 0a                	je     800a28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c1             	movzbl %cl,%eax
  800a21:	0f b6 db             	movzbl %bl,%ebx
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	eb 0f                	jmp    800a37 <memcmp+0x35>
		s1++, s2++;
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	39 f0                	cmp    %esi,%eax
  800a30:	75 e2                	jne    800a14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a42:	89 c1                	mov    %eax,%ecx
  800a44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	eb 0a                	jmp    800a57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	39 da                	cmp    %ebx,%edx
  800a52:	74 07                	je     800a5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	39 c8                	cmp    %ecx,%eax
  800a59:	72 f2                	jb     800a4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 03                	jmp    800a6f <strtol+0x11>
		s++;
  800a6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	3c 20                	cmp    $0x20,%al
  800a74:	74 f6                	je     800a6c <strtol+0xe>
  800a76:	3c 09                	cmp    $0x9,%al
  800a78:	74 f2                	je     800a6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7a:	3c 2b                	cmp    $0x2b,%al
  800a7c:	75 0a                	jne    800a88 <strtol+0x2a>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
  800a86:	eb 11                	jmp    800a99 <strtol+0x3b>
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x3b>
		s++, neg = 1;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9f:	75 15                	jne    800ab6 <strtol+0x58>
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	75 10                	jne    800ab6 <strtol+0x58>
  800aa6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaa:	75 7c                	jne    800b28 <strtol+0xca>
		s += 2, base = 16;
  800aac:	83 c1 02             	add    $0x2,%ecx
  800aaf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab4:	eb 16                	jmp    800acc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	75 12                	jne    800acc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac2:	75 08                	jne    800acc <strtol+0x6e>
		s++, base = 8;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	0f b6 11             	movzbl (%ecx),%edx
  800ad7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 09             	cmp    $0x9,%bl
  800adf:	77 08                	ja     800ae9 <strtol+0x8b>
			dig = *s - '0';
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 30             	sub    $0x30,%edx
  800ae7:	eb 22                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 19             	cmp    $0x19,%bl
  800af1:	77 08                	ja     800afb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 57             	sub    $0x57,%edx
  800af9:	eb 10                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 16                	ja     800b1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0e:	7d 0b                	jge    800b1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b19:	eb b9                	jmp    800ad4 <strtol+0x76>

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 0d                	je     800b2e <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
  800b26:	eb 06                	jmp    800b2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	74 98                	je     800ac4 <strtol+0x66>
  800b2c:	eb 9e                	jmp    800acc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	f7 da                	neg    %edx
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c2             	cmovne %edx,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 ff 25 80 00       	push   $0x8025ff
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 1c 26 80 00       	push   $0x80261c
  800bad:	e8 2e 13 00 00       	call   801ee0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_yield>:

void
sys_yield(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	be 00 00 00 00       	mov    $0x0,%esi
  800c06:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	89 f7                	mov    %esi,%edi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 04                	push   $0x4
  800c22:	68 ff 25 80 00       	push   $0x8025ff
  800c27:	6a 23                	push   $0x23
  800c29:	68 1c 26 80 00       	push   $0x80261c
  800c2e:	e8 ad 12 00 00       	call   801ee0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	b8 05 00 00 00       	mov    $0x5,%eax
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 75 18             	mov    0x18(%ebp),%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 05                	push   $0x5
  800c64:	68 ff 25 80 00       	push   $0x8025ff
  800c69:	6a 23                	push   $0x23
  800c6b:	68 1c 26 80 00       	push   $0x80261c
  800c70:	e8 6b 12 00 00       	call   801ee0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 ff 25 80 00       	push   $0x8025ff
  800cab:	6a 23                	push   $0x23
  800cad:	68 1c 26 80 00       	push   $0x80261c
  800cb2:	e8 29 12 00 00       	call   801ee0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 ff 25 80 00       	push   $0x8025ff
  800ced:	6a 23                	push   $0x23
  800cef:	68 1c 26 80 00       	push   $0x80261c
  800cf4:	e8 e7 11 00 00       	call   801ee0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 09                	push   $0x9
  800d2a:	68 ff 25 80 00       	push   $0x8025ff
  800d2f:	6a 23                	push   $0x23
  800d31:	68 1c 26 80 00       	push   $0x80261c
  800d36:	e8 a5 11 00 00       	call   801ee0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 ff 25 80 00       	push   $0x8025ff
  800d71:	6a 23                	push   $0x23
  800d73:	68 1c 26 80 00       	push   $0x80261c
  800d78:	e8 63 11 00 00       	call   801ee0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 ff 25 80 00       	push   $0x8025ff
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 1c 26 80 00       	push   $0x80261c
  800ddc:	e8 ff 10 00 00       	call   801ee0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800df1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800df3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df7:	74 11                	je     800e0a <pgfault+0x21>
  800df9:	89 d8                	mov    %ebx,%eax
  800dfb:	c1 e8 0c             	shr    $0xc,%eax
  800dfe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e05:	f6 c4 08             	test   $0x8,%ah
  800e08:	75 14                	jne    800e1e <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 2c 26 80 00       	push   $0x80262c
  800e12:	6a 1f                	push   $0x1f
  800e14:	68 8f 26 80 00       	push   $0x80268f
  800e19:	e8 c2 10 00 00       	call   801ee0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800e1e:	e8 97 fd ff ff       	call   800bba <sys_getenvid>
  800e23:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	6a 07                	push   $0x7
  800e2a:	68 00 f0 7f 00       	push   $0x7ff000
  800e2f:	50                   	push   %eax
  800e30:	e8 c3 fd ff ff       	call   800bf8 <sys_page_alloc>
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	79 12                	jns    800e4e <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800e3c:	50                   	push   %eax
  800e3d:	68 6c 26 80 00       	push   $0x80266c
  800e42:	6a 2c                	push   $0x2c
  800e44:	68 8f 26 80 00       	push   $0x80268f
  800e49:	e8 92 10 00 00       	call   801ee0 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e4e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	68 00 10 00 00       	push   $0x1000
  800e5c:	53                   	push   %ebx
  800e5d:	68 00 f0 7f 00       	push   $0x7ff000
  800e62:	e8 20 fb ff ff       	call   800987 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800e67:	83 c4 08             	add    $0x8,%esp
  800e6a:	53                   	push   %ebx
  800e6b:	56                   	push   %esi
  800e6c:	e8 0c fe ff ff       	call   800c7d <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	79 12                	jns    800e8a <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800e78:	50                   	push   %eax
  800e79:	68 9a 26 80 00       	push   $0x80269a
  800e7e:	6a 32                	push   $0x32
  800e80:	68 8f 26 80 00       	push   $0x80268f
  800e85:	e8 56 10 00 00       	call   801ee0 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	6a 07                	push   $0x7
  800e8f:	53                   	push   %ebx
  800e90:	56                   	push   %esi
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	56                   	push   %esi
  800e97:	e8 9f fd ff ff       	call   800c3b <sys_page_map>
  800e9c:	83 c4 20             	add    $0x20,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	79 12                	jns    800eb5 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800ea3:	50                   	push   %eax
  800ea4:	68 b8 26 80 00       	push   $0x8026b8
  800ea9:	6a 35                	push   $0x35
  800eab:	68 8f 26 80 00       	push   $0x80268f
  800eb0:	e8 2b 10 00 00       	call   801ee0 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	68 00 f0 7f 00       	push   $0x7ff000
  800ebd:	56                   	push   %esi
  800ebe:	e8 ba fd ff ff       	call   800c7d <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 12                	jns    800edc <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800eca:	50                   	push   %eax
  800ecb:	68 9a 26 80 00       	push   $0x80269a
  800ed0:	6a 38                	push   $0x38
  800ed2:	68 8f 26 80 00       	push   $0x80268f
  800ed7:	e8 04 10 00 00       	call   801ee0 <_panic>
	//panic("pgfault not implemented");
}
  800edc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800eec:	68 e9 0d 80 00       	push   $0x800de9
  800ef1:	e8 30 10 00 00       	call   801f26 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef6:	b8 07 00 00 00       	mov    $0x7,%eax
  800efb:	cd 30                	int    $0x30
  800efd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	0f 88 38 01 00 00    	js     801043 <fork+0x160>
  800f0b:	89 c7                	mov    %eax,%edi
  800f0d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800f12:	85 c0                	test   %eax,%eax
  800f14:	75 21                	jne    800f37 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f16:	e8 9f fc ff ff       	call   800bba <sys_getenvid>
  800f1b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f28:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f32:	e9 86 01 00 00       	jmp    8010bd <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 16             	shr    $0x16,%eax
  800f3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f43:	a8 01                	test   $0x1,%al
  800f45:	0f 84 90 00 00 00    	je     800fdb <fork+0xf8>
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	c1 e8 0c             	shr    $0xc,%eax
  800f50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f57:	f6 c2 01             	test   $0x1,%dl
  800f5a:	74 7f                	je     800fdb <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f5c:	89 c6                	mov    %eax,%esi
  800f5e:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800f61:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f68:	f6 c6 04             	test   $0x4,%dh
  800f6b:	74 33                	je     800fa0 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  800f6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7c:	50                   	push   %eax
  800f7d:	56                   	push   %esi
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	6a 00                	push   $0x0
  800f82:	e8 b4 fc ff ff       	call   800c3b <sys_page_map>
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	79 4d                	jns    800fdb <fork+0xf8>
		    panic("sys_page_map: %e", r);
  800f8e:	50                   	push   %eax
  800f8f:	68 d4 26 80 00       	push   $0x8026d4
  800f94:	6a 54                	push   $0x54
  800f96:	68 8f 26 80 00       	push   $0x80268f
  800f9b:	e8 40 0f 00 00       	call   801ee0 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800fa0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa7:	a9 02 08 00 00       	test   $0x802,%eax
  800fac:	0f 85 c6 00 00 00    	jne    801078 <fork+0x195>
  800fb2:	e9 e3 00 00 00       	jmp    80109a <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800fb7:	50                   	push   %eax
  800fb8:	68 d4 26 80 00       	push   $0x8026d4
  800fbd:	6a 5d                	push   $0x5d
  800fbf:	68 8f 26 80 00       	push   $0x80268f
  800fc4:	e8 17 0f 00 00       	call   801ee0 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800fc9:	50                   	push   %eax
  800fca:	68 d4 26 80 00       	push   $0x8026d4
  800fcf:	6a 64                	push   $0x64
  800fd1:	68 8f 26 80 00       	push   $0x80268f
  800fd6:	e8 05 0f 00 00       	call   801ee0 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800fdb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe1:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fe7:	0f 85 4a ff ff ff    	jne    800f37 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	6a 07                	push   $0x7
  800ff2:	68 00 f0 bf ee       	push   $0xeebff000
  800ff7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800ffa:	57                   	push   %edi
  800ffb:	e8 f8 fb ff ff       	call   800bf8 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801000:	83 c4 10             	add    $0x10,%esp
		return ret;
  801003:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	0f 88 b0 00 00 00    	js     8010bd <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80100d:	a1 08 40 80 00       	mov    0x804008,%eax
  801012:	8b 40 64             	mov    0x64(%eax),%eax
  801015:	83 ec 08             	sub    $0x8,%esp
  801018:	50                   	push   %eax
  801019:	57                   	push   %edi
  80101a:	e8 24 fd ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  80101f:	83 c4 10             	add    $0x10,%esp
		return ret;
  801022:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	0f 88 91 00 00 00    	js     8010bd <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	6a 02                	push   $0x2
  801031:	57                   	push   %edi
  801032:	e8 88 fc ff ff       	call   800cbf <sys_env_set_status>
  801037:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  80103a:	85 c0                	test   %eax,%eax
  80103c:	89 fa                	mov    %edi,%edx
  80103e:	0f 48 d0             	cmovs  %eax,%edx
  801041:	eb 7a                	jmp    8010bd <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801043:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801046:	eb 75                	jmp    8010bd <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801048:	e8 6d fb ff ff       	call   800bba <sys_getenvid>
  80104d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801050:	e8 65 fb ff ff       	call   800bba <sys_getenvid>
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	68 05 08 00 00       	push   $0x805
  80105d:	56                   	push   %esi
  80105e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801061:	56                   	push   %esi
  801062:	50                   	push   %eax
  801063:	e8 d3 fb ff ff       	call   800c3b <sys_page_map>
  801068:	83 c4 20             	add    $0x20,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	0f 89 68 ff ff ff    	jns    800fdb <fork+0xf8>
  801073:	e9 51 ff ff ff       	jmp    800fc9 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801078:	e8 3d fb ff ff       	call   800bba <sys_getenvid>
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	68 05 08 00 00       	push   $0x805
  801085:	56                   	push   %esi
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	50                   	push   %eax
  801089:	e8 ad fb ff ff       	call   800c3b <sys_page_map>
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 b3                	jns    801048 <fork+0x165>
  801095:	e9 1d ff ff ff       	jmp    800fb7 <fork+0xd4>
  80109a:	e8 1b fb ff ff       	call   800bba <sys_getenvid>
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	6a 05                	push   $0x5
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	50                   	push   %eax
  8010a8:	e8 8e fb ff ff       	call   800c3b <sys_page_map>
  8010ad:	83 c4 20             	add    $0x20,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	0f 89 23 ff ff ff    	jns    800fdb <fork+0xf8>
  8010b8:	e9 fa fe ff ff       	jmp    800fb7 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	5f                   	pop    %edi
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010cd:	68 e5 26 80 00       	push   $0x8026e5
  8010d2:	68 ac 00 00 00       	push   $0xac
  8010d7:	68 8f 26 80 00       	push   $0x80268f
  8010dc:	e8 ff 0d 00 00       	call   801ee0 <_panic>

008010e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  8010f3:	85 f6                	test   %esi,%esi
  8010f5:	74 06                	je     8010fd <ipc_recv+0x1c>
		*from_env_store = 0;
  8010f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  8010fd:	85 db                	test   %ebx,%ebx
  8010ff:	74 06                	je     801107 <ipc_recv+0x26>
		*perm_store = 0;
  801101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801107:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801109:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80110e:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	50                   	push   %eax
  801115:	e8 8e fc ff ff       	call   800da8 <sys_ipc_recv>
  80111a:	89 c7                	mov    %eax,%edi
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 14                	jns    801137 <ipc_recv+0x56>
		cprintf("im dead");
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	68 fb 26 80 00       	push   $0x8026fb
  80112b:	e8 c1 f0 ff ff       	call   8001f1 <cprintf>
		return r;
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	89 f8                	mov    %edi,%eax
  801135:	eb 24                	jmp    80115b <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801137:	85 f6                	test   %esi,%esi
  801139:	74 0a                	je     801145 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  80113b:	a1 08 40 80 00       	mov    0x804008,%eax
  801140:	8b 40 74             	mov    0x74(%eax),%eax
  801143:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801145:	85 db                	test   %ebx,%ebx
  801147:	74 0a                	je     801153 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801149:	a1 08 40 80 00       	mov    0x804008,%eax
  80114e:	8b 40 78             	mov    0x78(%eax),%eax
  801151:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801153:	a1 08 40 80 00       	mov    0x804008,%eax
  801158:	8b 40 70             	mov    0x70(%eax),%eax
}
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	57                   	push   %edi
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801172:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801175:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801177:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80117c:	0f 44 d8             	cmove  %eax,%ebx
  80117f:	eb 1c                	jmp    80119d <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801181:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801184:	74 12                	je     801198 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801186:	50                   	push   %eax
  801187:	68 03 27 80 00       	push   $0x802703
  80118c:	6a 4e                	push   $0x4e
  80118e:	68 10 27 80 00       	push   $0x802710
  801193:	e8 48 0d 00 00       	call   801ee0 <_panic>
		sys_yield();
  801198:	e8 3c fa ff ff       	call   800bd9 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80119d:	ff 75 14             	pushl  0x14(%ebp)
  8011a0:	53                   	push   %ebx
  8011a1:	56                   	push   %esi
  8011a2:	57                   	push   %edi
  8011a3:	e8 dd fb ff ff       	call   800d85 <sys_ipc_try_send>
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 d2                	js     801181 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  8011af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b2:	5b                   	pop    %ebx
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011c2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011c5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011cb:	8b 52 50             	mov    0x50(%edx),%edx
  8011ce:	39 ca                	cmp    %ecx,%edx
  8011d0:	75 0d                	jne    8011df <ipc_find_env+0x28>
			return envs[i].env_id;
  8011d2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011da:	8b 40 48             	mov    0x48(%eax),%eax
  8011dd:	eb 0f                	jmp    8011ee <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011df:	83 c0 01             	add    $0x1,%eax
  8011e2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011e7:	75 d9                	jne    8011c2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	05 00 00 00 30       	add    $0x30000000,%eax
  80120b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801210:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801222:	89 c2                	mov    %eax,%edx
  801224:	c1 ea 16             	shr    $0x16,%edx
  801227:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122e:	f6 c2 01             	test   $0x1,%dl
  801231:	74 11                	je     801244 <fd_alloc+0x2d>
  801233:	89 c2                	mov    %eax,%edx
  801235:	c1 ea 0c             	shr    $0xc,%edx
  801238:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123f:	f6 c2 01             	test   $0x1,%dl
  801242:	75 09                	jne    80124d <fd_alloc+0x36>
			*fd_store = fd;
  801244:	89 01                	mov    %eax,(%ecx)
			return 0;
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 17                	jmp    801264 <fd_alloc+0x4d>
  80124d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801252:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801257:	75 c9                	jne    801222 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801259:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80125f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80126c:	83 f8 1f             	cmp    $0x1f,%eax
  80126f:	77 36                	ja     8012a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801271:	c1 e0 0c             	shl    $0xc,%eax
  801274:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801279:	89 c2                	mov    %eax,%edx
  80127b:	c1 ea 16             	shr    $0x16,%edx
  80127e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801285:	f6 c2 01             	test   $0x1,%dl
  801288:	74 24                	je     8012ae <fd_lookup+0x48>
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	c1 ea 0c             	shr    $0xc,%edx
  80128f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 1a                	je     8012b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129e:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	eb 13                	jmp    8012ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 0c                	jmp    8012ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b3:	eb 05                	jmp    8012ba <fd_lookup+0x54>
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c5:	ba 98 27 80 00       	mov    $0x802798,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ca:	eb 13                	jmp    8012df <dev_lookup+0x23>
  8012cc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012cf:	39 08                	cmp    %ecx,(%eax)
  8012d1:	75 0c                	jne    8012df <dev_lookup+0x23>
			*dev = devtab[i];
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dd:	eb 2e                	jmp    80130d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012df:	8b 02                	mov    (%edx),%eax
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	75 e7                	jne    8012cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	51                   	push   %ecx
  8012f1:	50                   	push   %eax
  8012f2:	68 1c 27 80 00       	push   $0x80271c
  8012f7:	e8 f5 ee ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8012fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	83 ec 10             	sub    $0x10,%esp
  801317:	8b 75 08             	mov    0x8(%ebp),%esi
  80131a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
  80132a:	50                   	push   %eax
  80132b:	e8 36 ff ff ff       	call   801266 <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 05                	js     80133c <fd_close+0x2d>
	    || fd != fd2)
  801337:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80133a:	74 0c                	je     801348 <fd_close+0x39>
		return (must_exist ? r : 0);
  80133c:	84 db                	test   %bl,%bl
  80133e:	ba 00 00 00 00       	mov    $0x0,%edx
  801343:	0f 44 c2             	cmove  %edx,%eax
  801346:	eb 41                	jmp    801389 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	ff 36                	pushl  (%esi)
  801351:	e8 66 ff ff ff       	call   8012bc <dev_lookup>
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 1a                	js     801379 <fd_close+0x6a>
		if (dev->dev_close)
  80135f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801362:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801365:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	74 0b                	je     801379 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	56                   	push   %esi
  801372:	ff d0                	call   *%eax
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	56                   	push   %esi
  80137d:	6a 00                	push   $0x0
  80137f:	e8 f9 f8 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	89 d8                	mov    %ebx,%eax
}
  801389:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 08             	pushl  0x8(%ebp)
  80139d:	e8 c4 fe ff ff       	call   801266 <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 10                	js     8013b9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	6a 01                	push   $0x1
  8013ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b1:	e8 59 ff ff ff       	call   80130f <fd_close>
  8013b6:	83 c4 10             	add    $0x10,%esp
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <close_all>:

void
close_all(void)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	53                   	push   %ebx
  8013bf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	e8 c0 ff ff ff       	call   801390 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d0:	83 c3 01             	add    $0x1,%ebx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	83 fb 20             	cmp    $0x20,%ebx
  8013d9:	75 ec                	jne    8013c7 <close_all+0xc>
		close(i);
}
  8013db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    

008013e0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 2c             	sub    $0x2c,%esp
  8013e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 08             	pushl  0x8(%ebp)
  8013f3:	e8 6e fe ff ff       	call   801266 <fd_lookup>
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	0f 88 c1 00 00 00    	js     8014c4 <dup+0xe4>
		return r;
	close(newfdnum);
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	56                   	push   %esi
  801407:	e8 84 ff ff ff       	call   801390 <close>

	newfd = INDEX2FD(newfdnum);
  80140c:	89 f3                	mov    %esi,%ebx
  80140e:	c1 e3 0c             	shl    $0xc,%ebx
  801411:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801417:	83 c4 04             	add    $0x4,%esp
  80141a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80141d:	e8 de fd ff ff       	call   801200 <fd2data>
  801422:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801424:	89 1c 24             	mov    %ebx,(%esp)
  801427:	e8 d4 fd ff ff       	call   801200 <fd2data>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801432:	89 f8                	mov    %edi,%eax
  801434:	c1 e8 16             	shr    $0x16,%eax
  801437:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143e:	a8 01                	test   $0x1,%al
  801440:	74 37                	je     801479 <dup+0x99>
  801442:	89 f8                	mov    %edi,%eax
  801444:	c1 e8 0c             	shr    $0xc,%eax
  801447:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 26                	je     801479 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801453:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	25 07 0e 00 00       	and    $0xe07,%eax
  801462:	50                   	push   %eax
  801463:	ff 75 d4             	pushl  -0x2c(%ebp)
  801466:	6a 00                	push   $0x0
  801468:	57                   	push   %edi
  801469:	6a 00                	push   $0x0
  80146b:	e8 cb f7 ff ff       	call   800c3b <sys_page_map>
  801470:	89 c7                	mov    %eax,%edi
  801472:	83 c4 20             	add    $0x20,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 2e                	js     8014a7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801479:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80147c:	89 d0                	mov    %edx,%eax
  80147e:	c1 e8 0c             	shr    $0xc,%eax
  801481:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	25 07 0e 00 00       	and    $0xe07,%eax
  801490:	50                   	push   %eax
  801491:	53                   	push   %ebx
  801492:	6a 00                	push   $0x0
  801494:	52                   	push   %edx
  801495:	6a 00                	push   $0x0
  801497:	e8 9f f7 ff ff       	call   800c3b <sys_page_map>
  80149c:	89 c7                	mov    %eax,%edi
  80149e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014a1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a3:	85 ff                	test   %edi,%edi
  8014a5:	79 1d                	jns    8014c4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	6a 00                	push   $0x0
  8014ad:	e8 cb f7 ff ff       	call   800c7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 be f7 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 f8                	mov    %edi,%eax
}
  8014c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5f                   	pop    %edi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 14             	sub    $0x14,%esp
  8014d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	53                   	push   %ebx
  8014db:	e8 86 fd ff ff       	call   801266 <fd_lookup>
  8014e0:	83 c4 08             	add    $0x8,%esp
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 6d                	js     801556 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f3:	ff 30                	pushl  (%eax)
  8014f5:	e8 c2 fd ff ff       	call   8012bc <dev_lookup>
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 4c                	js     80154d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801504:	8b 42 08             	mov    0x8(%edx),%eax
  801507:	83 e0 03             	and    $0x3,%eax
  80150a:	83 f8 01             	cmp    $0x1,%eax
  80150d:	75 21                	jne    801530 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80150f:	a1 08 40 80 00       	mov    0x804008,%eax
  801514:	8b 40 48             	mov    0x48(%eax),%eax
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	53                   	push   %ebx
  80151b:	50                   	push   %eax
  80151c:	68 5d 27 80 00       	push   $0x80275d
  801521:	e8 cb ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152e:	eb 26                	jmp    801556 <read+0x8a>
	}
	if (!dev->dev_read)
  801530:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801533:	8b 40 08             	mov    0x8(%eax),%eax
  801536:	85 c0                	test   %eax,%eax
  801538:	74 17                	je     801551 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	ff 75 10             	pushl  0x10(%ebp)
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	52                   	push   %edx
  801544:	ff d0                	call   *%eax
  801546:	89 c2                	mov    %eax,%edx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	eb 09                	jmp    801556 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	eb 05                	jmp    801556 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801551:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801556:	89 d0                	mov    %edx,%eax
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	57                   	push   %edi
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	8b 7d 08             	mov    0x8(%ebp),%edi
  801569:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801571:	eb 21                	jmp    801594 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	89 f0                	mov    %esi,%eax
  801578:	29 d8                	sub    %ebx,%eax
  80157a:	50                   	push   %eax
  80157b:	89 d8                	mov    %ebx,%eax
  80157d:	03 45 0c             	add    0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	57                   	push   %edi
  801582:	e8 45 ff ff ff       	call   8014cc <read>
		if (m < 0)
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 10                	js     80159e <readn+0x41>
			return m;
		if (m == 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	74 0a                	je     80159c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801592:	01 c3                	add    %eax,%ebx
  801594:	39 f3                	cmp    %esi,%ebx
  801596:	72 db                	jb     801573 <readn+0x16>
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	eb 02                	jmp    80159e <readn+0x41>
  80159c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80159e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5f                   	pop    %edi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    

008015a6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	53                   	push   %ebx
  8015b5:	e8 ac fc ff ff       	call   801266 <fd_lookup>
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 68                	js     80162b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cd:	ff 30                	pushl  (%eax)
  8015cf:	e8 e8 fc ff ff       	call   8012bc <dev_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 47                	js     801622 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e2:	75 21                	jne    801605 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	68 79 27 80 00       	push   $0x802779
  8015f6:	e8 f6 eb ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801603:	eb 26                	jmp    80162b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801605:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801608:	8b 52 0c             	mov    0xc(%edx),%edx
  80160b:	85 d2                	test   %edx,%edx
  80160d:	74 17                	je     801626 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	ff 75 10             	pushl  0x10(%ebp)
  801615:	ff 75 0c             	pushl  0xc(%ebp)
  801618:	50                   	push   %eax
  801619:	ff d2                	call   *%edx
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 09                	jmp    80162b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	89 c2                	mov    %eax,%edx
  801624:	eb 05                	jmp    80162b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801626:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80162b:	89 d0                	mov    %edx,%eax
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <seek>:

int
seek(int fdnum, off_t offset)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801638:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 22 fc ff ff       	call   801266 <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 0e                	js     801659 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80164e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801651:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801654:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	83 ec 14             	sub    $0x14,%esp
  801662:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801665:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	53                   	push   %ebx
  80166a:	e8 f7 fb ff ff       	call   801266 <fd_lookup>
  80166f:	83 c4 08             	add    $0x8,%esp
  801672:	89 c2                	mov    %eax,%edx
  801674:	85 c0                	test   %eax,%eax
  801676:	78 65                	js     8016dd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801682:	ff 30                	pushl  (%eax)
  801684:	e8 33 fc ff ff       	call   8012bc <dev_lookup>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 44                	js     8016d4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801697:	75 21                	jne    8016ba <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801699:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169e:	8b 40 48             	mov    0x48(%eax),%eax
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	50                   	push   %eax
  8016a6:	68 3c 27 80 00       	push   $0x80273c
  8016ab:	e8 41 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b8:	eb 23                	jmp    8016dd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bd:	8b 52 18             	mov    0x18(%edx),%edx
  8016c0:	85 d2                	test   %edx,%edx
  8016c2:	74 14                	je     8016d8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	50                   	push   %eax
  8016cb:	ff d2                	call   *%edx
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	eb 09                	jmp    8016dd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	eb 05                	jmp    8016dd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016dd:	89 d0                	mov    %edx,%eax
  8016df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 14             	sub    $0x14,%esp
  8016eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 6c fb ff ff       	call   801266 <fd_lookup>
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 58                	js     80175b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	ff 30                	pushl  (%eax)
  80170f:	e8 a8 fb ff ff       	call   8012bc <dev_lookup>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 37                	js     801752 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801722:	74 32                	je     801756 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801724:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801727:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172e:	00 00 00 
	stat->st_isdir = 0;
  801731:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801738:	00 00 00 
	stat->st_dev = dev;
  80173b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	53                   	push   %ebx
  801745:	ff 75 f0             	pushl  -0x10(%ebp)
  801748:	ff 50 14             	call   *0x14(%eax)
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	eb 09                	jmp    80175b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801752:	89 c2                	mov    %eax,%edx
  801754:	eb 05                	jmp    80175b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801756:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	ff 75 08             	pushl  0x8(%ebp)
  80176f:	e8 e9 01 00 00       	call   80195d <open>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 1b                	js     801798 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	50                   	push   %eax
  801784:	e8 5b ff ff ff       	call   8016e4 <fstat>
  801789:	89 c6                	mov    %eax,%esi
	close(fd);
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 fd fb ff ff       	call   801390 <close>
	return r;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	89 f0                	mov    %esi,%eax
}
  801798:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	56                   	push   %esi
  8017a3:	53                   	push   %ebx
  8017a4:	89 c6                	mov    %eax,%esi
  8017a6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017a8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017af:	75 12                	jne    8017c3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	6a 01                	push   $0x1
  8017b6:	e8 fc f9 ff ff       	call   8011b7 <ipc_find_env>
  8017bb:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c0:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c3:	6a 07                	push   $0x7
  8017c5:	68 00 50 80 00       	push   $0x805000
  8017ca:	56                   	push   %esi
  8017cb:	ff 35 00 40 80 00    	pushl  0x804000
  8017d1:	e8 8d f9 ff ff       	call   801163 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8017d6:	83 c4 0c             	add    $0xc,%esp
  8017d9:	6a 00                	push   $0x0
  8017db:	53                   	push   %ebx
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 fe f8 ff ff       	call   8010e1 <ipc_recv>
}
  8017e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	b8 02 00 00 00       	mov    $0x2,%eax
  80180d:	e8 8d ff ff ff       	call   80179f <fsipc>
}
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	8b 40 0c             	mov    0xc(%eax),%eax
  801820:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801825:	ba 00 00 00 00       	mov    $0x0,%edx
  80182a:	b8 06 00 00 00       	mov    $0x6,%eax
  80182f:	e8 6b ff ff ff       	call   80179f <fsipc>
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	53                   	push   %ebx
  80183a:	83 ec 04             	sub    $0x4,%esp
  80183d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	8b 40 0c             	mov    0xc(%eax),%eax
  801846:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184b:	ba 00 00 00 00       	mov    $0x0,%edx
  801850:	b8 05 00 00 00       	mov    $0x5,%eax
  801855:	e8 45 ff ff ff       	call   80179f <fsipc>
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 2c                	js     80188a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	68 00 50 80 00       	push   $0x805000
  801866:	53                   	push   %ebx
  801867:	e8 89 ef ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80186c:	a1 80 50 80 00       	mov    0x805080,%eax
  801871:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801877:	a1 84 50 80 00       	mov    0x805084,%eax
  80187c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	8b 45 10             	mov    0x10(%ebp),%eax
  801898:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80189d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a2:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ab:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8018b1:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8018b6:	50                   	push   %eax
  8018b7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ba:	68 08 50 80 00       	push   $0x805008
  8018bf:	e8 c3 f0 ff ff       	call   800987 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ce:	e8 cc fe ff ff       	call   80179f <fsipc>
            return r;

    return r;
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e8:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f8:	e8 a2 fe ff ff       	call   80179f <fsipc>
  8018fd:	89 c3                	mov    %eax,%ebx
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 51                	js     801954 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801903:	39 c6                	cmp    %eax,%esi
  801905:	73 19                	jae    801920 <devfile_read+0x4b>
  801907:	68 a8 27 80 00       	push   $0x8027a8
  80190c:	68 af 27 80 00       	push   $0x8027af
  801911:	68 82 00 00 00       	push   $0x82
  801916:	68 c4 27 80 00       	push   $0x8027c4
  80191b:	e8 c0 05 00 00       	call   801ee0 <_panic>
	assert(r <= PGSIZE);
  801920:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801925:	7e 19                	jle    801940 <devfile_read+0x6b>
  801927:	68 cf 27 80 00       	push   $0x8027cf
  80192c:	68 af 27 80 00       	push   $0x8027af
  801931:	68 83 00 00 00       	push   $0x83
  801936:	68 c4 27 80 00       	push   $0x8027c4
  80193b:	e8 a0 05 00 00       	call   801ee0 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801940:	83 ec 04             	sub    $0x4,%esp
  801943:	50                   	push   %eax
  801944:	68 00 50 80 00       	push   $0x805000
  801949:	ff 75 0c             	pushl  0xc(%ebp)
  80194c:	e8 36 f0 ff ff       	call   800987 <memmove>
	return r;
  801951:	83 c4 10             	add    $0x10,%esp
}
  801954:	89 d8                	mov    %ebx,%eax
  801956:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	53                   	push   %ebx
  801961:	83 ec 20             	sub    $0x20,%esp
  801964:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801967:	53                   	push   %ebx
  801968:	e8 4f ee ff ff       	call   8007bc <strlen>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801975:	7f 67                	jg     8019de <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	e8 94 f8 ff ff       	call   801217 <fd_alloc>
  801983:	83 c4 10             	add    $0x10,%esp
		return r;
  801986:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 57                	js     8019e3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	53                   	push   %ebx
  801990:	68 00 50 80 00       	push   $0x805000
  801995:	e8 5b ee ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019aa:	e8 f0 fd ff ff       	call   80179f <fsipc>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	79 14                	jns    8019cc <open+0x6f>
		fd_close(fd, 0);
  8019b8:	83 ec 08             	sub    $0x8,%esp
  8019bb:	6a 00                	push   $0x0
  8019bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c0:	e8 4a f9 ff ff       	call   80130f <fd_close>
		return r;
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	89 da                	mov    %ebx,%edx
  8019ca:	eb 17                	jmp    8019e3 <open+0x86>
	}

	return fd2num(fd);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d2:	e8 19 f8 ff ff       	call   8011f0 <fd2num>
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	eb 05                	jmp    8019e3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019de:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019e3:	89 d0                	mov    %edx,%eax
  8019e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fa:	e8 a0 fd ff ff       	call   80179f <fsipc>
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 75 08             	pushl  0x8(%ebp)
  801a0f:	e8 ec f7 ff ff       	call   801200 <fd2data>
  801a14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a16:	83 c4 08             	add    $0x8,%esp
  801a19:	68 db 27 80 00       	push   $0x8027db
  801a1e:	53                   	push   %ebx
  801a1f:	e8 d1 ed ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a24:	8b 46 04             	mov    0x4(%esi),%eax
  801a27:	2b 06                	sub    (%esi),%eax
  801a29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a36:	00 00 00 
	stat->st_dev = &devpipe;
  801a39:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a40:	30 80 00 
	return 0;
}
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	53                   	push   %ebx
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a59:	53                   	push   %ebx
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 1c f2 ff ff       	call   800c7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a61:	89 1c 24             	mov    %ebx,(%esp)
  801a64:	e8 97 f7 ff ff       	call   801200 <fd2data>
  801a69:	83 c4 08             	add    $0x8,%esp
  801a6c:	50                   	push   %eax
  801a6d:	6a 00                	push   $0x0
  801a6f:	e8 09 f2 ff ff       	call   800c7d <sys_page_unmap>
}
  801a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	57                   	push   %edi
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 1c             	sub    $0x1c,%esp
  801a82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a85:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a87:	a1 08 40 80 00       	mov    0x804008,%eax
  801a8c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	ff 75 e0             	pushl  -0x20(%ebp)
  801a95:	e8 26 05 00 00       	call   801fc0 <pageref>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	89 3c 24             	mov    %edi,(%esp)
  801a9f:	e8 1c 05 00 00       	call   801fc0 <pageref>
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	39 c3                	cmp    %eax,%ebx
  801aa9:	0f 94 c1             	sete   %cl
  801aac:	0f b6 c9             	movzbl %cl,%ecx
  801aaf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ab2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ab8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801abb:	39 ce                	cmp    %ecx,%esi
  801abd:	74 1b                	je     801ada <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801abf:	39 c3                	cmp    %eax,%ebx
  801ac1:	75 c4                	jne    801a87 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac3:	8b 42 58             	mov    0x58(%edx),%eax
  801ac6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac9:	50                   	push   %eax
  801aca:	56                   	push   %esi
  801acb:	68 e2 27 80 00       	push   $0x8027e2
  801ad0:	e8 1c e7 ff ff       	call   8001f1 <cprintf>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	eb ad                	jmp    801a87 <_pipeisclosed+0xe>
	}
}
  801ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5f                   	pop    %edi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	57                   	push   %edi
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 28             	sub    $0x28,%esp
  801aee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801af1:	56                   	push   %esi
  801af2:	e8 09 f7 ff ff       	call   801200 <fd2data>
  801af7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	bf 00 00 00 00       	mov    $0x0,%edi
  801b01:	eb 4b                	jmp    801b4e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b03:	89 da                	mov    %ebx,%edx
  801b05:	89 f0                	mov    %esi,%eax
  801b07:	e8 6d ff ff ff       	call   801a79 <_pipeisclosed>
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	75 48                	jne    801b58 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b10:	e8 c4 f0 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b15:	8b 43 04             	mov    0x4(%ebx),%eax
  801b18:	8b 0b                	mov    (%ebx),%ecx
  801b1a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b1d:	39 d0                	cmp    %edx,%eax
  801b1f:	73 e2                	jae    801b03 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b24:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b28:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2b:	89 c2                	mov    %eax,%edx
  801b2d:	c1 fa 1f             	sar    $0x1f,%edx
  801b30:	89 d1                	mov    %edx,%ecx
  801b32:	c1 e9 1b             	shr    $0x1b,%ecx
  801b35:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b38:	83 e2 1f             	and    $0x1f,%edx
  801b3b:	29 ca                	sub    %ecx,%edx
  801b3d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b41:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4b:	83 c7 01             	add    $0x1,%edi
  801b4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b51:	75 c2                	jne    801b15 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b53:	8b 45 10             	mov    0x10(%ebp),%eax
  801b56:	eb 05                	jmp    801b5d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	57                   	push   %edi
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 18             	sub    $0x18,%esp
  801b6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b71:	57                   	push   %edi
  801b72:	e8 89 f6 ff ff       	call   801200 <fd2data>
  801b77:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b81:	eb 3d                	jmp    801bc0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b83:	85 db                	test   %ebx,%ebx
  801b85:	74 04                	je     801b8b <devpipe_read+0x26>
				return i;
  801b87:	89 d8                	mov    %ebx,%eax
  801b89:	eb 44                	jmp    801bcf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b8b:	89 f2                	mov    %esi,%edx
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	e8 e5 fe ff ff       	call   801a79 <_pipeisclosed>
  801b94:	85 c0                	test   %eax,%eax
  801b96:	75 32                	jne    801bca <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b98:	e8 3c f0 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b9d:	8b 06                	mov    (%esi),%eax
  801b9f:	3b 46 04             	cmp    0x4(%esi),%eax
  801ba2:	74 df                	je     801b83 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba4:	99                   	cltd   
  801ba5:	c1 ea 1b             	shr    $0x1b,%edx
  801ba8:	01 d0                	add    %edx,%eax
  801baa:	83 e0 1f             	and    $0x1f,%eax
  801bad:	29 d0                	sub    %edx,%eax
  801baf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bba:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbd:	83 c3 01             	add    $0x1,%ebx
  801bc0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc3:	75 d8                	jne    801b9d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc8:	eb 05                	jmp    801bcf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	e8 2f f6 ff ff       	call   801217 <fd_alloc>
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	89 c2                	mov    %eax,%edx
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 88 2c 01 00 00    	js     801d21 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf5:	83 ec 04             	sub    $0x4,%esp
  801bf8:	68 07 04 00 00       	push   $0x407
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	6a 00                	push   $0x0
  801c02:	e8 f1 ef ff ff       	call   800bf8 <sys_page_alloc>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	89 c2                	mov    %eax,%edx
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 0d 01 00 00    	js     801d21 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	e8 f7 f5 ff ff       	call   801217 <fd_alloc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	0f 88 e2 00 00 00    	js     801d0f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2d:	83 ec 04             	sub    $0x4,%esp
  801c30:	68 07 04 00 00       	push   $0x407
  801c35:	ff 75 f0             	pushl  -0x10(%ebp)
  801c38:	6a 00                	push   $0x0
  801c3a:	e8 b9 ef ff ff       	call   800bf8 <sys_page_alloc>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	0f 88 c3 00 00 00    	js     801d0f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c52:	e8 a9 f5 ff ff       	call   801200 <fd2data>
  801c57:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 c4 0c             	add    $0xc,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	50                   	push   %eax
  801c62:	6a 00                	push   $0x0
  801c64:	e8 8f ef ff ff       	call   800bf8 <sys_page_alloc>
  801c69:	89 c3                	mov    %eax,%ebx
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 89 00 00 00    	js     801cff <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7c:	e8 7f f5 ff ff       	call   801200 <fd2data>
  801c81:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c88:	50                   	push   %eax
  801c89:	6a 00                	push   $0x0
  801c8b:	56                   	push   %esi
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 a8 ef ff ff       	call   800c3b <sys_page_map>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 20             	add    $0x20,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 55                	js     801cf1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cb1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cba:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccc:	e8 1f f5 ff ff       	call   8011f0 <fd2num>
  801cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd6:	83 c4 04             	add    $0x4,%esp
  801cd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdc:	e8 0f f5 ff ff       	call   8011f0 <fd2num>
  801ce1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	ba 00 00 00 00       	mov    $0x0,%edx
  801cef:	eb 30                	jmp    801d21 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cf1:	83 ec 08             	sub    $0x8,%esp
  801cf4:	56                   	push   %esi
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 81 ef ff ff       	call   800c7d <sys_page_unmap>
  801cfc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	ff 75 f0             	pushl  -0x10(%ebp)
  801d05:	6a 00                	push   $0x0
  801d07:	e8 71 ef ff ff       	call   800c7d <sys_page_unmap>
  801d0c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	ff 75 f4             	pushl  -0xc(%ebp)
  801d15:	6a 00                	push   $0x0
  801d17:	e8 61 ef ff ff       	call   800c7d <sys_page_unmap>
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d21:	89 d0                	mov    %edx,%eax
  801d23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    

00801d2a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d33:	50                   	push   %eax
  801d34:	ff 75 08             	pushl  0x8(%ebp)
  801d37:	e8 2a f5 ff ff       	call   801266 <fd_lookup>
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 18                	js     801d5b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	ff 75 f4             	pushl  -0xc(%ebp)
  801d49:	e8 b2 f4 ff ff       	call   801200 <fd2data>
	return _pipeisclosed(fd, p);
  801d4e:	89 c2                	mov    %eax,%edx
  801d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d53:	e8 21 fd ff ff       	call   801a79 <_pipeisclosed>
  801d58:	83 c4 10             	add    $0x10,%esp
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d6d:	68 fa 27 80 00       	push   $0x8027fa
  801d72:	ff 75 0c             	pushl  0xc(%ebp)
  801d75:	e8 7b ea ff ff       	call   8007f5 <strcpy>
	return 0;
}
  801d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	57                   	push   %edi
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d92:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d98:	eb 2d                	jmp    801dc7 <devcons_write+0x46>
		m = n - tot;
  801d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d9d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d9f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801da2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	53                   	push   %ebx
  801dae:	03 45 0c             	add    0xc(%ebp),%eax
  801db1:	50                   	push   %eax
  801db2:	57                   	push   %edi
  801db3:	e8 cf eb ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801db8:	83 c4 08             	add    $0x8,%esp
  801dbb:	53                   	push   %ebx
  801dbc:	57                   	push   %edi
  801dbd:	e8 7a ed ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc2:	01 de                	add    %ebx,%esi
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	89 f0                	mov    %esi,%eax
  801dc9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dcc:	72 cc                	jb     801d9a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 08             	sub    $0x8,%esp
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801de1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de5:	74 2a                	je     801e11 <devcons_read+0x3b>
  801de7:	eb 05                	jmp    801dee <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de9:	e8 eb ed ff ff       	call   800bd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dee:	e8 67 ed ff ff       	call   800b5a <sys_cgetc>
  801df3:	85 c0                	test   %eax,%eax
  801df5:	74 f2                	je     801de9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 16                	js     801e11 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dfb:	83 f8 04             	cmp    $0x4,%eax
  801dfe:	74 0c                	je     801e0c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e00:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e03:	88 02                	mov    %al,(%edx)
	return 1;
  801e05:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0a:	eb 05                	jmp    801e11 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e19:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1f:	6a 01                	push   $0x1
  801e21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	e8 12 ed ff ff       	call   800b3c <sys_cputs>
}
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <getchar>:

int
getchar(void)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e35:	6a 01                	push   $0x1
  801e37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 8a f6 ff ff       	call   8014cc <read>
	if (r < 0)
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	78 0f                	js     801e58 <getchar+0x29>
		return r;
	if (r < 1)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	7e 06                	jle    801e53 <getchar+0x24>
		return -E_EOF;
	return c;
  801e4d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e51:	eb 05                	jmp    801e58 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e53:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	ff 75 08             	pushl  0x8(%ebp)
  801e67:	e8 fa f3 ff ff       	call   801266 <fd_lookup>
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 11                	js     801e84 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7c:	39 10                	cmp    %edx,(%eax)
  801e7e:	0f 94 c0             	sete   %al
  801e81:	0f b6 c0             	movzbl %al,%eax
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <opencons>:

int
opencons(void)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	e8 82 f3 ff ff       	call   801217 <fd_alloc>
  801e95:	83 c4 10             	add    $0x10,%esp
		return r;
  801e98:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	78 3e                	js     801edc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9e:	83 ec 04             	sub    $0x4,%esp
  801ea1:	68 07 04 00 00       	push   $0x407
  801ea6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea9:	6a 00                	push   $0x0
  801eab:	e8 48 ed ff ff       	call   800bf8 <sys_page_alloc>
  801eb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 23                	js     801edc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ece:	83 ec 0c             	sub    $0xc,%esp
  801ed1:	50                   	push   %eax
  801ed2:	e8 19 f3 ff ff       	call   8011f0 <fd2num>
  801ed7:	89 c2                	mov    %eax,%edx
  801ed9:	83 c4 10             	add    $0x10,%esp
}
  801edc:	89 d0                	mov    %edx,%eax
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ee5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ee8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eee:	e8 c7 ec ff ff       	call   800bba <sys_getenvid>
  801ef3:	83 ec 0c             	sub    $0xc,%esp
  801ef6:	ff 75 0c             	pushl  0xc(%ebp)
  801ef9:	ff 75 08             	pushl  0x8(%ebp)
  801efc:	56                   	push   %esi
  801efd:	50                   	push   %eax
  801efe:	68 08 28 80 00       	push   $0x802808
  801f03:	e8 e9 e2 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f08:	83 c4 18             	add    $0x18,%esp
  801f0b:	53                   	push   %ebx
  801f0c:	ff 75 10             	pushl  0x10(%ebp)
  801f0f:	e8 8c e2 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801f14:	c7 04 24 f3 27 80 00 	movl   $0x8027f3,(%esp)
  801f1b:	e8 d1 e2 ff ff       	call   8001f1 <cprintf>
  801f20:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f23:	cc                   	int3   
  801f24:	eb fd                	jmp    801f23 <_panic+0x43>

00801f26 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801f2d:	e8 88 ec ff ff       	call   800bba <sys_getenvid>
  801f32:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801f34:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f3b:	75 29                	jne    801f66 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801f3d:	83 ec 04             	sub    $0x4,%esp
  801f40:	6a 07                	push   $0x7
  801f42:	68 00 f0 bf ee       	push   $0xeebff000
  801f47:	50                   	push   %eax
  801f48:	e8 ab ec ff ff       	call   800bf8 <sys_page_alloc>
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	79 12                	jns    801f66 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801f54:	50                   	push   %eax
  801f55:	68 2c 28 80 00       	push   $0x80282c
  801f5a:	6a 24                	push   $0x24
  801f5c:	68 45 28 80 00       	push   $0x802845
  801f61:	e8 7a ff ff ff       	call   801ee0 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801f6e:	83 ec 08             	sub    $0x8,%esp
  801f71:	68 9a 1f 80 00       	push   $0x801f9a
  801f76:	53                   	push   %ebx
  801f77:	e8 c7 ed ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	79 12                	jns    801f95 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801f83:	50                   	push   %eax
  801f84:	68 2c 28 80 00       	push   $0x80282c
  801f89:	6a 2e                	push   $0x2e
  801f8b:	68 45 28 80 00       	push   $0x802845
  801f90:	e8 4b ff ff ff       	call   801ee0 <_panic>
}
  801f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f9a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f9b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fa0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801fa5:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801fa9:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801fac:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801fb0:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801fb2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801fb6:	83 c4 08             	add    $0x8,%esp
	popal
  801fb9:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801fba:	83 c4 04             	add    $0x4,%esp
	popfl
  801fbd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801fbe:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fbf:	c3                   	ret    

00801fc0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	c1 e8 16             	shr    $0x16,%eax
  801fcb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fd2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd7:	f6 c1 01             	test   $0x1,%cl
  801fda:	74 1d                	je     801ff9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fdc:	c1 ea 0c             	shr    $0xc,%edx
  801fdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fe6:	f6 c2 01             	test   $0x1,%dl
  801fe9:	74 0e                	je     801ff9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801feb:	c1 ea 0c             	shr    $0xc,%edx
  801fee:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ff5:	ef 
  801ff6:	0f b7 c0             	movzwl %ax,%eax
}
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    
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
