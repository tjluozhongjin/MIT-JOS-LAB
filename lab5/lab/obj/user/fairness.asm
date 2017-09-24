
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 1d 0b 00 00       	call   800b5d <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 2e 0d 00 00       	call   800d8c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 a0 1e 80 00       	push   $0x801ea0
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 b1 1e 80 00       	push   $0x801eb1
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 72 0d 00 00       	call   800e0e <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 ac 0a 00 00       	call   800b5d <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 74 0f 00 00       	call   801066 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 20 0a 00 00       	call   800b1c <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 ae 09 00 00       	call   800adf <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 1a 01 00 00       	call   800291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 53 09 00 00       	call   800adf <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 14 1a 00 00       	call   801c10 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 01 1b 00 00       	call   801d40 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 d2 1e 80 00 	movsbl 0x801ed2(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800261:	8b 10                	mov    (%eax),%edx
  800263:	3b 50 04             	cmp    0x4(%eax),%edx
  800266:	73 0a                	jae    800272 <sprintputch+0x1b>
		*b->buf++ = ch;
  800268:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	88 02                	mov    %al,(%edx)
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027d:	50                   	push   %eax
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	e8 05 00 00 00       	call   800291 <vprintfmt>
	va_end(ap);
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	8b 75 08             	mov    0x8(%ebp),%esi
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a3:	eb 12                	jmp    8002b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	0f 84 42 04 00 00    	je     8006ef <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	50                   	push   %eax
  8002b2:	ff d6                	call   *%esi
  8002b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	75 e2                	jne    8002a5 <vprintfmt+0x14>
  8002c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	eb 07                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8d 47 01             	lea    0x1(%edi),%eax
  8002ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f0:	0f b6 07             	movzbl (%edi),%eax
  8002f3:	0f b6 d0             	movzbl %al,%edx
  8002f6:	83 e8 23             	sub    $0x23,%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 d3 03 00 00    	ja     8006d4 <vprintfmt+0x443>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800312:	eb d6                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800329:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032c:	83 f9 09             	cmp    $0x9,%ecx
  80032f:	77 3f                	ja     800370 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800334:	eb e9                	jmp    80031f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 40 04             	lea    0x4(%eax),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034a:	eb 2a                	jmp    800376 <vprintfmt+0xe5>
  80034c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034f:	85 c0                	test   %eax,%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	0f 49 d0             	cmovns %eax,%edx
  800359:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035f:	eb 89                	jmp    8002ea <vprintfmt+0x59>
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800364:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036b:	e9 7a ff ff ff       	jmp    8002ea <vprintfmt+0x59>
  800370:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037a:	0f 89 6a ff ff ff    	jns    8002ea <vprintfmt+0x59>
				width = precision, precision = -1;
  800380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038d:	e9 58 ff ff ff       	jmp    8002ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800392:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800398:	e9 4d ff ff ff       	jmp    8002ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 78 04             	lea    0x4(%eax),%edi
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	53                   	push   %ebx
  8003a7:	ff 30                	pushl  (%eax)
  8003a9:	ff d6                	call   *%esi
			break;
  8003ab:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 fe fe ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 0b                	jg     8003d6 <vprintfmt+0x145>
  8003cb:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	75 1b                	jne    8003f1 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d6:	50                   	push   %eax
  8003d7:	68 ea 1e 80 00       	push   $0x801eea
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 91 fe ff ff       	call   800274 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ec:	e9 c6 fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 d1 22 80 00       	push   $0x8022d1
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 76 fe ff ff       	call   800274 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	e9 ab fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	83 c0 04             	add    $0x4,%eax
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041a:	85 ff                	test   %edi,%edi
  80041c:	b8 e3 1e 80 00       	mov    $0x801ee3,%eax
  800421:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800428:	0f 8e 94 00 00 00    	jle    8004c2 <vprintfmt+0x231>
  80042e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800432:	0f 84 98 00 00 00    	je     8004d0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 d0             	pushl  -0x30(%ebp)
  80043e:	57                   	push   %edi
  80043f:	e8 33 03 00 00       	call   800777 <strnlen>
  800444:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800447:	29 c1                	sub    %eax,%ecx
  800449:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800459:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	eb 0f                	jmp    80046c <vprintfmt+0x1db>
					putch(padc, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ef 01             	sub    $0x1,%edi
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	85 ff                	test   %edi,%edi
  80046e:	7f ed                	jg     80045d <vprintfmt+0x1cc>
  800470:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800473:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800476:	85 c9                	test   %ecx,%ecx
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	0f 49 c1             	cmovns %ecx,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 75 08             	mov    %esi,0x8(%ebp)
  800485:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	eb 4d                	jmp    8004dc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800493:	74 1b                	je     8004b0 <vprintfmt+0x21f>
  800495:	0f be c0             	movsbl %al,%eax
  800498:	83 e8 20             	sub    $0x20,%eax
  80049b:	83 f8 5e             	cmp    $0x5e,%eax
  80049e:	76 10                	jbe    8004b0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	6a 3f                	push   $0x3f
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb 0d                	jmp    8004bd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	52                   	push   %edx
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	eb 1a                	jmp    8004dc <vprintfmt+0x24b>
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ce:	eb 0c                	jmp    8004dc <vprintfmt+0x24b>
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dc:	83 c7 01             	add    $0x1,%edi
  8004df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e3:	0f be d0             	movsbl %al,%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 23                	je     80050d <vprintfmt+0x27c>
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	78 a1                	js     80048f <vprintfmt+0x1fe>
  8004ee:	83 ee 01             	sub    $0x1,%esi
  8004f1:	79 9c                	jns    80048f <vprintfmt+0x1fe>
  8004f3:	89 df                	mov    %ebx,%edi
  8004f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fb:	eb 18                	jmp    800515 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	6a 20                	push   $0x20
  800503:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 08                	jmp    800515 <vprintfmt+0x284>
  80050d:	89 df                	mov    %ebx,%edi
  80050f:	8b 75 08             	mov    0x8(%ebp),%esi
  800512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800515:	85 ff                	test   %edi,%edi
  800517:	7f e4                	jg     8004fd <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800522:	e9 90 fd ff ff       	jmp    8002b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 19                	jle    800545 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 50 04             	mov    0x4(%eax),%edx
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 40 08             	lea    0x8(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
  800543:	eb 38                	jmp    80057d <vprintfmt+0x2ec>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 1b                	je     800564 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 04             	lea    0x4(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
  800562:	eb 19                	jmp    80057d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 c1                	mov    %eax,%ecx
  80056e:	c1 f9 1f             	sar    $0x1f,%ecx
  800571:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800583:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	0f 89 0e 01 00 00    	jns    8006a0 <vprintfmt+0x40f>
				putch('-', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 2d                	push   $0x2d
  800598:	ff d6                	call   *%esi
				num = -(long long) num;
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a0:	f7 da                	neg    %edx
  8005a2:	83 d1 00             	adc    $0x0,%ecx
  8005a5:	f7 d9                	neg    %ecx
  8005a7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 ec 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7e 18                	jle    8005d1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c1:	8d 40 08             	lea    0x8(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 cf 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	74 1a                	je     8005ef <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ea:	e9 b1 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 97 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 58                	push   $0x58
  80060f:	ff d6                	call   *%esi
			putch('X', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 58                	push   $0x58
  800617:	ff d6                	call   *%esi
			putch('X', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 58                	push   $0x58
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800627:	e9 8b fc ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800646:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800654:	eb 4a                	jmp    8006a0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800656:	83 f9 01             	cmp    $0x1,%ecx
  800659:	7e 15                	jle    800670 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	8b 48 04             	mov    0x4(%eax),%ecx
  800663:	8d 40 08             	lea    0x8(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800669:	b8 10 00 00 00       	mov    $0x10,%eax
  80066e:	eb 30                	jmp    8006a0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 17                	je     80068b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800684:	b8 10 00 00 00       	mov    $0x10,%eax
  800689:	eb 15                	jmp    8006a0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	b9 00 00 00 00       	mov    $0x0,%ecx
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a7:	57                   	push   %edi
  8006a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	e8 f1 fa ff ff       	call   8001a8 <printnum>
			break;
  8006b7:	83 c4 20             	add    $0x20,%esp
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bd:	e9 f5 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	52                   	push   %edx
  8006c7:	ff d6                	call   *%esi
			break;
  8006c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cf:	e9 e3 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 03                	jmp    8006e4 <vprintfmt+0x453>
  8006e1:	83 ef 01             	sub    $0x1,%edi
  8006e4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e8:	75 f7                	jne    8006e1 <vprintfmt+0x450>
  8006ea:	e9 c8 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800706:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 26                	je     80073e <vsnprintf+0x47>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e 22                	jle    80073e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071c:	ff 75 14             	pushl  0x14(%ebp)
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	68 57 02 80 00       	push   $0x800257
  80072b:	e8 61 fb ff ff       	call   800291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 05                	jmp    800743 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074e:	50                   	push   %eax
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	ff 75 08             	pushl  0x8(%ebp)
  800758:	e8 9a ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	eb 03                	jmp    80076f <strlen+0x10>
		n++;
  80076c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800773:	75 f7                	jne    80076c <strlen+0xd>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	eb 03                	jmp    80078a <strnlen+0x13>
		n++;
  800787:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 c2                	cmp    %eax,%edx
  80078c:	74 08                	je     800796 <strnlen+0x1f>
  80078e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800792:	75 f3                	jne    800787 <strnlen+0x10>
  800794:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a2:	89 c2                	mov    %eax,%edx
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ef                	jne    8007a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bf:	53                   	push   %ebx
  8007c0:	e8 9a ff ff ff       	call   80075f <strlen>
  8007c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	01 d8                	add    %ebx,%eax
  8007cd:	50                   	push   %eax
  8007ce:	e8 c5 ff ff ff       	call   800798 <strcpy>
	return dst;
}
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	89 f3                	mov    %esi,%ebx
  8007e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	eb 0f                	jmp    8007fd <strncpy+0x23>
		*dst++ = *src;
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	39 da                	cmp    %ebx,%edx
  8007ff:	75 ed                	jne    8007ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800801:	89 f0                	mov    %esi,%eax
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	8b 55 10             	mov    0x10(%ebp),%edx
  800815:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 d2                	test   %edx,%edx
  800819:	74 21                	je     80083c <strlcpy+0x35>
  80081b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081f:	89 f2                	mov    %esi,%edx
  800821:	eb 09                	jmp    80082c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082c:	39 c2                	cmp    %eax,%edx
  80082e:	74 09                	je     800839 <strlcpy+0x32>
  800830:	0f b6 19             	movzbl (%ecx),%ebx
  800833:	84 db                	test   %bl,%bl
  800835:	75 ec                	jne    800823 <strlcpy+0x1c>
  800837:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083c:	29 f0                	sub    %esi,%eax
}
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084b:	eb 06                	jmp    800853 <strcmp+0x11>
		p++, q++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800853:	0f b6 01             	movzbl (%ecx),%eax
  800856:	84 c0                	test   %al,%al
  800858:	74 04                	je     80085e <strcmp+0x1c>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	74 ef                	je     80084d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 c0             	movzbl %al,%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	89 c3                	mov    %eax,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800877:	eb 06                	jmp    80087f <strncmp+0x17>
		n--, p++, q++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087f:	39 d8                	cmp    %ebx,%eax
  800881:	74 15                	je     800898 <strncmp+0x30>
  800883:	0f b6 08             	movzbl (%eax),%ecx
  800886:	84 c9                	test   %cl,%cl
  800888:	74 04                	je     80088e <strncmp+0x26>
  80088a:	3a 0a                	cmp    (%edx),%cl
  80088c:	74 eb                	je     800879 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 00             	movzbl (%eax),%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
  800896:	eb 05                	jmp    80089d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 07                	jmp    8008b3 <strchr+0x13>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0f                	je     8008bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 03                	jmp    8008d0 <strfind+0xf>
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 04                	je     8008db <strfind+0x1a>
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strfind+0xc>
			break;
	return (char *) s;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 36                	je     800923 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 28                	jne    80091d <memset+0x40>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 23                	jne    80091d <memset+0x40>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d3                	mov    %edx,%ebx
  800900:	c1 e3 08             	shl    $0x8,%ebx
  800903:	89 d6                	mov    %edx,%esi
  800905:	c1 e6 18             	shl    $0x18,%esi
  800908:	89 d0                	mov    %edx,%eax
  80090a:	c1 e0 10             	shl    $0x10,%eax
  80090d:	09 f0                	or     %esi,%eax
  80090f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800911:	89 d8                	mov    %ebx,%eax
  800913:	09 d0                	or     %edx,%eax
  800915:	c1 e9 02             	shr    $0x2,%ecx
  800918:	fc                   	cld    
  800919:	f3 ab                	rep stos %eax,%es:(%edi)
  80091b:	eb 06                	jmp    800923 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	fc                   	cld    
  800921:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800923:	89 f8                	mov    %edi,%eax
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 75 0c             	mov    0xc(%ebp),%esi
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800938:	39 c6                	cmp    %eax,%esi
  80093a:	73 35                	jae    800971 <memmove+0x47>
  80093c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093f:	39 d0                	cmp    %edx,%eax
  800941:	73 2e                	jae    800971 <memmove+0x47>
		s += n;
		d += n;
  800943:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	89 d6                	mov    %edx,%esi
  800948:	09 fe                	or     %edi,%esi
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 13                	jne    800965 <memmove+0x3b>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 0e                	jne    800965 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800957:	83 ef 04             	sub    $0x4,%edi
  80095a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	fd                   	std    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 09                	jmp    80096e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800965:	83 ef 01             	sub    $0x1,%edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 1d                	jmp    80098e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	89 f2                	mov    %esi,%edx
  800973:	09 c2                	or     %eax,%edx
  800975:	f6 c2 03             	test   $0x3,%dl
  800978:	75 0f                	jne    800989 <memmove+0x5f>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800995:	ff 75 10             	pushl  0x10(%ebp)
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	ff 75 08             	pushl  0x8(%ebp)
  80099e:	e8 87 ff ff ff       	call   80092a <memmove>
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c6                	mov    %eax,%esi
  8009b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	eb 1a                	jmp    8009d1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	0f b6 1a             	movzbl (%edx),%ebx
  8009bd:	38 d9                	cmp    %bl,%cl
  8009bf:	74 0a                	je     8009cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c1:	0f b6 c1             	movzbl %cl,%eax
  8009c4:	0f b6 db             	movzbl %bl,%ebx
  8009c7:	29 d8                	sub    %ebx,%eax
  8009c9:	eb 0f                	jmp    8009da <memcmp+0x35>
		s1++, s2++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	39 f0                	cmp    %esi,%eax
  8009d3:	75 e2                	jne    8009b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e5:	89 c1                	mov    %eax,%ecx
  8009e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ee:	eb 0a                	jmp    8009fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	39 da                	cmp    %ebx,%edx
  8009f5:	74 07                	je     8009fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	39 c8                	cmp    %ecx,%eax
  8009fc:	72 f2                	jb     8009f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	eb 03                	jmp    800a12 <strtol+0x11>
		s++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	0f b6 01             	movzbl (%ecx),%eax
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f6                	je     800a0f <strtol+0xe>
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f2                	je     800a0f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1d:	3c 2b                	cmp    $0x2b,%al
  800a1f:	75 0a                	jne    800a2b <strtol+0x2a>
		s++;
  800a21:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb 11                	jmp    800a3c <strtol+0x3b>
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a30:	3c 2d                	cmp    $0x2d,%al
  800a32:	75 08                	jne    800a3c <strtol+0x3b>
		s++, neg = 1;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a42:	75 15                	jne    800a59 <strtol+0x58>
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 10                	jne    800a59 <strtol+0x58>
  800a49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4d:	75 7c                	jne    800acb <strtol+0xca>
		s += 2, base = 16;
  800a4f:	83 c1 02             	add    $0x2,%ecx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 16                	jmp    800a6f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	75 12                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 08                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a77:	0f b6 11             	movzbl (%ecx),%edx
  800a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 09             	cmp    $0x9,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x8b>
			dig = *s - '0';
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 30             	sub    $0x30,%edx
  800a8a:	eb 22                	jmp    800aae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
  800a9c:	eb 10                	jmp    800aae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 16                	ja     800abe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab1:	7d 0b                	jge    800abe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abc:	eb b9                	jmp    800a77 <strtol+0x76>

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 0d                	je     800ad1 <strtol+0xd0>
		*endptr = (char *) s;
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	89 0e                	mov    %ecx,(%esi)
  800ac9:	eb 06                	jmp    800ad1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	74 98                	je     800a67 <strtol+0x66>
  800acf:	eb 9e                	jmp    800a6f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	f7 da                	neg    %edx
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	0f 45 c2             	cmovne %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cgetc>:

int
sys_cgetc(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	89 cb                	mov    %ecx,%ebx
  800b34:	89 cf                	mov    %ecx,%edi
  800b36:	89 ce                	mov    %ecx,%esi
  800b38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	7e 17                	jle    800b55 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	50                   	push   %eax
  800b42:	6a 03                	push   $0x3
  800b44:	68 df 21 80 00       	push   $0x8021df
  800b49:	6a 23                	push   $0x23
  800b4b:	68 fc 21 80 00       	push   $0x8021fc
  800b50:	e8 36 10 00 00       	call   801b8b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_yield>:

void
sys_yield(void)
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
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800ba4:	be 00 00 00 00       	mov    $0x0,%esi
  800ba9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	89 f7                	mov    %esi,%edi
  800bb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 04                	push   $0x4
  800bc5:	68 df 21 80 00       	push   $0x8021df
  800bca:	6a 23                	push   $0x23
  800bcc:	68 fc 21 80 00       	push   $0x8021fc
  800bd1:	e8 b5 0f 00 00       	call   801b8b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 05                	push   $0x5
  800c07:	68 df 21 80 00       	push   $0x8021df
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 fc 21 80 00       	push   $0x8021fc
  800c13:	e8 73 0f 00 00       	call   801b8b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 df                	mov    %ebx,%edi
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 06                	push   $0x6
  800c49:	68 df 21 80 00       	push   $0x8021df
  800c4e:	6a 23                	push   $0x23
  800c50:	68 fc 21 80 00       	push   $0x8021fc
  800c55:	e8 31 0f 00 00       	call   801b8b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	b8 08 00 00 00       	mov    $0x8,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 17                	jle    800c9c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 08                	push   $0x8
  800c8b:	68 df 21 80 00       	push   $0x8021df
  800c90:	6a 23                	push   $0x23
  800c92:	68 fc 21 80 00       	push   $0x8021fc
  800c97:	e8 ef 0e 00 00       	call   801b8b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 09                	push   $0x9
  800ccd:	68 df 21 80 00       	push   $0x8021df
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 fc 21 80 00       	push   $0x8021fc
  800cd9:	e8 ad 0e 00 00       	call   801b8b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 17                	jle    800d20 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 0a                	push   $0xa
  800d0f:	68 df 21 80 00       	push   $0x8021df
  800d14:	6a 23                	push   $0x23
  800d16:	68 fc 21 80 00       	push   $0x8021fc
  800d1b:	e8 6b 0e 00 00       	call   801b8b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0d                	push   $0xd
  800d73:	68 df 21 80 00       	push   $0x8021df
  800d78:	6a 23                	push   $0x23
  800d7a:	68 fc 21 80 00       	push   $0x8021fc
  800d7f:	e8 07 0e 00 00       	call   801b8b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	8b 75 08             	mov    0x8(%ebp),%esi
  800d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  800d9e:	85 f6                	test   %esi,%esi
  800da0:	74 06                	je     800da8 <ipc_recv+0x1c>
		*from_env_store = 0;
  800da2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  800da8:	85 db                	test   %ebx,%ebx
  800daa:	74 06                	je     800db2 <ipc_recv+0x26>
		*perm_store = 0;
  800dac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  800db2:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  800db4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800db9:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	50                   	push   %eax
  800dc0:	e8 86 ff ff ff       	call   800d4b <sys_ipc_recv>
  800dc5:	89 c7                	mov    %eax,%edi
  800dc7:	83 c4 10             	add    $0x10,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	79 14                	jns    800de2 <ipc_recv+0x56>
		cprintf("im dead");
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	68 0a 22 80 00       	push   $0x80220a
  800dd6:	e8 b9 f3 ff ff       	call   800194 <cprintf>
		return r;
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	89 f8                	mov    %edi,%eax
  800de0:	eb 24                	jmp    800e06 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  800de2:	85 f6                	test   %esi,%esi
  800de4:	74 0a                	je     800df0 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  800de6:	a1 04 40 80 00       	mov    0x804004,%eax
  800deb:	8b 40 74             	mov    0x74(%eax),%eax
  800dee:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  800df0:	85 db                	test   %ebx,%ebx
  800df2:	74 0a                	je     800dfe <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  800df4:	a1 04 40 80 00       	mov    0x804004,%eax
  800df9:	8b 40 78             	mov    0x78(%eax),%eax
  800dfc:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  800dfe:	a1 04 40 80 00       	mov    0x804004,%eax
  800e03:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  800e20:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  800e22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e27:	0f 44 d8             	cmove  %eax,%ebx
  800e2a:	eb 1c                	jmp    800e48 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  800e2c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e2f:	74 12                	je     800e43 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  800e31:	50                   	push   %eax
  800e32:	68 12 22 80 00       	push   $0x802212
  800e37:	6a 4e                	push   $0x4e
  800e39:	68 1f 22 80 00       	push   $0x80221f
  800e3e:	e8 48 0d 00 00       	call   801b8b <_panic>
		sys_yield();
  800e43:	e8 34 fd ff ff       	call   800b7c <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800e48:	ff 75 14             	pushl  0x14(%ebp)
  800e4b:	53                   	push   %ebx
  800e4c:	56                   	push   %esi
  800e4d:	57                   	push   %edi
  800e4e:	e8 d5 fe ff ff       	call   800d28 <sys_ipc_try_send>
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	78 d2                	js     800e2c <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e6d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e70:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e76:	8b 52 50             	mov    0x50(%edx),%edx
  800e79:	39 ca                	cmp    %ecx,%edx
  800e7b:	75 0d                	jne    800e8a <ipc_find_env+0x28>
			return envs[i].env_id;
  800e7d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e80:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e85:	8b 40 48             	mov    0x48(%eax),%eax
  800e88:	eb 0f                	jmp    800e99 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e8a:	83 c0 01             	add    $0x1,%eax
  800e8d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e92:	75 d9                	jne    800e6d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea6:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ebb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	c1 ea 16             	shr    $0x16,%edx
  800ed2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed9:	f6 c2 01             	test   $0x1,%dl
  800edc:	74 11                	je     800eef <fd_alloc+0x2d>
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 0c             	shr    $0xc,%edx
  800ee3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	75 09                	jne    800ef8 <fd_alloc+0x36>
			*fd_store = fd;
  800eef:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	eb 17                	jmp    800f0f <fd_alloc+0x4d>
  800ef8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800efd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f02:	75 c9                	jne    800ecd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f04:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f0a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f17:	83 f8 1f             	cmp    $0x1f,%eax
  800f1a:	77 36                	ja     800f52 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f1c:	c1 e0 0c             	shl    $0xc,%eax
  800f1f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f24:	89 c2                	mov    %eax,%edx
  800f26:	c1 ea 16             	shr    $0x16,%edx
  800f29:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	74 24                	je     800f59 <fd_lookup+0x48>
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 ea 0c             	shr    $0xc,%edx
  800f3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f41:	f6 c2 01             	test   $0x1,%dl
  800f44:	74 1a                	je     800f60 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f49:	89 02                	mov    %eax,(%edx)
	return 0;
  800f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f50:	eb 13                	jmp    800f65 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f57:	eb 0c                	jmp    800f65 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5e:	eb 05                	jmp    800f65 <fd_lookup+0x54>
  800f60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f70:	ba a8 22 80 00       	mov    $0x8022a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f75:	eb 13                	jmp    800f8a <dev_lookup+0x23>
  800f77:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f7a:	39 08                	cmp    %ecx,(%eax)
  800f7c:	75 0c                	jne    800f8a <dev_lookup+0x23>
			*dev = devtab[i];
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f83:	b8 00 00 00 00       	mov    $0x0,%eax
  800f88:	eb 2e                	jmp    800fb8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f8a:	8b 02                	mov    (%edx),%eax
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	75 e7                	jne    800f77 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f90:	a1 04 40 80 00       	mov    0x804004,%eax
  800f95:	8b 40 48             	mov    0x48(%eax),%eax
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	51                   	push   %ecx
  800f9c:	50                   	push   %eax
  800f9d:	68 2c 22 80 00       	push   $0x80222c
  800fa2:	e8 ed f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800faa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 10             	sub    $0x10,%esp
  800fc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fd2:	c1 e8 0c             	shr    $0xc,%eax
  800fd5:	50                   	push   %eax
  800fd6:	e8 36 ff ff ff       	call   800f11 <fd_lookup>
  800fdb:	83 c4 08             	add    $0x8,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 05                	js     800fe7 <fd_close+0x2d>
	    || fd != fd2)
  800fe2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fe5:	74 0c                	je     800ff3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fe7:	84 db                	test   %bl,%bl
  800fe9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fee:	0f 44 c2             	cmove  %edx,%eax
  800ff1:	eb 41                	jmp    801034 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	ff 36                	pushl  (%esi)
  800ffc:	e8 66 ff ff ff       	call   800f67 <dev_lookup>
  801001:	89 c3                	mov    %eax,%ebx
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 1a                	js     801024 <fd_close+0x6a>
		if (dev->dev_close)
  80100a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801010:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801015:	85 c0                	test   %eax,%eax
  801017:	74 0b                	je     801024 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	56                   	push   %esi
  80101d:	ff d0                	call   *%eax
  80101f:	89 c3                	mov    %eax,%ebx
  801021:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	56                   	push   %esi
  801028:	6a 00                	push   $0x0
  80102a:	e8 f1 fb ff ff       	call   800c20 <sys_page_unmap>
	return r;
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	89 d8                	mov    %ebx,%eax
}
  801034:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801037:	5b                   	pop    %ebx
  801038:	5e                   	pop    %esi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801041:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801044:	50                   	push   %eax
  801045:	ff 75 08             	pushl  0x8(%ebp)
  801048:	e8 c4 fe ff ff       	call   800f11 <fd_lookup>
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 10                	js     801064 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	6a 01                	push   $0x1
  801059:	ff 75 f4             	pushl  -0xc(%ebp)
  80105c:	e8 59 ff ff ff       	call   800fba <fd_close>
  801061:	83 c4 10             	add    $0x10,%esp
}
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <close_all>:

void
close_all(void)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	53                   	push   %ebx
  80106a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80106d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	53                   	push   %ebx
  801076:	e8 c0 ff ff ff       	call   80103b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80107b:	83 c3 01             	add    $0x1,%ebx
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	83 fb 20             	cmp    $0x20,%ebx
  801084:	75 ec                	jne    801072 <close_all+0xc>
		close(i);
}
  801086:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	83 ec 2c             	sub    $0x2c,%esp
  801094:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801097:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80109a:	50                   	push   %eax
  80109b:	ff 75 08             	pushl  0x8(%ebp)
  80109e:	e8 6e fe ff ff       	call   800f11 <fd_lookup>
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 88 c1 00 00 00    	js     80116f <dup+0xe4>
		return r;
	close(newfdnum);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	56                   	push   %esi
  8010b2:	e8 84 ff ff ff       	call   80103b <close>

	newfd = INDEX2FD(newfdnum);
  8010b7:	89 f3                	mov    %esi,%ebx
  8010b9:	c1 e3 0c             	shl    $0xc,%ebx
  8010bc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010c2:	83 c4 04             	add    $0x4,%esp
  8010c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c8:	e8 de fd ff ff       	call   800eab <fd2data>
  8010cd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010cf:	89 1c 24             	mov    %ebx,(%esp)
  8010d2:	e8 d4 fd ff ff       	call   800eab <fd2data>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010dd:	89 f8                	mov    %edi,%eax
  8010df:	c1 e8 16             	shr    $0x16,%eax
  8010e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e9:	a8 01                	test   $0x1,%al
  8010eb:	74 37                	je     801124 <dup+0x99>
  8010ed:	89 f8                	mov    %edi,%eax
  8010ef:	c1 e8 0c             	shr    $0xc,%eax
  8010f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f9:	f6 c2 01             	test   $0x1,%dl
  8010fc:	74 26                	je     801124 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	25 07 0e 00 00       	and    $0xe07,%eax
  80110d:	50                   	push   %eax
  80110e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801111:	6a 00                	push   $0x0
  801113:	57                   	push   %edi
  801114:	6a 00                	push   $0x0
  801116:	e8 c3 fa ff ff       	call   800bde <sys_page_map>
  80111b:	89 c7                	mov    %eax,%edi
  80111d:	83 c4 20             	add    $0x20,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 2e                	js     801152 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801124:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801127:	89 d0                	mov    %edx,%eax
  801129:	c1 e8 0c             	shr    $0xc,%eax
  80112c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	25 07 0e 00 00       	and    $0xe07,%eax
  80113b:	50                   	push   %eax
  80113c:	53                   	push   %ebx
  80113d:	6a 00                	push   $0x0
  80113f:	52                   	push   %edx
  801140:	6a 00                	push   $0x0
  801142:	e8 97 fa ff ff       	call   800bde <sys_page_map>
  801147:	89 c7                	mov    %eax,%edi
  801149:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80114c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114e:	85 ff                	test   %edi,%edi
  801150:	79 1d                	jns    80116f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	53                   	push   %ebx
  801156:	6a 00                	push   $0x0
  801158:	e8 c3 fa ff ff       	call   800c20 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	ff 75 d4             	pushl  -0x2c(%ebp)
  801163:	6a 00                	push   $0x0
  801165:	e8 b6 fa ff ff       	call   800c20 <sys_page_unmap>
	return r;
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	89 f8                	mov    %edi,%eax
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	83 ec 14             	sub    $0x14,%esp
  80117e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801181:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	53                   	push   %ebx
  801186:	e8 86 fd ff ff       	call   800f11 <fd_lookup>
  80118b:	83 c4 08             	add    $0x8,%esp
  80118e:	89 c2                	mov    %eax,%edx
  801190:	85 c0                	test   %eax,%eax
  801192:	78 6d                	js     801201 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801194:	83 ec 08             	sub    $0x8,%esp
  801197:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119a:	50                   	push   %eax
  80119b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119e:	ff 30                	pushl  (%eax)
  8011a0:	e8 c2 fd ff ff       	call   800f67 <dev_lookup>
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 4c                	js     8011f8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011af:	8b 42 08             	mov    0x8(%edx),%eax
  8011b2:	83 e0 03             	and    $0x3,%eax
  8011b5:	83 f8 01             	cmp    $0x1,%eax
  8011b8:	75 21                	jne    8011db <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bf:	8b 40 48             	mov    0x48(%eax),%eax
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	53                   	push   %ebx
  8011c6:	50                   	push   %eax
  8011c7:	68 6d 22 80 00       	push   $0x80226d
  8011cc:	e8 c3 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d9:	eb 26                	jmp    801201 <read+0x8a>
	}
	if (!dev->dev_read)
  8011db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011de:	8b 40 08             	mov    0x8(%eax),%eax
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	74 17                	je     8011fc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	ff 75 10             	pushl  0x10(%ebp)
  8011eb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ee:	52                   	push   %edx
  8011ef:	ff d0                	call   *%eax
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	eb 09                	jmp    801201 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	eb 05                	jmp    801201 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801201:	89 d0                	mov    %edx,%eax
  801203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	8b 7d 08             	mov    0x8(%ebp),%edi
  801214:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801217:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121c:	eb 21                	jmp    80123f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	89 f0                	mov    %esi,%eax
  801223:	29 d8                	sub    %ebx,%eax
  801225:	50                   	push   %eax
  801226:	89 d8                	mov    %ebx,%eax
  801228:	03 45 0c             	add    0xc(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	57                   	push   %edi
  80122d:	e8 45 ff ff ff       	call   801177 <read>
		if (m < 0)
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 10                	js     801249 <readn+0x41>
			return m;
		if (m == 0)
  801239:	85 c0                	test   %eax,%eax
  80123b:	74 0a                	je     801247 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123d:	01 c3                	add    %eax,%ebx
  80123f:	39 f3                	cmp    %esi,%ebx
  801241:	72 db                	jb     80121e <readn+0x16>
  801243:	89 d8                	mov    %ebx,%eax
  801245:	eb 02                	jmp    801249 <readn+0x41>
  801247:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801249:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5e                   	pop    %esi
  80124e:	5f                   	pop    %edi
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	53                   	push   %ebx
  801255:	83 ec 14             	sub    $0x14,%esp
  801258:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	53                   	push   %ebx
  801260:	e8 ac fc ff ff       	call   800f11 <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	89 c2                	mov    %eax,%edx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 68                	js     8012d6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	ff 30                	pushl  (%eax)
  80127a:	e8 e8 fc ff ff       	call   800f67 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 47                	js     8012cd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128d:	75 21                	jne    8012b0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80128f:	a1 04 40 80 00       	mov    0x804004,%eax
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	53                   	push   %ebx
  80129b:	50                   	push   %eax
  80129c:	68 89 22 80 00       	push   $0x802289
  8012a1:	e8 ee ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ae:	eb 26                	jmp    8012d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	74 17                	je     8012d1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	ff 75 10             	pushl  0x10(%ebp)
  8012c0:	ff 75 0c             	pushl  0xc(%ebp)
  8012c3:	50                   	push   %eax
  8012c4:	ff d2                	call   *%edx
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	eb 09                	jmp    8012d6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	eb 05                	jmp    8012d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <seek>:

int
seek(int fdnum, off_t offset)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	ff 75 08             	pushl  0x8(%ebp)
  8012ea:	e8 22 fc ff ff       	call   800f11 <fd_lookup>
  8012ef:	83 c4 08             	add    $0x8,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 0e                	js     801304 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	53                   	push   %ebx
  80130a:	83 ec 14             	sub    $0x14,%esp
  80130d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801310:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	53                   	push   %ebx
  801315:	e8 f7 fb ff ff       	call   800f11 <fd_lookup>
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	89 c2                	mov    %eax,%edx
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 65                	js     801388 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801329:	50                   	push   %eax
  80132a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132d:	ff 30                	pushl  (%eax)
  80132f:	e8 33 fc ff ff       	call   800f67 <dev_lookup>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 44                	js     80137f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801342:	75 21                	jne    801365 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801344:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801349:	8b 40 48             	mov    0x48(%eax),%eax
  80134c:	83 ec 04             	sub    $0x4,%esp
  80134f:	53                   	push   %ebx
  801350:	50                   	push   %eax
  801351:	68 4c 22 80 00       	push   $0x80224c
  801356:	e8 39 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801363:	eb 23                	jmp    801388 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801365:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801368:	8b 52 18             	mov    0x18(%edx),%edx
  80136b:	85 d2                	test   %edx,%edx
  80136d:	74 14                	je     801383 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	ff 75 0c             	pushl  0xc(%ebp)
  801375:	50                   	push   %eax
  801376:	ff d2                	call   *%edx
  801378:	89 c2                	mov    %eax,%edx
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	eb 09                	jmp    801388 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137f:	89 c2                	mov    %eax,%edx
  801381:	eb 05                	jmp    801388 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801383:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801388:	89 d0                	mov    %edx,%eax
  80138a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	83 ec 14             	sub    $0x14,%esp
  801396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801399:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139c:	50                   	push   %eax
  80139d:	ff 75 08             	pushl  0x8(%ebp)
  8013a0:	e8 6c fb ff ff       	call   800f11 <fd_lookup>
  8013a5:	83 c4 08             	add    $0x8,%esp
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 58                	js     801406 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b8:	ff 30                	pushl  (%eax)
  8013ba:	e8 a8 fb ff ff       	call   800f67 <dev_lookup>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 37                	js     8013fd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013cd:	74 32                	je     801401 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d9:	00 00 00 
	stat->st_isdir = 0;
  8013dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e3:	00 00 00 
	stat->st_dev = dev;
  8013e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	53                   	push   %ebx
  8013f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f3:	ff 50 14             	call   *0x14(%eax)
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	eb 09                	jmp    801406 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	eb 05                	jmp    801406 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801401:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801406:	89 d0                	mov    %edx,%eax
  801408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	6a 00                	push   $0x0
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 e9 01 00 00       	call   801608 <open>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 1b                	js     801443 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	50                   	push   %eax
  80142f:	e8 5b ff ff ff       	call   80138f <fstat>
  801434:	89 c6                	mov    %eax,%esi
	close(fd);
  801436:	89 1c 24             	mov    %ebx,(%esp)
  801439:	e8 fd fb ff ff       	call   80103b <close>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	89 f0                	mov    %esi,%eax
}
  801443:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	56                   	push   %esi
  80144e:	53                   	push   %ebx
  80144f:	89 c6                	mov    %eax,%esi
  801451:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801453:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80145a:	75 12                	jne    80146e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	6a 01                	push   $0x1
  801461:	e8 fc f9 ff ff       	call   800e62 <ipc_find_env>
  801466:	a3 00 40 80 00       	mov    %eax,0x804000
  80146b:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80146e:	6a 07                	push   $0x7
  801470:	68 00 50 80 00       	push   $0x805000
  801475:	56                   	push   %esi
  801476:	ff 35 00 40 80 00    	pushl  0x804000
  80147c:	e8 8d f9 ff ff       	call   800e0e <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801481:	83 c4 0c             	add    $0xc,%esp
  801484:	6a 00                	push   $0x0
  801486:	53                   	push   %ebx
  801487:	6a 00                	push   $0x0
  801489:	e8 fe f8 ff ff       	call   800d8c <ipc_recv>
}
  80148e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b8:	e8 8d ff ff ff       	call   80144a <fsipc>
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8014da:	e8 6b ff ff ff       	call   80144a <fsipc>
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	b8 05 00 00 00       	mov    $0x5,%eax
  801500:	e8 45 ff ff ff       	call   80144a <fsipc>
  801505:	85 c0                	test   %eax,%eax
  801507:	78 2c                	js     801535 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	68 00 50 80 00       	push   $0x805000
  801511:	53                   	push   %ebx
  801512:	e8 81 f2 ff ff       	call   800798 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801517:	a1 80 50 80 00       	mov    0x805080,%eax
  80151c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801522:	a1 84 50 80 00       	mov    0x805084,%eax
  801527:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	8b 45 10             	mov    0x10(%ebp),%eax
  801543:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801548:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80154d:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801550:	8b 55 08             	mov    0x8(%ebp),%edx
  801553:	8b 52 0c             	mov    0xc(%edx),%edx
  801556:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80155c:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801561:	50                   	push   %eax
  801562:	ff 75 0c             	pushl  0xc(%ebp)
  801565:	68 08 50 80 00       	push   $0x805008
  80156a:	e8 bb f3 ff ff       	call   80092a <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 04 00 00 00       	mov    $0x4,%eax
  801579:	e8 cc fe ff ff       	call   80144a <fsipc>
            return r;

    return r;
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	8b 40 0c             	mov    0xc(%eax),%eax
  80158e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801593:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801599:	ba 00 00 00 00       	mov    $0x0,%edx
  80159e:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a3:	e8 a2 fe ff ff       	call   80144a <fsipc>
  8015a8:	89 c3                	mov    %eax,%ebx
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 51                	js     8015ff <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8015ae:	39 c6                	cmp    %eax,%esi
  8015b0:	73 19                	jae    8015cb <devfile_read+0x4b>
  8015b2:	68 b8 22 80 00       	push   $0x8022b8
  8015b7:	68 bf 22 80 00       	push   $0x8022bf
  8015bc:	68 82 00 00 00       	push   $0x82
  8015c1:	68 d4 22 80 00       	push   $0x8022d4
  8015c6:	e8 c0 05 00 00       	call   801b8b <_panic>
	assert(r <= PGSIZE);
  8015cb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015d0:	7e 19                	jle    8015eb <devfile_read+0x6b>
  8015d2:	68 df 22 80 00       	push   $0x8022df
  8015d7:	68 bf 22 80 00       	push   $0x8022bf
  8015dc:	68 83 00 00 00       	push   $0x83
  8015e1:	68 d4 22 80 00       	push   $0x8022d4
  8015e6:	e8 a0 05 00 00       	call   801b8b <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	50                   	push   %eax
  8015ef:	68 00 50 80 00       	push   $0x805000
  8015f4:	ff 75 0c             	pushl  0xc(%ebp)
  8015f7:	e8 2e f3 ff ff       	call   80092a <memmove>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
}
  8015ff:	89 d8                	mov    %ebx,%eax
  801601:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 20             	sub    $0x20,%esp
  80160f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801612:	53                   	push   %ebx
  801613:	e8 47 f1 ff ff       	call   80075f <strlen>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801620:	7f 67                	jg     801689 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	e8 94 f8 ff ff       	call   800ec2 <fd_alloc>
  80162e:	83 c4 10             	add    $0x10,%esp
		return r;
  801631:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801633:	85 c0                	test   %eax,%eax
  801635:	78 57                	js     80168e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	53                   	push   %ebx
  80163b:	68 00 50 80 00       	push   $0x805000
  801640:	e8 53 f1 ff ff       	call   800798 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801645:	8b 45 0c             	mov    0xc(%ebp),%eax
  801648:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	b8 01 00 00 00       	mov    $0x1,%eax
  801655:	e8 f0 fd ff ff       	call   80144a <fsipc>
  80165a:	89 c3                	mov    %eax,%ebx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	79 14                	jns    801677 <open+0x6f>
		fd_close(fd, 0);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	6a 00                	push   $0x0
  801668:	ff 75 f4             	pushl  -0xc(%ebp)
  80166b:	e8 4a f9 ff ff       	call   800fba <fd_close>
		return r;
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	89 da                	mov    %ebx,%edx
  801675:	eb 17                	jmp    80168e <open+0x86>
	}

	return fd2num(fd);
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	ff 75 f4             	pushl  -0xc(%ebp)
  80167d:	e8 19 f8 ff ff       	call   800e9b <fd2num>
  801682:	89 c2                	mov    %eax,%edx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb 05                	jmp    80168e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801689:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80168e:	89 d0                	mov    %edx,%eax
  801690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169b:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a5:	e8 a0 fd ff ff       	call   80144a <fsipc>
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016b4:	83 ec 0c             	sub    $0xc,%esp
  8016b7:	ff 75 08             	pushl  0x8(%ebp)
  8016ba:	e8 ec f7 ff ff       	call   800eab <fd2data>
  8016bf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016c1:	83 c4 08             	add    $0x8,%esp
  8016c4:	68 eb 22 80 00       	push   $0x8022eb
  8016c9:	53                   	push   %ebx
  8016ca:	e8 c9 f0 ff ff       	call   800798 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016cf:	8b 46 04             	mov    0x4(%esi),%eax
  8016d2:	2b 06                	sub    (%esi),%eax
  8016d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e1:	00 00 00 
	stat->st_dev = &devpipe;
  8016e4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016eb:	30 80 00 
	return 0;
}
  8016ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f6:	5b                   	pop    %ebx
  8016f7:	5e                   	pop    %esi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801704:	53                   	push   %ebx
  801705:	6a 00                	push   $0x0
  801707:	e8 14 f5 ff ff       	call   800c20 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80170c:	89 1c 24             	mov    %ebx,(%esp)
  80170f:	e8 97 f7 ff ff       	call   800eab <fd2data>
  801714:	83 c4 08             	add    $0x8,%esp
  801717:	50                   	push   %eax
  801718:	6a 00                	push   $0x0
  80171a:	e8 01 f5 ff ff       	call   800c20 <sys_page_unmap>
}
  80171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	57                   	push   %edi
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	83 ec 1c             	sub    $0x1c,%esp
  80172d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801730:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801732:	a1 04 40 80 00       	mov    0x804004,%eax
  801737:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	ff 75 e0             	pushl  -0x20(%ebp)
  801740:	e8 8c 04 00 00       	call   801bd1 <pageref>
  801745:	89 c3                	mov    %eax,%ebx
  801747:	89 3c 24             	mov    %edi,(%esp)
  80174a:	e8 82 04 00 00       	call   801bd1 <pageref>
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	39 c3                	cmp    %eax,%ebx
  801754:	0f 94 c1             	sete   %cl
  801757:	0f b6 c9             	movzbl %cl,%ecx
  80175a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80175d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801763:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801766:	39 ce                	cmp    %ecx,%esi
  801768:	74 1b                	je     801785 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80176a:	39 c3                	cmp    %eax,%ebx
  80176c:	75 c4                	jne    801732 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80176e:	8b 42 58             	mov    0x58(%edx),%eax
  801771:	ff 75 e4             	pushl  -0x1c(%ebp)
  801774:	50                   	push   %eax
  801775:	56                   	push   %esi
  801776:	68 f2 22 80 00       	push   $0x8022f2
  80177b:	e8 14 ea ff ff       	call   800194 <cprintf>
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	eb ad                	jmp    801732 <_pipeisclosed+0xe>
	}
}
  801785:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	57                   	push   %edi
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 28             	sub    $0x28,%esp
  801799:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80179c:	56                   	push   %esi
  80179d:	e8 09 f7 ff ff       	call   800eab <fd2data>
  8017a2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8017ac:	eb 4b                	jmp    8017f9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017ae:	89 da                	mov    %ebx,%edx
  8017b0:	89 f0                	mov    %esi,%eax
  8017b2:	e8 6d ff ff ff       	call   801724 <_pipeisclosed>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	75 48                	jne    801803 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017bb:	e8 bc f3 ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c3:	8b 0b                	mov    (%ebx),%ecx
  8017c5:	8d 51 20             	lea    0x20(%ecx),%edx
  8017c8:	39 d0                	cmp    %edx,%eax
  8017ca:	73 e2                	jae    8017ae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017d3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017d6:	89 c2                	mov    %eax,%edx
  8017d8:	c1 fa 1f             	sar    $0x1f,%edx
  8017db:	89 d1                	mov    %edx,%ecx
  8017dd:	c1 e9 1b             	shr    $0x1b,%ecx
  8017e0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017e3:	83 e2 1f             	and    $0x1f,%edx
  8017e6:	29 ca                	sub    %ecx,%edx
  8017e8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017f0:	83 c0 01             	add    $0x1,%eax
  8017f3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f6:	83 c7 01             	add    $0x1,%edi
  8017f9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017fc:	75 c2                	jne    8017c0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801801:	eb 05                	jmp    801808 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801808:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5f                   	pop    %edi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	57                   	push   %edi
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	83 ec 18             	sub    $0x18,%esp
  801819:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80181c:	57                   	push   %edi
  80181d:	e8 89 f6 ff ff       	call   800eab <fd2data>
  801822:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182c:	eb 3d                	jmp    80186b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80182e:	85 db                	test   %ebx,%ebx
  801830:	74 04                	je     801836 <devpipe_read+0x26>
				return i;
  801832:	89 d8                	mov    %ebx,%eax
  801834:	eb 44                	jmp    80187a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801836:	89 f2                	mov    %esi,%edx
  801838:	89 f8                	mov    %edi,%eax
  80183a:	e8 e5 fe ff ff       	call   801724 <_pipeisclosed>
  80183f:	85 c0                	test   %eax,%eax
  801841:	75 32                	jne    801875 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801843:	e8 34 f3 ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801848:	8b 06                	mov    (%esi),%eax
  80184a:	3b 46 04             	cmp    0x4(%esi),%eax
  80184d:	74 df                	je     80182e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80184f:	99                   	cltd   
  801850:	c1 ea 1b             	shr    $0x1b,%edx
  801853:	01 d0                	add    %edx,%eax
  801855:	83 e0 1f             	and    $0x1f,%eax
  801858:	29 d0                	sub    %edx,%eax
  80185a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80185f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801862:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801865:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801868:	83 c3 01             	add    $0x1,%ebx
  80186b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80186e:	75 d8                	jne    801848 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801870:	8b 45 10             	mov    0x10(%ebp),%eax
  801873:	eb 05                	jmp    80187a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80187a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5f                   	pop    %edi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80188a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	e8 2f f6 ff ff       	call   800ec2 <fd_alloc>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	89 c2                	mov    %eax,%edx
  801898:	85 c0                	test   %eax,%eax
  80189a:	0f 88 2c 01 00 00    	js     8019cc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a0:	83 ec 04             	sub    $0x4,%esp
  8018a3:	68 07 04 00 00       	push   $0x407
  8018a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ab:	6a 00                	push   $0x0
  8018ad:	e8 e9 f2 ff ff       	call   800b9b <sys_page_alloc>
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	89 c2                	mov    %eax,%edx
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	0f 88 0d 01 00 00    	js     8019cc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	e8 f7 f5 ff ff       	call   800ec2 <fd_alloc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	0f 88 e2 00 00 00    	js     8019ba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d8:	83 ec 04             	sub    $0x4,%esp
  8018db:	68 07 04 00 00       	push   $0x407
  8018e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e3:	6a 00                	push   $0x0
  8018e5:	e8 b1 f2 ff ff       	call   800b9b <sys_page_alloc>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	0f 88 c3 00 00 00    	js     8019ba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fd:	e8 a9 f5 ff ff       	call   800eab <fd2data>
  801902:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801904:	83 c4 0c             	add    $0xc,%esp
  801907:	68 07 04 00 00       	push   $0x407
  80190c:	50                   	push   %eax
  80190d:	6a 00                	push   $0x0
  80190f:	e8 87 f2 ff ff       	call   800b9b <sys_page_alloc>
  801914:	89 c3                	mov    %eax,%ebx
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	0f 88 89 00 00 00    	js     8019aa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	ff 75 f0             	pushl  -0x10(%ebp)
  801927:	e8 7f f5 ff ff       	call   800eab <fd2data>
  80192c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801933:	50                   	push   %eax
  801934:	6a 00                	push   $0x0
  801936:	56                   	push   %esi
  801937:	6a 00                	push   $0x0
  801939:	e8 a0 f2 ff ff       	call   800bde <sys_page_map>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	83 c4 20             	add    $0x20,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	78 55                	js     80199c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801947:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801950:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80195c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801962:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801965:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801967:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	ff 75 f4             	pushl  -0xc(%ebp)
  801977:	e8 1f f5 ff ff       	call   800e9b <fd2num>
  80197c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801981:	83 c4 04             	add    $0x4,%esp
  801984:	ff 75 f0             	pushl  -0x10(%ebp)
  801987:	e8 0f f5 ff ff       	call   800e9b <fd2num>
  80198c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	ba 00 00 00 00       	mov    $0x0,%edx
  80199a:	eb 30                	jmp    8019cc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	56                   	push   %esi
  8019a0:	6a 00                	push   $0x0
  8019a2:	e8 79 f2 ff ff       	call   800c20 <sys_page_unmap>
  8019a7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 69 f2 ff ff       	call   800c20 <sys_page_unmap>
  8019b7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c0:	6a 00                	push   $0x0
  8019c2:	e8 59 f2 ff ff       	call   800c20 <sys_page_unmap>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019cc:	89 d0                	mov    %edx,%eax
  8019ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	ff 75 08             	pushl  0x8(%ebp)
  8019e2:	e8 2a f5 ff ff       	call   800f11 <fd_lookup>
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 18                	js     801a06 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	e8 b2 f4 ff ff       	call   800eab <fd2data>
	return _pipeisclosed(fd, p);
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fe:	e8 21 fd ff ff       	call   801724 <_pipeisclosed>
  801a03:	83 c4 10             	add    $0x10,%esp
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a18:	68 0a 23 80 00       	push   $0x80230a
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	e8 73 ed ff ff       	call   800798 <strcpy>
	return 0;
}
  801a25:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a38:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a3d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a43:	eb 2d                	jmp    801a72 <devcons_write+0x46>
		m = n - tot;
  801a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a48:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a4a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a4d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a52:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a55:	83 ec 04             	sub    $0x4,%esp
  801a58:	53                   	push   %ebx
  801a59:	03 45 0c             	add    0xc(%ebp),%eax
  801a5c:	50                   	push   %eax
  801a5d:	57                   	push   %edi
  801a5e:	e8 c7 ee ff ff       	call   80092a <memmove>
		sys_cputs(buf, m);
  801a63:	83 c4 08             	add    $0x8,%esp
  801a66:	53                   	push   %ebx
  801a67:	57                   	push   %edi
  801a68:	e8 72 f0 ff ff       	call   800adf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a6d:	01 de                	add    %ebx,%esi
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	89 f0                	mov    %esi,%eax
  801a74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a77:	72 cc                	jb     801a45 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5f                   	pop    %edi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a90:	74 2a                	je     801abc <devcons_read+0x3b>
  801a92:	eb 05                	jmp    801a99 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a94:	e8 e3 f0 ff ff       	call   800b7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a99:	e8 5f f0 ff ff       	call   800afd <sys_cgetc>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	74 f2                	je     801a94 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 16                	js     801abc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aa6:	83 f8 04             	cmp    $0x4,%eax
  801aa9:	74 0c                	je     801ab7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aae:	88 02                	mov    %al,(%edx)
	return 1;
  801ab0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab5:	eb 05                	jmp    801abc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    

00801abe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801aca:	6a 01                	push   $0x1
  801acc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	e8 0a f0 ff ff       	call   800adf <sys_cputs>
}
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <getchar>:

int
getchar(void)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ae0:	6a 01                	push   $0x1
  801ae2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae5:	50                   	push   %eax
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 8a f6 ff ff       	call   801177 <read>
	if (r < 0)
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 0f                	js     801b03 <getchar+0x29>
		return r;
	if (r < 1)
  801af4:	85 c0                	test   %eax,%eax
  801af6:	7e 06                	jle    801afe <getchar+0x24>
		return -E_EOF;
	return c;
  801af8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801afc:	eb 05                	jmp    801b03 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801afe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0e:	50                   	push   %eax
  801b0f:	ff 75 08             	pushl  0x8(%ebp)
  801b12:	e8 fa f3 ff ff       	call   800f11 <fd_lookup>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 11                	js     801b2f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b27:	39 10                	cmp    %edx,(%eax)
  801b29:	0f 94 c0             	sete   %al
  801b2c:	0f b6 c0             	movzbl %al,%eax
}
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    

00801b31 <opencons>:

int
opencons(void)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3a:	50                   	push   %eax
  801b3b:	e8 82 f3 ff ff       	call   800ec2 <fd_alloc>
  801b40:	83 c4 10             	add    $0x10,%esp
		return r;
  801b43:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 3e                	js     801b87 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b49:	83 ec 04             	sub    $0x4,%esp
  801b4c:	68 07 04 00 00       	push   $0x407
  801b51:	ff 75 f4             	pushl  -0xc(%ebp)
  801b54:	6a 00                	push   $0x0
  801b56:	e8 40 f0 ff ff       	call   800b9b <sys_page_alloc>
  801b5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b5e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 23                	js     801b87 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	50                   	push   %eax
  801b7d:	e8 19 f3 ff ff       	call   800e9b <fd2num>
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	83 c4 10             	add    $0x10,%esp
}
  801b87:	89 d0                	mov    %edx,%eax
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b90:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b93:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b99:	e8 bf ef ff ff       	call   800b5d <sys_getenvid>
  801b9e:	83 ec 0c             	sub    $0xc,%esp
  801ba1:	ff 75 0c             	pushl  0xc(%ebp)
  801ba4:	ff 75 08             	pushl  0x8(%ebp)
  801ba7:	56                   	push   %esi
  801ba8:	50                   	push   %eax
  801ba9:	68 18 23 80 00       	push   $0x802318
  801bae:	e8 e1 e5 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bb3:	83 c4 18             	add    $0x18,%esp
  801bb6:	53                   	push   %ebx
  801bb7:	ff 75 10             	pushl  0x10(%ebp)
  801bba:	e8 84 e5 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801bbf:	c7 04 24 03 23 80 00 	movl   $0x802303,(%esp)
  801bc6:	e8 c9 e5 ff ff       	call   800194 <cprintf>
  801bcb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bce:	cc                   	int3   
  801bcf:	eb fd                	jmp    801bce <_panic+0x43>

00801bd1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd7:	89 d0                	mov    %edx,%eax
  801bd9:	c1 e8 16             	shr    $0x16,%eax
  801bdc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be8:	f6 c1 01             	test   $0x1,%cl
  801beb:	74 1d                	je     801c0a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bed:	c1 ea 0c             	shr    $0xc,%edx
  801bf0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf7:	f6 c2 01             	test   $0x1,%dl
  801bfa:	74 0e                	je     801c0a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bfc:	c1 ea 0c             	shr    $0xc,%edx
  801bff:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c06:	ef 
  801c07:	0f b7 c0             	movzwl %ax,%eax
}
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

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
