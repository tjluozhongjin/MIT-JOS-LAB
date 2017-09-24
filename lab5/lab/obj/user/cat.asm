
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 cd 11 00 00       	call   80121a <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 40 20 80 00       	push   $0x802040
  800060:	6a 0d                	push   $0xd
  800062:	68 5b 20 80 00       	push   $0x80205b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 c1 10 00 00       	call   801140 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 66 20 80 00       	push   $0x802066
  800098:	6a 0f                	push   $0xf
  80009a:	68 5b 20 80 00       	push   $0x80205b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 7b 	movl   $0x80207b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 7f 20 80 00       	push   $0x80207f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 e4 14 00 00       	call   8015d1 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 87 20 80 00       	push   $0x802087
  800102:	e8 68 16 00 00       	call   80176f <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 e4 0e 00 00       	call   801004 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 f2 0a 00 00       	call   800c35 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 ab 0e 00 00       	call   80102f <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 66 0a 00 00       	call   800bf4 <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 8f 0a 00 00       	call   800c35 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 a4 20 80 00       	push   $0x8020a4
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 ae 09 00 00       	call   800bb7 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 1a 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 53 09 00 00       	call   800bb7 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 dc 1a 00 00       	call   801db0 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 c9 1b 00 00       	call   801ee0 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8d 4a 01             	lea    0x1(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	88 02                	mov    %al,(%edx)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
	va_end(ap);
}
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 2c             	sub    $0x2c,%esp
  800372:	8b 75 08             	mov    0x8(%ebp),%esi
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800378:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037b:	eb 12                	jmp    80038f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037d:	85 c0                	test   %eax,%eax
  80037f:	0f 84 42 04 00 00    	je     8007c7 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	53                   	push   %ebx
  800389:	50                   	push   %eax
  80038a:	ff d6                	call   *%esi
  80038c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038f:	83 c7 01             	add    $0x1,%edi
  800392:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800396:	83 f8 25             	cmp    $0x25,%eax
  800399:	75 e2                	jne    80037d <vprintfmt+0x14>
  80039b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	eb 07                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8d 47 01             	lea    0x1(%edi),%eax
  8003c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c8:	0f b6 07             	movzbl (%edi),%eax
  8003cb:	0f b6 d0             	movzbl %al,%edx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 d3 03 00 00    	ja     8007ac <vprintfmt+0x443>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ea:	eb d6                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fa:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003fe:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800401:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800404:	83 f9 09             	cmp    $0x9,%ecx
  800407:	77 3f                	ja     800448 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040c:	eb e9                	jmp    8003f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 00                	mov    (%eax),%eax
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 40 04             	lea    0x4(%eax),%eax
  80041c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800422:	eb 2a                	jmp    80044e <vprintfmt+0xe5>
  800424:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800427:	85 c0                	test   %eax,%eax
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	0f 49 d0             	cmovns %eax,%edx
  800431:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800437:	eb 89                	jmp    8003c2 <vprintfmt+0x59>
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800443:	e9 7a ff ff ff       	jmp    8003c2 <vprintfmt+0x59>
  800448:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80044b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	0f 89 6a ff ff ff    	jns    8003c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800458:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800465:	e9 58 ff ff ff       	jmp    8003c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800470:	e9 4d ff ff ff       	jmp    8003c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 78 04             	lea    0x4(%eax),%edi
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	ff 30                	pushl  (%eax)
  800481:	ff d6                	call   *%esi
			break;
  800483:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800486:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048c:	e9 fe fe ff ff       	jmp    80038f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 78 04             	lea    0x4(%eax),%edi
  800497:	8b 00                	mov    (%eax),%eax
  800499:	99                   	cltd   
  80049a:	31 d0                	xor    %edx,%eax
  80049c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049e:	83 f8 0f             	cmp    $0xf,%eax
  8004a1:	7f 0b                	jg     8004ae <vprintfmt+0x145>
  8004a3:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	75 1b                	jne    8004c9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ae:	50                   	push   %eax
  8004af:	68 df 20 80 00       	push   $0x8020df
  8004b4:	53                   	push   %ebx
  8004b5:	56                   	push   %esi
  8004b6:	e8 91 fe ff ff       	call   80034c <printfmt>
  8004bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c4:	e9 c6 fe ff ff       	jmp    80038f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	52                   	push   %edx
  8004ca:	68 95 24 80 00       	push   $0x802495
  8004cf:	53                   	push   %ebx
  8004d0:	56                   	push   %esi
  8004d1:	e8 76 fe ff ff       	call   80034c <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 ab fe ff ff       	jmp    80038f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	b8 d8 20 80 00       	mov    $0x8020d8,%eax
  8004f9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	0f 8e 94 00 00 00    	jle    80059a <vprintfmt+0x231>
  800506:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050a:	0f 84 98 00 00 00    	je     8005a8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 d0             	pushl  -0x30(%ebp)
  800516:	57                   	push   %edi
  800517:	e8 33 03 00 00       	call   80084f <strnlen>
  80051c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800527:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800531:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	eb 0f                	jmp    800544 <vprintfmt+0x1db>
					putch(padc, putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	ff 75 e0             	pushl  -0x20(%ebp)
  80053c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ef 01             	sub    $0x1,%edi
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	85 ff                	test   %edi,%edi
  800546:	7f ed                	jg     800535 <vprintfmt+0x1cc>
  800548:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	0f 49 c1             	cmovns %ecx,%eax
  800558:	29 c1                	sub    %eax,%ecx
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	89 cb                	mov    %ecx,%ebx
  800565:	eb 4d                	jmp    8005b4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800567:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056b:	74 1b                	je     800588 <vprintfmt+0x21f>
  80056d:	0f be c0             	movsbl %al,%eax
  800570:	83 e8 20             	sub    $0x20,%eax
  800573:	83 f8 5e             	cmp    $0x5e,%eax
  800576:	76 10                	jbe    800588 <vprintfmt+0x21f>
					putch('?', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	6a 3f                	push   $0x3f
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	eb 0d                	jmp    800595 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	52                   	push   %edx
  80058f:	ff 55 08             	call   *0x8(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800595:	83 eb 01             	sub    $0x1,%ebx
  800598:	eb 1a                	jmp    8005b4 <vprintfmt+0x24b>
  80059a:	89 75 08             	mov    %esi,0x8(%ebp)
  80059d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a6:	eb 0c                	jmp    8005b4 <vprintfmt+0x24b>
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b4:	83 c7 01             	add    $0x1,%edi
  8005b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bb:	0f be d0             	movsbl %al,%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	74 23                	je     8005e5 <vprintfmt+0x27c>
  8005c2:	85 f6                	test   %esi,%esi
  8005c4:	78 a1                	js     800567 <vprintfmt+0x1fe>
  8005c6:	83 ee 01             	sub    $0x1,%esi
  8005c9:	79 9c                	jns    800567 <vprintfmt+0x1fe>
  8005cb:	89 df                	mov    %ebx,%edi
  8005cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d3:	eb 18                	jmp    8005ed <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 20                	push   $0x20
  8005db:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dd:	83 ef 01             	sub    $0x1,%edi
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	eb 08                	jmp    8005ed <vprintfmt+0x284>
  8005e5:	89 df                	mov    %ebx,%edi
  8005e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	7f e4                	jg     8005d5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fa:	e9 90 fd ff ff       	jmp    80038f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ff:	83 f9 01             	cmp    $0x1,%ecx
  800602:	7e 19                	jle    80061d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 50 04             	mov    0x4(%eax),%edx
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 40 08             	lea    0x8(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
  80061b:	eb 38                	jmp    800655 <vprintfmt+0x2ec>
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 1b                	je     80063c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	c1 f9 1f             	sar    $0x1f,%ecx
  80062e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
  80063a:	eb 19                	jmp    800655 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800644:	89 c1                	mov    %eax,%ecx
  800646:	c1 f9 1f             	sar    $0x1f,%ecx
  800649:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800655:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800658:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800660:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800664:	0f 89 0e 01 00 00    	jns    800778 <vprintfmt+0x40f>
				putch('-', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 2d                	push   $0x2d
  800670:	ff d6                	call   *%esi
				num = -(long long) num;
  800672:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800675:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800678:	f7 da                	neg    %edx
  80067a:	83 d1 00             	adc    $0x0,%ecx
  80067d:	f7 d9                	neg    %ecx
  80067f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 ec 00 00 00       	jmp    800778 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068c:	83 f9 01             	cmp    $0x1,%ecx
  80068f:	7e 18                	jle    8006a9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	8b 48 04             	mov    0x4(%eax),%ecx
  800699:	8d 40 08             	lea    0x8(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a4:	e9 cf 00 00 00       	jmp    800778 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	74 1a                	je     8006c7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c2:	e9 b1 00 00 00       	jmp    800778 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	8d 40 04             	lea    0x4(%eax),%eax
  8006d4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dc:	e9 97 00 00 00       	jmp    800778 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 58                	push   $0x58
  8006e7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006e9:	83 c4 08             	add    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	6a 58                	push   $0x58
  8006ef:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 58                	push   $0x58
  8006f7:	ff d6                	call   *%esi
			break;
  8006f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006ff:	e9 8b fc ff ff       	jmp    80038f <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	6a 30                	push   $0x30
  80070a:	ff d6                	call   *%esi
			putch('x', putdat);
  80070c:	83 c4 08             	add    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 78                	push   $0x78
  800712:	ff d6                	call   *%esi
			num = (unsigned long long)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800721:	8d 40 04             	lea    0x4(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800727:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072c:	eb 4a                	jmp    800778 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072e:	83 f9 01             	cmp    $0x1,%ecx
  800731:	7e 15                	jle    800748 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	8b 48 04             	mov    0x4(%eax),%ecx
  80073b:	8d 40 08             	lea    0x8(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800741:	b8 10 00 00 00       	mov    $0x10,%eax
  800746:	eb 30                	jmp    800778 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800748:	85 c9                	test   %ecx,%ecx
  80074a:	74 17                	je     800763 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80075c:	b8 10 00 00 00       	mov    $0x10,%eax
  800761:	eb 15                	jmp    800778 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8b 10                	mov    (%eax),%edx
  800768:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800773:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80077f:	57                   	push   %edi
  800780:	ff 75 e0             	pushl  -0x20(%ebp)
  800783:	50                   	push   %eax
  800784:	51                   	push   %ecx
  800785:	52                   	push   %edx
  800786:	89 da                	mov    %ebx,%edx
  800788:	89 f0                	mov    %esi,%eax
  80078a:	e8 f1 fa ff ff       	call   800280 <printnum>
			break;
  80078f:	83 c4 20             	add    $0x20,%esp
  800792:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800795:	e9 f5 fb ff ff       	jmp    80038f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079a:	83 ec 08             	sub    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	52                   	push   %edx
  80079f:	ff d6                	call   *%esi
			break;
  8007a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a7:	e9 e3 fb ff ff       	jmp    80038f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	6a 25                	push   $0x25
  8007b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 03                	jmp    8007bc <vprintfmt+0x453>
  8007b9:	83 ef 01             	sub    $0x1,%edi
  8007bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c0:	75 f7                	jne    8007b9 <vprintfmt+0x450>
  8007c2:	e9 c8 fb ff ff       	jmp    80038f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5f                   	pop    %edi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	83 ec 18             	sub    $0x18,%esp
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	74 26                	je     800816 <vsnprintf+0x47>
  8007f0:	85 d2                	test   %edx,%edx
  8007f2:	7e 22                	jle    800816 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f4:	ff 75 14             	pushl  0x14(%ebp)
  8007f7:	ff 75 10             	pushl  0x10(%ebp)
  8007fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	68 2f 03 80 00       	push   $0x80032f
  800803:	e8 61 fb ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800808:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	eb 05                	jmp    80081b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800816:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800826:	50                   	push   %eax
  800827:	ff 75 10             	pushl  0x10(%ebp)
  80082a:	ff 75 0c             	pushl  0xc(%ebp)
  80082d:	ff 75 08             	pushl  0x8(%ebp)
  800830:	e8 9a ff ff ff       	call   8007cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	eb 03                	jmp    800847 <strlen+0x10>
		n++;
  800844:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800847:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084b:	75 f7                	jne    800844 <strlen+0xd>
		n++;
	return n;
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800858:	ba 00 00 00 00       	mov    $0x0,%edx
  80085d:	eb 03                	jmp    800862 <strnlen+0x13>
		n++;
  80085f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800862:	39 c2                	cmp    %eax,%edx
  800864:	74 08                	je     80086e <strnlen+0x1f>
  800866:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80086a:	75 f3                	jne    80085f <strnlen+0x10>
  80086c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087a:	89 c2                	mov    %eax,%edx
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800886:	88 5a ff             	mov    %bl,-0x1(%edx)
  800889:	84 db                	test   %bl,%bl
  80088b:	75 ef                	jne    80087c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800897:	53                   	push   %ebx
  800898:	e8 9a ff ff ff       	call   800837 <strlen>
  80089d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a0:	ff 75 0c             	pushl  0xc(%ebp)
  8008a3:	01 d8                	add    %ebx,%eax
  8008a5:	50                   	push   %eax
  8008a6:	e8 c5 ff ff ff       	call   800870 <strcpy>
	return dst;
}
  8008ab:	89 d8                	mov    %ebx,%eax
  8008ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
		*dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ef:	85 d2                	test   %edx,%edx
  8008f1:	74 21                	je     800914 <strlcpy+0x35>
  8008f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f7:	89 f2                	mov    %esi,%edx
  8008f9:	eb 09                	jmp    800904 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fb:	83 c2 01             	add    $0x1,%edx
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800904:	39 c2                	cmp    %eax,%edx
  800906:	74 09                	je     800911 <strlcpy+0x32>
  800908:	0f b6 19             	movzbl (%ecx),%ebx
  80090b:	84 db                	test   %bl,%bl
  80090d:	75 ec                	jne    8008fb <strlcpy+0x1c>
  80090f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800911:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800914:	29 f0                	sub    %esi,%eax
}
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800923:	eb 06                	jmp    80092b <strcmp+0x11>
		p++, q++;
  800925:	83 c1 01             	add    $0x1,%ecx
  800928:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092b:	0f b6 01             	movzbl (%ecx),%eax
  80092e:	84 c0                	test   %al,%al
  800930:	74 04                	je     800936 <strcmp+0x1c>
  800932:	3a 02                	cmp    (%edx),%al
  800934:	74 ef                	je     800925 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800936:	0f b6 c0             	movzbl %al,%eax
  800939:	0f b6 12             	movzbl (%edx),%edx
  80093c:	29 d0                	sub    %edx,%eax
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	53                   	push   %ebx
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	89 c3                	mov    %eax,%ebx
  80094c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80094f:	eb 06                	jmp    800957 <strncmp+0x17>
		n--, p++, q++;
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800957:	39 d8                	cmp    %ebx,%eax
  800959:	74 15                	je     800970 <strncmp+0x30>
  80095b:	0f b6 08             	movzbl (%eax),%ecx
  80095e:	84 c9                	test   %cl,%cl
  800960:	74 04                	je     800966 <strncmp+0x26>
  800962:	3a 0a                	cmp    (%edx),%cl
  800964:	74 eb                	je     800951 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800966:	0f b6 00             	movzbl (%eax),%eax
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	29 d0                	sub    %edx,%eax
  80096e:	eb 05                	jmp    800975 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800975:	5b                   	pop    %ebx
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800982:	eb 07                	jmp    80098b <strchr+0x13>
		if (*s == c)
  800984:	38 ca                	cmp    %cl,%dl
  800986:	74 0f                	je     800997 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	0f b6 10             	movzbl (%eax),%edx
  80098e:	84 d2                	test   %dl,%dl
  800990:	75 f2                	jne    800984 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a3:	eb 03                	jmp    8009a8 <strfind+0xf>
  8009a5:	83 c0 01             	add    $0x1,%eax
  8009a8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ab:	38 ca                	cmp    %cl,%dl
  8009ad:	74 04                	je     8009b3 <strfind+0x1a>
  8009af:	84 d2                	test   %dl,%dl
  8009b1:	75 f2                	jne    8009a5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	57                   	push   %edi
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c1:	85 c9                	test   %ecx,%ecx
  8009c3:	74 36                	je     8009fb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cb:	75 28                	jne    8009f5 <memset+0x40>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 23                	jne    8009f5 <memset+0x40>
		c &= 0xFF;
  8009d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d6:	89 d3                	mov    %edx,%ebx
  8009d8:	c1 e3 08             	shl    $0x8,%ebx
  8009db:	89 d6                	mov    %edx,%esi
  8009dd:	c1 e6 18             	shl    $0x18,%esi
  8009e0:	89 d0                	mov    %edx,%eax
  8009e2:	c1 e0 10             	shl    $0x10,%eax
  8009e5:	09 f0                	or     %esi,%eax
  8009e7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009e9:	89 d8                	mov    %ebx,%eax
  8009eb:	09 d0                	or     %edx,%eax
  8009ed:	c1 e9 02             	shr    $0x2,%ecx
  8009f0:	fc                   	cld    
  8009f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f3:	eb 06                	jmp    8009fb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	fc                   	cld    
  8009f9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a10:	39 c6                	cmp    %eax,%esi
  800a12:	73 35                	jae    800a49 <memmove+0x47>
  800a14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a17:	39 d0                	cmp    %edx,%eax
  800a19:	73 2e                	jae    800a49 <memmove+0x47>
		s += n;
		d += n;
  800a1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1e:	89 d6                	mov    %edx,%esi
  800a20:	09 fe                	or     %edi,%esi
  800a22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a28:	75 13                	jne    800a3d <memmove+0x3b>
  800a2a:	f6 c1 03             	test   $0x3,%cl
  800a2d:	75 0e                	jne    800a3d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a2f:	83 ef 04             	sub    $0x4,%edi
  800a32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a35:	c1 e9 02             	shr    $0x2,%ecx
  800a38:	fd                   	std    
  800a39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3b:	eb 09                	jmp    800a46 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3d:	83 ef 01             	sub    $0x1,%edi
  800a40:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a43:	fd                   	std    
  800a44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a46:	fc                   	cld    
  800a47:	eb 1d                	jmp    800a66 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a49:	89 f2                	mov    %esi,%edx
  800a4b:	09 c2                	or     %eax,%edx
  800a4d:	f6 c2 03             	test   $0x3,%dl
  800a50:	75 0f                	jne    800a61 <memmove+0x5f>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 0a                	jne    800a61 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a57:	c1 e9 02             	shr    $0x2,%ecx
  800a5a:	89 c7                	mov    %eax,%edi
  800a5c:	fc                   	cld    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 05                	jmp    800a66 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	fc                   	cld    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a6d:	ff 75 10             	pushl  0x10(%ebp)
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	ff 75 08             	pushl  0x8(%ebp)
  800a76:	e8 87 ff ff ff       	call   800a02 <memmove>
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a88:	89 c6                	mov    %eax,%esi
  800a8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8d:	eb 1a                	jmp    800aa9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8f:	0f b6 08             	movzbl (%eax),%ecx
  800a92:	0f b6 1a             	movzbl (%edx),%ebx
  800a95:	38 d9                	cmp    %bl,%cl
  800a97:	74 0a                	je     800aa3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c1             	movzbl %cl,%eax
  800a9c:	0f b6 db             	movzbl %bl,%ebx
  800a9f:	29 d8                	sub    %ebx,%eax
  800aa1:	eb 0f                	jmp    800ab2 <memcmp+0x35>
		s1++, s2++;
  800aa3:	83 c0 01             	add    $0x1,%eax
  800aa6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa9:	39 f0                	cmp    %esi,%eax
  800aab:	75 e2                	jne    800a8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	53                   	push   %ebx
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abd:	89 c1                	mov    %eax,%ecx
  800abf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac6:	eb 0a                	jmp    800ad2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 10             	movzbl (%eax),%edx
  800acb:	39 da                	cmp    %ebx,%edx
  800acd:	74 07                	je     800ad6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	39 c8                	cmp    %ecx,%eax
  800ad4:	72 f2                	jb     800ac8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae5:	eb 03                	jmp    800aea <strtol+0x11>
		s++;
  800ae7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aea:	0f b6 01             	movzbl (%ecx),%eax
  800aed:	3c 20                	cmp    $0x20,%al
  800aef:	74 f6                	je     800ae7 <strtol+0xe>
  800af1:	3c 09                	cmp    $0x9,%al
  800af3:	74 f2                	je     800ae7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af5:	3c 2b                	cmp    $0x2b,%al
  800af7:	75 0a                	jne    800b03 <strtol+0x2a>
		s++;
  800af9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afc:	bf 00 00 00 00       	mov    $0x0,%edi
  800b01:	eb 11                	jmp    800b14 <strtol+0x3b>
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b08:	3c 2d                	cmp    $0x2d,%al
  800b0a:	75 08                	jne    800b14 <strtol+0x3b>
		s++, neg = 1;
  800b0c:	83 c1 01             	add    $0x1,%ecx
  800b0f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1a:	75 15                	jne    800b31 <strtol+0x58>
  800b1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1f:	75 10                	jne    800b31 <strtol+0x58>
  800b21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b25:	75 7c                	jne    800ba3 <strtol+0xca>
		s += 2, base = 16;
  800b27:	83 c1 02             	add    $0x2,%ecx
  800b2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2f:	eb 16                	jmp    800b47 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b31:	85 db                	test   %ebx,%ebx
  800b33:	75 12                	jne    800b47 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b35:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3d:	75 08                	jne    800b47 <strtol+0x6e>
		s++, base = 8;
  800b3f:	83 c1 01             	add    $0x1,%ecx
  800b42:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b4f:	0f b6 11             	movzbl (%ecx),%edx
  800b52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b55:	89 f3                	mov    %esi,%ebx
  800b57:	80 fb 09             	cmp    $0x9,%bl
  800b5a:	77 08                	ja     800b64 <strtol+0x8b>
			dig = *s - '0';
  800b5c:	0f be d2             	movsbl %dl,%edx
  800b5f:	83 ea 30             	sub    $0x30,%edx
  800b62:	eb 22                	jmp    800b86 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b67:	89 f3                	mov    %esi,%ebx
  800b69:	80 fb 19             	cmp    $0x19,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b6e:	0f be d2             	movsbl %dl,%edx
  800b71:	83 ea 57             	sub    $0x57,%edx
  800b74:	eb 10                	jmp    800b86 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 16                	ja     800b96 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b89:	7d 0b                	jge    800b96 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b8b:	83 c1 01             	add    $0x1,%ecx
  800b8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b92:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b94:	eb b9                	jmp    800b4f <strtol+0x76>

	if (endptr)
  800b96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9a:	74 0d                	je     800ba9 <strtol+0xd0>
		*endptr = (char *) s;
  800b9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9f:	89 0e                	mov    %ecx,(%esi)
  800ba1:	eb 06                	jmp    800ba9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba3:	85 db                	test   %ebx,%ebx
  800ba5:	74 98                	je     800b3f <strtol+0x66>
  800ba7:	eb 9e                	jmp    800b47 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ba9:	89 c2                	mov    %eax,%edx
  800bab:	f7 da                	neg    %edx
  800bad:	85 ff                	test   %edi,%edi
  800baf:	0f 45 c2             	cmovne %edx,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 c3                	mov    %eax,%ebx
  800bca:	89 c7                	mov    %eax,%edi
  800bcc:	89 c6                	mov    %eax,%esi
  800bce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 01 00 00 00       	mov    $0x1,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c02:	b8 03 00 00 00       	mov    $0x3,%eax
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	89 cb                	mov    %ecx,%ebx
  800c0c:	89 cf                	mov    %ecx,%edi
  800c0e:	89 ce                	mov    %ecx,%esi
  800c10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 17                	jle    800c2d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 03                	push   $0x3
  800c1c:	68 bf 23 80 00       	push   $0x8023bf
  800c21:	6a 23                	push   $0x23
  800c23:	68 dc 23 80 00       	push   $0x8023dc
  800c28:	e8 66 f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 02 00 00 00       	mov    $0x2,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_yield>:

void
sys_yield(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	be 00 00 00 00       	mov    $0x0,%esi
  800c81:	b8 04 00 00 00       	mov    $0x4,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	89 f7                	mov    %esi,%edi
  800c91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 04                	push   $0x4
  800c9d:	68 bf 23 80 00       	push   $0x8023bf
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 dc 23 80 00       	push   $0x8023dc
  800ca9:	e8 e5 f4 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 05                	push   $0x5
  800cdf:	68 bf 23 80 00       	push   $0x8023bf
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 dc 23 80 00       	push   $0x8023dc
  800ceb:	e8 a3 f4 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d06:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 df                	mov    %ebx,%edi
  800d13:	89 de                	mov    %ebx,%esi
  800d15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 06                	push   $0x6
  800d21:	68 bf 23 80 00       	push   $0x8023bf
  800d26:	6a 23                	push   $0x23
  800d28:	68 dc 23 80 00       	push   $0x8023dc
  800d2d:	e8 61 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 08                	push   $0x8
  800d63:	68 bf 23 80 00       	push   $0x8023bf
  800d68:	6a 23                	push   $0x23
  800d6a:	68 dc 23 80 00       	push   $0x8023dc
  800d6f:	e8 1f f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	89 df                	mov    %ebx,%edi
  800d97:	89 de                	mov    %ebx,%esi
  800d99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7e 17                	jle    800db6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	50                   	push   %eax
  800da3:	6a 09                	push   $0x9
  800da5:	68 bf 23 80 00       	push   $0x8023bf
  800daa:	6a 23                	push   $0x23
  800dac:	68 dc 23 80 00       	push   $0x8023dc
  800db1:	e8 dd f3 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	89 de                	mov    %ebx,%esi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 0a                	push   $0xa
  800de7:	68 bf 23 80 00       	push   $0x8023bf
  800dec:	6a 23                	push   $0x23
  800dee:	68 dc 23 80 00       	push   $0x8023dc
  800df3:	e8 9b f3 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	be 00 00 00 00       	mov    $0x0,%esi
  800e0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 17                	jle    800e5c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 0d                	push   $0xd
  800e4b:	68 bf 23 80 00       	push   $0x8023bf
  800e50:	6a 23                	push   $0x23
  800e52:	68 dc 23 80 00       	push   $0x8023dc
  800e57:	e8 37 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e84:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e91:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 16             	shr    $0x16,%edx
  800e9b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	74 11                	je     800eb8 <fd_alloc+0x2d>
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	c1 ea 0c             	shr    $0xc,%edx
  800eac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb3:	f6 c2 01             	test   $0x1,%dl
  800eb6:	75 09                	jne    800ec1 <fd_alloc+0x36>
			*fd_store = fd;
  800eb8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 17                	jmp    800ed8 <fd_alloc+0x4d>
  800ec1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ecb:	75 c9                	jne    800e96 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee0:	83 f8 1f             	cmp    $0x1f,%eax
  800ee3:	77 36                	ja     800f1b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee5:	c1 e0 0c             	shl    $0xc,%eax
  800ee8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	c1 ea 16             	shr    $0x16,%edx
  800ef2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef9:	f6 c2 01             	test   $0x1,%dl
  800efc:	74 24                	je     800f22 <fd_lookup+0x48>
  800efe:	89 c2                	mov    %eax,%edx
  800f00:	c1 ea 0c             	shr    $0xc,%edx
  800f03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0a:	f6 c2 01             	test   $0x1,%dl
  800f0d:	74 1a                	je     800f29 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f12:	89 02                	mov    %eax,(%edx)
	return 0;
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
  800f19:	eb 13                	jmp    800f2e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f20:	eb 0c                	jmp    800f2e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f27:	eb 05                	jmp    800f2e <fd_lookup+0x54>
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	ba 6c 24 80 00       	mov    $0x80246c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3e:	eb 13                	jmp    800f53 <dev_lookup+0x23>
  800f40:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f43:	39 08                	cmp    %ecx,(%eax)
  800f45:	75 0c                	jne    800f53 <dev_lookup+0x23>
			*dev = devtab[i];
  800f47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f51:	eb 2e                	jmp    800f81 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f53:	8b 02                	mov    (%edx),%eax
  800f55:	85 c0                	test   %eax,%eax
  800f57:	75 e7                	jne    800f40 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f59:	a1 20 60 80 00       	mov    0x806020,%eax
  800f5e:	8b 40 48             	mov    0x48(%eax),%eax
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	51                   	push   %ecx
  800f65:	50                   	push   %eax
  800f66:	68 ec 23 80 00       	push   $0x8023ec
  800f6b:	e8 fc f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 10             	sub    $0x10,%esp
  800f8b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f94:	50                   	push   %eax
  800f95:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f9b:	c1 e8 0c             	shr    $0xc,%eax
  800f9e:	50                   	push   %eax
  800f9f:	e8 36 ff ff ff       	call   800eda <fd_lookup>
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 05                	js     800fb0 <fd_close+0x2d>
	    || fd != fd2)
  800fab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fae:	74 0c                	je     800fbc <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb0:	84 db                	test   %bl,%bl
  800fb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb7:	0f 44 c2             	cmove  %edx,%eax
  800fba:	eb 41                	jmp    800ffd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	ff 36                	pushl  (%esi)
  800fc5:	e8 66 ff ff ff       	call   800f30 <dev_lookup>
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 1a                	js     800fed <fd_close+0x6a>
		if (dev->dev_close)
  800fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fd9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	74 0b                	je     800fed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	56                   	push   %esi
  800fe6:	ff d0                	call   *%eax
  800fe8:	89 c3                	mov    %eax,%ebx
  800fea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	56                   	push   %esi
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 00 fd ff ff       	call   800cf8 <sys_page_unmap>
	return r;
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	89 d8                	mov    %ebx,%eax
}
  800ffd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	ff 75 08             	pushl  0x8(%ebp)
  801011:	e8 c4 fe ff ff       	call   800eda <fd_lookup>
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 10                	js     80102d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	6a 01                	push   $0x1
  801022:	ff 75 f4             	pushl  -0xc(%ebp)
  801025:	e8 59 ff ff ff       	call   800f83 <fd_close>
  80102a:	83 c4 10             	add    $0x10,%esp
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <close_all>:

void
close_all(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	53                   	push   %ebx
  801033:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	53                   	push   %ebx
  80103f:	e8 c0 ff ff ff       	call   801004 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801044:	83 c3 01             	add    $0x1,%ebx
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	83 fb 20             	cmp    $0x20,%ebx
  80104d:	75 ec                	jne    80103b <close_all+0xc>
		close(i);
}
  80104f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
  80105a:	83 ec 2c             	sub    $0x2c,%esp
  80105d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801060:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801063:	50                   	push   %eax
  801064:	ff 75 08             	pushl  0x8(%ebp)
  801067:	e8 6e fe ff ff       	call   800eda <fd_lookup>
  80106c:	83 c4 08             	add    $0x8,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	0f 88 c1 00 00 00    	js     801138 <dup+0xe4>
		return r;
	close(newfdnum);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	56                   	push   %esi
  80107b:	e8 84 ff ff ff       	call   801004 <close>

	newfd = INDEX2FD(newfdnum);
  801080:	89 f3                	mov    %esi,%ebx
  801082:	c1 e3 0c             	shl    $0xc,%ebx
  801085:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80108b:	83 c4 04             	add    $0x4,%esp
  80108e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801091:	e8 de fd ff ff       	call   800e74 <fd2data>
  801096:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801098:	89 1c 24             	mov    %ebx,(%esp)
  80109b:	e8 d4 fd ff ff       	call   800e74 <fd2data>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a6:	89 f8                	mov    %edi,%eax
  8010a8:	c1 e8 16             	shr    $0x16,%eax
  8010ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b2:	a8 01                	test   $0x1,%al
  8010b4:	74 37                	je     8010ed <dup+0x99>
  8010b6:	89 f8                	mov    %edi,%eax
  8010b8:	c1 e8 0c             	shr    $0xc,%eax
  8010bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c2:	f6 c2 01             	test   $0x1,%dl
  8010c5:	74 26                	je     8010ed <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d6:	50                   	push   %eax
  8010d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010da:	6a 00                	push   $0x0
  8010dc:	57                   	push   %edi
  8010dd:	6a 00                	push   $0x0
  8010df:	e8 d2 fb ff ff       	call   800cb6 <sys_page_map>
  8010e4:	89 c7                	mov    %eax,%edi
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 2e                	js     80111b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f0:	89 d0                	mov    %edx,%eax
  8010f2:	c1 e8 0c             	shr    $0xc,%eax
  8010f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801104:	50                   	push   %eax
  801105:	53                   	push   %ebx
  801106:	6a 00                	push   $0x0
  801108:	52                   	push   %edx
  801109:	6a 00                	push   $0x0
  80110b:	e8 a6 fb ff ff       	call   800cb6 <sys_page_map>
  801110:	89 c7                	mov    %eax,%edi
  801112:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801115:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801117:	85 ff                	test   %edi,%edi
  801119:	79 1d                	jns    801138 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80111b:	83 ec 08             	sub    $0x8,%esp
  80111e:	53                   	push   %ebx
  80111f:	6a 00                	push   $0x0
  801121:	e8 d2 fb ff ff       	call   800cf8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801126:	83 c4 08             	add    $0x8,%esp
  801129:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112c:	6a 00                	push   $0x0
  80112e:	e8 c5 fb ff ff       	call   800cf8 <sys_page_unmap>
	return r;
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	89 f8                	mov    %edi,%eax
}
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	53                   	push   %ebx
  801144:	83 ec 14             	sub    $0x14,%esp
  801147:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	53                   	push   %ebx
  80114f:	e8 86 fd ff ff       	call   800eda <fd_lookup>
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	89 c2                	mov    %eax,%edx
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 6d                	js     8011ca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801163:	50                   	push   %eax
  801164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801167:	ff 30                	pushl  (%eax)
  801169:	e8 c2 fd ff ff       	call   800f30 <dev_lookup>
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	78 4c                	js     8011c1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801175:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801178:	8b 42 08             	mov    0x8(%edx),%eax
  80117b:	83 e0 03             	and    $0x3,%eax
  80117e:	83 f8 01             	cmp    $0x1,%eax
  801181:	75 21                	jne    8011a4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801183:	a1 20 60 80 00       	mov    0x806020,%eax
  801188:	8b 40 48             	mov    0x48(%eax),%eax
  80118b:	83 ec 04             	sub    $0x4,%esp
  80118e:	53                   	push   %ebx
  80118f:	50                   	push   %eax
  801190:	68 30 24 80 00       	push   $0x802430
  801195:	e8 d2 f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a2:	eb 26                	jmp    8011ca <read+0x8a>
	}
	if (!dev->dev_read)
  8011a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a7:	8b 40 08             	mov    0x8(%eax),%eax
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	74 17                	je     8011c5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	ff 75 10             	pushl  0x10(%ebp)
  8011b4:	ff 75 0c             	pushl  0xc(%ebp)
  8011b7:	52                   	push   %edx
  8011b8:	ff d0                	call   *%eax
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	eb 09                	jmp    8011ca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	eb 05                	jmp    8011ca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011ca:	89 d0                	mov    %edx,%eax
  8011cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e5:	eb 21                	jmp    801208 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	89 f0                	mov    %esi,%eax
  8011ec:	29 d8                	sub    %ebx,%eax
  8011ee:	50                   	push   %eax
  8011ef:	89 d8                	mov    %ebx,%eax
  8011f1:	03 45 0c             	add    0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	57                   	push   %edi
  8011f6:	e8 45 ff ff ff       	call   801140 <read>
		if (m < 0)
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 10                	js     801212 <readn+0x41>
			return m;
		if (m == 0)
  801202:	85 c0                	test   %eax,%eax
  801204:	74 0a                	je     801210 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801206:	01 c3                	add    %eax,%ebx
  801208:	39 f3                	cmp    %esi,%ebx
  80120a:	72 db                	jb     8011e7 <readn+0x16>
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	eb 02                	jmp    801212 <readn+0x41>
  801210:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 14             	sub    $0x14,%esp
  801221:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801224:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	53                   	push   %ebx
  801229:	e8 ac fc ff ff       	call   800eda <fd_lookup>
  80122e:	83 c4 08             	add    $0x8,%esp
  801231:	89 c2                	mov    %eax,%edx
  801233:	85 c0                	test   %eax,%eax
  801235:	78 68                	js     80129f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	ff 30                	pushl  (%eax)
  801243:	e8 e8 fc ff ff       	call   800f30 <dev_lookup>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 47                	js     801296 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801256:	75 21                	jne    801279 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801258:	a1 20 60 80 00       	mov    0x806020,%eax
  80125d:	8b 40 48             	mov    0x48(%eax),%eax
  801260:	83 ec 04             	sub    $0x4,%esp
  801263:	53                   	push   %ebx
  801264:	50                   	push   %eax
  801265:	68 4c 24 80 00       	push   $0x80244c
  80126a:	e8 fd ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801277:	eb 26                	jmp    80129f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801279:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127c:	8b 52 0c             	mov    0xc(%edx),%edx
  80127f:	85 d2                	test   %edx,%edx
  801281:	74 17                	je     80129a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801283:	83 ec 04             	sub    $0x4,%esp
  801286:	ff 75 10             	pushl  0x10(%ebp)
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	50                   	push   %eax
  80128d:	ff d2                	call   *%edx
  80128f:	89 c2                	mov    %eax,%edx
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	eb 09                	jmp    80129f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801296:	89 c2                	mov    %eax,%edx
  801298:	eb 05                	jmp    80129f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80129a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80129f:	89 d0                	mov    %edx,%eax
  8012a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a4:	c9                   	leave  
  8012a5:	c3                   	ret    

008012a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	ff 75 08             	pushl  0x8(%ebp)
  8012b3:	e8 22 fc ff ff       	call   800eda <fd_lookup>
  8012b8:	83 c4 08             	add    $0x8,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 0e                	js     8012cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	53                   	push   %ebx
  8012de:	e8 f7 fb ff ff       	call   800eda <fd_lookup>
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 65                	js     801351 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	ff 30                	pushl  (%eax)
  8012f8:	e8 33 fc ff ff       	call   800f30 <dev_lookup>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 44                	js     801348 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130b:	75 21                	jne    80132e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130d:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801312:	8b 40 48             	mov    0x48(%eax),%eax
  801315:	83 ec 04             	sub    $0x4,%esp
  801318:	53                   	push   %ebx
  801319:	50                   	push   %eax
  80131a:	68 0c 24 80 00       	push   $0x80240c
  80131f:	e8 48 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132c:	eb 23                	jmp    801351 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80132e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801331:	8b 52 18             	mov    0x18(%edx),%edx
  801334:	85 d2                	test   %edx,%edx
  801336:	74 14                	je     80134c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	ff 75 0c             	pushl  0xc(%ebp)
  80133e:	50                   	push   %eax
  80133f:	ff d2                	call   *%edx
  801341:	89 c2                	mov    %eax,%edx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	eb 09                	jmp    801351 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801348:	89 c2                	mov    %eax,%edx
  80134a:	eb 05                	jmp    801351 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801351:	89 d0                	mov    %edx,%eax
  801353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	53                   	push   %ebx
  80135c:	83 ec 14             	sub    $0x14,%esp
  80135f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801362:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	ff 75 08             	pushl  0x8(%ebp)
  801369:	e8 6c fb ff ff       	call   800eda <fd_lookup>
  80136e:	83 c4 08             	add    $0x8,%esp
  801371:	89 c2                	mov    %eax,%edx
  801373:	85 c0                	test   %eax,%eax
  801375:	78 58                	js     8013cf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	ff 30                	pushl  (%eax)
  801383:	e8 a8 fb ff ff       	call   800f30 <dev_lookup>
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 37                	js     8013c6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801392:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801396:	74 32                	je     8013ca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801398:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80139b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a2:	00 00 00 
	stat->st_isdir = 0;
  8013a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ac:	00 00 00 
	stat->st_dev = dev;
  8013af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013bc:	ff 50 14             	call   *0x14(%eax)
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	eb 09                	jmp    8013cf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	eb 05                	jmp    8013cf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013cf:	89 d0                	mov    %edx,%eax
  8013d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	6a 00                	push   $0x0
  8013e0:	ff 75 08             	pushl  0x8(%ebp)
  8013e3:	e8 e9 01 00 00       	call   8015d1 <open>
  8013e8:	89 c3                	mov    %eax,%ebx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 1b                	js     80140c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	ff 75 0c             	pushl  0xc(%ebp)
  8013f7:	50                   	push   %eax
  8013f8:	e8 5b ff ff ff       	call   801358 <fstat>
  8013fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ff:	89 1c 24             	mov    %ebx,(%esp)
  801402:	e8 fd fb ff ff       	call   801004 <close>
	return r;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	89 f0                	mov    %esi,%eax
}
  80140c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    

00801413 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	89 c6                	mov    %eax,%esi
  80141a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801423:	75 12                	jne    801437 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	6a 01                	push   $0x1
  80142a:	e8 0b 09 00 00       	call   801d3a <ipc_find_env>
  80142f:	a3 00 40 80 00       	mov    %eax,0x804000
  801434:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801437:	6a 07                	push   $0x7
  801439:	68 00 70 80 00       	push   $0x807000
  80143e:	56                   	push   %esi
  80143f:	ff 35 00 40 80 00    	pushl  0x804000
  801445:	e8 9c 08 00 00       	call   801ce6 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80144a:	83 c4 0c             	add    $0xc,%esp
  80144d:	6a 00                	push   $0x0
  80144f:	53                   	push   %ebx
  801450:	6a 00                	push   $0x0
  801452:	e8 0d 08 00 00       	call   801c64 <ipc_recv>
}
  801457:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	8b 40 0c             	mov    0xc(%eax),%eax
  80146a:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80146f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801472:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801477:	ba 00 00 00 00       	mov    $0x0,%edx
  80147c:	b8 02 00 00 00       	mov    $0x2,%eax
  801481:	e8 8d ff ff ff       	call   801413 <fsipc>
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148e:	8b 45 08             	mov    0x8(%ebp),%eax
  801491:	8b 40 0c             	mov    0xc(%eax),%eax
  801494:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801499:	ba 00 00 00 00       	mov    $0x0,%edx
  80149e:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a3:	e8 6b ff ff ff       	call   801413 <fsipc>
}
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ba:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c9:	e8 45 ff ff ff       	call   801413 <fsipc>
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 2c                	js     8014fe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	68 00 70 80 00       	push   $0x807000
  8014da:	53                   	push   %ebx
  8014db:	e8 90 f3 ff ff       	call   800870 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e0:	a1 80 70 80 00       	mov    0x807080,%eax
  8014e5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014eb:	a1 84 70 80 00       	mov    0x807084,%eax
  8014f0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	8b 45 10             	mov    0x10(%ebp),%eax
  80150c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801511:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801516:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801519:	8b 55 08             	mov    0x8(%ebp),%edx
  80151c:	8b 52 0c             	mov    0xc(%edx),%edx
  80151f:	89 15 00 70 80 00    	mov    %edx,0x807000
    fsipcbuf.write.req_n = n;
  801525:	a3 04 70 80 00       	mov    %eax,0x807004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80152a:	50                   	push   %eax
  80152b:	ff 75 0c             	pushl  0xc(%ebp)
  80152e:	68 08 70 80 00       	push   $0x807008
  801533:	e8 ca f4 ff ff       	call   800a02 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801538:	ba 00 00 00 00       	mov    $0x0,%edx
  80153d:	b8 04 00 00 00       	mov    $0x4,%eax
  801542:	e8 cc fe ff ff       	call   801413 <fsipc>
            return r;

    return r;
}
  801547:	c9                   	leave  
  801548:	c3                   	ret    

00801549 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	56                   	push   %esi
  80154d:	53                   	push   %ebx
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801551:	8b 45 08             	mov    0x8(%ebp),%eax
  801554:	8b 40 0c             	mov    0xc(%eax),%eax
  801557:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80155c:	89 35 04 70 80 00    	mov    %esi,0x807004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801562:	ba 00 00 00 00       	mov    $0x0,%edx
  801567:	b8 03 00 00 00       	mov    $0x3,%eax
  80156c:	e8 a2 fe ff ff       	call   801413 <fsipc>
  801571:	89 c3                	mov    %eax,%ebx
  801573:	85 c0                	test   %eax,%eax
  801575:	78 51                	js     8015c8 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801577:	39 c6                	cmp    %eax,%esi
  801579:	73 19                	jae    801594 <devfile_read+0x4b>
  80157b:	68 7c 24 80 00       	push   $0x80247c
  801580:	68 83 24 80 00       	push   $0x802483
  801585:	68 82 00 00 00       	push   $0x82
  80158a:	68 98 24 80 00       	push   $0x802498
  80158f:	e8 ff eb ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  801594:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801599:	7e 19                	jle    8015b4 <devfile_read+0x6b>
  80159b:	68 a3 24 80 00       	push   $0x8024a3
  8015a0:	68 83 24 80 00       	push   $0x802483
  8015a5:	68 83 00 00 00       	push   $0x83
  8015aa:	68 98 24 80 00       	push   $0x802498
  8015af:	e8 df eb ff ff       	call   800193 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	50                   	push   %eax
  8015b8:	68 00 70 80 00       	push   $0x807000
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	e8 3d f4 ff ff       	call   800a02 <memmove>
	return r;
  8015c5:	83 c4 10             	add    $0x10,%esp
}
  8015c8:	89 d8                	mov    %ebx,%eax
  8015ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 20             	sub    $0x20,%esp
  8015d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015db:	53                   	push   %ebx
  8015dc:	e8 56 f2 ff ff       	call   800837 <strlen>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e9:	7f 67                	jg     801652 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015eb:	83 ec 0c             	sub    $0xc,%esp
  8015ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	e8 94 f8 ff ff       	call   800e8b <fd_alloc>
  8015f7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015fa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 57                	js     801657 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	53                   	push   %ebx
  801604:	68 00 70 80 00       	push   $0x807000
  801609:	e8 62 f2 ff ff       	call   800870 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801611:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	b8 01 00 00 00       	mov    $0x1,%eax
  80161e:	e8 f0 fd ff ff       	call   801413 <fsipc>
  801623:	89 c3                	mov    %eax,%ebx
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	79 14                	jns    801640 <open+0x6f>
		fd_close(fd, 0);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	6a 00                	push   $0x0
  801631:	ff 75 f4             	pushl  -0xc(%ebp)
  801634:	e8 4a f9 ff ff       	call   800f83 <fd_close>
		return r;
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	89 da                	mov    %ebx,%edx
  80163e:	eb 17                	jmp    801657 <open+0x86>
	}

	return fd2num(fd);
  801640:	83 ec 0c             	sub    $0xc,%esp
  801643:	ff 75 f4             	pushl  -0xc(%ebp)
  801646:	e8 19 f8 ff ff       	call   800e64 <fd2num>
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 05                	jmp    801657 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801652:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801657:	89 d0                	mov    %edx,%eax
  801659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801664:	ba 00 00 00 00       	mov    $0x0,%edx
  801669:	b8 08 00 00 00       	mov    $0x8,%eax
  80166e:	e8 a0 fd ff ff       	call   801413 <fsipc>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801675:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801679:	7e 37                	jle    8016b2 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801684:	ff 70 04             	pushl  0x4(%eax)
  801687:	8d 40 10             	lea    0x10(%eax),%eax
  80168a:	50                   	push   %eax
  80168b:	ff 33                	pushl  (%ebx)
  80168d:	e8 88 fb ff ff       	call   80121a <write>
		if (result > 0)
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	85 c0                	test   %eax,%eax
  801697:	7e 03                	jle    80169c <writebuf+0x27>
			b->result += result;
  801699:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80169c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80169f:	74 0d                	je     8016ae <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	0f 4f c2             	cmovg  %edx,%eax
  8016ab:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b1:	c9                   	leave  
  8016b2:	f3 c3                	repz ret 

008016b4 <putch>:

static void
putch(int ch, void *thunk)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 04             	sub    $0x4,%esp
  8016bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016be:	8b 53 04             	mov    0x4(%ebx),%edx
  8016c1:	8d 42 01             	lea    0x1(%edx),%eax
  8016c4:	89 43 04             	mov    %eax,0x4(%ebx)
  8016c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ca:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016ce:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016d3:	75 0e                	jne    8016e3 <putch+0x2f>
		writebuf(b);
  8016d5:	89 d8                	mov    %ebx,%eax
  8016d7:	e8 99 ff ff ff       	call   801675 <writebuf>
		b->idx = 0;
  8016dc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016e3:	83 c4 04             	add    $0x4,%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016fb:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801702:	00 00 00 
	b.result = 0;
  801705:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80170c:	00 00 00 
	b.error = 1;
  80170f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801716:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801719:	ff 75 10             	pushl  0x10(%ebp)
  80171c:	ff 75 0c             	pushl  0xc(%ebp)
  80171f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	68 b4 16 80 00       	push   $0x8016b4
  80172b:	e8 39 ec ff ff       	call   800369 <vprintfmt>
	if (b.idx > 0)
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80173a:	7e 0b                	jle    801747 <vfprintf+0x5e>
		writebuf(&b);
  80173c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801742:	e8 2e ff ff ff       	call   801675 <writebuf>

	return (b.result ? b.result : b.error);
  801747:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80174d:	85 c0                	test   %eax,%eax
  80174f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80175e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801761:	50                   	push   %eax
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	ff 75 08             	pushl  0x8(%ebp)
  801768:	e8 7c ff ff ff       	call   8016e9 <vfprintf>
	va_end(ap);

	return cnt;
}
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <printf>:

int
printf(const char *fmt, ...)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801775:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801778:	50                   	push   %eax
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	6a 01                	push   $0x1
  80177e:	e8 66 ff ff ff       	call   8016e9 <vfprintf>
	va_end(ap);

	return cnt;
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	ff 75 08             	pushl  0x8(%ebp)
  801793:	e8 dc f6 ff ff       	call   800e74 <fd2data>
  801798:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80179a:	83 c4 08             	add    $0x8,%esp
  80179d:	68 af 24 80 00       	push   $0x8024af
  8017a2:	53                   	push   %ebx
  8017a3:	e8 c8 f0 ff ff       	call   800870 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017a8:	8b 46 04             	mov    0x4(%esi),%eax
  8017ab:	2b 06                	sub    (%esi),%eax
  8017ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ba:	00 00 00 
	stat->st_dev = &devpipe;
  8017bd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017c4:	30 80 00 
	return 0;
}
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017dd:	53                   	push   %ebx
  8017de:	6a 00                	push   $0x0
  8017e0:	e8 13 f5 ff ff       	call   800cf8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017e5:	89 1c 24             	mov    %ebx,(%esp)
  8017e8:	e8 87 f6 ff ff       	call   800e74 <fd2data>
  8017ed:	83 c4 08             	add    $0x8,%esp
  8017f0:	50                   	push   %eax
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 00 f5 ff ff       	call   800cf8 <sys_page_unmap>
}
  8017f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	83 ec 1c             	sub    $0x1c,%esp
  801806:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801809:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80180b:	a1 20 60 80 00       	mov    0x806020,%eax
  801810:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	ff 75 e0             	pushl  -0x20(%ebp)
  801819:	e8 55 05 00 00       	call   801d73 <pageref>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	89 3c 24             	mov    %edi,(%esp)
  801823:	e8 4b 05 00 00       	call   801d73 <pageref>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	39 c3                	cmp    %eax,%ebx
  80182d:	0f 94 c1             	sete   %cl
  801830:	0f b6 c9             	movzbl %cl,%ecx
  801833:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801836:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80183c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80183f:	39 ce                	cmp    %ecx,%esi
  801841:	74 1b                	je     80185e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801843:	39 c3                	cmp    %eax,%ebx
  801845:	75 c4                	jne    80180b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801847:	8b 42 58             	mov    0x58(%edx),%eax
  80184a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80184d:	50                   	push   %eax
  80184e:	56                   	push   %esi
  80184f:	68 b6 24 80 00       	push   $0x8024b6
  801854:	e8 13 ea ff ff       	call   80026c <cprintf>
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	eb ad                	jmp    80180b <_pipeisclosed+0xe>
	}
}
  80185e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801861:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5f                   	pop    %edi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	83 ec 28             	sub    $0x28,%esp
  801872:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801875:	56                   	push   %esi
  801876:	e8 f9 f5 ff ff       	call   800e74 <fd2data>
  80187b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	bf 00 00 00 00       	mov    $0x0,%edi
  801885:	eb 4b                	jmp    8018d2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801887:	89 da                	mov    %ebx,%edx
  801889:	89 f0                	mov    %esi,%eax
  80188b:	e8 6d ff ff ff       	call   8017fd <_pipeisclosed>
  801890:	85 c0                	test   %eax,%eax
  801892:	75 48                	jne    8018dc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801894:	e8 bb f3 ff ff       	call   800c54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801899:	8b 43 04             	mov    0x4(%ebx),%eax
  80189c:	8b 0b                	mov    (%ebx),%ecx
  80189e:	8d 51 20             	lea    0x20(%ecx),%edx
  8018a1:	39 d0                	cmp    %edx,%eax
  8018a3:	73 e2                	jae    801887 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018ac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018af:	89 c2                	mov    %eax,%edx
  8018b1:	c1 fa 1f             	sar    $0x1f,%edx
  8018b4:	89 d1                	mov    %edx,%ecx
  8018b6:	c1 e9 1b             	shr    $0x1b,%ecx
  8018b9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018bc:	83 e2 1f             	and    $0x1f,%edx
  8018bf:	29 ca                	sub    %ecx,%edx
  8018c1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018c9:	83 c0 01             	add    $0x1,%eax
  8018cc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018cf:	83 c7 01             	add    $0x1,%edi
  8018d2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018d5:	75 c2                	jne    801899 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018da:	eb 05                	jmp    8018e1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018dc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5f                   	pop    %edi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	57                   	push   %edi
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 18             	sub    $0x18,%esp
  8018f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018f5:	57                   	push   %edi
  8018f6:	e8 79 f5 ff ff       	call   800e74 <fd2data>
  8018fb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	bb 00 00 00 00       	mov    $0x0,%ebx
  801905:	eb 3d                	jmp    801944 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801907:	85 db                	test   %ebx,%ebx
  801909:	74 04                	je     80190f <devpipe_read+0x26>
				return i;
  80190b:	89 d8                	mov    %ebx,%eax
  80190d:	eb 44                	jmp    801953 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80190f:	89 f2                	mov    %esi,%edx
  801911:	89 f8                	mov    %edi,%eax
  801913:	e8 e5 fe ff ff       	call   8017fd <_pipeisclosed>
  801918:	85 c0                	test   %eax,%eax
  80191a:	75 32                	jne    80194e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80191c:	e8 33 f3 ff ff       	call   800c54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801921:	8b 06                	mov    (%esi),%eax
  801923:	3b 46 04             	cmp    0x4(%esi),%eax
  801926:	74 df                	je     801907 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801928:	99                   	cltd   
  801929:	c1 ea 1b             	shr    $0x1b,%edx
  80192c:	01 d0                	add    %edx,%eax
  80192e:	83 e0 1f             	and    $0x1f,%eax
  801931:	29 d0                	sub    %edx,%eax
  801933:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80193e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801941:	83 c3 01             	add    $0x1,%ebx
  801944:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801947:	75 d8                	jne    801921 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801949:	8b 45 10             	mov    0x10(%ebp),%eax
  80194c:	eb 05                	jmp    801953 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801953:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5f                   	pop    %edi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	50                   	push   %eax
  801967:	e8 1f f5 ff ff       	call   800e8b <fd_alloc>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	89 c2                	mov    %eax,%edx
  801971:	85 c0                	test   %eax,%eax
  801973:	0f 88 2c 01 00 00    	js     801aa5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801979:	83 ec 04             	sub    $0x4,%esp
  80197c:	68 07 04 00 00       	push   $0x407
  801981:	ff 75 f4             	pushl  -0xc(%ebp)
  801984:	6a 00                	push   $0x0
  801986:	e8 e8 f2 ff ff       	call   800c73 <sys_page_alloc>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	89 c2                	mov    %eax,%edx
  801990:	85 c0                	test   %eax,%eax
  801992:	0f 88 0d 01 00 00    	js     801aa5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199e:	50                   	push   %eax
  80199f:	e8 e7 f4 ff ff       	call   800e8b <fd_alloc>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	0f 88 e2 00 00 00    	js     801a93 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b1:	83 ec 04             	sub    $0x4,%esp
  8019b4:	68 07 04 00 00       	push   $0x407
  8019b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bc:	6a 00                	push   $0x0
  8019be:	e8 b0 f2 ff ff       	call   800c73 <sys_page_alloc>
  8019c3:	89 c3                	mov    %eax,%ebx
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	0f 88 c3 00 00 00    	js     801a93 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019d0:	83 ec 0c             	sub    $0xc,%esp
  8019d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d6:	e8 99 f4 ff ff       	call   800e74 <fd2data>
  8019db:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019dd:	83 c4 0c             	add    $0xc,%esp
  8019e0:	68 07 04 00 00       	push   $0x407
  8019e5:	50                   	push   %eax
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 86 f2 ff ff       	call   800c73 <sys_page_alloc>
  8019ed:	89 c3                	mov    %eax,%ebx
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	0f 88 89 00 00 00    	js     801a83 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801a00:	e8 6f f4 ff ff       	call   800e74 <fd2data>
  801a05:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a0c:	50                   	push   %eax
  801a0d:	6a 00                	push   $0x0
  801a0f:	56                   	push   %esi
  801a10:	6a 00                	push   $0x0
  801a12:	e8 9f f2 ff ff       	call   800cb6 <sys_page_map>
  801a17:	89 c3                	mov    %eax,%ebx
  801a19:	83 c4 20             	add    $0x20,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 55                	js     801a75 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a20:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a29:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a43:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a50:	e8 0f f4 ff ff       	call   800e64 <fd2num>
  801a55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a58:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a5a:	83 c4 04             	add    $0x4,%esp
  801a5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a60:	e8 ff f3 ff ff       	call   800e64 <fd2num>
  801a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a68:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a73:	eb 30                	jmp    801aa5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	56                   	push   %esi
  801a79:	6a 00                	push   $0x0
  801a7b:	e8 78 f2 ff ff       	call   800cf8 <sys_page_unmap>
  801a80:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	ff 75 f0             	pushl  -0x10(%ebp)
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 68 f2 ff ff       	call   800cf8 <sys_page_unmap>
  801a90:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	ff 75 f4             	pushl  -0xc(%ebp)
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 58 f2 ff ff       	call   800cf8 <sys_page_unmap>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801aa5:	89 d0                	mov    %edx,%eax
  801aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	ff 75 08             	pushl  0x8(%ebp)
  801abb:	e8 1a f4 ff ff       	call   800eda <fd_lookup>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 18                	js     801adf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	ff 75 f4             	pushl  -0xc(%ebp)
  801acd:	e8 a2 f3 ff ff       	call   800e74 <fd2data>
	return _pipeisclosed(fd, p);
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	e8 21 fd ff ff       	call   8017fd <_pipeisclosed>
  801adc:	83 c4 10             	add    $0x10,%esp
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801af1:	68 ce 24 80 00       	push   $0x8024ce
  801af6:	ff 75 0c             	pushl  0xc(%ebp)
  801af9:	e8 72 ed ff ff       	call   800870 <strcpy>
	return 0;
}
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	57                   	push   %edi
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b11:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b16:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b1c:	eb 2d                	jmp    801b4b <devcons_write+0x46>
		m = n - tot;
  801b1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b21:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b23:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b26:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b2b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b2e:	83 ec 04             	sub    $0x4,%esp
  801b31:	53                   	push   %ebx
  801b32:	03 45 0c             	add    0xc(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	57                   	push   %edi
  801b37:	e8 c6 ee ff ff       	call   800a02 <memmove>
		sys_cputs(buf, m);
  801b3c:	83 c4 08             	add    $0x8,%esp
  801b3f:	53                   	push   %ebx
  801b40:	57                   	push   %edi
  801b41:	e8 71 f0 ff ff       	call   800bb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b46:	01 de                	add    %ebx,%esi
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b50:	72 cc                	jb     801b1e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b69:	74 2a                	je     801b95 <devcons_read+0x3b>
  801b6b:	eb 05                	jmp    801b72 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b6d:	e8 e2 f0 ff ff       	call   800c54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b72:	e8 5e f0 ff ff       	call   800bd5 <sys_cgetc>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	74 f2                	je     801b6d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 16                	js     801b95 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b7f:	83 f8 04             	cmp    $0x4,%eax
  801b82:	74 0c                	je     801b90 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b87:	88 02                	mov    %al,(%edx)
	return 1;
  801b89:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8e:	eb 05                	jmp    801b95 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    

00801b97 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ba3:	6a 01                	push   $0x1
  801ba5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 09 f0 ff ff       	call   800bb7 <sys_cputs>
}
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <getchar>:

int
getchar(void)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb9:	6a 01                	push   $0x1
  801bbb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbe:	50                   	push   %eax
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 7a f5 ff ff       	call   801140 <read>
	if (r < 0)
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 0f                	js     801bdc <getchar+0x29>
		return r;
	if (r < 1)
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	7e 06                	jle    801bd7 <getchar+0x24>
		return -E_EOF;
	return c;
  801bd1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bd5:	eb 05                	jmp    801bdc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bd7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be7:	50                   	push   %eax
  801be8:	ff 75 08             	pushl  0x8(%ebp)
  801beb:	e8 ea f2 ff ff       	call   800eda <fd_lookup>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 11                	js     801c08 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c00:	39 10                	cmp    %edx,(%eax)
  801c02:	0f 94 c0             	sete   %al
  801c05:	0f b6 c0             	movzbl %al,%eax
}
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <opencons>:

int
opencons(void)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	e8 72 f2 ff ff       	call   800e8b <fd_alloc>
  801c19:	83 c4 10             	add    $0x10,%esp
		return r;
  801c1c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 3e                	js     801c60 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c22:	83 ec 04             	sub    $0x4,%esp
  801c25:	68 07 04 00 00       	push   $0x407
  801c2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 3f f0 ff ff       	call   800c73 <sys_page_alloc>
  801c34:	83 c4 10             	add    $0x10,%esp
		return r;
  801c37:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 23                	js     801c60 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c52:	83 ec 0c             	sub    $0xc,%esp
  801c55:	50                   	push   %eax
  801c56:	e8 09 f2 ff ff       	call   800e64 <fd2num>
  801c5b:	89 c2                	mov    %eax,%edx
  801c5d:	83 c4 10             	add    $0x10,%esp
}
  801c60:	89 d0                	mov    %edx,%eax
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	57                   	push   %edi
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801c76:	85 f6                	test   %esi,%esi
  801c78:	74 06                	je     801c80 <ipc_recv+0x1c>
		*from_env_store = 0;
  801c7a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801c80:	85 db                	test   %ebx,%ebx
  801c82:	74 06                	je     801c8a <ipc_recv+0x26>
		*perm_store = 0;
  801c84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801c8a:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801c8c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c91:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	50                   	push   %eax
  801c98:	e8 86 f1 ff ff       	call   800e23 <sys_ipc_recv>
  801c9d:	89 c7                	mov    %eax,%edi
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	79 14                	jns    801cba <ipc_recv+0x56>
		cprintf("im dead");
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	68 da 24 80 00       	push   $0x8024da
  801cae:	e8 b9 e5 ff ff       	call   80026c <cprintf>
		return r;
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	89 f8                	mov    %edi,%eax
  801cb8:	eb 24                	jmp    801cde <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801cba:	85 f6                	test   %esi,%esi
  801cbc:	74 0a                	je     801cc8 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801cbe:	a1 20 60 80 00       	mov    0x806020,%eax
  801cc3:	8b 40 74             	mov    0x74(%eax),%eax
  801cc6:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801cc8:	85 db                	test   %ebx,%ebx
  801cca:	74 0a                	je     801cd6 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ccc:	a1 20 60 80 00       	mov    0x806020,%eax
  801cd1:	8b 40 78             	mov    0x78(%eax),%eax
  801cd4:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801cd6:	a1 20 60 80 00       	mov    0x806020,%eax
  801cdb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801cf8:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801cfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801cff:	0f 44 d8             	cmove  %eax,%ebx
  801d02:	eb 1c                	jmp    801d20 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801d04:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d07:	74 12                	je     801d1b <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801d09:	50                   	push   %eax
  801d0a:	68 e2 24 80 00       	push   $0x8024e2
  801d0f:	6a 4e                	push   $0x4e
  801d11:	68 ef 24 80 00       	push   $0x8024ef
  801d16:	e8 78 e4 ff ff       	call   800193 <_panic>
		sys_yield();
  801d1b:	e8 34 ef ff ff       	call   800c54 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d20:	ff 75 14             	pushl  0x14(%ebp)
  801d23:	53                   	push   %ebx
  801d24:	56                   	push   %esi
  801d25:	57                   	push   %edi
  801d26:	e8 d5 f0 ff ff       	call   800e00 <sys_ipc_try_send>
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 d2                	js     801d04 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d45:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d48:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d4e:	8b 52 50             	mov    0x50(%edx),%edx
  801d51:	39 ca                	cmp    %ecx,%edx
  801d53:	75 0d                	jne    801d62 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d55:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d5d:	8b 40 48             	mov    0x48(%eax),%eax
  801d60:	eb 0f                	jmp    801d71 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d62:	83 c0 01             	add    $0x1,%eax
  801d65:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d6a:	75 d9                	jne    801d45 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d79:	89 d0                	mov    %edx,%eax
  801d7b:	c1 e8 16             	shr    $0x16,%eax
  801d7e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d8a:	f6 c1 01             	test   $0x1,%cl
  801d8d:	74 1d                	je     801dac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d8f:	c1 ea 0c             	shr    $0xc,%edx
  801d92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d99:	f6 c2 01             	test   $0x1,%dl
  801d9c:	74 0e                	je     801dac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d9e:	c1 ea 0c             	shr    $0xc,%edx
  801da1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801da8:	ef 
  801da9:	0f b7 c0             	movzwl %ax,%eax
}
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__udivdi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801dbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801dbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 f6                	test   %esi,%esi
  801dc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dcd:	89 ca                	mov    %ecx,%edx
  801dcf:	89 f8                	mov    %edi,%eax
  801dd1:	75 3d                	jne    801e10 <__udivdi3+0x60>
  801dd3:	39 cf                	cmp    %ecx,%edi
  801dd5:	0f 87 c5 00 00 00    	ja     801ea0 <__udivdi3+0xf0>
  801ddb:	85 ff                	test   %edi,%edi
  801ddd:	89 fd                	mov    %edi,%ebp
  801ddf:	75 0b                	jne    801dec <__udivdi3+0x3c>
  801de1:	b8 01 00 00 00       	mov    $0x1,%eax
  801de6:	31 d2                	xor    %edx,%edx
  801de8:	f7 f7                	div    %edi
  801dea:	89 c5                	mov    %eax,%ebp
  801dec:	89 c8                	mov    %ecx,%eax
  801dee:	31 d2                	xor    %edx,%edx
  801df0:	f7 f5                	div    %ebp
  801df2:	89 c1                	mov    %eax,%ecx
  801df4:	89 d8                	mov    %ebx,%eax
  801df6:	89 cf                	mov    %ecx,%edi
  801df8:	f7 f5                	div    %ebp
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	39 ce                	cmp    %ecx,%esi
  801e12:	77 74                	ja     801e88 <__udivdi3+0xd8>
  801e14:	0f bd fe             	bsr    %esi,%edi
  801e17:	83 f7 1f             	xor    $0x1f,%edi
  801e1a:	0f 84 98 00 00 00    	je     801eb8 <__udivdi3+0x108>
  801e20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e25:	89 f9                	mov    %edi,%ecx
  801e27:	89 c5                	mov    %eax,%ebp
  801e29:	29 fb                	sub    %edi,%ebx
  801e2b:	d3 e6                	shl    %cl,%esi
  801e2d:	89 d9                	mov    %ebx,%ecx
  801e2f:	d3 ed                	shr    %cl,%ebp
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	d3 e0                	shl    %cl,%eax
  801e35:	09 ee                	or     %ebp,%esi
  801e37:	89 d9                	mov    %ebx,%ecx
  801e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3d:	89 d5                	mov    %edx,%ebp
  801e3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e43:	d3 ed                	shr    %cl,%ebp
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	d3 e2                	shl    %cl,%edx
  801e49:	89 d9                	mov    %ebx,%ecx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	09 c2                	or     %eax,%edx
  801e4f:	89 d0                	mov    %edx,%eax
  801e51:	89 ea                	mov    %ebp,%edx
  801e53:	f7 f6                	div    %esi
  801e55:	89 d5                	mov    %edx,%ebp
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	f7 64 24 0c          	mull   0xc(%esp)
  801e5d:	39 d5                	cmp    %edx,%ebp
  801e5f:	72 10                	jb     801e71 <__udivdi3+0xc1>
  801e61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	d3 e6                	shl    %cl,%esi
  801e69:	39 c6                	cmp    %eax,%esi
  801e6b:	73 07                	jae    801e74 <__udivdi3+0xc4>
  801e6d:	39 d5                	cmp    %edx,%ebp
  801e6f:	75 03                	jne    801e74 <__udivdi3+0xc4>
  801e71:	83 eb 01             	sub    $0x1,%ebx
  801e74:	31 ff                	xor    %edi,%edi
  801e76:	89 d8                	mov    %ebx,%eax
  801e78:	89 fa                	mov    %edi,%edx
  801e7a:	83 c4 1c             	add    $0x1c,%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    
  801e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e88:	31 ff                	xor    %edi,%edi
  801e8a:	31 db                	xor    %ebx,%ebx
  801e8c:	89 d8                	mov    %ebx,%eax
  801e8e:	89 fa                	mov    %edi,%edx
  801e90:	83 c4 1c             	add    $0x1c,%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    
  801e98:	90                   	nop
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	89 d8                	mov    %ebx,%eax
  801ea2:	f7 f7                	div    %edi
  801ea4:	31 ff                	xor    %edi,%edi
  801ea6:	89 c3                	mov    %eax,%ebx
  801ea8:	89 d8                	mov    %ebx,%eax
  801eaa:	89 fa                	mov    %edi,%edx
  801eac:	83 c4 1c             	add    $0x1c,%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5f                   	pop    %edi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    
  801eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb8:	39 ce                	cmp    %ecx,%esi
  801eba:	72 0c                	jb     801ec8 <__udivdi3+0x118>
  801ebc:	31 db                	xor    %ebx,%ebx
  801ebe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ec2:	0f 87 34 ff ff ff    	ja     801dfc <__udivdi3+0x4c>
  801ec8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ecd:	e9 2a ff ff ff       	jmp    801dfc <__udivdi3+0x4c>
  801ed2:	66 90                	xchg   %ax,%ax
  801ed4:	66 90                	xchg   %ax,%ax
  801ed6:	66 90                	xchg   %ax,%ax
  801ed8:	66 90                	xchg   %ax,%ax
  801eda:	66 90                	xchg   %ax,%ax
  801edc:	66 90                	xchg   %ax,%ax
  801ede:	66 90                	xchg   %ax,%ax

00801ee0 <__umoddi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801eeb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801eef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 d2                	test   %edx,%edx
  801ef9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f01:	89 f3                	mov    %esi,%ebx
  801f03:	89 3c 24             	mov    %edi,(%esp)
  801f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0a:	75 1c                	jne    801f28 <__umoddi3+0x48>
  801f0c:	39 f7                	cmp    %esi,%edi
  801f0e:	76 50                	jbe    801f60 <__umoddi3+0x80>
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	89 f2                	mov    %esi,%edx
  801f14:	f7 f7                	div    %edi
  801f16:	89 d0                	mov    %edx,%eax
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	83 c4 1c             	add    $0x1c,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
  801f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f28:	39 f2                	cmp    %esi,%edx
  801f2a:	89 d0                	mov    %edx,%eax
  801f2c:	77 52                	ja     801f80 <__umoddi3+0xa0>
  801f2e:	0f bd ea             	bsr    %edx,%ebp
  801f31:	83 f5 1f             	xor    $0x1f,%ebp
  801f34:	75 5a                	jne    801f90 <__umoddi3+0xb0>
  801f36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f3a:	0f 82 e0 00 00 00    	jb     802020 <__umoddi3+0x140>
  801f40:	39 0c 24             	cmp    %ecx,(%esp)
  801f43:	0f 86 d7 00 00 00    	jbe    802020 <__umoddi3+0x140>
  801f49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f51:	83 c4 1c             	add    $0x1c,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	85 ff                	test   %edi,%edi
  801f62:	89 fd                	mov    %edi,%ebp
  801f64:	75 0b                	jne    801f71 <__umoddi3+0x91>
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	f7 f7                	div    %edi
  801f6f:	89 c5                	mov    %eax,%ebp
  801f71:	89 f0                	mov    %esi,%eax
  801f73:	31 d2                	xor    %edx,%edx
  801f75:	f7 f5                	div    %ebp
  801f77:	89 c8                	mov    %ecx,%eax
  801f79:	f7 f5                	div    %ebp
  801f7b:	89 d0                	mov    %edx,%eax
  801f7d:	eb 99                	jmp    801f18 <__umoddi3+0x38>
  801f7f:	90                   	nop
  801f80:	89 c8                	mov    %ecx,%eax
  801f82:	89 f2                	mov    %esi,%edx
  801f84:	83 c4 1c             	add    $0x1c,%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5f                   	pop    %edi
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    
  801f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f90:	8b 34 24             	mov    (%esp),%esi
  801f93:	bf 20 00 00 00       	mov    $0x20,%edi
  801f98:	89 e9                	mov    %ebp,%ecx
  801f9a:	29 ef                	sub    %ebp,%edi
  801f9c:	d3 e0                	shl    %cl,%eax
  801f9e:	89 f9                	mov    %edi,%ecx
  801fa0:	89 f2                	mov    %esi,%edx
  801fa2:	d3 ea                	shr    %cl,%edx
  801fa4:	89 e9                	mov    %ebp,%ecx
  801fa6:	09 c2                	or     %eax,%edx
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	89 14 24             	mov    %edx,(%esp)
  801fad:	89 f2                	mov    %esi,%edx
  801faf:	d3 e2                	shl    %cl,%edx
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	89 e9                	mov    %ebp,%ecx
  801fbf:	89 c6                	mov    %eax,%esi
  801fc1:	d3 e3                	shl    %cl,%ebx
  801fc3:	89 f9                	mov    %edi,%ecx
  801fc5:	89 d0                	mov    %edx,%eax
  801fc7:	d3 e8                	shr    %cl,%eax
  801fc9:	89 e9                	mov    %ebp,%ecx
  801fcb:	09 d8                	or     %ebx,%eax
  801fcd:	89 d3                	mov    %edx,%ebx
  801fcf:	89 f2                	mov    %esi,%edx
  801fd1:	f7 34 24             	divl   (%esp)
  801fd4:	89 d6                	mov    %edx,%esi
  801fd6:	d3 e3                	shl    %cl,%ebx
  801fd8:	f7 64 24 04          	mull   0x4(%esp)
  801fdc:	39 d6                	cmp    %edx,%esi
  801fde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fe2:	89 d1                	mov    %edx,%ecx
  801fe4:	89 c3                	mov    %eax,%ebx
  801fe6:	72 08                	jb     801ff0 <__umoddi3+0x110>
  801fe8:	75 11                	jne    801ffb <__umoddi3+0x11b>
  801fea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fee:	73 0b                	jae    801ffb <__umoddi3+0x11b>
  801ff0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ff4:	1b 14 24             	sbb    (%esp),%edx
  801ff7:	89 d1                	mov    %edx,%ecx
  801ff9:	89 c3                	mov    %eax,%ebx
  801ffb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fff:	29 da                	sub    %ebx,%edx
  802001:	19 ce                	sbb    %ecx,%esi
  802003:	89 f9                	mov    %edi,%ecx
  802005:	89 f0                	mov    %esi,%eax
  802007:	d3 e0                	shl    %cl,%eax
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	d3 ea                	shr    %cl,%edx
  80200d:	89 e9                	mov    %ebp,%ecx
  80200f:	d3 ee                	shr    %cl,%esi
  802011:	09 d0                	or     %edx,%eax
  802013:	89 f2                	mov    %esi,%edx
  802015:	83 c4 1c             	add    $0x1c,%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    
  80201d:	8d 76 00             	lea    0x0(%esi),%esi
  802020:	29 f9                	sub    %edi,%ecx
  802022:	19 d6                	sbb    %edx,%esi
  802024:	89 74 24 04          	mov    %esi,0x4(%esp)
  802028:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80202c:	e9 18 ff ff ff       	jmp    801f49 <__umoddi3+0x69>
