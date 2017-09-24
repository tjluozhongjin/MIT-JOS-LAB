
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 a0 20 80 00       	push   $0x8020a0
  800062:	e8 5a 17 00 00       	call   8017c1 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 eb 11 00 00       	call   80126c <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 a5 20 80 00       	push   $0x8020a5
  800095:	6a 13                	push   $0x13
  800097:	68 c0 20 80 00       	push   $0x8020c0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 d5 10 00 00       	call   801192 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 cb 20 80 00       	push   $0x8020cb
  8000d8:	6a 18                	push   $0x18
  8000da:	68 c0 20 80 00       	push   $0x8020c0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 e0 	movl   $0x8020e0,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 e4 20 80 00       	push   $0x8020e4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 ef 14 00 00       	call   801623 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 ec 20 80 00       	push   $0x8020ec
  80014b:	6a 27                	push   $0x27
  80014d:	68 c0 20 80 00       	push   $0x8020c0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 ec 0e 00 00       	call   801056 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800190:	e8 f2 0a 00 00       	call   800c87 <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 ab 0e 00 00       	call   801081 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 66 0a 00 00       	call   800c46 <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 8f 0a 00 00       	call   800c87 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 08 21 80 00       	push   $0x802108
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 27 25 80 00 	movl   $0x802527,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 ae 09 00 00       	call   800c09 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 1a 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 53 09 00 00       	call   800c09 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 da 1a 00 00       	call   801e00 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 c7 1b 00 00       	call   801f30 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 2b 21 80 00 	movsbl 0x80212b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8d 4a 01             	lea    0x1(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	88 02                	mov    %al,(%edx)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	50                   	push   %eax
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 05 00 00 00       	call   8003bb <vprintfmt>
	va_end(ap);
}
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 2c             	sub    $0x2c,%esp
  8003c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cd:	eb 12                	jmp    8003e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 42 04 00 00    	je     800819 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	53                   	push   %ebx
  8003db:	50                   	push   %eax
  8003dc:	ff d6                	call   *%esi
  8003de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	83 c7 01             	add    $0x1,%edi
  8003e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003e8:	83 f8 25             	cmp    $0x25,%eax
  8003eb:	75 e2                	jne    8003cf <vprintfmt+0x14>
  8003ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	eb 07                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8d 47 01             	lea    0x1(%edi),%eax
  800417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041a:	0f b6 07             	movzbl (%edi),%eax
  80041d:	0f b6 d0             	movzbl %al,%edx
  800420:	83 e8 23             	sub    $0x23,%eax
  800423:	3c 55                	cmp    $0x55,%al
  800425:	0f 87 d3 03 00 00    	ja     8007fe <vprintfmt+0x443>
  80042b:	0f b6 c0             	movzbl %al,%eax
  80042e:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80043c:	eb d6                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800449:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800450:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800453:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800456:	83 f9 09             	cmp    $0x9,%ecx
  800459:	77 3f                	ja     80049a <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb e9                	jmp    800449 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8b 00                	mov    (%eax),%eax
  800465:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 40 04             	lea    0x4(%eax),%eax
  80046e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800474:	eb 2a                	jmp    8004a0 <vprintfmt+0xe5>
  800476:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800479:	85 c0                	test   %eax,%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	0f 49 d0             	cmovns %eax,%edx
  800483:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800489:	eb 89                	jmp    800414 <vprintfmt+0x59>
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800495:	e9 7a ff ff ff       	jmp    800414 <vprintfmt+0x59>
  80049a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80049d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a4:	0f 89 6a ff ff ff    	jns    800414 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b7:	e9 58 ff ff ff       	jmp    800414 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bc:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c2:	e9 4d ff ff ff       	jmp    800414 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 78 04             	lea    0x4(%eax),%edi
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	53                   	push   %ebx
  8004d1:	ff 30                	pushl  (%eax)
  8004d3:	ff d6                	call   *%esi
			break;
  8004d5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004de:	e9 fe fe ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 78 04             	lea    0x4(%eax),%edi
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	99                   	cltd   
  8004ec:	31 d0                	xor    %edx,%eax
  8004ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f0:	83 f8 0f             	cmp    $0xf,%eax
  8004f3:	7f 0b                	jg     800500 <vprintfmt+0x145>
  8004f5:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	75 1b                	jne    80051b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800500:	50                   	push   %eax
  800501:	68 43 21 80 00       	push   $0x802143
  800506:	53                   	push   %ebx
  800507:	56                   	push   %esi
  800508:	e8 91 fe ff ff       	call   80039e <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800510:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800516:	e9 c6 fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051b:	52                   	push   %edx
  80051c:	68 f5 24 80 00       	push   $0x8024f5
  800521:	53                   	push   %ebx
  800522:	56                   	push   %esi
  800523:	e8 76 fe ff ff       	call   80039e <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800531:	e9 ab fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	83 c0 04             	add    $0x4,%eax
  80053c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800544:	85 ff                	test   %edi,%edi
  800546:	b8 3c 21 80 00       	mov    $0x80213c,%eax
  80054b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800552:	0f 8e 94 00 00 00    	jle    8005ec <vprintfmt+0x231>
  800558:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055c:	0f 84 98 00 00 00    	je     8005fa <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 d0             	pushl  -0x30(%ebp)
  800568:	57                   	push   %edi
  800569:	e8 33 03 00 00       	call   8008a1 <strnlen>
  80056e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800571:	29 c1                	sub    %eax,%ecx
  800573:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800579:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800583:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x1db>
					putch(padc, putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	ff 75 e0             	pushl  -0x20(%ebp)
  80058e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	85 ff                	test   %edi,%edi
  800598:	7f ed                	jg     800587 <vprintfmt+0x1cc>
  80059a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	0f 49 c1             	cmovns %ecx,%eax
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8005af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b5:	89 cb                	mov    %ecx,%ebx
  8005b7:	eb 4d                	jmp    800606 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bd:	74 1b                	je     8005da <vprintfmt+0x21f>
  8005bf:	0f be c0             	movsbl %al,%eax
  8005c2:	83 e8 20             	sub    $0x20,%eax
  8005c5:	83 f8 5e             	cmp    $0x5e,%eax
  8005c8:	76 10                	jbe    8005da <vprintfmt+0x21f>
					putch('?', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	6a 3f                	push   $0x3f
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 0d                	jmp    8005e7 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	ff 75 0c             	pushl  0xc(%ebp)
  8005e0:	52                   	push   %edx
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e7:	83 eb 01             	sub    $0x1,%ebx
  8005ea:	eb 1a                	jmp    800606 <vprintfmt+0x24b>
  8005ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f8:	eb 0c                	jmp    800606 <vprintfmt+0x24b>
  8005fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800600:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800603:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800606:	83 c7 01             	add    $0x1,%edi
  800609:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060d:	0f be d0             	movsbl %al,%edx
  800610:	85 d2                	test   %edx,%edx
  800612:	74 23                	je     800637 <vprintfmt+0x27c>
  800614:	85 f6                	test   %esi,%esi
  800616:	78 a1                	js     8005b9 <vprintfmt+0x1fe>
  800618:	83 ee 01             	sub    $0x1,%esi
  80061b:	79 9c                	jns    8005b9 <vprintfmt+0x1fe>
  80061d:	89 df                	mov    %ebx,%edi
  80061f:	8b 75 08             	mov    0x8(%ebp),%esi
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	eb 18                	jmp    80063f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 20                	push   $0x20
  80062d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062f:	83 ef 01             	sub    $0x1,%edi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb 08                	jmp    80063f <vprintfmt+0x284>
  800637:	89 df                	mov    %ebx,%edi
  800639:	8b 75 08             	mov    0x8(%ebp),%esi
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063f:	85 ff                	test   %edi,%edi
  800641:	7f e4                	jg     800627 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800643:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064c:	e9 90 fd ff ff       	jmp    8003e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800651:	83 f9 01             	cmp    $0x1,%ecx
  800654:	7e 19                	jle    80066f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 50 04             	mov    0x4(%eax),%edx
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 40 08             	lea    0x8(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
  80066d:	eb 38                	jmp    8006a7 <vprintfmt+0x2ec>
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 1b                	je     80068e <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 c1                	mov    %eax,%ecx
  80067d:	c1 f9 1f             	sar    $0x1f,%ecx
  800680:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 40 04             	lea    0x4(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
  80068c:	eb 19                	jmp    8006a7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800696:	89 c1                	mov    %eax,%ecx
  800698:	c1 f9 1f             	sar    $0x1f,%ecx
  80069b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 40 04             	lea    0x4(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ad:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006b6:	0f 89 0e 01 00 00    	jns    8007ca <vprintfmt+0x40f>
				putch('-', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 2d                	push   $0x2d
  8006c2:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ca:	f7 da                	neg    %edx
  8006cc:	83 d1 00             	adc    $0x0,%ecx
  8006cf:	f7 d9                	neg    %ecx
  8006d1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d9:	e9 ec 00 00 00       	jmp    8007ca <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006de:	83 f9 01             	cmp    $0x1,%ecx
  8006e1:	7e 18                	jle    8006fb <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006eb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ee:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f6:	e9 cf 00 00 00       	jmp    8007ca <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	74 1a                	je     800719 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80070f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800714:	e9 b1 00 00 00       	jmp    8007ca <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800723:	8d 40 04             	lea    0x4(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	e9 97 00 00 00       	jmp    8007ca <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 58                	push   $0x58
  800739:	ff d6                	call   *%esi
			putch('X', putdat);
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 58                	push   $0x58
  800741:	ff d6                	call   *%esi
			putch('X', putdat);
  800743:	83 c4 08             	add    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 58                	push   $0x58
  800749:	ff d6                	call   *%esi
			break;
  80074b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800751:	e9 8b fc ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 30                	push   $0x30
  80075c:	ff d6                	call   *%esi
			putch('x', putdat);
  80075e:	83 c4 08             	add    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 78                	push   $0x78
  800764:	ff d6                	call   *%esi
			num = (unsigned long long)
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800770:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800773:	8d 40 04             	lea    0x4(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800779:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80077e:	eb 4a                	jmp    8007ca <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800780:	83 f9 01             	cmp    $0x1,%ecx
  800783:	7e 15                	jle    80079a <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	8b 48 04             	mov    0x4(%eax),%ecx
  80078d:	8d 40 08             	lea    0x8(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800793:	b8 10 00 00 00       	mov    $0x10,%eax
  800798:	eb 30                	jmp    8007ca <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	74 17                	je     8007b5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 10                	mov    (%eax),%edx
  8007a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a8:	8d 40 04             	lea    0x4(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b3:	eb 15                	jmp    8007ca <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 10                	mov    (%eax),%edx
  8007ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bf:	8d 40 04             	lea    0x4(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007c5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ca:	83 ec 0c             	sub    $0xc,%esp
  8007cd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007d1:	57                   	push   %edi
  8007d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d5:	50                   	push   %eax
  8007d6:	51                   	push   %ecx
  8007d7:	52                   	push   %edx
  8007d8:	89 da                	mov    %ebx,%edx
  8007da:	89 f0                	mov    %esi,%eax
  8007dc:	e8 f1 fa ff ff       	call   8002d2 <printnum>
			break;
  8007e1:	83 c4 20             	add    $0x20,%esp
  8007e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e7:	e9 f5 fb ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	52                   	push   %edx
  8007f1:	ff d6                	call   *%esi
			break;
  8007f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f9:	e9 e3 fb ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	6a 25                	push   $0x25
  800804:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	eb 03                	jmp    80080e <vprintfmt+0x453>
  80080b:	83 ef 01             	sub    $0x1,%edi
  80080e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800812:	75 f7                	jne    80080b <vprintfmt+0x450>
  800814:	e9 c8 fb ff ff       	jmp    8003e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800819:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 18             	sub    $0x18,%esp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800830:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800834:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083e:	85 c0                	test   %eax,%eax
  800840:	74 26                	je     800868 <vsnprintf+0x47>
  800842:	85 d2                	test   %edx,%edx
  800844:	7e 22                	jle    800868 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800846:	ff 75 14             	pushl  0x14(%ebp)
  800849:	ff 75 10             	pushl  0x10(%ebp)
  80084c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	68 81 03 80 00       	push   $0x800381
  800855:	e8 61 fb ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	eb 05                	jmp    80086d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800878:	50                   	push   %eax
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	ff 75 08             	pushl  0x8(%ebp)
  800882:	e8 9a ff ff ff       	call   800821 <vsnprintf>
	va_end(ap);

	return rc;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
  800894:	eb 03                	jmp    800899 <strlen+0x10>
		n++;
  800896:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800899:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089d:	75 f7                	jne    800896 <strlen+0xd>
		n++;
	return n;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8008af:	eb 03                	jmp    8008b4 <strnlen+0x13>
		n++;
  8008b1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b4:	39 c2                	cmp    %eax,%edx
  8008b6:	74 08                	je     8008c0 <strnlen+0x1f>
  8008b8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008bc:	75 f3                	jne    8008b1 <strnlen+0x10>
  8008be:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008db:	84 db                	test   %bl,%bl
  8008dd:	75 ef                	jne    8008ce <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e9:	53                   	push   %ebx
  8008ea:	e8 9a ff ff ff       	call   800889 <strlen>
  8008ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	01 d8                	add    %ebx,%eax
  8008f7:	50                   	push   %eax
  8008f8:	e8 c5 ff ff ff       	call   8008c2 <strcpy>
	return dst;
}
  8008fd:	89 d8                	mov    %ebx,%eax
  8008ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090f:	89 f3                	mov    %esi,%ebx
  800911:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800914:	89 f2                	mov    %esi,%edx
  800916:	eb 0f                	jmp    800927 <strncpy+0x23>
		*dst++ = *src;
  800918:	83 c2 01             	add    $0x1,%edx
  80091b:	0f b6 01             	movzbl (%ecx),%eax
  80091e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800921:	80 39 01             	cmpb   $0x1,(%ecx)
  800924:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800927:	39 da                	cmp    %ebx,%edx
  800929:	75 ed                	jne    800918 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80092b:	89 f0                	mov    %esi,%eax
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 75 08             	mov    0x8(%ebp),%esi
  800939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093c:	8b 55 10             	mov    0x10(%ebp),%edx
  80093f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800941:	85 d2                	test   %edx,%edx
  800943:	74 21                	je     800966 <strlcpy+0x35>
  800945:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800949:	89 f2                	mov    %esi,%edx
  80094b:	eb 09                	jmp    800956 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094d:	83 c2 01             	add    $0x1,%edx
  800950:	83 c1 01             	add    $0x1,%ecx
  800953:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800956:	39 c2                	cmp    %eax,%edx
  800958:	74 09                	je     800963 <strlcpy+0x32>
  80095a:	0f b6 19             	movzbl (%ecx),%ebx
  80095d:	84 db                	test   %bl,%bl
  80095f:	75 ec                	jne    80094d <strlcpy+0x1c>
  800961:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800963:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800966:	29 f0                	sub    %esi,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800975:	eb 06                	jmp    80097d <strcmp+0x11>
		p++, q++;
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	84 c0                	test   %al,%al
  800982:	74 04                	je     800988 <strcmp+0x1c>
  800984:	3a 02                	cmp    (%edx),%al
  800986:	74 ef                	je     800977 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 c0             	movzbl %al,%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strncmp+0x17>
		n--, p++, q++;
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	39 d8                	cmp    %ebx,%eax
  8009ab:	74 15                	je     8009c2 <strncmp+0x30>
  8009ad:	0f b6 08             	movzbl (%eax),%ecx
  8009b0:	84 c9                	test   %cl,%cl
  8009b2:	74 04                	je     8009b8 <strncmp+0x26>
  8009b4:	3a 0a                	cmp    (%edx),%cl
  8009b6:	74 eb                	je     8009a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
  8009c0:	eb 05                	jmp    8009c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 07                	jmp    8009dd <strchr+0x13>
		if (*s == c)
  8009d6:	38 ca                	cmp    %cl,%dl
  8009d8:	74 0f                	je     8009e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 f2                	jne    8009d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	eb 03                	jmp    8009fa <strfind+0xf>
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fd:	38 ca                	cmp    %cl,%dl
  8009ff:	74 04                	je     800a05 <strfind+0x1a>
  800a01:	84 d2                	test   %dl,%dl
  800a03:	75 f2                	jne    8009f7 <strfind+0xc>
			break;
	return (char *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a13:	85 c9                	test   %ecx,%ecx
  800a15:	74 36                	je     800a4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1d:	75 28                	jne    800a47 <memset+0x40>
  800a1f:	f6 c1 03             	test   $0x3,%cl
  800a22:	75 23                	jne    800a47 <memset+0x40>
		c &= 0xFF;
  800a24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a28:	89 d3                	mov    %edx,%ebx
  800a2a:	c1 e3 08             	shl    $0x8,%ebx
  800a2d:	89 d6                	mov    %edx,%esi
  800a2f:	c1 e6 18             	shl    $0x18,%esi
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	c1 e0 10             	shl    $0x10,%eax
  800a37:	09 f0                	or     %esi,%eax
  800a39:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	09 d0                	or     %edx,%eax
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
  800a42:	fc                   	cld    
  800a43:	f3 ab                	rep stos %eax,%es:(%edi)
  800a45:	eb 06                	jmp    800a4d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 35                	jae    800a9b <memmove+0x47>
  800a66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a69:	39 d0                	cmp    %edx,%eax
  800a6b:	73 2e                	jae    800a9b <memmove+0x47>
		s += n;
		d += n;
  800a6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	09 fe                	or     %edi,%esi
  800a74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7a:	75 13                	jne    800a8f <memmove+0x3b>
  800a7c:	f6 c1 03             	test   $0x3,%cl
  800a7f:	75 0e                	jne    800a8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a81:	83 ef 04             	sub    $0x4,%edi
  800a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a87:	c1 e9 02             	shr    $0x2,%ecx
  800a8a:	fd                   	std    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 09                	jmp    800a98 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a95:	fd                   	std    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a98:	fc                   	cld    
  800a99:	eb 1d                	jmp    800ab8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	89 f2                	mov    %esi,%edx
  800a9d:	09 c2                	or     %eax,%edx
  800a9f:	f6 c2 03             	test   $0x3,%dl
  800aa2:	75 0f                	jne    800ab3 <memmove+0x5f>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 0a                	jne    800ab3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
  800aac:	89 c7                	mov    %eax,%edi
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb 05                	jmp    800ab8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	fc                   	cld    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abf:	ff 75 10             	pushl  0x10(%ebp)
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	ff 75 08             	pushl  0x8(%ebp)
  800ac8:	e8 87 ff ff ff       	call   800a54 <memmove>
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ada:	89 c6                	mov    %eax,%esi
  800adc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adf:	eb 1a                	jmp    800afb <memcmp+0x2c>
		if (*s1 != *s2)
  800ae1:	0f b6 08             	movzbl (%eax),%ecx
  800ae4:	0f b6 1a             	movzbl (%edx),%ebx
  800ae7:	38 d9                	cmp    %bl,%cl
  800ae9:	74 0a                	je     800af5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aeb:	0f b6 c1             	movzbl %cl,%eax
  800aee:	0f b6 db             	movzbl %bl,%ebx
  800af1:	29 d8                	sub    %ebx,%eax
  800af3:	eb 0f                	jmp    800b04 <memcmp+0x35>
		s1++, s2++;
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 f0                	cmp    %esi,%eax
  800afd:	75 e2                	jne    800ae1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	53                   	push   %ebx
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0f:	89 c1                	mov    %eax,%ecx
  800b11:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b14:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b18:	eb 0a                	jmp    800b24 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1a:	0f b6 10             	movzbl (%eax),%edx
  800b1d:	39 da                	cmp    %ebx,%edx
  800b1f:	74 07                	je     800b28 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	39 c8                	cmp    %ecx,%eax
  800b26:	72 f2                	jb     800b1a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b28:	5b                   	pop    %ebx
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	eb 03                	jmp    800b3c <strtol+0x11>
		s++;
  800b39:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	3c 20                	cmp    $0x20,%al
  800b41:	74 f6                	je     800b39 <strtol+0xe>
  800b43:	3c 09                	cmp    $0x9,%al
  800b45:	74 f2                	je     800b39 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b47:	3c 2b                	cmp    $0x2b,%al
  800b49:	75 0a                	jne    800b55 <strtol+0x2a>
		s++;
  800b4b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b53:	eb 11                	jmp    800b66 <strtol+0x3b>
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	75 08                	jne    800b66 <strtol+0x3b>
		s++, neg = 1;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6c:	75 15                	jne    800b83 <strtol+0x58>
  800b6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b71:	75 10                	jne    800b83 <strtol+0x58>
  800b73:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b77:	75 7c                	jne    800bf5 <strtol+0xca>
		s += 2, base = 16;
  800b79:	83 c1 02             	add    $0x2,%ecx
  800b7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b81:	eb 16                	jmp    800b99 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	75 12                	jne    800b99 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b87:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8f:	75 08                	jne    800b99 <strtol+0x6e>
		s++, base = 8;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba1:	0f b6 11             	movzbl (%ecx),%edx
  800ba4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	80 fb 09             	cmp    $0x9,%bl
  800bac:	77 08                	ja     800bb6 <strtol+0x8b>
			dig = *s - '0';
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	83 ea 30             	sub    $0x30,%edx
  800bb4:	eb 22                	jmp    800bd8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb9:	89 f3                	mov    %esi,%ebx
  800bbb:	80 fb 19             	cmp    $0x19,%bl
  800bbe:	77 08                	ja     800bc8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bc0:	0f be d2             	movsbl %dl,%edx
  800bc3:	83 ea 57             	sub    $0x57,%edx
  800bc6:	eb 10                	jmp    800bd8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 16                	ja     800be8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd2:	0f be d2             	movsbl %dl,%edx
  800bd5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bdb:	7d 0b                	jge    800be8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be6:	eb b9                	jmp    800ba1 <strtol+0x76>

	if (endptr)
  800be8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bec:	74 0d                	je     800bfb <strtol+0xd0>
		*endptr = (char *) s;
  800bee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf1:	89 0e                	mov    %ecx,(%esi)
  800bf3:	eb 06                	jmp    800bfb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf5:	85 db                	test   %ebx,%ebx
  800bf7:	74 98                	je     800b91 <strtol+0x66>
  800bf9:	eb 9e                	jmp    800b99 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bfb:	89 c2                	mov    %eax,%edx
  800bfd:	f7 da                	neg    %edx
  800bff:	85 ff                	test   %edi,%edi
  800c01:	0f 45 c2             	cmovne %edx,%eax
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 c7                	mov    %eax,%edi
  800c1e:	89 c6                	mov    %eax,%esi
  800c20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 01 00 00 00       	mov    $0x1,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c54:	b8 03 00 00 00       	mov    $0x3,%eax
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 cb                	mov    %ecx,%ebx
  800c5e:	89 cf                	mov    %ecx,%edi
  800c60:	89 ce                	mov    %ecx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 03                	push   $0x3
  800c6e:	68 1f 24 80 00       	push   $0x80241f
  800c73:	6a 23                	push   $0x23
  800c75:	68 3c 24 80 00       	push   $0x80243c
  800c7a:	e8 66 f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 02 00 00 00       	mov    $0x2,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_yield>:

void
sys_yield(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce1:	89 f7                	mov    %esi,%edi
  800ce3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 04                	push   $0x4
  800cef:	68 1f 24 80 00       	push   $0x80241f
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 3c 24 80 00       	push   $0x80243c
  800cfb:	e8 e5 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800d11:	b8 05 00 00 00       	mov    $0x5,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	8b 75 18             	mov    0x18(%ebp),%esi
  800d25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 05                	push   $0x5
  800d31:	68 1f 24 80 00       	push   $0x80241f
  800d36:	6a 23                	push   $0x23
  800d38:	68 3c 24 80 00       	push   $0x80243c
  800d3d:	e8 a3 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 06                	push   $0x6
  800d73:	68 1f 24 80 00       	push   $0x80241f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 3c 24 80 00       	push   $0x80243c
  800d7f:	e8 61 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 17                	jle    800dc6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 08                	push   $0x8
  800db5:	68 1f 24 80 00       	push   $0x80241f
  800dba:	6a 23                	push   $0x23
  800dbc:	68 3c 24 80 00       	push   $0x80243c
  800dc1:	e8 1f f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	b8 09 00 00 00       	mov    $0x9,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	89 de                	mov    %ebx,%esi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 17                	jle    800e08 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 09                	push   $0x9
  800df7:	68 1f 24 80 00       	push   $0x80241f
  800dfc:	6a 23                	push   $0x23
  800dfe:	68 3c 24 80 00       	push   $0x80243c
  800e03:	e8 dd f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 df                	mov    %ebx,%edi
  800e2b:	89 de                	mov    %ebx,%esi
  800e2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 17                	jle    800e4a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	50                   	push   %eax
  800e37:	6a 0a                	push   $0xa
  800e39:	68 1f 24 80 00       	push   $0x80241f
  800e3e:	6a 23                	push   $0x23
  800e40:	68 3c 24 80 00       	push   $0x80243c
  800e45:	e8 9b f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	be 00 00 00 00       	mov    $0x0,%esi
  800e5d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	89 cb                	mov    %ecx,%ebx
  800e8d:	89 cf                	mov    %ecx,%edi
  800e8f:	89 ce                	mov    %ecx,%esi
  800e91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e93:	85 c0                	test   %eax,%eax
  800e95:	7e 17                	jle    800eae <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	6a 0d                	push   $0xd
  800e9d:	68 1f 24 80 00       	push   $0x80241f
  800ea2:	6a 23                	push   $0x23
  800ea4:	68 3c 24 80 00       	push   $0x80243c
  800ea9:	e8 37 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec1:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	c1 ea 16             	shr    $0x16,%edx
  800eed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef4:	f6 c2 01             	test   $0x1,%dl
  800ef7:	74 11                	je     800f0a <fd_alloc+0x2d>
  800ef9:	89 c2                	mov    %eax,%edx
  800efb:	c1 ea 0c             	shr    $0xc,%edx
  800efe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f05:	f6 c2 01             	test   $0x1,%dl
  800f08:	75 09                	jne    800f13 <fd_alloc+0x36>
			*fd_store = fd;
  800f0a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f11:	eb 17                	jmp    800f2a <fd_alloc+0x4d>
  800f13:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f18:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1d:	75 c9                	jne    800ee8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f1f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f25:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f32:	83 f8 1f             	cmp    $0x1f,%eax
  800f35:	77 36                	ja     800f6d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f37:	c1 e0 0c             	shl    $0xc,%eax
  800f3a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f3f:	89 c2                	mov    %eax,%edx
  800f41:	c1 ea 16             	shr    $0x16,%edx
  800f44:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4b:	f6 c2 01             	test   $0x1,%dl
  800f4e:	74 24                	je     800f74 <fd_lookup+0x48>
  800f50:	89 c2                	mov    %eax,%edx
  800f52:	c1 ea 0c             	shr    $0xc,%edx
  800f55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5c:	f6 c2 01             	test   $0x1,%dl
  800f5f:	74 1a                	je     800f7b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f64:	89 02                	mov    %eax,(%edx)
	return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb 13                	jmp    800f80 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f72:	eb 0c                	jmp    800f80 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f79:	eb 05                	jmp    800f80 <fd_lookup+0x54>
  800f7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8b:	ba cc 24 80 00       	mov    $0x8024cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f90:	eb 13                	jmp    800fa5 <dev_lookup+0x23>
  800f92:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f95:	39 08                	cmp    %ecx,(%eax)
  800f97:	75 0c                	jne    800fa5 <dev_lookup+0x23>
			*dev = devtab[i];
  800f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa3:	eb 2e                	jmp    800fd3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fa5:	8b 02                	mov    (%edx),%eax
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	75 e7                	jne    800f92 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fab:	a1 08 40 80 00       	mov    0x804008,%eax
  800fb0:	8b 40 48             	mov    0x48(%eax),%eax
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	51                   	push   %ecx
  800fb7:	50                   	push   %eax
  800fb8:	68 4c 24 80 00       	push   $0x80244c
  800fbd:	e8 fc f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 10             	sub    $0x10,%esp
  800fdd:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fed:	c1 e8 0c             	shr    $0xc,%eax
  800ff0:	50                   	push   %eax
  800ff1:	e8 36 ff ff ff       	call   800f2c <fd_lookup>
  800ff6:	83 c4 08             	add    $0x8,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 05                	js     801002 <fd_close+0x2d>
	    || fd != fd2)
  800ffd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801000:	74 0c                	je     80100e <fd_close+0x39>
		return (must_exist ? r : 0);
  801002:	84 db                	test   %bl,%bl
  801004:	ba 00 00 00 00       	mov    $0x0,%edx
  801009:	0f 44 c2             	cmove  %edx,%eax
  80100c:	eb 41                	jmp    80104f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	ff 36                	pushl  (%esi)
  801017:	e8 66 ff ff ff       	call   800f82 <dev_lookup>
  80101c:	89 c3                	mov    %eax,%ebx
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 1a                	js     80103f <fd_close+0x6a>
		if (dev->dev_close)
  801025:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801028:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801030:	85 c0                	test   %eax,%eax
  801032:	74 0b                	je     80103f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	56                   	push   %esi
  801038:	ff d0                	call   *%eax
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	56                   	push   %esi
  801043:	6a 00                	push   $0x0
  801045:	e8 00 fd ff ff       	call   800d4a <sys_page_unmap>
	return r;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	89 d8                	mov    %ebx,%eax
}
  80104f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105f:	50                   	push   %eax
  801060:	ff 75 08             	pushl  0x8(%ebp)
  801063:	e8 c4 fe ff ff       	call   800f2c <fd_lookup>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 10                	js     80107f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	6a 01                	push   $0x1
  801074:	ff 75 f4             	pushl  -0xc(%ebp)
  801077:	e8 59 ff ff ff       	call   800fd5 <fd_close>
  80107c:	83 c4 10             	add    $0x10,%esp
}
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <close_all>:

void
close_all(void)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	53                   	push   %ebx
  801085:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801088:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	53                   	push   %ebx
  801091:	e8 c0 ff ff ff       	call   801056 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801096:	83 c3 01             	add    $0x1,%ebx
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	83 fb 20             	cmp    $0x20,%ebx
  80109f:	75 ec                	jne    80108d <close_all+0xc>
		close(i);
}
  8010a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 2c             	sub    $0x2c,%esp
  8010af:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 6e fe ff ff       	call   800f2c <fd_lookup>
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	0f 88 c1 00 00 00    	js     80118a <dup+0xe4>
		return r;
	close(newfdnum);
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	56                   	push   %esi
  8010cd:	e8 84 ff ff ff       	call   801056 <close>

	newfd = INDEX2FD(newfdnum);
  8010d2:	89 f3                	mov    %esi,%ebx
  8010d4:	c1 e3 0c             	shl    $0xc,%ebx
  8010d7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010dd:	83 c4 04             	add    $0x4,%esp
  8010e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e3:	e8 de fd ff ff       	call   800ec6 <fd2data>
  8010e8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010ea:	89 1c 24             	mov    %ebx,(%esp)
  8010ed:	e8 d4 fd ff ff       	call   800ec6 <fd2data>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f8:	89 f8                	mov    %edi,%eax
  8010fa:	c1 e8 16             	shr    $0x16,%eax
  8010fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801104:	a8 01                	test   $0x1,%al
  801106:	74 37                	je     80113f <dup+0x99>
  801108:	89 f8                	mov    %edi,%eax
  80110a:	c1 e8 0c             	shr    $0xc,%eax
  80110d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801114:	f6 c2 01             	test   $0x1,%dl
  801117:	74 26                	je     80113f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801119:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	25 07 0e 00 00       	and    $0xe07,%eax
  801128:	50                   	push   %eax
  801129:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112c:	6a 00                	push   $0x0
  80112e:	57                   	push   %edi
  80112f:	6a 00                	push   $0x0
  801131:	e8 d2 fb ff ff       	call   800d08 <sys_page_map>
  801136:	89 c7                	mov    %eax,%edi
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 2e                	js     80116d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801142:	89 d0                	mov    %edx,%eax
  801144:	c1 e8 0c             	shr    $0xc,%eax
  801147:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	25 07 0e 00 00       	and    $0xe07,%eax
  801156:	50                   	push   %eax
  801157:	53                   	push   %ebx
  801158:	6a 00                	push   $0x0
  80115a:	52                   	push   %edx
  80115b:	6a 00                	push   $0x0
  80115d:	e8 a6 fb ff ff       	call   800d08 <sys_page_map>
  801162:	89 c7                	mov    %eax,%edi
  801164:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801167:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801169:	85 ff                	test   %edi,%edi
  80116b:	79 1d                	jns    80118a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	53                   	push   %ebx
  801171:	6a 00                	push   $0x0
  801173:	e8 d2 fb ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117e:	6a 00                	push   $0x0
  801180:	e8 c5 fb ff ff       	call   800d4a <sys_page_unmap>
	return r;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	89 f8                	mov    %edi,%eax
}
  80118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	53                   	push   %ebx
  801196:	83 ec 14             	sub    $0x14,%esp
  801199:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	53                   	push   %ebx
  8011a1:	e8 86 fd ff ff       	call   800f2c <fd_lookup>
  8011a6:	83 c4 08             	add    $0x8,%esp
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 6d                	js     80121c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	ff 30                	pushl  (%eax)
  8011bb:	e8 c2 fd ff ff       	call   800f82 <dev_lookup>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 4c                	js     801213 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ca:	8b 42 08             	mov    0x8(%edx),%eax
  8011cd:	83 e0 03             	and    $0x3,%eax
  8011d0:	83 f8 01             	cmp    $0x1,%eax
  8011d3:	75 21                	jne    8011f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8011da:	8b 40 48             	mov    0x48(%eax),%eax
  8011dd:	83 ec 04             	sub    $0x4,%esp
  8011e0:	53                   	push   %ebx
  8011e1:	50                   	push   %eax
  8011e2:	68 90 24 80 00       	push   $0x802490
  8011e7:	e8 d2 f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f4:	eb 26                	jmp    80121c <read+0x8a>
	}
	if (!dev->dev_read)
  8011f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f9:	8b 40 08             	mov    0x8(%eax),%eax
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	74 17                	je     801217 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	ff 75 10             	pushl  0x10(%ebp)
  801206:	ff 75 0c             	pushl  0xc(%ebp)
  801209:	52                   	push   %edx
  80120a:	ff d0                	call   *%eax
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	eb 09                	jmp    80121c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	89 c2                	mov    %eax,%edx
  801215:	eb 05                	jmp    80121c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801217:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80121c:	89 d0                	mov    %edx,%eax
  80121e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	57                   	push   %edi
  801227:	56                   	push   %esi
  801228:	53                   	push   %ebx
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801232:	bb 00 00 00 00       	mov    $0x0,%ebx
  801237:	eb 21                	jmp    80125a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	89 f0                	mov    %esi,%eax
  80123e:	29 d8                	sub    %ebx,%eax
  801240:	50                   	push   %eax
  801241:	89 d8                	mov    %ebx,%eax
  801243:	03 45 0c             	add    0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	57                   	push   %edi
  801248:	e8 45 ff ff ff       	call   801192 <read>
		if (m < 0)
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 10                	js     801264 <readn+0x41>
			return m;
		if (m == 0)
  801254:	85 c0                	test   %eax,%eax
  801256:	74 0a                	je     801262 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801258:	01 c3                	add    %eax,%ebx
  80125a:	39 f3                	cmp    %esi,%ebx
  80125c:	72 db                	jb     801239 <readn+0x16>
  80125e:	89 d8                	mov    %ebx,%eax
  801260:	eb 02                	jmp    801264 <readn+0x41>
  801262:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 14             	sub    $0x14,%esp
  801273:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	53                   	push   %ebx
  80127b:	e8 ac fc ff ff       	call   800f2c <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 c0                	test   %eax,%eax
  801287:	78 68                	js     8012f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	ff 30                	pushl  (%eax)
  801295:	e8 e8 fc ff ff       	call   800f82 <dev_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 47                	js     8012e8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a8:	75 21                	jne    8012cb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	68 ac 24 80 00       	push   $0x8024ac
  8012bc:	e8 fd ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c9:	eb 26                	jmp    8012f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d1:	85 d2                	test   %edx,%edx
  8012d3:	74 17                	je     8012ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d5:	83 ec 04             	sub    $0x4,%esp
  8012d8:	ff 75 10             	pushl  0x10(%ebp)
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	50                   	push   %eax
  8012df:	ff d2                	call   *%edx
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	eb 09                	jmp    8012f1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	eb 05                	jmp    8012f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012f1:	89 d0                	mov    %edx,%eax
  8012f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 22 fc ff ff       	call   800f2c <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 0e                	js     80131f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801311:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	53                   	push   %ebx
  801325:	83 ec 14             	sub    $0x14,%esp
  801328:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	53                   	push   %ebx
  801330:	e8 f7 fb ff ff       	call   800f2c <fd_lookup>
  801335:	83 c4 08             	add    $0x8,%esp
  801338:	89 c2                	mov    %eax,%edx
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 65                	js     8013a3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801348:	ff 30                	pushl  (%eax)
  80134a:	e8 33 fc ff ff       	call   800f82 <dev_lookup>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 44                	js     80139a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801359:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135d:	75 21                	jne    801380 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80135f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801364:	8b 40 48             	mov    0x48(%eax),%eax
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	53                   	push   %ebx
  80136b:	50                   	push   %eax
  80136c:	68 6c 24 80 00       	push   $0x80246c
  801371:	e8 48 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80137e:	eb 23                	jmp    8013a3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801380:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801383:	8b 52 18             	mov    0x18(%edx),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	74 14                	je     80139e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	ff 75 0c             	pushl  0xc(%ebp)
  801390:	50                   	push   %eax
  801391:	ff d2                	call   *%edx
  801393:	89 c2                	mov    %eax,%edx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	eb 09                	jmp    8013a3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	eb 05                	jmp    8013a3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a3:	89 d0                	mov    %edx,%eax
  8013a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 14             	sub    $0x14,%esp
  8013b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	ff 75 08             	pushl  0x8(%ebp)
  8013bb:	e8 6c fb ff ff       	call   800f2c <fd_lookup>
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 58                	js     801421 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d3:	ff 30                	pushl  (%eax)
  8013d5:	e8 a8 fb ff ff       	call   800f82 <dev_lookup>
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 37                	js     801418 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e8:	74 32                	je     80141c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f4:	00 00 00 
	stat->st_isdir = 0;
  8013f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013fe:	00 00 00 
	stat->st_dev = dev;
  801401:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	53                   	push   %ebx
  80140b:	ff 75 f0             	pushl  -0x10(%ebp)
  80140e:	ff 50 14             	call   *0x14(%eax)
  801411:	89 c2                	mov    %eax,%edx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	eb 09                	jmp    801421 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801418:	89 c2                	mov    %eax,%edx
  80141a:	eb 05                	jmp    801421 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80141c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801421:	89 d0                	mov    %edx,%eax
  801423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	6a 00                	push   $0x0
  801432:	ff 75 08             	pushl  0x8(%ebp)
  801435:	e8 e9 01 00 00       	call   801623 <open>
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 1b                	js     80145e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	50                   	push   %eax
  80144a:	e8 5b ff ff ff       	call   8013aa <fstat>
  80144f:	89 c6                	mov    %eax,%esi
	close(fd);
  801451:	89 1c 24             	mov    %ebx,(%esp)
  801454:	e8 fd fb ff ff       	call   801056 <close>
	return r;
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	89 f0                	mov    %esi,%eax
}
  80145e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	56                   	push   %esi
  801469:	53                   	push   %ebx
  80146a:	89 c6                	mov    %eax,%esi
  80146c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801475:	75 12                	jne    801489 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801477:	83 ec 0c             	sub    $0xc,%esp
  80147a:	6a 01                	push   $0x1
  80147c:	e8 0b 09 00 00       	call   801d8c <ipc_find_env>
  801481:	a3 04 40 80 00       	mov    %eax,0x804004
  801486:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801489:	6a 07                	push   $0x7
  80148b:	68 00 50 80 00       	push   $0x805000
  801490:	56                   	push   %esi
  801491:	ff 35 04 40 80 00    	pushl  0x804004
  801497:	e8 9c 08 00 00       	call   801d38 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80149c:	83 c4 0c             	add    $0xc,%esp
  80149f:	6a 00                	push   $0x0
  8014a1:	53                   	push   %ebx
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 0d 08 00 00       	call   801cb6 <ipc_recv>
}
  8014a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d3:	e8 8d ff ff ff       	call   801465 <fsipc>
}
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014f5:	e8 6b ff ff ff       	call   801465 <fsipc>
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 40 0c             	mov    0xc(%eax),%eax
  80150c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 05 00 00 00       	mov    $0x5,%eax
  80151b:	e8 45 ff ff ff       	call   801465 <fsipc>
  801520:	85 c0                	test   %eax,%eax
  801522:	78 2c                	js     801550 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	68 00 50 80 00       	push   $0x805000
  80152c:	53                   	push   %ebx
  80152d:	e8 90 f3 ff ff       	call   8008c2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801532:	a1 80 50 80 00       	mov    0x805080,%eax
  801537:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80153d:	a1 84 50 80 00       	mov    0x805084,%eax
  801542:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	8b 45 10             	mov    0x10(%ebp),%eax
  80155e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801563:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801568:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80156b:	8b 55 08             	mov    0x8(%ebp),%edx
  80156e:	8b 52 0c             	mov    0xc(%edx),%edx
  801571:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801577:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80157c:	50                   	push   %eax
  80157d:	ff 75 0c             	pushl  0xc(%ebp)
  801580:	68 08 50 80 00       	push   $0x805008
  801585:	e8 ca f4 ff ff       	call   800a54 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80158a:	ba 00 00 00 00       	mov    $0x0,%edx
  80158f:	b8 04 00 00 00       	mov    $0x4,%eax
  801594:	e8 cc fe ff ff       	call   801465 <fsipc>
            return r;

    return r;
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015ae:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8015be:	e8 a2 fe ff ff       	call   801465 <fsipc>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 51                	js     80161a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8015c9:	39 c6                	cmp    %eax,%esi
  8015cb:	73 19                	jae    8015e6 <devfile_read+0x4b>
  8015cd:	68 dc 24 80 00       	push   $0x8024dc
  8015d2:	68 e3 24 80 00       	push   $0x8024e3
  8015d7:	68 82 00 00 00       	push   $0x82
  8015dc:	68 f8 24 80 00       	push   $0x8024f8
  8015e1:	e8 ff eb ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  8015e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015eb:	7e 19                	jle    801606 <devfile_read+0x6b>
  8015ed:	68 03 25 80 00       	push   $0x802503
  8015f2:	68 e3 24 80 00       	push   $0x8024e3
  8015f7:	68 83 00 00 00       	push   $0x83
  8015fc:	68 f8 24 80 00       	push   $0x8024f8
  801601:	e8 df eb ff ff       	call   8001e5 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801606:	83 ec 04             	sub    $0x4,%esp
  801609:	50                   	push   %eax
  80160a:	68 00 50 80 00       	push   $0x805000
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	e8 3d f4 ff ff       	call   800a54 <memmove>
	return r;
  801617:	83 c4 10             	add    $0x10,%esp
}
  80161a:	89 d8                	mov    %ebx,%eax
  80161c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 20             	sub    $0x20,%esp
  80162a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80162d:	53                   	push   %ebx
  80162e:	e8 56 f2 ff ff       	call   800889 <strlen>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80163b:	7f 67                	jg     8016a4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163d:	83 ec 0c             	sub    $0xc,%esp
  801640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	e8 94 f8 ff ff       	call   800edd <fd_alloc>
  801649:	83 c4 10             	add    $0x10,%esp
		return r;
  80164c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 57                	js     8016a9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	53                   	push   %ebx
  801656:	68 00 50 80 00       	push   $0x805000
  80165b:	e8 62 f2 ff ff       	call   8008c2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801660:	8b 45 0c             	mov    0xc(%ebp),%eax
  801663:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801668:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166b:	b8 01 00 00 00       	mov    $0x1,%eax
  801670:	e8 f0 fd ff ff       	call   801465 <fsipc>
  801675:	89 c3                	mov    %eax,%ebx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	79 14                	jns    801692 <open+0x6f>
		fd_close(fd, 0);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	6a 00                	push   $0x0
  801683:	ff 75 f4             	pushl  -0xc(%ebp)
  801686:	e8 4a f9 ff ff       	call   800fd5 <fd_close>
		return r;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	89 da                	mov    %ebx,%edx
  801690:	eb 17                	jmp    8016a9 <open+0x86>
	}

	return fd2num(fd);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	ff 75 f4             	pushl  -0xc(%ebp)
  801698:	e8 19 f8 ff ff       	call   800eb6 <fd2num>
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 05                	jmp    8016a9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c0:	e8 a0 fd ff ff       	call   801465 <fsipc>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016c7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016cb:	7e 37                	jle    801704 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016d6:	ff 70 04             	pushl  0x4(%eax)
  8016d9:	8d 40 10             	lea    0x10(%eax),%eax
  8016dc:	50                   	push   %eax
  8016dd:	ff 33                	pushl  (%ebx)
  8016df:	e8 88 fb ff ff       	call   80126c <write>
		if (result > 0)
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	7e 03                	jle    8016ee <writebuf+0x27>
			b->result += result;
  8016eb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016ee:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016f1:	74 0d                	je     801700 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	0f 4f c2             	cmovg  %edx,%eax
  8016fd:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	f3 c3                	repz ret 

00801706 <putch>:

static void
putch(int ch, void *thunk)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 04             	sub    $0x4,%esp
  80170d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801710:	8b 53 04             	mov    0x4(%ebx),%edx
  801713:	8d 42 01             	lea    0x1(%edx),%eax
  801716:	89 43 04             	mov    %eax,0x4(%ebx)
  801719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801720:	3d 00 01 00 00       	cmp    $0x100,%eax
  801725:	75 0e                	jne    801735 <putch+0x2f>
		writebuf(b);
  801727:	89 d8                	mov    %ebx,%eax
  801729:	e8 99 ff ff ff       	call   8016c7 <writebuf>
		b->idx = 0;
  80172e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801735:	83 c4 04             	add    $0x4,%esp
  801738:	5b                   	pop    %ebx
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80174d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801754:	00 00 00 
	b.result = 0;
  801757:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80175e:	00 00 00 
	b.error = 1;
  801761:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801768:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80176b:	ff 75 10             	pushl  0x10(%ebp)
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	68 06 17 80 00       	push   $0x801706
  80177d:	e8 39 ec ff ff       	call   8003bb <vprintfmt>
	if (b.idx > 0)
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80178c:	7e 0b                	jle    801799 <vfprintf+0x5e>
		writebuf(&b);
  80178e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801794:	e8 2e ff ff ff       	call   8016c7 <writebuf>

	return (b.result ? b.result : b.error);
  801799:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017b0:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017b3:	50                   	push   %eax
  8017b4:	ff 75 0c             	pushl  0xc(%ebp)
  8017b7:	ff 75 08             	pushl  0x8(%ebp)
  8017ba:	e8 7c ff ff ff       	call   80173b <vfprintf>
	va_end(ap);

	return cnt;
}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <printf>:

int
printf(const char *fmt, ...)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017ca:	50                   	push   %eax
  8017cb:	ff 75 08             	pushl  0x8(%ebp)
  8017ce:	6a 01                	push   $0x1
  8017d0:	e8 66 ff ff ff       	call   80173b <vfprintf>
	va_end(ap);

	return cnt;
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017df:	83 ec 0c             	sub    $0xc,%esp
  8017e2:	ff 75 08             	pushl  0x8(%ebp)
  8017e5:	e8 dc f6 ff ff       	call   800ec6 <fd2data>
  8017ea:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017ec:	83 c4 08             	add    $0x8,%esp
  8017ef:	68 0f 25 80 00       	push   $0x80250f
  8017f4:	53                   	push   %ebx
  8017f5:	e8 c8 f0 ff ff       	call   8008c2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017fa:	8b 46 04             	mov    0x4(%esi),%eax
  8017fd:	2b 06                	sub    (%esi),%eax
  8017ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801805:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80180c:	00 00 00 
	stat->st_dev = &devpipe;
  80180f:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801816:	30 80 00 
	return 0;
}
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
  80181e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801821:	5b                   	pop    %ebx
  801822:	5e                   	pop    %esi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	53                   	push   %ebx
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80182f:	53                   	push   %ebx
  801830:	6a 00                	push   $0x0
  801832:	e8 13 f5 ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801837:	89 1c 24             	mov    %ebx,(%esp)
  80183a:	e8 87 f6 ff ff       	call   800ec6 <fd2data>
  80183f:	83 c4 08             	add    $0x8,%esp
  801842:	50                   	push   %eax
  801843:	6a 00                	push   $0x0
  801845:	e8 00 f5 ff ff       	call   800d4a <sys_page_unmap>
}
  80184a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	57                   	push   %edi
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 1c             	sub    $0x1c,%esp
  801858:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80185b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80185d:	a1 08 40 80 00       	mov    0x804008,%eax
  801862:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801865:	83 ec 0c             	sub    $0xc,%esp
  801868:	ff 75 e0             	pushl  -0x20(%ebp)
  80186b:	e8 55 05 00 00       	call   801dc5 <pageref>
  801870:	89 c3                	mov    %eax,%ebx
  801872:	89 3c 24             	mov    %edi,(%esp)
  801875:	e8 4b 05 00 00       	call   801dc5 <pageref>
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	39 c3                	cmp    %eax,%ebx
  80187f:	0f 94 c1             	sete   %cl
  801882:	0f b6 c9             	movzbl %cl,%ecx
  801885:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801888:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80188e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801891:	39 ce                	cmp    %ecx,%esi
  801893:	74 1b                	je     8018b0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801895:	39 c3                	cmp    %eax,%ebx
  801897:	75 c4                	jne    80185d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801899:	8b 42 58             	mov    0x58(%edx),%eax
  80189c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80189f:	50                   	push   %eax
  8018a0:	56                   	push   %esi
  8018a1:	68 16 25 80 00       	push   $0x802516
  8018a6:	e8 13 ea ff ff       	call   8002be <cprintf>
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	eb ad                	jmp    80185d <_pipeisclosed+0xe>
	}
}
  8018b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b6:	5b                   	pop    %ebx
  8018b7:	5e                   	pop    %esi
  8018b8:	5f                   	pop    %edi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	57                   	push   %edi
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	83 ec 28             	sub    $0x28,%esp
  8018c4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018c7:	56                   	push   %esi
  8018c8:	e8 f9 f5 ff ff       	call   800ec6 <fd2data>
  8018cd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8018d7:	eb 4b                	jmp    801924 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018d9:	89 da                	mov    %ebx,%edx
  8018db:	89 f0                	mov    %esi,%eax
  8018dd:	e8 6d ff ff ff       	call   80184f <_pipeisclosed>
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	75 48                	jne    80192e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018e6:	e8 bb f3 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ee:	8b 0b                	mov    (%ebx),%ecx
  8018f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8018f3:	39 d0                	cmp    %edx,%eax
  8018f5:	73 e2                	jae    8018d9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801901:	89 c2                	mov    %eax,%edx
  801903:	c1 fa 1f             	sar    $0x1f,%edx
  801906:	89 d1                	mov    %edx,%ecx
  801908:	c1 e9 1b             	shr    $0x1b,%ecx
  80190b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80190e:	83 e2 1f             	and    $0x1f,%edx
  801911:	29 ca                	sub    %ecx,%edx
  801913:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801917:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80191b:	83 c0 01             	add    $0x1,%eax
  80191e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801921:	83 c7 01             	add    $0x1,%edi
  801924:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801927:	75 c2                	jne    8018eb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801929:	8b 45 10             	mov    0x10(%ebp),%eax
  80192c:	eb 05                	jmp    801933 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801933:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5f                   	pop    %edi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 18             	sub    $0x18,%esp
  801944:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801947:	57                   	push   %edi
  801948:	e8 79 f5 ff ff       	call   800ec6 <fd2data>
  80194d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	bb 00 00 00 00       	mov    $0x0,%ebx
  801957:	eb 3d                	jmp    801996 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801959:	85 db                	test   %ebx,%ebx
  80195b:	74 04                	je     801961 <devpipe_read+0x26>
				return i;
  80195d:	89 d8                	mov    %ebx,%eax
  80195f:	eb 44                	jmp    8019a5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801961:	89 f2                	mov    %esi,%edx
  801963:	89 f8                	mov    %edi,%eax
  801965:	e8 e5 fe ff ff       	call   80184f <_pipeisclosed>
  80196a:	85 c0                	test   %eax,%eax
  80196c:	75 32                	jne    8019a0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80196e:	e8 33 f3 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801973:	8b 06                	mov    (%esi),%eax
  801975:	3b 46 04             	cmp    0x4(%esi),%eax
  801978:	74 df                	je     801959 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80197a:	99                   	cltd   
  80197b:	c1 ea 1b             	shr    $0x1b,%edx
  80197e:	01 d0                	add    %edx,%eax
  801980:	83 e0 1f             	and    $0x1f,%eax
  801983:	29 d0                	sub    %edx,%eax
  801985:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80198a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801990:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801993:	83 c3 01             	add    $0x1,%ebx
  801996:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801999:	75 d8                	jne    801973 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80199b:	8b 45 10             	mov    0x10(%ebp),%eax
  80199e:	eb 05                	jmp    8019a5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5f                   	pop    %edi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b8:	50                   	push   %eax
  8019b9:	e8 1f f5 ff ff       	call   800edd <fd_alloc>
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	0f 88 2c 01 00 00    	js     801af7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019cb:	83 ec 04             	sub    $0x4,%esp
  8019ce:	68 07 04 00 00       	push   $0x407
  8019d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 e8 f2 ff ff       	call   800cc5 <sys_page_alloc>
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	0f 88 0d 01 00 00    	js     801af7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	e8 e7 f4 ff ff       	call   800edd <fd_alloc>
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	0f 88 e2 00 00 00    	js     801ae5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a03:	83 ec 04             	sub    $0x4,%esp
  801a06:	68 07 04 00 00       	push   $0x407
  801a0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a0e:	6a 00                	push   $0x0
  801a10:	e8 b0 f2 ff ff       	call   800cc5 <sys_page_alloc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	0f 88 c3 00 00 00    	js     801ae5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	ff 75 f4             	pushl  -0xc(%ebp)
  801a28:	e8 99 f4 ff ff       	call   800ec6 <fd2data>
  801a2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a2f:	83 c4 0c             	add    $0xc,%esp
  801a32:	68 07 04 00 00       	push   $0x407
  801a37:	50                   	push   %eax
  801a38:	6a 00                	push   $0x0
  801a3a:	e8 86 f2 ff ff       	call   800cc5 <sys_page_alloc>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	85 c0                	test   %eax,%eax
  801a46:	0f 88 89 00 00 00    	js     801ad5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a52:	e8 6f f4 ff ff       	call   800ec6 <fd2data>
  801a57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a5e:	50                   	push   %eax
  801a5f:	6a 00                	push   $0x0
  801a61:	56                   	push   %esi
  801a62:	6a 00                	push   $0x0
  801a64:	e8 9f f2 ff ff       	call   800d08 <sys_page_map>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 20             	add    $0x20,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 55                	js     801ac7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a72:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a87:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a90:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa2:	e8 0f f4 ff ff       	call   800eb6 <fd2num>
  801aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aaa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aac:	83 c4 04             	add    $0x4,%esp
  801aaf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab2:	e8 ff f3 ff ff       	call   800eb6 <fd2num>
  801ab7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac5:	eb 30                	jmp    801af7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	56                   	push   %esi
  801acb:	6a 00                	push   $0x0
  801acd:	e8 78 f2 ff ff       	call   800d4a <sys_page_unmap>
  801ad2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ad5:	83 ec 08             	sub    $0x8,%esp
  801ad8:	ff 75 f0             	pushl  -0x10(%ebp)
  801adb:	6a 00                	push   $0x0
  801add:	e8 68 f2 ff ff       	call   800d4a <sys_page_unmap>
  801ae2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ae5:	83 ec 08             	sub    $0x8,%esp
  801ae8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 58 f2 ff ff       	call   800d4a <sys_page_unmap>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801af7:	89 d0                	mov    %edx,%eax
  801af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b09:	50                   	push   %eax
  801b0a:	ff 75 08             	pushl  0x8(%ebp)
  801b0d:	e8 1a f4 ff ff       	call   800f2c <fd_lookup>
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 18                	js     801b31 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1f:	e8 a2 f3 ff ff       	call   800ec6 <fd2data>
	return _pipeisclosed(fd, p);
  801b24:	89 c2                	mov    %eax,%edx
  801b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b29:	e8 21 fd ff ff       	call   80184f <_pipeisclosed>
  801b2e:	83 c4 10             	add    $0x10,%esp
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b43:	68 2e 25 80 00       	push   $0x80252e
  801b48:	ff 75 0c             	pushl  0xc(%ebp)
  801b4b:	e8 72 ed ff ff       	call   8008c2 <strcpy>
	return 0;
}
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	57                   	push   %edi
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b63:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b68:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b6e:	eb 2d                	jmp    801b9d <devcons_write+0x46>
		m = n - tot;
  801b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b73:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b75:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b78:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b7d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b80:	83 ec 04             	sub    $0x4,%esp
  801b83:	53                   	push   %ebx
  801b84:	03 45 0c             	add    0xc(%ebp),%eax
  801b87:	50                   	push   %eax
  801b88:	57                   	push   %edi
  801b89:	e8 c6 ee ff ff       	call   800a54 <memmove>
		sys_cputs(buf, m);
  801b8e:	83 c4 08             	add    $0x8,%esp
  801b91:	53                   	push   %ebx
  801b92:	57                   	push   %edi
  801b93:	e8 71 f0 ff ff       	call   800c09 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b98:	01 de                	add    %ebx,%esi
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	89 f0                	mov    %esi,%eax
  801b9f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ba2:	72 cc                	jb     801b70 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5f                   	pop    %edi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 08             	sub    $0x8,%esp
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bbb:	74 2a                	je     801be7 <devcons_read+0x3b>
  801bbd:	eb 05                	jmp    801bc4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bbf:	e8 e2 f0 ff ff       	call   800ca6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bc4:	e8 5e f0 ff ff       	call   800c27 <sys_cgetc>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	74 f2                	je     801bbf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 16                	js     801be7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bd1:	83 f8 04             	cmp    $0x4,%eax
  801bd4:	74 0c                	je     801be2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd9:	88 02                	mov    %al,(%edx)
	return 1;
  801bdb:	b8 01 00 00 00       	mov    $0x1,%eax
  801be0:	eb 05                	jmp    801be7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801be2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bf5:	6a 01                	push   $0x1
  801bf7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bfa:	50                   	push   %eax
  801bfb:	e8 09 f0 ff ff       	call   800c09 <sys_cputs>
}
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <getchar>:

int
getchar(void)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c0b:	6a 01                	push   $0x1
  801c0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c10:	50                   	push   %eax
  801c11:	6a 00                	push   $0x0
  801c13:	e8 7a f5 ff ff       	call   801192 <read>
	if (r < 0)
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 0f                	js     801c2e <getchar+0x29>
		return r;
	if (r < 1)
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	7e 06                	jle    801c29 <getchar+0x24>
		return -E_EOF;
	return c;
  801c23:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c27:	eb 05                	jmp    801c2e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c29:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c39:	50                   	push   %eax
  801c3a:	ff 75 08             	pushl  0x8(%ebp)
  801c3d:	e8 ea f2 ff ff       	call   800f2c <fd_lookup>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 11                	js     801c5a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c52:	39 10                	cmp    %edx,(%eax)
  801c54:	0f 94 c0             	sete   %al
  801c57:	0f b6 c0             	movzbl %al,%eax
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <opencons>:

int
opencons(void)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c65:	50                   	push   %eax
  801c66:	e8 72 f2 ff ff       	call   800edd <fd_alloc>
  801c6b:	83 c4 10             	add    $0x10,%esp
		return r;
  801c6e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 3e                	js     801cb2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 3f f0 ff ff       	call   800cc5 <sys_page_alloc>
  801c86:	83 c4 10             	add    $0x10,%esp
		return r;
  801c89:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 23                	js     801cb2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c8f:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c98:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ca4:	83 ec 0c             	sub    $0xc,%esp
  801ca7:	50                   	push   %eax
  801ca8:	e8 09 f2 ff ff       	call   800eb6 <fd2num>
  801cad:	89 c2                	mov    %eax,%edx
  801caf:	83 c4 10             	add    $0x10,%esp
}
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	57                   	push   %edi
  801cba:	56                   	push   %esi
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801cc8:	85 f6                	test   %esi,%esi
  801cca:	74 06                	je     801cd2 <ipc_recv+0x1c>
		*from_env_store = 0;
  801ccc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801cd2:	85 db                	test   %ebx,%ebx
  801cd4:	74 06                	je     801cdc <ipc_recv+0x26>
		*perm_store = 0;
  801cd6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801cdc:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801cde:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ce3:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	50                   	push   %eax
  801cea:	e8 86 f1 ff ff       	call   800e75 <sys_ipc_recv>
  801cef:	89 c7                	mov    %eax,%edi
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	79 14                	jns    801d0c <ipc_recv+0x56>
		cprintf("im dead");
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	68 3a 25 80 00       	push   $0x80253a
  801d00:	e8 b9 e5 ff ff       	call   8002be <cprintf>
		return r;
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	89 f8                	mov    %edi,%eax
  801d0a:	eb 24                	jmp    801d30 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801d0c:	85 f6                	test   %esi,%esi
  801d0e:	74 0a                	je     801d1a <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801d10:	a1 08 40 80 00       	mov    0x804008,%eax
  801d15:	8b 40 74             	mov    0x74(%eax),%eax
  801d18:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801d1a:	85 db                	test   %ebx,%ebx
  801d1c:	74 0a                	je     801d28 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801d1e:	a1 08 40 80 00       	mov    0x804008,%eax
  801d23:	8b 40 78             	mov    0x78(%eax),%eax
  801d26:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801d28:	a1 08 40 80 00       	mov    0x804008,%eax
  801d2d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801d4a:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801d51:	0f 44 d8             	cmove  %eax,%ebx
  801d54:	eb 1c                	jmp    801d72 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801d56:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d59:	74 12                	je     801d6d <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801d5b:	50                   	push   %eax
  801d5c:	68 42 25 80 00       	push   $0x802542
  801d61:	6a 4e                	push   $0x4e
  801d63:	68 4f 25 80 00       	push   $0x80254f
  801d68:	e8 78 e4 ff ff       	call   8001e5 <_panic>
		sys_yield();
  801d6d:	e8 34 ef ff ff       	call   800ca6 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d72:	ff 75 14             	pushl  0x14(%ebp)
  801d75:	53                   	push   %ebx
  801d76:	56                   	push   %esi
  801d77:	57                   	push   %edi
  801d78:	e8 d5 f0 ff ff       	call   800e52 <sys_ipc_try_send>
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 d2                	js     801d56 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d97:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d9a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801da0:	8b 52 50             	mov    0x50(%edx),%edx
  801da3:	39 ca                	cmp    %ecx,%edx
  801da5:	75 0d                	jne    801db4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801da7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801daa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801daf:	8b 40 48             	mov    0x48(%eax),%eax
  801db2:	eb 0f                	jmp    801dc3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801db4:	83 c0 01             	add    $0x1,%eax
  801db7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dbc:	75 d9                	jne    801d97 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dcb:	89 d0                	mov    %edx,%eax
  801dcd:	c1 e8 16             	shr    $0x16,%eax
  801dd0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ddc:	f6 c1 01             	test   $0x1,%cl
  801ddf:	74 1d                	je     801dfe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801de1:	c1 ea 0c             	shr    $0xc,%edx
  801de4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801deb:	f6 c2 01             	test   $0x1,%dl
  801dee:	74 0e                	je     801dfe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801df0:	c1 ea 0c             	shr    $0xc,%edx
  801df3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dfa:	ef 
  801dfb:	0f b7 c0             	movzwl %ax,%eax
}
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <__udivdi3>:
  801e00:	55                   	push   %ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	83 ec 1c             	sub    $0x1c,%esp
  801e07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e17:	85 f6                	test   %esi,%esi
  801e19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e1d:	89 ca                	mov    %ecx,%edx
  801e1f:	89 f8                	mov    %edi,%eax
  801e21:	75 3d                	jne    801e60 <__udivdi3+0x60>
  801e23:	39 cf                	cmp    %ecx,%edi
  801e25:	0f 87 c5 00 00 00    	ja     801ef0 <__udivdi3+0xf0>
  801e2b:	85 ff                	test   %edi,%edi
  801e2d:	89 fd                	mov    %edi,%ebp
  801e2f:	75 0b                	jne    801e3c <__udivdi3+0x3c>
  801e31:	b8 01 00 00 00       	mov    $0x1,%eax
  801e36:	31 d2                	xor    %edx,%edx
  801e38:	f7 f7                	div    %edi
  801e3a:	89 c5                	mov    %eax,%ebp
  801e3c:	89 c8                	mov    %ecx,%eax
  801e3e:	31 d2                	xor    %edx,%edx
  801e40:	f7 f5                	div    %ebp
  801e42:	89 c1                	mov    %eax,%ecx
  801e44:	89 d8                	mov    %ebx,%eax
  801e46:	89 cf                	mov    %ecx,%edi
  801e48:	f7 f5                	div    %ebp
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	89 d8                	mov    %ebx,%eax
  801e4e:	89 fa                	mov    %edi,%edx
  801e50:	83 c4 1c             	add    $0x1c,%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    
  801e58:	90                   	nop
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	39 ce                	cmp    %ecx,%esi
  801e62:	77 74                	ja     801ed8 <__udivdi3+0xd8>
  801e64:	0f bd fe             	bsr    %esi,%edi
  801e67:	83 f7 1f             	xor    $0x1f,%edi
  801e6a:	0f 84 98 00 00 00    	je     801f08 <__udivdi3+0x108>
  801e70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e75:	89 f9                	mov    %edi,%ecx
  801e77:	89 c5                	mov    %eax,%ebp
  801e79:	29 fb                	sub    %edi,%ebx
  801e7b:	d3 e6                	shl    %cl,%esi
  801e7d:	89 d9                	mov    %ebx,%ecx
  801e7f:	d3 ed                	shr    %cl,%ebp
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	d3 e0                	shl    %cl,%eax
  801e85:	09 ee                	or     %ebp,%esi
  801e87:	89 d9                	mov    %ebx,%ecx
  801e89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8d:	89 d5                	mov    %edx,%ebp
  801e8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e93:	d3 ed                	shr    %cl,%ebp
  801e95:	89 f9                	mov    %edi,%ecx
  801e97:	d3 e2                	shl    %cl,%edx
  801e99:	89 d9                	mov    %ebx,%ecx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	09 c2                	or     %eax,%edx
  801e9f:	89 d0                	mov    %edx,%eax
  801ea1:	89 ea                	mov    %ebp,%edx
  801ea3:	f7 f6                	div    %esi
  801ea5:	89 d5                	mov    %edx,%ebp
  801ea7:	89 c3                	mov    %eax,%ebx
  801ea9:	f7 64 24 0c          	mull   0xc(%esp)
  801ead:	39 d5                	cmp    %edx,%ebp
  801eaf:	72 10                	jb     801ec1 <__udivdi3+0xc1>
  801eb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801eb5:	89 f9                	mov    %edi,%ecx
  801eb7:	d3 e6                	shl    %cl,%esi
  801eb9:	39 c6                	cmp    %eax,%esi
  801ebb:	73 07                	jae    801ec4 <__udivdi3+0xc4>
  801ebd:	39 d5                	cmp    %edx,%ebp
  801ebf:	75 03                	jne    801ec4 <__udivdi3+0xc4>
  801ec1:	83 eb 01             	sub    $0x1,%ebx
  801ec4:	31 ff                	xor    %edi,%edi
  801ec6:	89 d8                	mov    %ebx,%eax
  801ec8:	89 fa                	mov    %edi,%edx
  801eca:	83 c4 1c             	add    $0x1c,%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    
  801ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ed8:	31 ff                	xor    %edi,%edi
  801eda:	31 db                	xor    %ebx,%ebx
  801edc:	89 d8                	mov    %ebx,%eax
  801ede:	89 fa                	mov    %edi,%edx
  801ee0:	83 c4 1c             	add    $0x1c,%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5f                   	pop    %edi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    
  801ee8:	90                   	nop
  801ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	89 d8                	mov    %ebx,%eax
  801ef2:	f7 f7                	div    %edi
  801ef4:	31 ff                	xor    %edi,%edi
  801ef6:	89 c3                	mov    %eax,%ebx
  801ef8:	89 d8                	mov    %ebx,%eax
  801efa:	89 fa                	mov    %edi,%edx
  801efc:	83 c4 1c             	add    $0x1c,%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    
  801f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f08:	39 ce                	cmp    %ecx,%esi
  801f0a:	72 0c                	jb     801f18 <__udivdi3+0x118>
  801f0c:	31 db                	xor    %ebx,%ebx
  801f0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f12:	0f 87 34 ff ff ff    	ja     801e4c <__udivdi3+0x4c>
  801f18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f1d:	e9 2a ff ff ff       	jmp    801e4c <__udivdi3+0x4c>
  801f22:	66 90                	xchg   %ax,%ax
  801f24:	66 90                	xchg   %ax,%ax
  801f26:	66 90                	xchg   %ax,%ax
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__umoddi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 d2                	test   %edx,%edx
  801f49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f51:	89 f3                	mov    %esi,%ebx
  801f53:	89 3c 24             	mov    %edi,(%esp)
  801f56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f5a:	75 1c                	jne    801f78 <__umoddi3+0x48>
  801f5c:	39 f7                	cmp    %esi,%edi
  801f5e:	76 50                	jbe    801fb0 <__umoddi3+0x80>
  801f60:	89 c8                	mov    %ecx,%eax
  801f62:	89 f2                	mov    %esi,%edx
  801f64:	f7 f7                	div    %edi
  801f66:	89 d0                	mov    %edx,%eax
  801f68:	31 d2                	xor    %edx,%edx
  801f6a:	83 c4 1c             	add    $0x1c,%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    
  801f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f78:	39 f2                	cmp    %esi,%edx
  801f7a:	89 d0                	mov    %edx,%eax
  801f7c:	77 52                	ja     801fd0 <__umoddi3+0xa0>
  801f7e:	0f bd ea             	bsr    %edx,%ebp
  801f81:	83 f5 1f             	xor    $0x1f,%ebp
  801f84:	75 5a                	jne    801fe0 <__umoddi3+0xb0>
  801f86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f8a:	0f 82 e0 00 00 00    	jb     802070 <__umoddi3+0x140>
  801f90:	39 0c 24             	cmp    %ecx,(%esp)
  801f93:	0f 86 d7 00 00 00    	jbe    802070 <__umoddi3+0x140>
  801f99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fa1:	83 c4 1c             	add    $0x1c,%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	85 ff                	test   %edi,%edi
  801fb2:	89 fd                	mov    %edi,%ebp
  801fb4:	75 0b                	jne    801fc1 <__umoddi3+0x91>
  801fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbb:	31 d2                	xor    %edx,%edx
  801fbd:	f7 f7                	div    %edi
  801fbf:	89 c5                	mov    %eax,%ebp
  801fc1:	89 f0                	mov    %esi,%eax
  801fc3:	31 d2                	xor    %edx,%edx
  801fc5:	f7 f5                	div    %ebp
  801fc7:	89 c8                	mov    %ecx,%eax
  801fc9:	f7 f5                	div    %ebp
  801fcb:	89 d0                	mov    %edx,%eax
  801fcd:	eb 99                	jmp    801f68 <__umoddi3+0x38>
  801fcf:	90                   	nop
  801fd0:	89 c8                	mov    %ecx,%eax
  801fd2:	89 f2                	mov    %esi,%edx
  801fd4:	83 c4 1c             	add    $0x1c,%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5f                   	pop    %edi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    
  801fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	8b 34 24             	mov    (%esp),%esi
  801fe3:	bf 20 00 00 00       	mov    $0x20,%edi
  801fe8:	89 e9                	mov    %ebp,%ecx
  801fea:	29 ef                	sub    %ebp,%edi
  801fec:	d3 e0                	shl    %cl,%eax
  801fee:	89 f9                	mov    %edi,%ecx
  801ff0:	89 f2                	mov    %esi,%edx
  801ff2:	d3 ea                	shr    %cl,%edx
  801ff4:	89 e9                	mov    %ebp,%ecx
  801ff6:	09 c2                	or     %eax,%edx
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	89 14 24             	mov    %edx,(%esp)
  801ffd:	89 f2                	mov    %esi,%edx
  801fff:	d3 e2                	shl    %cl,%edx
  802001:	89 f9                	mov    %edi,%ecx
  802003:	89 54 24 04          	mov    %edx,0x4(%esp)
  802007:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	89 e9                	mov    %ebp,%ecx
  80200f:	89 c6                	mov    %eax,%esi
  802011:	d3 e3                	shl    %cl,%ebx
  802013:	89 f9                	mov    %edi,%ecx
  802015:	89 d0                	mov    %edx,%eax
  802017:	d3 e8                	shr    %cl,%eax
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	09 d8                	or     %ebx,%eax
  80201d:	89 d3                	mov    %edx,%ebx
  80201f:	89 f2                	mov    %esi,%edx
  802021:	f7 34 24             	divl   (%esp)
  802024:	89 d6                	mov    %edx,%esi
  802026:	d3 e3                	shl    %cl,%ebx
  802028:	f7 64 24 04          	mull   0x4(%esp)
  80202c:	39 d6                	cmp    %edx,%esi
  80202e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802032:	89 d1                	mov    %edx,%ecx
  802034:	89 c3                	mov    %eax,%ebx
  802036:	72 08                	jb     802040 <__umoddi3+0x110>
  802038:	75 11                	jne    80204b <__umoddi3+0x11b>
  80203a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80203e:	73 0b                	jae    80204b <__umoddi3+0x11b>
  802040:	2b 44 24 04          	sub    0x4(%esp),%eax
  802044:	1b 14 24             	sbb    (%esp),%edx
  802047:	89 d1                	mov    %edx,%ecx
  802049:	89 c3                	mov    %eax,%ebx
  80204b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80204f:	29 da                	sub    %ebx,%edx
  802051:	19 ce                	sbb    %ecx,%esi
  802053:	89 f9                	mov    %edi,%ecx
  802055:	89 f0                	mov    %esi,%eax
  802057:	d3 e0                	shl    %cl,%eax
  802059:	89 e9                	mov    %ebp,%ecx
  80205b:	d3 ea                	shr    %cl,%edx
  80205d:	89 e9                	mov    %ebp,%ecx
  80205f:	d3 ee                	shr    %cl,%esi
  802061:	09 d0                	or     %edx,%eax
  802063:	89 f2                	mov    %esi,%edx
  802065:	83 c4 1c             	add    $0x1c,%esp
  802068:	5b                   	pop    %ebx
  802069:	5e                   	pop    %esi
  80206a:	5f                   	pop    %edi
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    
  80206d:	8d 76 00             	lea    0x0(%esi),%esi
  802070:	29 f9                	sub    %edi,%ecx
  802072:	19 d6                	sbb    %edx,%esi
  802074:	89 74 24 04          	mov    %esi,0x4(%esp)
  802078:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80207c:	e9 18 ff ff ff       	jmp    801f99 <__umoddi3+0x69>
