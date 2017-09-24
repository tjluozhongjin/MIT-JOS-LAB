
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 5b 0b 00 00       	call   800b9d <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 80 22 80 00       	push   $0x802280
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 1c 07 00 00       	call   80079f <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 91 22 80 00       	push   $0x802291
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 e0 06 00 00       	call   800785 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 19 0e 00 00       	call   800ec6 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 90 22 80 00       	push   $0x802290
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 ac 0a 00 00       	call   800b9d <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 5d 11 00 00       	call   80128f <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 20 0a 00 00       	call   800b5c <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 ae 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 1a 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 53 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 a4 1d 00 00       	call   801fe0 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 91 1e 00 00       	call   802110 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 0a                	jae    8002b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	88 02                	mov    %al,(%edx)
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
	va_end(ap);
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 2c             	sub    $0x2c,%esp
  8002da:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e3:	eb 12                	jmp    8002f7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	0f 84 42 04 00 00    	je     80072f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	53                   	push   %ebx
  8002f1:	50                   	push   %eax
  8002f2:	ff d6                	call   *%esi
  8002f4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f7:	83 c7 01             	add    $0x1,%edi
  8002fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fe:	83 f8 25             	cmp    $0x25,%eax
  800301:	75 e2                	jne    8002e5 <vprintfmt+0x14>
  800303:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800307:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800315:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	eb 07                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800326:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 07             	movzbl (%edi),%eax
  800333:	0f b6 d0             	movzbl %al,%edx
  800336:	83 e8 23             	sub    $0x23,%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 d3 03 00 00    	ja     800714 <vprintfmt+0x443>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb d6                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
  80035c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800362:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800366:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800369:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036c:	83 f9 09             	cmp    $0x9,%ecx
  80036f:	77 3f                	ja     8003b0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800374:	eb e9                	jmp    80035f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 40 04             	lea    0x4(%eax),%eax
  800384:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 2a                	jmp    8003b6 <vprintfmt+0xe5>
  80038c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038f:	85 c0                	test   %eax,%eax
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
  800396:	0f 49 d0             	cmovns %eax,%edx
  800399:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039f:	eb 89                	jmp    80032a <vprintfmt+0x59>
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ab:	e9 7a ff ff ff       	jmp    80032a <vprintfmt+0x59>
  8003b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 6a ff ff ff    	jns    80032a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	e9 58 ff ff ff       	jmp    80032a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 4d ff ff ff       	jmp    80032a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 78 04             	lea    0x4(%eax),%edi
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	ff 30                	pushl  (%eax)
  8003e9:	ff d6                	call   *%esi
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 fe fe ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	99                   	cltd   
  800402:	31 d0                	xor    %edx,%eax
  800404:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x145>
  80040b:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 1b                	jne    800431 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 b8 22 80 00       	push   $0x8022b8
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 91 fe ff ff       	call   8002b4 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800426:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 c6 fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 41 27 80 00       	push   $0x802741
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 76 fe ff ff       	call   8002b4 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800441:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	e9 ab fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	83 c0 04             	add    $0x4,%eax
  800452:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045a:	85 ff                	test   %edi,%edi
  80045c:	b8 b1 22 80 00       	mov    $0x8022b1,%eax
  800461:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	0f 8e 94 00 00 00    	jle    800502 <vprintfmt+0x231>
  80046e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800472:	0f 84 98 00 00 00    	je     800510 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 d0             	pushl  -0x30(%ebp)
  80047e:	57                   	push   %edi
  80047f:	e8 33 03 00 00       	call   8007b7 <strnlen>
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	29 c1                	sub    %eax,%ecx
  800489:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800499:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0f                	jmp    8004ac <vprintfmt+0x1db>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	7f ed                	jg     80049d <vprintfmt+0x1cc>
  8004b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	0f 49 c1             	cmovns %ecx,%eax
  8004c0:	29 c1                	sub    %eax,%ecx
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	89 cb                	mov    %ecx,%ebx
  8004cd:	eb 4d                	jmp    80051c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d3:	74 1b                	je     8004f0 <vprintfmt+0x21f>
  8004d5:	0f be c0             	movsbl %al,%eax
  8004d8:	83 e8 20             	sub    $0x20,%eax
  8004db:	83 f8 5e             	cmp    $0x5e,%eax
  8004de:	76 10                	jbe    8004f0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	6a 3f                	push   $0x3f
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb 0d                	jmp    8004fd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	52                   	push   %edx
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	eb 1a                	jmp    80051c <vprintfmt+0x24b>
  800502:	89 75 08             	mov    %esi,0x8(%ebp)
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800508:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050e:	eb 0c                	jmp    80051c <vprintfmt+0x24b>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	83 c7 01             	add    $0x1,%edi
  80051f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800523:	0f be d0             	movsbl %al,%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	74 23                	je     80054d <vprintfmt+0x27c>
  80052a:	85 f6                	test   %esi,%esi
  80052c:	78 a1                	js     8004cf <vprintfmt+0x1fe>
  80052e:	83 ee 01             	sub    $0x1,%esi
  800531:	79 9c                	jns    8004cf <vprintfmt+0x1fe>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	eb 18                	jmp    800555 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 08                	jmp    800555 <vprintfmt+0x284>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	85 ff                	test   %edi,%edi
  800557:	7f e4                	jg     80053d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 90 fd ff ff       	jmp    8002f7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 19                	jle    800585 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 50 04             	mov    0x4(%eax),%edx
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 40 08             	lea    0x8(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
  800583:	eb 38                	jmp    8005bd <vprintfmt+0x2ec>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 1b                	je     8005a4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a2:	eb 19                	jmp    8005bd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cc:	0f 89 0e 01 00 00    	jns    8006e0 <vprintfmt+0x40f>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 d1 00             	adc    $0x0,%ecx
  8005e5:	f7 d9                	neg    %ecx
  8005e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 ec 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f4:	83 f9 01             	cmp    $0x1,%ecx
  8005f7:	7e 18                	jle    800611 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 cf 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 1a                	je     80062f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 b1 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 97 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 58                	push   $0x58
  80064f:	ff d6                	call   *%esi
			putch('X', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 58                	push   $0x58
  800657:	ff d6                	call   *%esi
			putch('X', putdat);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 58                	push   $0x58
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800667:	e9 8b fc ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 30                	push   $0x30
  800672:	ff d6                	call   *%esi
			putch('x', putdat);
  800674:	83 c4 08             	add    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 78                	push   $0x78
  80067a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800686:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800694:	eb 4a                	jmp    8006e0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800696:	83 f9 01             	cmp    $0x1,%ecx
  800699:	7e 15                	jle    8006b0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a3:	8d 40 08             	lea    0x8(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ae:	eb 30                	jmp    8006e0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	74 17                	je     8006cb <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c9:	eb 15                	jmp    8006e0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e0:	83 ec 0c             	sub    $0xc,%esp
  8006e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e7:	57                   	push   %edi
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	50                   	push   %eax
  8006ec:	51                   	push   %ecx
  8006ed:	52                   	push   %edx
  8006ee:	89 da                	mov    %ebx,%edx
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	e8 f1 fa ff ff       	call   8001e8 <printnum>
			break;
  8006f7:	83 c4 20             	add    $0x20,%esp
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fd:	e9 f5 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	52                   	push   %edx
  800707:	ff d6                	call   *%esi
			break;
  800709:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070f:	e9 e3 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 03                	jmp    800724 <vprintfmt+0x453>
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800728:	75 f7                	jne    800721 <vprintfmt+0x450>
  80072a:	e9 c8 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	5f                   	pop    %edi
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 18             	sub    $0x18,%esp
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800743:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800746:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800754:	85 c0                	test   %eax,%eax
  800756:	74 26                	je     80077e <vsnprintf+0x47>
  800758:	85 d2                	test   %edx,%edx
  80075a:	7e 22                	jle    80077e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075c:	ff 75 14             	pushl  0x14(%ebp)
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	68 97 02 80 00       	push   $0x800297
  80076b:	e8 61 fb ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800770:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800773:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	50                   	push   %eax
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 9a ff ff ff       	call   800737 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	eb 03                	jmp    8007af <strlen+0x10>
		n++;
  8007ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b3:	75 f7                	jne    8007ac <strlen+0xd>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c5:	eb 03                	jmp    8007ca <strnlen+0x13>
		n++;
  8007c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 08                	je     8007d6 <strnlen+0x1f>
  8007ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d2:	75 f3                	jne    8007c7 <strnlen+0x10>
  8007d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ef                	jne    8007e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ff:	53                   	push   %ebx
  800800:	e8 9a ff ff ff       	call   80079f <strlen>
  800805:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	01 d8                	add    %ebx,%eax
  80080d:	50                   	push   %eax
  80080e:	e8 c5 ff ff ff       	call   8007d8 <strcpy>
	return dst;
}
  800813:	89 d8                	mov    %ebx,%eax
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	89 f3                	mov    %esi,%ebx
  800827:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082a:	89 f2                	mov    %esi,%edx
  80082c:	eb 0f                	jmp    80083d <strncpy+0x23>
		*dst++ = *src;
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800837:	80 39 01             	cmpb   $0x1,(%ecx)
  80083a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	39 da                	cmp    %ebx,%edx
  80083f:	75 ed                	jne    80082e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800841:	89 f0                	mov    %esi,%eax
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	8b 55 10             	mov    0x10(%ebp),%edx
  800855:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 d2                	test   %edx,%edx
  800859:	74 21                	je     80087c <strlcpy+0x35>
  80085b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085f:	89 f2                	mov    %esi,%edx
  800861:	eb 09                	jmp    80086c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 09                	je     800879 <strlcpy+0x32>
  800870:	0f b6 19             	movzbl (%ecx),%ebx
  800873:	84 db                	test   %bl,%bl
  800875:	75 ec                	jne    800863 <strlcpy+0x1c>
  800877:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strcmp+0x11>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1c>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 ef                	je     80088d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x17>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 15                	je     8008d8 <strncmp+0x30>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x26>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
  8008d6:	eb 05                	jmp    8008dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 07                	jmp    8008f3 <strchr+0x13>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 0f                	je     8008ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 10             	movzbl (%eax),%edx
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	eb 03                	jmp    800910 <strfind+0xf>
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 04                	je     80091b <strfind+0x1a>
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f2                	jne    80090d <strfind+0xc>
			break;
	return (char *) s;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 36                	je     800963 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 28                	jne    80095d <memset+0x40>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 23                	jne    80095d <memset+0x40>
		c &= 0xFF;
  80093a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093e:	89 d3                	mov    %edx,%ebx
  800940:	c1 e3 08             	shl    $0x8,%ebx
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 18             	shl    $0x18,%esi
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 10             	shl    $0x10,%eax
  80094d:	09 f0                	or     %esi,%eax
  80094f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800951:	89 d8                	mov    %ebx,%eax
  800953:	09 d0                	or     %edx,%eax
  800955:	c1 e9 02             	shr    $0x2,%ecx
  800958:	fc                   	cld    
  800959:	f3 ab                	rep stos %eax,%es:(%edi)
  80095b:	eb 06                	jmp    800963 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	fc                   	cld    
  800961:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800963:	89 f8                	mov    %edi,%eax
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 75 0c             	mov    0xc(%ebp),%esi
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800978:	39 c6                	cmp    %eax,%esi
  80097a:	73 35                	jae    8009b1 <memmove+0x47>
  80097c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	73 2e                	jae    8009b1 <memmove+0x47>
		s += n;
		d += n;
  800983:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800986:	89 d6                	mov    %edx,%esi
  800988:	09 fe                	or     %edi,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 13                	jne    8009a5 <memmove+0x3b>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 0e                	jne    8009a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800997:	83 ef 04             	sub    $0x4,%edi
  80099a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	fd                   	std    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 09                	jmp    8009ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 1d                	jmp    8009ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	f6 c2 03             	test   $0x3,%dl
  8009b8:	75 0f                	jne    8009c9 <memmove+0x5f>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 87 ff ff ff       	call   80096a <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	eb 1a                	jmp    800a11 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	0f b6 1a             	movzbl (%edx),%ebx
  8009fd:	38 d9                	cmp    %bl,%cl
  8009ff:	74 0a                	je     800a0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c1             	movzbl %cl,%eax
  800a04:	0f b6 db             	movzbl %bl,%ebx
  800a07:	29 d8                	sub    %ebx,%eax
  800a09:	eb 0f                	jmp    800a1a <memcmp+0x35>
		s1++, s2++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	39 f0                	cmp    %esi,%eax
  800a13:	75 e2                	jne    8009f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a25:	89 c1                	mov    %eax,%ecx
  800a27:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2e:	eb 0a                	jmp    800a3a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	74 07                	je     800a3e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	39 c8                	cmp    %ecx,%eax
  800a3c:	72 f2                	jb     800a30 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	eb 03                	jmp    800a52 <strtol+0x11>
		s++;
  800a4f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	0f b6 01             	movzbl (%ecx),%eax
  800a55:	3c 20                	cmp    $0x20,%al
  800a57:	74 f6                	je     800a4f <strtol+0xe>
  800a59:	3c 09                	cmp    $0x9,%al
  800a5b:	74 f2                	je     800a4f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5d:	3c 2b                	cmp    $0x2b,%al
  800a5f:	75 0a                	jne    800a6b <strtol+0x2a>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a64:	bf 00 00 00 00       	mov    $0x0,%edi
  800a69:	eb 11                	jmp    800a7c <strtol+0x3b>
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a70:	3c 2d                	cmp    $0x2d,%al
  800a72:	75 08                	jne    800a7c <strtol+0x3b>
		s++, neg = 1;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a82:	75 15                	jne    800a99 <strtol+0x58>
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 10                	jne    800a99 <strtol+0x58>
  800a89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8d:	75 7c                	jne    800b0b <strtol+0xca>
		s += 2, base = 16;
  800a8f:	83 c1 02             	add    $0x2,%ecx
  800a92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a97:	eb 16                	jmp    800aaf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 12                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa5:	75 08                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab7:	0f b6 11             	movzbl (%ecx),%edx
  800aba:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 09             	cmp    $0x9,%bl
  800ac2:	77 08                	ja     800acc <strtol+0x8b>
			dig = *s - '0';
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 30             	sub    $0x30,%edx
  800aca:	eb 22                	jmp    800aee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 57             	sub    $0x57,%edx
  800adc:	eb 10                	jmp    800aee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 16                	ja     800afe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aee:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af1:	7d 0b                	jge    800afe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afc:	eb b9                	jmp    800ab7 <strtol+0x76>

	if (endptr)
  800afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b02:	74 0d                	je     800b11 <strtol+0xd0>
		*endptr = (char *) s;
  800b04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b07:	89 0e                	mov    %ecx,(%esi)
  800b09:	eb 06                	jmp    800b11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	74 98                	je     800aa7 <strtol+0x66>
  800b0f:	eb 9e                	jmp    800aaf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	f7 da                	neg    %edx
  800b15:	85 ff                	test   %edi,%edi
  800b17:	0f 45 c2             	cmovne %edx,%eax
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	89 c6                	mov    %eax,%esi
  800b36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	89 cb                	mov    %ecx,%ebx
  800b74:	89 cf                	mov    %ecx,%edi
  800b76:	89 ce                	mov    %ecx,%esi
  800b78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 03                	push   $0x3
  800b84:	68 9f 25 80 00       	push   $0x80259f
  800b89:	6a 23                	push   $0x23
  800b8b:	68 bc 25 80 00       	push   $0x8025bc
  800b90:	e8 1f 12 00 00       	call   801db4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_yield>:

void
sys_yield(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	be 00 00 00 00       	mov    $0x0,%esi
  800be9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	89 f7                	mov    %esi,%edi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 04                	push   $0x4
  800c05:	68 9f 25 80 00       	push   $0x80259f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 bc 25 80 00       	push   $0x8025bc
  800c11:	e8 9e 11 00 00       	call   801db4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c38:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 05                	push   $0x5
  800c47:	68 9f 25 80 00       	push   $0x80259f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 bc 25 80 00       	push   $0x8025bc
  800c53:	e8 5c 11 00 00       	call   801db4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 06                	push   $0x6
  800c89:	68 9f 25 80 00       	push   $0x80259f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 bc 25 80 00       	push   $0x8025bc
  800c95:	e8 1a 11 00 00       	call   801db4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 08                	push   $0x8
  800ccb:	68 9f 25 80 00       	push   $0x80259f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 bc 25 80 00       	push   $0x8025bc
  800cd7:	e8 d8 10 00 00       	call   801db4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 09                	push   $0x9
  800d0d:	68 9f 25 80 00       	push   $0x80259f
  800d12:	6a 23                	push   $0x23
  800d14:	68 bc 25 80 00       	push   $0x8025bc
  800d19:	e8 96 10 00 00       	call   801db4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0a                	push   $0xa
  800d4f:	68 9f 25 80 00       	push   $0x80259f
  800d54:	6a 23                	push   $0x23
  800d56:	68 bc 25 80 00       	push   $0x8025bc
  800d5b:	e8 54 10 00 00       	call   801db4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	be 00 00 00 00       	mov    $0x0,%esi
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 0d                	push   $0xd
  800db3:	68 9f 25 80 00       	push   $0x80259f
  800db8:	6a 23                	push   $0x23
  800dba:	68 bc 25 80 00       	push   $0x8025bc
  800dbf:	e8 f0 0f 00 00       	call   801db4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800dd4:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800dd6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dda:	74 11                	je     800ded <pgfault+0x21>
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	c1 e8 0c             	shr    $0xc,%eax
  800de1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800de8:	f6 c4 08             	test   $0x8,%ah
  800deb:	75 14                	jne    800e01 <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	68 cc 25 80 00       	push   $0x8025cc
  800df5:	6a 1f                	push   $0x1f
  800df7:	68 2f 26 80 00       	push   $0x80262f
  800dfc:	e8 b3 0f 00 00       	call   801db4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800e01:	e8 97 fd ff ff       	call   800b9d <sys_getenvid>
  800e06:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	6a 07                	push   $0x7
  800e0d:	68 00 f0 7f 00       	push   $0x7ff000
  800e12:	50                   	push   %eax
  800e13:	e8 c3 fd ff ff       	call   800bdb <sys_page_alloc>
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	79 12                	jns    800e31 <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800e1f:	50                   	push   %eax
  800e20:	68 0c 26 80 00       	push   $0x80260c
  800e25:	6a 2c                	push   $0x2c
  800e27:	68 2f 26 80 00       	push   $0x80262f
  800e2c:	e8 83 0f 00 00       	call   801db4 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e31:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	68 00 10 00 00       	push   $0x1000
  800e3f:	53                   	push   %ebx
  800e40:	68 00 f0 7f 00       	push   $0x7ff000
  800e45:	e8 20 fb ff ff       	call   80096a <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800e4a:	83 c4 08             	add    $0x8,%esp
  800e4d:	53                   	push   %ebx
  800e4e:	56                   	push   %esi
  800e4f:	e8 0c fe ff ff       	call   800c60 <sys_page_unmap>
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	79 12                	jns    800e6d <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800e5b:	50                   	push   %eax
  800e5c:	68 3a 26 80 00       	push   $0x80263a
  800e61:	6a 32                	push   $0x32
  800e63:	68 2f 26 80 00       	push   $0x80262f
  800e68:	e8 47 0f 00 00       	call   801db4 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	6a 07                	push   $0x7
  800e72:	53                   	push   %ebx
  800e73:	56                   	push   %esi
  800e74:	68 00 f0 7f 00       	push   $0x7ff000
  800e79:	56                   	push   %esi
  800e7a:	e8 9f fd ff ff       	call   800c1e <sys_page_map>
  800e7f:	83 c4 20             	add    $0x20,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	79 12                	jns    800e98 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800e86:	50                   	push   %eax
  800e87:	68 58 26 80 00       	push   $0x802658
  800e8c:	6a 35                	push   $0x35
  800e8e:	68 2f 26 80 00       	push   $0x80262f
  800e93:	e8 1c 0f 00 00       	call   801db4 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	68 00 f0 7f 00       	push   $0x7ff000
  800ea0:	56                   	push   %esi
  800ea1:	e8 ba fd ff ff       	call   800c60 <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 12                	jns    800ebf <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800ead:	50                   	push   %eax
  800eae:	68 3a 26 80 00       	push   $0x80263a
  800eb3:	6a 38                	push   $0x38
  800eb5:	68 2f 26 80 00       	push   $0x80262f
  800eba:	e8 f5 0e 00 00       	call   801db4 <_panic>
	//panic("pgfault not implemented");
}
  800ebf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800ecf:	68 cc 0d 80 00       	push   $0x800dcc
  800ed4:	e8 21 0f 00 00       	call   801dfa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ede:	cd 30                	int    $0x30
  800ee0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	0f 88 38 01 00 00    	js     801026 <fork+0x160>
  800eee:	89 c7                	mov    %eax,%edi
  800ef0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 21                	jne    800f1a <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef9:	e8 9f fc ff ff       	call   800b9d <sys_getenvid>
  800efe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f03:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f06:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f0b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f10:	ba 00 00 00 00       	mov    $0x0,%edx
  800f15:	e9 86 01 00 00       	jmp    8010a0 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f1a:	89 d8                	mov    %ebx,%eax
  800f1c:	c1 e8 16             	shr    $0x16,%eax
  800f1f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f26:	a8 01                	test   $0x1,%al
  800f28:	0f 84 90 00 00 00    	je     800fbe <fork+0xf8>
  800f2e:	89 d8                	mov    %ebx,%eax
  800f30:	c1 e8 0c             	shr    $0xc,%eax
  800f33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3a:	f6 c2 01             	test   $0x1,%dl
  800f3d:	74 7f                	je     800fbe <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800f44:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f4b:	f6 c6 04             	test   $0x4,%dh
  800f4e:	74 33                	je     800f83 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  800f50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5f:	50                   	push   %eax
  800f60:	56                   	push   %esi
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	6a 00                	push   $0x0
  800f65:	e8 b4 fc ff ff       	call   800c1e <sys_page_map>
  800f6a:	83 c4 20             	add    $0x20,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	79 4d                	jns    800fbe <fork+0xf8>
		    panic("sys_page_map: %e", r);
  800f71:	50                   	push   %eax
  800f72:	68 74 26 80 00       	push   $0x802674
  800f77:	6a 54                	push   $0x54
  800f79:	68 2f 26 80 00       	push   $0x80262f
  800f7e:	e8 31 0e 00 00       	call   801db4 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800f83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8a:	a9 02 08 00 00       	test   $0x802,%eax
  800f8f:	0f 85 c6 00 00 00    	jne    80105b <fork+0x195>
  800f95:	e9 e3 00 00 00       	jmp    80107d <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 74 26 80 00       	push   $0x802674
  800fa0:	6a 5d                	push   $0x5d
  800fa2:	68 2f 26 80 00       	push   $0x80262f
  800fa7:	e8 08 0e 00 00       	call   801db4 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800fac:	50                   	push   %eax
  800fad:	68 74 26 80 00       	push   $0x802674
  800fb2:	6a 64                	push   $0x64
  800fb4:	68 2f 26 80 00       	push   $0x80262f
  800fb9:	e8 f6 0d 00 00       	call   801db4 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800fbe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc4:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fca:	0f 85 4a ff ff ff    	jne    800f1a <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	6a 07                	push   $0x7
  800fd5:	68 00 f0 bf ee       	push   $0xeebff000
  800fda:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fdd:	57                   	push   %edi
  800fde:	e8 f8 fb ff ff       	call   800bdb <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fe3:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fe6:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	0f 88 b0 00 00 00    	js     8010a0 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800ff0:	a1 04 40 80 00       	mov    0x804004,%eax
  800ff5:	8b 40 64             	mov    0x64(%eax),%eax
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	50                   	push   %eax
  800ffc:	57                   	push   %edi
  800ffd:	e8 24 fd ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  801002:	83 c4 10             	add    $0x10,%esp
		return ret;
  801005:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	0f 88 91 00 00 00    	js     8010a0 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	6a 02                	push   $0x2
  801014:	57                   	push   %edi
  801015:	e8 88 fc ff ff       	call   800ca2 <sys_env_set_status>
  80101a:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  80101d:	85 c0                	test   %eax,%eax
  80101f:	89 fa                	mov    %edi,%edx
  801021:	0f 48 d0             	cmovs  %eax,%edx
  801024:	eb 7a                	jmp    8010a0 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801026:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801029:	eb 75                	jmp    8010a0 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  80102b:	e8 6d fb ff ff       	call   800b9d <sys_getenvid>
  801030:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801033:	e8 65 fb ff ff       	call   800b9d <sys_getenvid>
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	68 05 08 00 00       	push   $0x805
  801040:	56                   	push   %esi
  801041:	ff 75 e4             	pushl  -0x1c(%ebp)
  801044:	56                   	push   %esi
  801045:	50                   	push   %eax
  801046:	e8 d3 fb ff ff       	call   800c1e <sys_page_map>
  80104b:	83 c4 20             	add    $0x20,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	0f 89 68 ff ff ff    	jns    800fbe <fork+0xf8>
  801056:	e9 51 ff ff ff       	jmp    800fac <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  80105b:	e8 3d fb ff ff       	call   800b9d <sys_getenvid>
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	68 05 08 00 00       	push   $0x805
  801068:	56                   	push   %esi
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	50                   	push   %eax
  80106c:	e8 ad fb ff ff       	call   800c1e <sys_page_map>
  801071:	83 c4 20             	add    $0x20,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	79 b3                	jns    80102b <fork+0x165>
  801078:	e9 1d ff ff ff       	jmp    800f9a <fork+0xd4>
  80107d:	e8 1b fb ff ff       	call   800b9d <sys_getenvid>
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	6a 05                	push   $0x5
  801087:	56                   	push   %esi
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	50                   	push   %eax
  80108b:	e8 8e fb ff ff       	call   800c1e <sys_page_map>
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 89 23 ff ff ff    	jns    800fbe <fork+0xf8>
  80109b:	e9 fa fe ff ff       	jmp    800f9a <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8010a0:	89 d0                	mov    %edx,%eax
  8010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    

008010aa <sfork>:

// Challenge!
int
sfork(void)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b0:	68 85 26 80 00       	push   $0x802685
  8010b5:	68 ac 00 00 00       	push   $0xac
  8010ba:	68 2f 26 80 00       	push   $0x80262f
  8010bf:	e8 f0 0c 00 00       	call   801db4 <_panic>

008010c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	05 00 00 00 30       	add    $0x30000000,%eax
  8010df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	c1 ea 16             	shr    $0x16,%edx
  8010fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 11                	je     801118 <fd_alloc+0x2d>
  801107:	89 c2                	mov    %eax,%edx
  801109:	c1 ea 0c             	shr    $0xc,%edx
  80110c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801113:	f6 c2 01             	test   $0x1,%dl
  801116:	75 09                	jne    801121 <fd_alloc+0x36>
			*fd_store = fd;
  801118:	89 01                	mov    %eax,(%ecx)
			return 0;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	eb 17                	jmp    801138 <fd_alloc+0x4d>
  801121:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801126:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80112b:	75 c9                	jne    8010f6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80112d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801133:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801140:	83 f8 1f             	cmp    $0x1f,%eax
  801143:	77 36                	ja     80117b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801145:	c1 e0 0c             	shl    $0xc,%eax
  801148:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 16             	shr    $0x16,%edx
  801152:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	74 24                	je     801182 <fd_lookup+0x48>
  80115e:	89 c2                	mov    %eax,%edx
  801160:	c1 ea 0c             	shr    $0xc,%edx
  801163:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	74 1a                	je     801189 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80116f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801172:	89 02                	mov    %eax,(%edx)
	return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	eb 13                	jmp    80118e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80117b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801180:	eb 0c                	jmp    80118e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801182:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801187:	eb 05                	jmp    80118e <fd_lookup+0x54>
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801199:	ba 18 27 80 00       	mov    $0x802718,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80119e:	eb 13                	jmp    8011b3 <dev_lookup+0x23>
  8011a0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011a3:	39 08                	cmp    %ecx,(%eax)
  8011a5:	75 0c                	jne    8011b3 <dev_lookup+0x23>
			*dev = devtab[i];
  8011a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b1:	eb 2e                	jmp    8011e1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b3:	8b 02                	mov    (%edx),%eax
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	75 e7                	jne    8011a0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	51                   	push   %ecx
  8011c5:	50                   	push   %eax
  8011c6:	68 9c 26 80 00       	push   $0x80269c
  8011cb:	e8 04 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8011d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 10             	sub    $0x10,%esp
  8011eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
  8011fe:	50                   	push   %eax
  8011ff:	e8 36 ff ff ff       	call   80113a <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 05                	js     801210 <fd_close+0x2d>
	    || fd != fd2)
  80120b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80120e:	74 0c                	je     80121c <fd_close+0x39>
		return (must_exist ? r : 0);
  801210:	84 db                	test   %bl,%bl
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	0f 44 c2             	cmove  %edx,%eax
  80121a:	eb 41                	jmp    80125d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 36                	pushl  (%esi)
  801225:	e8 66 ff ff ff       	call   801190 <dev_lookup>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 1a                	js     80124d <fd_close+0x6a>
		if (dev->dev_close)
  801233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801236:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80123e:	85 c0                	test   %eax,%eax
  801240:	74 0b                	je     80124d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	56                   	push   %esi
  801246:	ff d0                	call   *%eax
  801248:	89 c3                	mov    %eax,%ebx
  80124a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	56                   	push   %esi
  801251:	6a 00                	push   $0x0
  801253:	e8 08 fa ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	89 d8                	mov    %ebx,%eax
}
  80125d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 75 08             	pushl  0x8(%ebp)
  801271:	e8 c4 fe ff ff       	call   80113a <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 10                	js     80128d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	6a 01                	push   $0x1
  801282:	ff 75 f4             	pushl  -0xc(%ebp)
  801285:	e8 59 ff ff ff       	call   8011e3 <fd_close>
  80128a:	83 c4 10             	add    $0x10,%esp
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <close_all>:

void
close_all(void)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801296:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80129b:	83 ec 0c             	sub    $0xc,%esp
  80129e:	53                   	push   %ebx
  80129f:	e8 c0 ff ff ff       	call   801264 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a4:	83 c3 01             	add    $0x1,%ebx
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	83 fb 20             	cmp    $0x20,%ebx
  8012ad:	75 ec                	jne    80129b <close_all+0xc>
		close(i);
}
  8012af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 2c             	sub    $0x2c,%esp
  8012bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c3:	50                   	push   %eax
  8012c4:	ff 75 08             	pushl  0x8(%ebp)
  8012c7:	e8 6e fe ff ff       	call   80113a <fd_lookup>
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 c1 00 00 00    	js     801398 <dup+0xe4>
		return r;
	close(newfdnum);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	56                   	push   %esi
  8012db:	e8 84 ff ff ff       	call   801264 <close>

	newfd = INDEX2FD(newfdnum);
  8012e0:	89 f3                	mov    %esi,%ebx
  8012e2:	c1 e3 0c             	shl    $0xc,%ebx
  8012e5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012eb:	83 c4 04             	add    $0x4,%esp
  8012ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f1:	e8 de fd ff ff       	call   8010d4 <fd2data>
  8012f6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012f8:	89 1c 24             	mov    %ebx,(%esp)
  8012fb:	e8 d4 fd ff ff       	call   8010d4 <fd2data>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801306:	89 f8                	mov    %edi,%eax
  801308:	c1 e8 16             	shr    $0x16,%eax
  80130b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801312:	a8 01                	test   $0x1,%al
  801314:	74 37                	je     80134d <dup+0x99>
  801316:	89 f8                	mov    %edi,%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
  80131b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801322:	f6 c2 01             	test   $0x1,%dl
  801325:	74 26                	je     80134d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801327:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	25 07 0e 00 00       	and    $0xe07,%eax
  801336:	50                   	push   %eax
  801337:	ff 75 d4             	pushl  -0x2c(%ebp)
  80133a:	6a 00                	push   $0x0
  80133c:	57                   	push   %edi
  80133d:	6a 00                	push   $0x0
  80133f:	e8 da f8 ff ff       	call   800c1e <sys_page_map>
  801344:	89 c7                	mov    %eax,%edi
  801346:	83 c4 20             	add    $0x20,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 2e                	js     80137b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801350:	89 d0                	mov    %edx,%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	25 07 0e 00 00       	and    $0xe07,%eax
  801364:	50                   	push   %eax
  801365:	53                   	push   %ebx
  801366:	6a 00                	push   $0x0
  801368:	52                   	push   %edx
  801369:	6a 00                	push   $0x0
  80136b:	e8 ae f8 ff ff       	call   800c1e <sys_page_map>
  801370:	89 c7                	mov    %eax,%edi
  801372:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801375:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801377:	85 ff                	test   %edi,%edi
  801379:	79 1d                	jns    801398 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	53                   	push   %ebx
  80137f:	6a 00                	push   $0x0
  801381:	e8 da f8 ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138c:	6a 00                	push   $0x0
  80138e:	e8 cd f8 ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	89 f8                	mov    %edi,%eax
}
  801398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 14             	sub    $0x14,%esp
  8013a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	53                   	push   %ebx
  8013af:	e8 86 fd ff ff       	call   80113a <fd_lookup>
  8013b4:	83 c4 08             	add    $0x8,%esp
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 6d                	js     80142a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	ff 30                	pushl  (%eax)
  8013c9:	e8 c2 fd ff ff       	call   801190 <dev_lookup>
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 4c                	js     801421 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d8:	8b 42 08             	mov    0x8(%edx),%eax
  8013db:	83 e0 03             	and    $0x3,%eax
  8013de:	83 f8 01             	cmp    $0x1,%eax
  8013e1:	75 21                	jne    801404 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e8:	8b 40 48             	mov    0x48(%eax),%eax
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	50                   	push   %eax
  8013f0:	68 dd 26 80 00       	push   $0x8026dd
  8013f5:	e8 da ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801402:	eb 26                	jmp    80142a <read+0x8a>
	}
	if (!dev->dev_read)
  801404:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801407:	8b 40 08             	mov    0x8(%eax),%eax
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 17                	je     801425 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	ff 75 10             	pushl  0x10(%ebp)
  801414:	ff 75 0c             	pushl  0xc(%ebp)
  801417:	52                   	push   %edx
  801418:	ff d0                	call   *%eax
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	eb 09                	jmp    80142a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801421:	89 c2                	mov    %eax,%edx
  801423:	eb 05                	jmp    80142a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801425:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80142a:	89 d0                	mov    %edx,%eax
  80142c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
  801445:	eb 21                	jmp    801468 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	89 f0                	mov    %esi,%eax
  80144c:	29 d8                	sub    %ebx,%eax
  80144e:	50                   	push   %eax
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	03 45 0c             	add    0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	57                   	push   %edi
  801456:	e8 45 ff ff ff       	call   8013a0 <read>
		if (m < 0)
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 10                	js     801472 <readn+0x41>
			return m;
		if (m == 0)
  801462:	85 c0                	test   %eax,%eax
  801464:	74 0a                	je     801470 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801466:	01 c3                	add    %eax,%ebx
  801468:	39 f3                	cmp    %esi,%ebx
  80146a:	72 db                	jb     801447 <readn+0x16>
  80146c:	89 d8                	mov    %ebx,%eax
  80146e:	eb 02                	jmp    801472 <readn+0x41>
  801470:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801472:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5f                   	pop    %edi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 14             	sub    $0x14,%esp
  801481:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801484:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	53                   	push   %ebx
  801489:	e8 ac fc ff ff       	call   80113a <fd_lookup>
  80148e:	83 c4 08             	add    $0x8,%esp
  801491:	89 c2                	mov    %eax,%edx
  801493:	85 c0                	test   %eax,%eax
  801495:	78 68                	js     8014ff <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a1:	ff 30                	pushl  (%eax)
  8014a3:	e8 e8 fc ff ff       	call   801190 <dev_lookup>
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 47                	js     8014f6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b6:	75 21                	jne    8014d9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bd:	8b 40 48             	mov    0x48(%eax),%eax
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	50                   	push   %eax
  8014c5:	68 f9 26 80 00       	push   $0x8026f9
  8014ca:	e8 05 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d7:	eb 26                	jmp    8014ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	74 17                	je     8014fa <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	ff 75 10             	pushl  0x10(%ebp)
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	50                   	push   %eax
  8014ed:	ff d2                	call   *%edx
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	eb 09                	jmp    8014ff <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	eb 05                	jmp    8014ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ff:	89 d0                	mov    %edx,%eax
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <seek>:

int
seek(int fdnum, off_t offset)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	ff 75 08             	pushl  0x8(%ebp)
  801513:	e8 22 fc ff ff       	call   80113a <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 0e                	js     80152d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80151f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801522:	8b 55 0c             	mov    0xc(%ebp),%edx
  801525:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801528:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 14             	sub    $0x14,%esp
  801536:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801539:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	53                   	push   %ebx
  80153e:	e8 f7 fb ff ff       	call   80113a <fd_lookup>
  801543:	83 c4 08             	add    $0x8,%esp
  801546:	89 c2                	mov    %eax,%edx
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 65                	js     8015b1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801556:	ff 30                	pushl  (%eax)
  801558:	e8 33 fc ff ff       	call   801190 <dev_lookup>
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 44                	js     8015a8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801567:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156b:	75 21                	jne    80158e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80156d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801572:	8b 40 48             	mov    0x48(%eax),%eax
  801575:	83 ec 04             	sub    $0x4,%esp
  801578:	53                   	push   %ebx
  801579:	50                   	push   %eax
  80157a:	68 bc 26 80 00       	push   $0x8026bc
  80157f:	e8 50 ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158c:	eb 23                	jmp    8015b1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80158e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801591:	8b 52 18             	mov    0x18(%edx),%edx
  801594:	85 d2                	test   %edx,%edx
  801596:	74 14                	je     8015ac <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	50                   	push   %eax
  80159f:	ff d2                	call   *%edx
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb 09                	jmp    8015b1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	eb 05                	jmp    8015b1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 14             	sub    $0x14,%esp
  8015bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	e8 6c fb ff ff       	call   80113a <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 58                	js     80162f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 a8 fb ff ff       	call   801190 <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 37                	js     801626 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015f6:	74 32                	je     80162a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801602:	00 00 00 
	stat->st_isdir = 0;
  801605:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160c:	00 00 00 
	stat->st_dev = dev;
  80160f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	ff 75 f0             	pushl  -0x10(%ebp)
  80161c:	ff 50 14             	call   *0x14(%eax)
  80161f:	89 c2                	mov    %eax,%edx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 09                	jmp    80162f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801626:	89 c2                	mov    %eax,%edx
  801628:	eb 05                	jmp    80162f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80162a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80162f:	89 d0                	mov    %edx,%eax
  801631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	6a 00                	push   $0x0
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 e9 01 00 00       	call   801831 <open>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 1b                	js     80166c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	e8 5b ff ff ff       	call   8015b8 <fstat>
  80165d:	89 c6                	mov    %eax,%esi
	close(fd);
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 fd fb ff ff       	call   801264 <close>
	return r;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	89 f0                	mov    %esi,%eax
}
  80166c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	89 c6                	mov    %eax,%esi
  80167a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801683:	75 12                	jne    801697 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	6a 01                	push   $0x1
  80168a:	e8 db 08 00 00       	call   801f6a <ipc_find_env>
  80168f:	a3 00 40 80 00       	mov    %eax,0x804000
  801694:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801697:	6a 07                	push   $0x7
  801699:	68 00 50 80 00       	push   $0x805000
  80169e:	56                   	push   %esi
  80169f:	ff 35 00 40 80 00    	pushl  0x804000
  8016a5:	e8 6c 08 00 00       	call   801f16 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8016aa:	83 c4 0c             	add    $0xc,%esp
  8016ad:	6a 00                	push   $0x0
  8016af:	53                   	push   %ebx
  8016b0:	6a 00                	push   $0x0
  8016b2:	e8 dd 07 00 00       	call   801e94 <ipc_recv>
}
  8016b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ba:	5b                   	pop    %ebx
  8016bb:	5e                   	pop    %esi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e1:	e8 8d ff ff ff       	call   801673 <fsipc>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801703:	e8 6b ff ff ff       	call   801673 <fsipc>
}
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 40 0c             	mov    0xc(%eax),%eax
  80171a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80171f:	ba 00 00 00 00       	mov    $0x0,%edx
  801724:	b8 05 00 00 00       	mov    $0x5,%eax
  801729:	e8 45 ff ff ff       	call   801673 <fsipc>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 2c                	js     80175e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	68 00 50 80 00       	push   $0x805000
  80173a:	53                   	push   %ebx
  80173b:	e8 98 f0 ff ff       	call   8007d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801740:	a1 80 50 80 00       	mov    0x805080,%eax
  801745:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80174b:	a1 84 50 80 00       	mov    0x805084,%eax
  801750:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	8b 45 10             	mov    0x10(%ebp),%eax
  80176c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801771:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801776:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801779:	8b 55 08             	mov    0x8(%ebp),%edx
  80177c:	8b 52 0c             	mov    0xc(%edx),%edx
  80177f:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801785:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80178a:	50                   	push   %eax
  80178b:	ff 75 0c             	pushl  0xc(%ebp)
  80178e:	68 08 50 80 00       	push   $0x805008
  801793:	e8 d2 f1 ff ff       	call   80096a <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801798:	ba 00 00 00 00       	mov    $0x0,%edx
  80179d:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a2:	e8 cc fe ff ff       	call   801673 <fsipc>
            return r;

    return r;
}
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017bc:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017cc:	e8 a2 fe ff ff       	call   801673 <fsipc>
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 51                	js     801828 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8017d7:	39 c6                	cmp    %eax,%esi
  8017d9:	73 19                	jae    8017f4 <devfile_read+0x4b>
  8017db:	68 28 27 80 00       	push   $0x802728
  8017e0:	68 2f 27 80 00       	push   $0x80272f
  8017e5:	68 82 00 00 00       	push   $0x82
  8017ea:	68 44 27 80 00       	push   $0x802744
  8017ef:	e8 c0 05 00 00       	call   801db4 <_panic>
	assert(r <= PGSIZE);
  8017f4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f9:	7e 19                	jle    801814 <devfile_read+0x6b>
  8017fb:	68 4f 27 80 00       	push   $0x80274f
  801800:	68 2f 27 80 00       	push   $0x80272f
  801805:	68 83 00 00 00       	push   $0x83
  80180a:	68 44 27 80 00       	push   $0x802744
  80180f:	e8 a0 05 00 00       	call   801db4 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	50                   	push   %eax
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	e8 45 f1 ff ff       	call   80096a <memmove>
	return r;
  801825:	83 c4 10             	add    $0x10,%esp
}
  801828:	89 d8                	mov    %ebx,%eax
  80182a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 20             	sub    $0x20,%esp
  801838:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183b:	53                   	push   %ebx
  80183c:	e8 5e ef ff ff       	call   80079f <strlen>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801849:	7f 67                	jg     8018b2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184b:	83 ec 0c             	sub    $0xc,%esp
  80184e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801851:	50                   	push   %eax
  801852:	e8 94 f8 ff ff       	call   8010eb <fd_alloc>
  801857:	83 c4 10             	add    $0x10,%esp
		return r;
  80185a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 57                	js     8018b7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	53                   	push   %ebx
  801864:	68 00 50 80 00       	push   $0x805000
  801869:	e8 6a ef ff ff       	call   8007d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80186e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801871:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801879:	b8 01 00 00 00       	mov    $0x1,%eax
  80187e:	e8 f0 fd ff ff       	call   801673 <fsipc>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	79 14                	jns    8018a0 <open+0x6f>
		fd_close(fd, 0);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	6a 00                	push   $0x0
  801891:	ff 75 f4             	pushl  -0xc(%ebp)
  801894:	e8 4a f9 ff ff       	call   8011e3 <fd_close>
		return r;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	89 da                	mov    %ebx,%edx
  80189e:	eb 17                	jmp    8018b7 <open+0x86>
	}

	return fd2num(fd);
  8018a0:	83 ec 0c             	sub    $0xc,%esp
  8018a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a6:	e8 19 f8 ff ff       	call   8010c4 <fd2num>
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	eb 05                	jmp    8018b7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b7:	89 d0                	mov    %edx,%eax
  8018b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c9:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ce:	e8 a0 fd ff ff       	call   801673 <fsipc>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 08             	pushl  0x8(%ebp)
  8018e3:	e8 ec f7 ff ff       	call   8010d4 <fd2data>
  8018e8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	68 5b 27 80 00       	push   $0x80275b
  8018f2:	53                   	push   %ebx
  8018f3:	e8 e0 ee ff ff       	call   8007d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f8:	8b 46 04             	mov    0x4(%esi),%eax
  8018fb:	2b 06                	sub    (%esi),%eax
  8018fd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801903:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190a:	00 00 00 
	stat->st_dev = &devpipe;
  80190d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801914:	30 80 00 
	return 0;
}
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
  80191c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80192d:	53                   	push   %ebx
  80192e:	6a 00                	push   $0x0
  801930:	e8 2b f3 ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801935:	89 1c 24             	mov    %ebx,(%esp)
  801938:	e8 97 f7 ff ff       	call   8010d4 <fd2data>
  80193d:	83 c4 08             	add    $0x8,%esp
  801940:	50                   	push   %eax
  801941:	6a 00                	push   $0x0
  801943:	e8 18 f3 ff ff       	call   800c60 <sys_page_unmap>
}
  801948:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	57                   	push   %edi
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	83 ec 1c             	sub    $0x1c,%esp
  801956:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801959:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80195b:	a1 04 40 80 00       	mov    0x804004,%eax
  801960:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 e0             	pushl  -0x20(%ebp)
  801969:	e8 35 06 00 00       	call   801fa3 <pageref>
  80196e:	89 c3                	mov    %eax,%ebx
  801970:	89 3c 24             	mov    %edi,(%esp)
  801973:	e8 2b 06 00 00       	call   801fa3 <pageref>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	39 c3                	cmp    %eax,%ebx
  80197d:	0f 94 c1             	sete   %cl
  801980:	0f b6 c9             	movzbl %cl,%ecx
  801983:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801986:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80198c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80198f:	39 ce                	cmp    %ecx,%esi
  801991:	74 1b                	je     8019ae <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801993:	39 c3                	cmp    %eax,%ebx
  801995:	75 c4                	jne    80195b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801997:	8b 42 58             	mov    0x58(%edx),%eax
  80199a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80199d:	50                   	push   %eax
  80199e:	56                   	push   %esi
  80199f:	68 62 27 80 00       	push   $0x802762
  8019a4:	e8 2b e8 ff ff       	call   8001d4 <cprintf>
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	eb ad                	jmp    80195b <_pipeisclosed+0xe>
	}
}
  8019ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b4:	5b                   	pop    %ebx
  8019b5:	5e                   	pop    %esi
  8019b6:	5f                   	pop    %edi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	57                   	push   %edi
  8019bd:	56                   	push   %esi
  8019be:	53                   	push   %ebx
  8019bf:	83 ec 28             	sub    $0x28,%esp
  8019c2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019c5:	56                   	push   %esi
  8019c6:	e8 09 f7 ff ff       	call   8010d4 <fd2data>
  8019cb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d5:	eb 4b                	jmp    801a22 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019d7:	89 da                	mov    %ebx,%edx
  8019d9:	89 f0                	mov    %esi,%eax
  8019db:	e8 6d ff ff ff       	call   80194d <_pipeisclosed>
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	75 48                	jne    801a2c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019e4:	e8 d3 f1 ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019e9:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ec:	8b 0b                	mov    (%ebx),%ecx
  8019ee:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f1:	39 d0                	cmp    %edx,%eax
  8019f3:	73 e2                	jae    8019d7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019fc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ff:	89 c2                	mov    %eax,%edx
  801a01:	c1 fa 1f             	sar    $0x1f,%edx
  801a04:	89 d1                	mov    %edx,%ecx
  801a06:	c1 e9 1b             	shr    $0x1b,%ecx
  801a09:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a0c:	83 e2 1f             	and    $0x1f,%edx
  801a0f:	29 ca                	sub    %ecx,%edx
  801a11:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a15:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a19:	83 c0 01             	add    $0x1,%eax
  801a1c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1f:	83 c7 01             	add    $0x1,%edi
  801a22:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a25:	75 c2                	jne    8019e9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a27:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2a:	eb 05                	jmp    801a31 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5f                   	pop    %edi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	57                   	push   %edi
  801a3d:	56                   	push   %esi
  801a3e:	53                   	push   %ebx
  801a3f:	83 ec 18             	sub    $0x18,%esp
  801a42:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a45:	57                   	push   %edi
  801a46:	e8 89 f6 ff ff       	call   8010d4 <fd2data>
  801a4b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a55:	eb 3d                	jmp    801a94 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a57:	85 db                	test   %ebx,%ebx
  801a59:	74 04                	je     801a5f <devpipe_read+0x26>
				return i;
  801a5b:	89 d8                	mov    %ebx,%eax
  801a5d:	eb 44                	jmp    801aa3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a5f:	89 f2                	mov    %esi,%edx
  801a61:	89 f8                	mov    %edi,%eax
  801a63:	e8 e5 fe ff ff       	call   80194d <_pipeisclosed>
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	75 32                	jne    801a9e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a6c:	e8 4b f1 ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a71:	8b 06                	mov    (%esi),%eax
  801a73:	3b 46 04             	cmp    0x4(%esi),%eax
  801a76:	74 df                	je     801a57 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a78:	99                   	cltd   
  801a79:	c1 ea 1b             	shr    $0x1b,%edx
  801a7c:	01 d0                	add    %edx,%eax
  801a7e:	83 e0 1f             	and    $0x1f,%eax
  801a81:	29 d0                	sub    %edx,%eax
  801a83:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a8e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a91:	83 c3 01             	add    $0x1,%ebx
  801a94:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a97:	75 d8                	jne    801a71 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a99:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9c:	eb 05                	jmp    801aa3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab6:	50                   	push   %eax
  801ab7:	e8 2f f6 ff ff       	call   8010eb <fd_alloc>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	0f 88 2c 01 00 00    	js     801bf5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	68 07 04 00 00       	push   $0x407
  801ad1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad4:	6a 00                	push   $0x0
  801ad6:	e8 00 f1 ff ff       	call   800bdb <sys_page_alloc>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	89 c2                	mov    %eax,%edx
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	0f 88 0d 01 00 00    	js     801bf5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aee:	50                   	push   %eax
  801aef:	e8 f7 f5 ff ff       	call   8010eb <fd_alloc>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	0f 88 e2 00 00 00    	js     801be3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b01:	83 ec 04             	sub    $0x4,%esp
  801b04:	68 07 04 00 00       	push   $0x407
  801b09:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 c8 f0 ff ff       	call   800bdb <sys_page_alloc>
  801b13:	89 c3                	mov    %eax,%ebx
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	0f 88 c3 00 00 00    	js     801be3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b20:	83 ec 0c             	sub    $0xc,%esp
  801b23:	ff 75 f4             	pushl  -0xc(%ebp)
  801b26:	e8 a9 f5 ff ff       	call   8010d4 <fd2data>
  801b2b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2d:	83 c4 0c             	add    $0xc,%esp
  801b30:	68 07 04 00 00       	push   $0x407
  801b35:	50                   	push   %eax
  801b36:	6a 00                	push   $0x0
  801b38:	e8 9e f0 ff ff       	call   800bdb <sys_page_alloc>
  801b3d:	89 c3                	mov    %eax,%ebx
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	85 c0                	test   %eax,%eax
  801b44:	0f 88 89 00 00 00    	js     801bd3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b50:	e8 7f f5 ff ff       	call   8010d4 <fd2data>
  801b55:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b5c:	50                   	push   %eax
  801b5d:	6a 00                	push   $0x0
  801b5f:	56                   	push   %esi
  801b60:	6a 00                	push   $0x0
  801b62:	e8 b7 f0 ff ff       	call   800c1e <sys_page_map>
  801b67:	89 c3                	mov    %eax,%ebx
  801b69:	83 c4 20             	add    $0x20,%esp
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 55                	js     801bc5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b79:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b85:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b93:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba0:	e8 1f f5 ff ff       	call   8010c4 <fd2num>
  801ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801baa:	83 c4 04             	add    $0x4,%esp
  801bad:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb0:	e8 0f f5 ff ff       	call   8010c4 <fd2num>
  801bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc3:	eb 30                	jmp    801bf5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bc5:	83 ec 08             	sub    $0x8,%esp
  801bc8:	56                   	push   %esi
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 90 f0 ff ff       	call   800c60 <sys_page_unmap>
  801bd0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 80 f0 ff ff       	call   800c60 <sys_page_unmap>
  801be0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be3:	83 ec 08             	sub    $0x8,%esp
  801be6:	ff 75 f4             	pushl  -0xc(%ebp)
  801be9:	6a 00                	push   $0x0
  801beb:	e8 70 f0 ff ff       	call   800c60 <sys_page_unmap>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bf5:	89 d0                	mov    %edx,%eax
  801bf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c07:	50                   	push   %eax
  801c08:	ff 75 08             	pushl  0x8(%ebp)
  801c0b:	e8 2a f5 ff ff       	call   80113a <fd_lookup>
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	85 c0                	test   %eax,%eax
  801c15:	78 18                	js     801c2f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1d:	e8 b2 f4 ff ff       	call   8010d4 <fd2data>
	return _pipeisclosed(fd, p);
  801c22:	89 c2                	mov    %eax,%edx
  801c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c27:	e8 21 fd ff ff       	call   80194d <_pipeisclosed>
  801c2c:	83 c4 10             	add    $0x10,%esp
}
  801c2f:	c9                   	leave  
  801c30:	c3                   	ret    

00801c31 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c41:	68 7a 27 80 00       	push   $0x80277a
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	e8 8a eb ff ff       	call   8007d8 <strcpy>
	return 0;
}
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	57                   	push   %edi
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c61:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c66:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6c:	eb 2d                	jmp    801c9b <devcons_write+0x46>
		m = n - tot;
  801c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c71:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c73:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c76:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c7b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	53                   	push   %ebx
  801c82:	03 45 0c             	add    0xc(%ebp),%eax
  801c85:	50                   	push   %eax
  801c86:	57                   	push   %edi
  801c87:	e8 de ec ff ff       	call   80096a <memmove>
		sys_cputs(buf, m);
  801c8c:	83 c4 08             	add    $0x8,%esp
  801c8f:	53                   	push   %ebx
  801c90:	57                   	push   %edi
  801c91:	e8 89 ee ff ff       	call   800b1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c96:	01 de                	add    %ebx,%esi
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	89 f0                	mov    %esi,%eax
  801c9d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca0:	72 cc                	jb     801c6e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5f                   	pop    %edi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 08             	sub    $0x8,%esp
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb9:	74 2a                	je     801ce5 <devcons_read+0x3b>
  801cbb:	eb 05                	jmp    801cc2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cbd:	e8 fa ee ff ff       	call   800bbc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc2:	e8 76 ee ff ff       	call   800b3d <sys_cgetc>
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	74 f2                	je     801cbd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 16                	js     801ce5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ccf:	83 f8 04             	cmp    $0x4,%eax
  801cd2:	74 0c                	je     801ce0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd7:	88 02                	mov    %al,(%edx)
	return 1;
  801cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cde:	eb 05                	jmp    801ce5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ced:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cf3:	6a 01                	push   $0x1
  801cf5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf8:	50                   	push   %eax
  801cf9:	e8 21 ee ff ff       	call   800b1f <sys_cputs>
}
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <getchar>:

int
getchar(void)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d09:	6a 01                	push   $0x1
  801d0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d0e:	50                   	push   %eax
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 8a f6 ff ff       	call   8013a0 <read>
	if (r < 0)
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	78 0f                	js     801d2c <getchar+0x29>
		return r;
	if (r < 1)
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	7e 06                	jle    801d27 <getchar+0x24>
		return -E_EOF;
	return c;
  801d21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d25:	eb 05                	jmp    801d2c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	ff 75 08             	pushl  0x8(%ebp)
  801d3b:	e8 fa f3 ff ff       	call   80113a <fd_lookup>
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 11                	js     801d58 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d50:	39 10                	cmp    %edx,(%eax)
  801d52:	0f 94 c0             	sete   %al
  801d55:	0f b6 c0             	movzbl %al,%eax
}
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <opencons>:

int
opencons(void)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	e8 82 f3 ff ff       	call   8010eb <fd_alloc>
  801d69:	83 c4 10             	add    $0x10,%esp
		return r;
  801d6c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 3e                	js     801db0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	68 07 04 00 00       	push   $0x407
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 57 ee ff ff       	call   800bdb <sys_page_alloc>
  801d84:	83 c4 10             	add    $0x10,%esp
		return r;
  801d87:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 23                	js     801db0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d96:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	50                   	push   %eax
  801da6:	e8 19 f3 ff ff       	call   8010c4 <fd2num>
  801dab:	89 c2                	mov    %eax,%edx
  801dad:	83 c4 10             	add    $0x10,%esp
}
  801db0:	89 d0                	mov    %edx,%eax
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801db9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dbc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dc2:	e8 d6 ed ff ff       	call   800b9d <sys_getenvid>
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	ff 75 08             	pushl  0x8(%ebp)
  801dd0:	56                   	push   %esi
  801dd1:	50                   	push   %eax
  801dd2:	68 88 27 80 00       	push   $0x802788
  801dd7:	e8 f8 e3 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ddc:	83 c4 18             	add    $0x18,%esp
  801ddf:	53                   	push   %ebx
  801de0:	ff 75 10             	pushl  0x10(%ebp)
  801de3:	e8 9b e3 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801de8:	c7 04 24 8f 22 80 00 	movl   $0x80228f,(%esp)
  801def:	e8 e0 e3 ff ff       	call   8001d4 <cprintf>
  801df4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801df7:	cc                   	int3   
  801df8:	eb fd                	jmp    801df7 <_panic+0x43>

00801dfa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801e01:	e8 97 ed ff ff       	call   800b9d <sys_getenvid>
  801e06:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801e08:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e0f:	75 29                	jne    801e3a <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	6a 07                	push   $0x7
  801e16:	68 00 f0 bf ee       	push   $0xeebff000
  801e1b:	50                   	push   %eax
  801e1c:	e8 ba ed ff ff       	call   800bdb <sys_page_alloc>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	79 12                	jns    801e3a <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801e28:	50                   	push   %eax
  801e29:	68 ac 27 80 00       	push   $0x8027ac
  801e2e:	6a 24                	push   $0x24
  801e30:	68 c5 27 80 00       	push   $0x8027c5
  801e35:	e8 7a ff ff ff       	call   801db4 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801e42:	83 ec 08             	sub    $0x8,%esp
  801e45:	68 6e 1e 80 00       	push   $0x801e6e
  801e4a:	53                   	push   %ebx
  801e4b:	e8 d6 ee ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	79 12                	jns    801e69 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801e57:	50                   	push   %eax
  801e58:	68 ac 27 80 00       	push   $0x8027ac
  801e5d:	6a 2e                	push   $0x2e
  801e5f:	68 c5 27 80 00       	push   $0x8027c5
  801e64:	e8 4b ff ff ff       	call   801db4 <_panic>
}
  801e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e6e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e6f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e74:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e76:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801e79:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801e7d:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801e80:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801e84:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801e86:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801e8a:	83 c4 08             	add    $0x8,%esp
	popal
  801e8d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e8e:	83 c4 04             	add    $0x4,%esp
	popfl
  801e91:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801e92:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e93:	c3                   	ret    

00801e94 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	57                   	push   %edi
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801ea6:	85 f6                	test   %esi,%esi
  801ea8:	74 06                	je     801eb0 <ipc_recv+0x1c>
		*from_env_store = 0;
  801eaa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801eb0:	85 db                	test   %ebx,%ebx
  801eb2:	74 06                	je     801eba <ipc_recv+0x26>
		*perm_store = 0;
  801eb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801eba:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801ebc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ec1:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	50                   	push   %eax
  801ec8:	e8 be ee ff ff       	call   800d8b <sys_ipc_recv>
  801ecd:	89 c7                	mov    %eax,%edi
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	79 14                	jns    801eea <ipc_recv+0x56>
		cprintf("im dead");
  801ed6:	83 ec 0c             	sub    $0xc,%esp
  801ed9:	68 d3 27 80 00       	push   $0x8027d3
  801ede:	e8 f1 e2 ff ff       	call   8001d4 <cprintf>
		return r;
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	89 f8                	mov    %edi,%eax
  801ee8:	eb 24                	jmp    801f0e <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801eea:	85 f6                	test   %esi,%esi
  801eec:	74 0a                	je     801ef8 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801eee:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef3:	8b 40 74             	mov    0x74(%eax),%eax
  801ef6:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ef8:	85 db                	test   %ebx,%ebx
  801efa:	74 0a                	je     801f06 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801efc:	a1 04 40 80 00       	mov    0x804004,%eax
  801f01:	8b 40 78             	mov    0x78(%eax),%eax
  801f04:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801f06:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f11:	5b                   	pop    %ebx
  801f12:	5e                   	pop    %esi
  801f13:	5f                   	pop    %edi
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    

00801f16 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	57                   	push   %edi
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f22:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801f28:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f2f:	0f 44 d8             	cmove  %eax,%ebx
  801f32:	eb 1c                	jmp    801f50 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801f34:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f37:	74 12                	je     801f4b <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801f39:	50                   	push   %eax
  801f3a:	68 db 27 80 00       	push   $0x8027db
  801f3f:	6a 4e                	push   $0x4e
  801f41:	68 e8 27 80 00       	push   $0x8027e8
  801f46:	e8 69 fe ff ff       	call   801db4 <_panic>
		sys_yield();
  801f4b:	e8 6c ec ff ff       	call   800bbc <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f50:	ff 75 14             	pushl  0x14(%ebp)
  801f53:	53                   	push   %ebx
  801f54:	56                   	push   %esi
  801f55:	57                   	push   %edi
  801f56:	e8 0d ee ff ff       	call   800d68 <sys_ipc_try_send>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 d2                	js     801f34 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5f                   	pop    %edi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f75:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f78:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f7e:	8b 52 50             	mov    0x50(%edx),%edx
  801f81:	39 ca                	cmp    %ecx,%edx
  801f83:	75 0d                	jne    801f92 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f85:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f88:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f8d:	8b 40 48             	mov    0x48(%eax),%eax
  801f90:	eb 0f                	jmp    801fa1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f92:	83 c0 01             	add    $0x1,%eax
  801f95:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f9a:	75 d9                	jne    801f75 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa9:	89 d0                	mov    %edx,%eax
  801fab:	c1 e8 16             	shr    $0x16,%eax
  801fae:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fb5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fba:	f6 c1 01             	test   $0x1,%cl
  801fbd:	74 1d                	je     801fdc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fbf:	c1 ea 0c             	shr    $0xc,%edx
  801fc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc9:	f6 c2 01             	test   $0x1,%dl
  801fcc:	74 0e                	je     801fdc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fce:	c1 ea 0c             	shr    $0xc,%edx
  801fd1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fd8:	ef 
  801fd9:	0f b7 c0             	movzwl %ax,%eax
}
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
