
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 80 21 80 00       	push   $0x802180
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 8c 0d 00 00       	call   800df8 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 92 0d 00 00       	call   800e28 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 8e 13 00 00       	call   801440 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 94 21 80 00       	push   $0x802194
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 66 17 00 00       	call   801840 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 94 21 80 00       	push   $0x802194
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 ac 0a 00 00       	call   800bc9 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 b9 0f 00 00       	call   801117 <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 20 0a 00 00       	call   800b88 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 ae 09 00 00       	call   800b4b <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 1a 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 53 09 00 00       	call   800b4b <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 78 1c 00 00       	call   801ee0 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 65 1d 00 00       	call   802010 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 c6 21 80 00 	movsbl 0x8021c6(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 02                	mov    %al,(%edx)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 10             	pushl  0x10(%ebp)
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	ff 75 08             	pushl  0x8(%ebp)
  8002f3:	e8 05 00 00 00       	call   8002fd <vprintfmt>
	va_end(ap);
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 2c             	sub    $0x2c,%esp
  800306:	8b 75 08             	mov    0x8(%ebp),%esi
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030f:	eb 12                	jmp    800323 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	0f 84 42 04 00 00    	je     80075b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	53                   	push   %ebx
  80031d:	50                   	push   %eax
  80031e:	ff d6                	call   *%esi
  800320:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800323:	83 c7 01             	add    $0x1,%edi
  800326:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032a:	83 f8 25             	cmp    $0x25,%eax
  80032d:	75 e2                	jne    800311 <vprintfmt+0x14>
  80032f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800333:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800341:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800348:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034d:	eb 07                	jmp    800356 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800352:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8d 47 01             	lea    0x1(%edi),%eax
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	0f b6 07             	movzbl (%edi),%eax
  80035f:	0f b6 d0             	movzbl %al,%edx
  800362:	83 e8 23             	sub    $0x23,%eax
  800365:	3c 55                	cmp    $0x55,%al
  800367:	0f 87 d3 03 00 00    	ja     800740 <vprintfmt+0x443>
  80036d:	0f b6 c0             	movzbl %al,%eax
  800370:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037e:	eb d6                	jmp    800356 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800392:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800395:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800398:	83 f9 09             	cmp    $0x9,%ecx
  80039b:	77 3f                	ja     8003dc <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a0:	eb e9                	jmp    80038b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 40 04             	lea    0x4(%eax),%eax
  8003b0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b6:	eb 2a                	jmp    8003e2 <vprintfmt+0xe5>
  8003b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c2:	0f 49 d0             	cmovns %eax,%edx
  8003c5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cb:	eb 89                	jmp    800356 <vprintfmt+0x59>
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d7:	e9 7a ff ff ff       	jmp    800356 <vprintfmt+0x59>
  8003dc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e6:	0f 89 6a ff ff ff    	jns    800356 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f9:	e9 58 ff ff ff       	jmp    800356 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fe:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800404:	e9 4d ff ff ff       	jmp    800356 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 78 04             	lea    0x4(%eax),%edi
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	53                   	push   %ebx
  800413:	ff 30                	pushl  (%eax)
  800415:	ff d6                	call   *%esi
			break;
  800417:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 fe fe ff ff       	jmp    800323 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 78 04             	lea    0x4(%eax),%edi
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	99                   	cltd   
  80042e:	31 d0                	xor    %edx,%eax
  800430:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800432:	83 f8 0f             	cmp    $0xf,%eax
  800435:	7f 0b                	jg     800442 <vprintfmt+0x145>
  800437:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  80043e:	85 d2                	test   %edx,%edx
  800440:	75 1b                	jne    80045d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800442:	50                   	push   %eax
  800443:	68 de 21 80 00       	push   $0x8021de
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 91 fe ff ff       	call   8002e0 <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800452:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800458:	e9 c6 fe ff ff       	jmp    800323 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 91 25 80 00       	push   $0x802591
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 76 fe ff ff       	call   8002e0 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800473:	e9 ab fe ff ff       	jmp    800323 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	83 c0 04             	add    $0x4,%eax
  80047e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800486:	85 ff                	test   %edi,%edi
  800488:	b8 d7 21 80 00       	mov    $0x8021d7,%eax
  80048d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800490:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800494:	0f 8e 94 00 00 00    	jle    80052e <vprintfmt+0x231>
  80049a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049e:	0f 84 98 00 00 00    	je     80053c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8004aa:	57                   	push   %edi
  8004ab:	e8 33 03 00 00       	call   8007e3 <strnlen>
  8004b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b3:	29 c1                	sub    %eax,%ecx
  8004b5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	eb 0f                	jmp    8004d8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ed                	jg     8004c9 <vprintfmt+0x1cc>
  8004dc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004df:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e2:	85 c9                	test   %ecx,%ecx
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	0f 49 c1             	cmovns %ecx,%eax
  8004ec:	29 c1                	sub    %eax,%ecx
  8004ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f7:	89 cb                	mov    %ecx,%ebx
  8004f9:	eb 4d                	jmp    800548 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ff:	74 1b                	je     80051c <vprintfmt+0x21f>
  800501:	0f be c0             	movsbl %al,%eax
  800504:	83 e8 20             	sub    $0x20,%eax
  800507:	83 f8 5e             	cmp    $0x5e,%eax
  80050a:	76 10                	jbe    80051c <vprintfmt+0x21f>
					putch('?', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	ff 75 0c             	pushl  0xc(%ebp)
  800512:	6a 3f                	push   $0x3f
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb 0d                	jmp    800529 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	52                   	push   %edx
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800529:	83 eb 01             	sub    $0x1,%ebx
  80052c:	eb 1a                	jmp    800548 <vprintfmt+0x24b>
  80052e:	89 75 08             	mov    %esi,0x8(%ebp)
  800531:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800534:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800537:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053a:	eb 0c                	jmp    800548 <vprintfmt+0x24b>
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800545:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	0f be d0             	movsbl %al,%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	74 23                	je     800579 <vprintfmt+0x27c>
  800556:	85 f6                	test   %esi,%esi
  800558:	78 a1                	js     8004fb <vprintfmt+0x1fe>
  80055a:	83 ee 01             	sub    $0x1,%esi
  80055d:	79 9c                	jns    8004fb <vprintfmt+0x1fe>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	eb 18                	jmp    800581 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 20                	push   $0x20
  80056f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800571:	83 ef 01             	sub    $0x1,%edi
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	eb 08                	jmp    800581 <vprintfmt+0x284>
  800579:	89 df                	mov    %ebx,%edi
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800581:	85 ff                	test   %edi,%edi
  800583:	7f e4                	jg     800569 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800585:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058e:	e9 90 fd ff ff       	jmp    800323 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 19                	jle    8005b1 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 50 04             	mov    0x4(%eax),%edx
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8005af:	eb 38                	jmp    8005e9 <vprintfmt+0x2ec>
	else if (lflag)
  8005b1:	85 c9                	test   %ecx,%ecx
  8005b3:	74 1b                	je     8005d0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ce:	eb 19                	jmp    8005e9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f8:	0f 89 0e 01 00 00    	jns    80070c <vprintfmt+0x40f>
				putch('-', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 2d                	push   $0x2d
  800604:	ff d6                	call   *%esi
				num = -(long long) num;
  800606:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800609:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060c:	f7 da                	neg    %edx
  80060e:	83 d1 00             	adc    $0x0,%ecx
  800611:	f7 d9                	neg    %ecx
  800613:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061b:	e9 ec 00 00 00       	jmp    80070c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 18                	jle    80063d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8b 48 04             	mov    0x4(%eax),%ecx
  80062d:	8d 40 08             	lea    0x8(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
  800638:	e9 cf 00 00 00       	jmp    80070c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 1a                	je     80065b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	e9 b1 00 00 00       	jmp    80070c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800670:	e9 97 00 00 00       	jmp    80070c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 58                	push   $0x58
  80067b:	ff d6                	call   *%esi
			putch('X', putdat);
  80067d:	83 c4 08             	add    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 58                	push   $0x58
  800683:	ff d6                	call   *%esi
			putch('X', putdat);
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 58                	push   $0x58
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800693:	e9 8b fc ff ff       	jmp    800323 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 30                	push   $0x30
  80069e:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a0:	83 c4 08             	add    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	6a 78                	push   $0x78
  8006a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c0:	eb 4a                	jmp    80070c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c2:	83 f9 01             	cmp    $0x1,%ecx
  8006c5:	7e 15                	jle    8006dc <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cf:	8d 40 08             	lea    0x8(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006da:	eb 30                	jmp    80070c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 17                	je     8006f7 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f5:	eb 15                	jmp    80070c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800701:	8d 40 04             	lea    0x4(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800713:	57                   	push   %edi
  800714:	ff 75 e0             	pushl  -0x20(%ebp)
  800717:	50                   	push   %eax
  800718:	51                   	push   %ecx
  800719:	52                   	push   %edx
  80071a:	89 da                	mov    %ebx,%edx
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	e8 f1 fa ff ff       	call   800214 <printnum>
			break;
  800723:	83 c4 20             	add    $0x20,%esp
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800729:	e9 f5 fb ff ff       	jmp    800323 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	52                   	push   %edx
  800733:	ff d6                	call   *%esi
			break;
  800735:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073b:	e9 e3 fb ff ff       	jmp    800323 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 25                	push   $0x25
  800746:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	eb 03                	jmp    800750 <vprintfmt+0x453>
  80074d:	83 ef 01             	sub    $0x1,%edi
  800750:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800754:	75 f7                	jne    80074d <vprintfmt+0x450>
  800756:	e9 c8 fb ff ff       	jmp    800323 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075e:	5b                   	pop    %ebx
  80075f:	5e                   	pop    %esi
  800760:	5f                   	pop    %edi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 18             	sub    $0x18,%esp
  800769:	8b 45 08             	mov    0x8(%ebp),%eax
  80076c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800772:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800776:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800780:	85 c0                	test   %eax,%eax
  800782:	74 26                	je     8007aa <vsnprintf+0x47>
  800784:	85 d2                	test   %edx,%edx
  800786:	7e 22                	jle    8007aa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800788:	ff 75 14             	pushl  0x14(%ebp)
  80078b:	ff 75 10             	pushl  0x10(%ebp)
  80078e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	68 c3 02 80 00       	push   $0x8002c3
  800797:	e8 61 fb ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	eb 05                	jmp    8007af <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	50                   	push   %eax
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	ff 75 08             	pushl  0x8(%ebp)
  8007c4:	e8 9a ff ff ff       	call   800763 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 03                	jmp    8007db <strlen+0x10>
		n++;
  8007d8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007db:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007df:	75 f7                	jne    8007d8 <strlen+0xd>
		n++;
	return n;
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f1:	eb 03                	jmp    8007f6 <strnlen+0x13>
		n++;
  8007f3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f6:	39 c2                	cmp    %eax,%edx
  8007f8:	74 08                	je     800802 <strnlen+0x1f>
  8007fa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007fe:	75 f3                	jne    8007f3 <strnlen+0x10>
  800800:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080e:	89 c2                	mov    %eax,%edx
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081d:	84 db                	test   %bl,%bl
  80081f:	75 ef                	jne    800810 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082b:	53                   	push   %ebx
  80082c:	e8 9a ff ff ff       	call   8007cb <strlen>
  800831:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800834:	ff 75 0c             	pushl  0xc(%ebp)
  800837:	01 d8                	add    %ebx,%eax
  800839:	50                   	push   %eax
  80083a:	e8 c5 ff ff ff       	call   800804 <strcpy>
	return dst;
}
  80083f:	89 d8                	mov    %ebx,%eax
  800841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 75 08             	mov    0x8(%ebp),%esi
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	89 f3                	mov    %esi,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800856:	89 f2                	mov    %esi,%edx
  800858:	eb 0f                	jmp    800869 <strncpy+0x23>
		*dst++ = *src;
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800863:	80 39 01             	cmpb   $0x1,(%ecx)
  800866:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	39 da                	cmp    %ebx,%edx
  80086b:	75 ed                	jne    80085a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 75 08             	mov    0x8(%ebp),%esi
  80087b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087e:	8b 55 10             	mov    0x10(%ebp),%edx
  800881:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800883:	85 d2                	test   %edx,%edx
  800885:	74 21                	je     8008a8 <strlcpy+0x35>
  800887:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088b:	89 f2                	mov    %esi,%edx
  80088d:	eb 09                	jmp    800898 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800898:	39 c2                	cmp    %eax,%edx
  80089a:	74 09                	je     8008a5 <strlcpy+0x32>
  80089c:	0f b6 19             	movzbl (%ecx),%ebx
  80089f:	84 db                	test   %bl,%bl
  8008a1:	75 ec                	jne    80088f <strlcpy+0x1c>
  8008a3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a8:	29 f0                	sub    %esi,%eax
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strcmp+0x11>
		p++, q++;
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bf:	0f b6 01             	movzbl (%ecx),%eax
  8008c2:	84 c0                	test   %al,%al
  8008c4:	74 04                	je     8008ca <strcmp+0x1c>
  8008c6:	3a 02                	cmp    (%edx),%al
  8008c8:	74 ef                	je     8008b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 c0             	movzbl %al,%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	89 c3                	mov    %eax,%ebx
  8008e0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e3:	eb 06                	jmp    8008eb <strncmp+0x17>
		n--, p++, q++;
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008eb:	39 d8                	cmp    %ebx,%eax
  8008ed:	74 15                	je     800904 <strncmp+0x30>
  8008ef:	0f b6 08             	movzbl (%eax),%ecx
  8008f2:	84 c9                	test   %cl,%cl
  8008f4:	74 04                	je     8008fa <strncmp+0x26>
  8008f6:	3a 0a                	cmp    (%edx),%cl
  8008f8:	74 eb                	je     8008e5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fa:	0f b6 00             	movzbl (%eax),%eax
  8008fd:	0f b6 12             	movzbl (%edx),%edx
  800900:	29 d0                	sub    %edx,%eax
  800902:	eb 05                	jmp    800909 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800916:	eb 07                	jmp    80091f <strchr+0x13>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 0f                	je     80092b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	0f b6 10             	movzbl (%eax),%edx
  800922:	84 d2                	test   %dl,%dl
  800924:	75 f2                	jne    800918 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800937:	eb 03                	jmp    80093c <strfind+0xf>
  800939:	83 c0 01             	add    $0x1,%eax
  80093c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	74 04                	je     800947 <strfind+0x1a>
  800943:	84 d2                	test   %dl,%dl
  800945:	75 f2                	jne    800939 <strfind+0xc>
			break;
	return (char *) s;
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800955:	85 c9                	test   %ecx,%ecx
  800957:	74 36                	je     80098f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800959:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095f:	75 28                	jne    800989 <memset+0x40>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 23                	jne    800989 <memset+0x40>
		c &= 0xFF;
  800966:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096a:	89 d3                	mov    %edx,%ebx
  80096c:	c1 e3 08             	shl    $0x8,%ebx
  80096f:	89 d6                	mov    %edx,%esi
  800971:	c1 e6 18             	shl    $0x18,%esi
  800974:	89 d0                	mov    %edx,%eax
  800976:	c1 e0 10             	shl    $0x10,%eax
  800979:	09 f0                	or     %esi,%eax
  80097b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80097d:	89 d8                	mov    %ebx,%eax
  80097f:	09 d0                	or     %edx,%eax
  800981:	c1 e9 02             	shr    $0x2,%ecx
  800984:	fc                   	cld    
  800985:	f3 ab                	rep stos %eax,%es:(%edi)
  800987:	eb 06                	jmp    80098f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098c:	fc                   	cld    
  80098d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098f:	89 f8                	mov    %edi,%eax
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a4:	39 c6                	cmp    %eax,%esi
  8009a6:	73 35                	jae    8009dd <memmove+0x47>
  8009a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ab:	39 d0                	cmp    %edx,%eax
  8009ad:	73 2e                	jae    8009dd <memmove+0x47>
		s += n;
		d += n;
  8009af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	09 fe                	or     %edi,%esi
  8009b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bc:	75 13                	jne    8009d1 <memmove+0x3b>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 0e                	jne    8009d1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c3:	83 ef 04             	sub    $0x4,%edi
  8009c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
  8009cc:	fd                   	std    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 09                	jmp    8009da <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d1:	83 ef 01             	sub    $0x1,%edi
  8009d4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d7:	fd                   	std    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009da:	fc                   	cld    
  8009db:	eb 1d                	jmp    8009fa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	89 f2                	mov    %esi,%edx
  8009df:	09 c2                	or     %eax,%edx
  8009e1:	f6 c2 03             	test   $0x3,%dl
  8009e4:	75 0f                	jne    8009f5 <memmove+0x5f>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 0a                	jne    8009f5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f3:	eb 05                	jmp    8009fa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a01:	ff 75 10             	pushl  0x10(%ebp)
  800a04:	ff 75 0c             	pushl  0xc(%ebp)
  800a07:	ff 75 08             	pushl  0x8(%ebp)
  800a0a:	e8 87 ff ff ff       	call   800996 <memmove>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 c6                	mov    %eax,%esi
  800a1e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a21:	eb 1a                	jmp    800a3d <memcmp+0x2c>
		if (*s1 != *s2)
  800a23:	0f b6 08             	movzbl (%eax),%ecx
  800a26:	0f b6 1a             	movzbl (%edx),%ebx
  800a29:	38 d9                	cmp    %bl,%cl
  800a2b:	74 0a                	je     800a37 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a2d:	0f b6 c1             	movzbl %cl,%eax
  800a30:	0f b6 db             	movzbl %bl,%ebx
  800a33:	29 d8                	sub    %ebx,%eax
  800a35:	eb 0f                	jmp    800a46 <memcmp+0x35>
		s1++, s2++;
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3d:	39 f0                	cmp    %esi,%eax
  800a3f:	75 e2                	jne    800a23 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	53                   	push   %ebx
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a51:	89 c1                	mov    %eax,%ecx
  800a53:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5a:	eb 0a                	jmp    800a66 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5c:	0f b6 10             	movzbl (%eax),%edx
  800a5f:	39 da                	cmp    %ebx,%edx
  800a61:	74 07                	je     800a6a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	39 c8                	cmp    %ecx,%eax
  800a68:	72 f2                	jb     800a5c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	eb 03                	jmp    800a7e <strtol+0x11>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7e:	0f b6 01             	movzbl (%ecx),%eax
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f6                	je     800a7b <strtol+0xe>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f2                	je     800a7b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	75 0a                	jne    800a97 <strtol+0x2a>
		s++;
  800a8d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
  800a95:	eb 11                	jmp    800aa8 <strtol+0x3b>
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9c:	3c 2d                	cmp    $0x2d,%al
  800a9e:	75 08                	jne    800aa8 <strtol+0x3b>
		s++, neg = 1;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aae:	75 15                	jne    800ac5 <strtol+0x58>
  800ab0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab3:	75 10                	jne    800ac5 <strtol+0x58>
  800ab5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab9:	75 7c                	jne    800b37 <strtol+0xca>
		s += 2, base = 16;
  800abb:	83 c1 02             	add    $0x2,%ecx
  800abe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac3:	eb 16                	jmp    800adb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	75 12                	jne    800adb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ace:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad1:	75 08                	jne    800adb <strtol+0x6e>
		s++, base = 8;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae3:	0f b6 11             	movzbl (%ecx),%edx
  800ae6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 09             	cmp    $0x9,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x8b>
			dig = *s - '0';
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 30             	sub    $0x30,%edx
  800af6:	eb 22                	jmp    800b1a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 08                	ja     800b0a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 57             	sub    $0x57,%edx
  800b08:	eb 10                	jmp    800b1a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 16                	ja     800b2a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b14:	0f be d2             	movsbl %dl,%edx
  800b17:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b1d:	7d 0b                	jge    800b2a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b26:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b28:	eb b9                	jmp    800ae3 <strtol+0x76>

	if (endptr)
  800b2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2e:	74 0d                	je     800b3d <strtol+0xd0>
		*endptr = (char *) s;
  800b30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b33:	89 0e                	mov    %ecx,(%esi)
  800b35:	eb 06                	jmp    800b3d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	74 98                	je     800ad3 <strtol+0x66>
  800b3b:	eb 9e                	jmp    800adb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	f7 da                	neg    %edx
  800b41:	85 ff                	test   %edi,%edi
  800b43:	0f 45 c2             	cmovne %edx,%eax
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	89 c7                	mov    %eax,%edi
  800b60:	89 c6                	mov    %eax,%esi
  800b62:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 01 00 00 00       	mov    $0x1,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b96:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	89 cb                	mov    %ecx,%ebx
  800ba0:	89 cf                	mov    %ecx,%edi
  800ba2:	89 ce                	mov    %ecx,%esi
  800ba4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba6:	85 c0                	test   %eax,%eax
  800ba8:	7e 17                	jle    800bc1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	50                   	push   %eax
  800bae:	6a 03                	push   $0x3
  800bb0:	68 bf 24 80 00       	push   $0x8024bf
  800bb5:	6a 23                	push   $0x23
  800bb7:	68 dc 24 80 00       	push   $0x8024dc
  800bbc:	e8 8b 11 00 00       	call   801d4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd9:	89 d1                	mov    %edx,%ecx
  800bdb:	89 d3                	mov    %edx,%ebx
  800bdd:	89 d7                	mov    %edx,%edi
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_yield>:

void
sys_yield(void)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf8:	89 d1                	mov    %edx,%ecx
  800bfa:	89 d3                	mov    %edx,%ebx
  800bfc:	89 d7                	mov    %edx,%edi
  800bfe:	89 d6                	mov    %edx,%esi
  800c00:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	be 00 00 00 00       	mov    $0x0,%esi
  800c15:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	89 f7                	mov    %esi,%edi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 04                	push   $0x4
  800c31:	68 bf 24 80 00       	push   $0x8024bf
  800c36:	6a 23                	push   $0x23
  800c38:	68 dc 24 80 00       	push   $0x8024dc
  800c3d:	e8 0a 11 00 00       	call   801d4c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	b8 05 00 00 00       	mov    $0x5,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c64:	8b 75 18             	mov    0x18(%ebp),%esi
  800c67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 05                	push   $0x5
  800c73:	68 bf 24 80 00       	push   $0x8024bf
  800c78:	6a 23                	push   $0x23
  800c7a:	68 dc 24 80 00       	push   $0x8024dc
  800c7f:	e8 c8 10 00 00       	call   801d4c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 06                	push   $0x6
  800cb5:	68 bf 24 80 00       	push   $0x8024bf
  800cba:	6a 23                	push   $0x23
  800cbc:	68 dc 24 80 00       	push   $0x8024dc
  800cc1:	e8 86 10 00 00       	call   801d4c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 17                	jle    800d08 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 08                	push   $0x8
  800cf7:	68 bf 24 80 00       	push   $0x8024bf
  800cfc:	6a 23                	push   $0x23
  800cfe:	68 dc 24 80 00       	push   $0x8024dc
  800d03:	e8 44 10 00 00       	call   801d4c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 df                	mov    %ebx,%edi
  800d2b:	89 de                	mov    %ebx,%esi
  800d2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7e 17                	jle    800d4a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	50                   	push   %eax
  800d37:	6a 09                	push   $0x9
  800d39:	68 bf 24 80 00       	push   $0x8024bf
  800d3e:	6a 23                	push   $0x23
  800d40:	68 dc 24 80 00       	push   $0x8024dc
  800d45:	e8 02 10 00 00       	call   801d4c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 df                	mov    %ebx,%edi
  800d6d:	89 de                	mov    %ebx,%esi
  800d6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 17                	jle    800d8c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	6a 0a                	push   $0xa
  800d7b:	68 bf 24 80 00       	push   $0x8024bf
  800d80:	6a 23                	push   $0x23
  800d82:	68 dc 24 80 00       	push   $0x8024dc
  800d87:	e8 c0 0f 00 00       	call   801d4c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 cb                	mov    %ecx,%ebx
  800dcf:	89 cf                	mov    %ecx,%edi
  800dd1:	89 ce                	mov    %ecx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 0d                	push   $0xd
  800ddf:	68 bf 24 80 00       	push   $0x8024bf
  800de4:	6a 23                	push   $0x23
  800de6:	68 dc 24 80 00       	push   $0x8024dc
  800deb:	e8 5c 0f 00 00       	call   801d4c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e04:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e06:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e09:	83 3a 01             	cmpl   $0x1,(%edx)
  800e0c:	7e 09                	jle    800e17 <argstart+0x1f>
  800e0e:	ba 91 21 80 00       	mov    $0x802191,%edx
  800e13:	85 c9                	test   %ecx,%ecx
  800e15:	75 05                	jne    800e1c <argstart+0x24>
  800e17:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1c:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e1f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <argnext>:

int
argnext(struct Argstate *args)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e32:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e39:	8b 43 08             	mov    0x8(%ebx),%eax
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	74 6f                	je     800eaf <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e40:	80 38 00             	cmpb   $0x0,(%eax)
  800e43:	75 4e                	jne    800e93 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e45:	8b 0b                	mov    (%ebx),%ecx
  800e47:	83 39 01             	cmpl   $0x1,(%ecx)
  800e4a:	74 55                	je     800ea1 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e4c:	8b 53 04             	mov    0x4(%ebx),%edx
  800e4f:	8b 42 04             	mov    0x4(%edx),%eax
  800e52:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e55:	75 4a                	jne    800ea1 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e57:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e5b:	74 44                	je     800ea1 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e5d:	83 c0 01             	add    $0x1,%eax
  800e60:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	8b 01                	mov    (%ecx),%eax
  800e68:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e6f:	50                   	push   %eax
  800e70:	8d 42 08             	lea    0x8(%edx),%eax
  800e73:	50                   	push   %eax
  800e74:	83 c2 04             	add    $0x4,%edx
  800e77:	52                   	push   %edx
  800e78:	e8 19 fb ff ff       	call   800996 <memmove>
		(*args->argc)--;
  800e7d:	8b 03                	mov    (%ebx),%eax
  800e7f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e82:	8b 43 08             	mov    0x8(%ebx),%eax
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e8b:	75 06                	jne    800e93 <argnext+0x6b>
  800e8d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e91:	74 0e                	je     800ea1 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e93:	8b 53 08             	mov    0x8(%ebx),%edx
  800e96:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e99:	83 c2 01             	add    $0x1,%edx
  800e9c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e9f:	eb 13                	jmp    800eb4 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800ea1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ead:	eb 05                	jmp    800eb4 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800eaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    

00800eb9 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	53                   	push   %ebx
  800ebd:	83 ec 04             	sub    $0x4,%esp
  800ec0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800ec3:	8b 43 08             	mov    0x8(%ebx),%eax
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	74 58                	je     800f22 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800eca:	80 38 00             	cmpb   $0x0,(%eax)
  800ecd:	74 0c                	je     800edb <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800ecf:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800ed2:	c7 43 08 91 21 80 00 	movl   $0x802191,0x8(%ebx)
  800ed9:	eb 42                	jmp    800f1d <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800edb:	8b 13                	mov    (%ebx),%edx
  800edd:	83 3a 01             	cmpl   $0x1,(%edx)
  800ee0:	7e 2d                	jle    800f0f <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800ee2:	8b 43 04             	mov    0x4(%ebx),%eax
  800ee5:	8b 48 04             	mov    0x4(%eax),%ecx
  800ee8:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	8b 12                	mov    (%edx),%edx
  800ef0:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ef7:	52                   	push   %edx
  800ef8:	8d 50 08             	lea    0x8(%eax),%edx
  800efb:	52                   	push   %edx
  800efc:	83 c0 04             	add    $0x4,%eax
  800eff:	50                   	push   %eax
  800f00:	e8 91 fa ff ff       	call   800996 <memmove>
		(*args->argc)--;
  800f05:	8b 03                	mov    (%ebx),%eax
  800f07:	83 28 01             	subl   $0x1,(%eax)
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	eb 0e                	jmp    800f1d <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800f0f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f16:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f1d:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f20:	eb 05                	jmp    800f27 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f35:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f38:	89 d0                	mov    %edx,%eax
  800f3a:	85 d2                	test   %edx,%edx
  800f3c:	75 0c                	jne    800f4a <argvalue+0x1e>
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	51                   	push   %ecx
  800f42:	e8 72 ff ff ff       	call   800eb9 <argnextvalue>
  800f47:	83 c4 10             	add    $0x10,%esp
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	05 00 00 00 30       	add    $0x30000000,%eax
  800f57:	c1 e8 0c             	shr    $0xc,%eax
}
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	05 00 00 00 30       	add    $0x30000000,%eax
  800f67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f6c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f79:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 16             	shr    $0x16,%edx
  800f83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	74 11                	je     800fa0 <fd_alloc+0x2d>
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	c1 ea 0c             	shr    $0xc,%edx
  800f94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	75 09                	jne    800fa9 <fd_alloc+0x36>
			*fd_store = fd;
  800fa0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	eb 17                	jmp    800fc0 <fd_alloc+0x4d>
  800fa9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fb3:	75 c9                	jne    800f7e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fb5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fbb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fc8:	83 f8 1f             	cmp    $0x1f,%eax
  800fcb:	77 36                	ja     801003 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fcd:	c1 e0 0c             	shl    $0xc,%eax
  800fd0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fd5:	89 c2                	mov    %eax,%edx
  800fd7:	c1 ea 16             	shr    $0x16,%edx
  800fda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe1:	f6 c2 01             	test   $0x1,%dl
  800fe4:	74 24                	je     80100a <fd_lookup+0x48>
  800fe6:	89 c2                	mov    %eax,%edx
  800fe8:	c1 ea 0c             	shr    $0xc,%edx
  800feb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ff2:	f6 c2 01             	test   $0x1,%dl
  800ff5:	74 1a                	je     801011 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffa:	89 02                	mov    %eax,(%edx)
	return 0;
  800ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  801001:	eb 13                	jmp    801016 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801003:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801008:	eb 0c                	jmp    801016 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80100a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80100f:	eb 05                	jmp    801016 <fd_lookup+0x54>
  801011:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801021:	ba 68 25 80 00       	mov    $0x802568,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801026:	eb 13                	jmp    80103b <dev_lookup+0x23>
  801028:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80102b:	39 08                	cmp    %ecx,(%eax)
  80102d:	75 0c                	jne    80103b <dev_lookup+0x23>
			*dev = devtab[i];
  80102f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801032:	89 01                	mov    %eax,(%ecx)
			return 0;
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
  801039:	eb 2e                	jmp    801069 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80103b:	8b 02                	mov    (%edx),%eax
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 e7                	jne    801028 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801041:	a1 04 40 80 00       	mov    0x804004,%eax
  801046:	8b 40 48             	mov    0x48(%eax),%eax
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	51                   	push   %ecx
  80104d:	50                   	push   %eax
  80104e:	68 ec 24 80 00       	push   $0x8024ec
  801053:	e8 a8 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  801058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801069:	c9                   	leave  
  80106a:	c3                   	ret    

0080106b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 10             	sub    $0x10,%esp
  801073:	8b 75 08             	mov    0x8(%ebp),%esi
  801076:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801079:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107c:	50                   	push   %eax
  80107d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801083:	c1 e8 0c             	shr    $0xc,%eax
  801086:	50                   	push   %eax
  801087:	e8 36 ff ff ff       	call   800fc2 <fd_lookup>
  80108c:	83 c4 08             	add    $0x8,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	78 05                	js     801098 <fd_close+0x2d>
	    || fd != fd2)
  801093:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801096:	74 0c                	je     8010a4 <fd_close+0x39>
		return (must_exist ? r : 0);
  801098:	84 db                	test   %bl,%bl
  80109a:	ba 00 00 00 00       	mov    $0x0,%edx
  80109f:	0f 44 c2             	cmove  %edx,%eax
  8010a2:	eb 41                	jmp    8010e5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	ff 36                	pushl  (%esi)
  8010ad:	e8 66 ff ff ff       	call   801018 <dev_lookup>
  8010b2:	89 c3                	mov    %eax,%ebx
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 1a                	js     8010d5 <fd_close+0x6a>
		if (dev->dev_close)
  8010bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010be:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010c1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	74 0b                	je     8010d5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	56                   	push   %esi
  8010ce:	ff d0                	call   *%eax
  8010d0:	89 c3                	mov    %eax,%ebx
  8010d2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	56                   	push   %esi
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 ac fb ff ff       	call   800c8c <sys_page_unmap>
	return r;
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 d8                	mov    %ebx,%eax
}
  8010e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	ff 75 08             	pushl  0x8(%ebp)
  8010f9:	e8 c4 fe ff ff       	call   800fc2 <fd_lookup>
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 10                	js     801115 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	6a 01                	push   $0x1
  80110a:	ff 75 f4             	pushl  -0xc(%ebp)
  80110d:	e8 59 ff ff ff       	call   80106b <fd_close>
  801112:	83 c4 10             	add    $0x10,%esp
}
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <close_all>:

void
close_all(void)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	53                   	push   %ebx
  80111b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	53                   	push   %ebx
  801127:	e8 c0 ff ff ff       	call   8010ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112c:	83 c3 01             	add    $0x1,%ebx
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	83 fb 20             	cmp    $0x20,%ebx
  801135:	75 ec                	jne    801123 <close_all+0xc>
		close(i);
}
  801137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 2c             	sub    $0x2c,%esp
  801145:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801148:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	ff 75 08             	pushl  0x8(%ebp)
  80114f:	e8 6e fe ff ff       	call   800fc2 <fd_lookup>
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 88 c1 00 00 00    	js     801220 <dup+0xe4>
		return r;
	close(newfdnum);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	56                   	push   %esi
  801163:	e8 84 ff ff ff       	call   8010ec <close>

	newfd = INDEX2FD(newfdnum);
  801168:	89 f3                	mov    %esi,%ebx
  80116a:	c1 e3 0c             	shl    $0xc,%ebx
  80116d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801173:	83 c4 04             	add    $0x4,%esp
  801176:	ff 75 e4             	pushl  -0x1c(%ebp)
  801179:	e8 de fd ff ff       	call   800f5c <fd2data>
  80117e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801180:	89 1c 24             	mov    %ebx,(%esp)
  801183:	e8 d4 fd ff ff       	call   800f5c <fd2data>
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118e:	89 f8                	mov    %edi,%eax
  801190:	c1 e8 16             	shr    $0x16,%eax
  801193:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119a:	a8 01                	test   $0x1,%al
  80119c:	74 37                	je     8011d5 <dup+0x99>
  80119e:	89 f8                	mov    %edi,%eax
  8011a0:	c1 e8 0c             	shr    $0xc,%eax
  8011a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011aa:	f6 c2 01             	test   $0x1,%dl
  8011ad:	74 26                	je     8011d5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b6:	83 ec 0c             	sub    $0xc,%esp
  8011b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8011be:	50                   	push   %eax
  8011bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011c2:	6a 00                	push   $0x0
  8011c4:	57                   	push   %edi
  8011c5:	6a 00                	push   $0x0
  8011c7:	e8 7e fa ff ff       	call   800c4a <sys_page_map>
  8011cc:	89 c7                	mov    %eax,%edi
  8011ce:	83 c4 20             	add    $0x20,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 2e                	js     801203 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011d8:	89 d0                	mov    %edx,%eax
  8011da:	c1 e8 0c             	shr    $0xc,%eax
  8011dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e4:	83 ec 0c             	sub    $0xc,%esp
  8011e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ec:	50                   	push   %eax
  8011ed:	53                   	push   %ebx
  8011ee:	6a 00                	push   $0x0
  8011f0:	52                   	push   %edx
  8011f1:	6a 00                	push   $0x0
  8011f3:	e8 52 fa ff ff       	call   800c4a <sys_page_map>
  8011f8:	89 c7                	mov    %eax,%edi
  8011fa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011fd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ff:	85 ff                	test   %edi,%edi
  801201:	79 1d                	jns    801220 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	53                   	push   %ebx
  801207:	6a 00                	push   $0x0
  801209:	e8 7e fa ff ff       	call   800c8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120e:	83 c4 08             	add    $0x8,%esp
  801211:	ff 75 d4             	pushl  -0x2c(%ebp)
  801214:	6a 00                	push   $0x0
  801216:	e8 71 fa ff ff       	call   800c8c <sys_page_unmap>
	return r;
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	89 f8                	mov    %edi,%eax
}
  801220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 14             	sub    $0x14,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	53                   	push   %ebx
  801237:	e8 86 fd ff ff       	call   800fc2 <fd_lookup>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	89 c2                	mov    %eax,%edx
  801241:	85 c0                	test   %eax,%eax
  801243:	78 6d                	js     8012b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	ff 30                	pushl  (%eax)
  801251:	e8 c2 fd ff ff       	call   801018 <dev_lookup>
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 4c                	js     8012a9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80125d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801260:	8b 42 08             	mov    0x8(%edx),%eax
  801263:	83 e0 03             	and    $0x3,%eax
  801266:	83 f8 01             	cmp    $0x1,%eax
  801269:	75 21                	jne    80128c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126b:	a1 04 40 80 00       	mov    0x804004,%eax
  801270:	8b 40 48             	mov    0x48(%eax),%eax
  801273:	83 ec 04             	sub    $0x4,%esp
  801276:	53                   	push   %ebx
  801277:	50                   	push   %eax
  801278:	68 2d 25 80 00       	push   $0x80252d
  80127d:	e8 7e ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80128a:	eb 26                	jmp    8012b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	8b 40 08             	mov    0x8(%eax),%eax
  801292:	85 c0                	test   %eax,%eax
  801294:	74 17                	je     8012ad <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801296:	83 ec 04             	sub    $0x4,%esp
  801299:	ff 75 10             	pushl  0x10(%ebp)
  80129c:	ff 75 0c             	pushl  0xc(%ebp)
  80129f:	52                   	push   %edx
  8012a0:	ff d0                	call   *%eax
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	eb 09                	jmp    8012b2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	eb 05                	jmp    8012b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012b2:	89 d0                	mov    %edx,%eax
  8012b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 0c             	sub    $0xc,%esp
  8012c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012cd:	eb 21                	jmp    8012f0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	89 f0                	mov    %esi,%eax
  8012d4:	29 d8                	sub    %ebx,%eax
  8012d6:	50                   	push   %eax
  8012d7:	89 d8                	mov    %ebx,%eax
  8012d9:	03 45 0c             	add    0xc(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	57                   	push   %edi
  8012de:	e8 45 ff ff ff       	call   801228 <read>
		if (m < 0)
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 10                	js     8012fa <readn+0x41>
			return m;
		if (m == 0)
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	74 0a                	je     8012f8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ee:	01 c3                	add    %eax,%ebx
  8012f0:	39 f3                	cmp    %esi,%ebx
  8012f2:	72 db                	jb     8012cf <readn+0x16>
  8012f4:	89 d8                	mov    %ebx,%eax
  8012f6:	eb 02                	jmp    8012fa <readn+0x41>
  8012f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 14             	sub    $0x14,%esp
  801309:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	53                   	push   %ebx
  801311:	e8 ac fc ff ff       	call   800fc2 <fd_lookup>
  801316:	83 c4 08             	add    $0x8,%esp
  801319:	89 c2                	mov    %eax,%edx
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 68                	js     801387 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	ff 30                	pushl  (%eax)
  80132b:	e8 e8 fc ff ff       	call   801018 <dev_lookup>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 47                	js     80137e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133e:	75 21                	jne    801361 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801340:	a1 04 40 80 00       	mov    0x804004,%eax
  801345:	8b 40 48             	mov    0x48(%eax),%eax
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	53                   	push   %ebx
  80134c:	50                   	push   %eax
  80134d:	68 49 25 80 00       	push   $0x802549
  801352:	e8 a9 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135f:	eb 26                	jmp    801387 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801361:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801364:	8b 52 0c             	mov    0xc(%edx),%edx
  801367:	85 d2                	test   %edx,%edx
  801369:	74 17                	je     801382 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	ff 75 10             	pushl  0x10(%ebp)
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	50                   	push   %eax
  801375:	ff d2                	call   *%edx
  801377:	89 c2                	mov    %eax,%edx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	eb 09                	jmp    801387 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137e:	89 c2                	mov    %eax,%edx
  801380:	eb 05                	jmp    801387 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801382:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801387:	89 d0                	mov    %edx,%eax
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <seek>:

int
seek(int fdnum, off_t offset)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801394:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	ff 75 08             	pushl  0x8(%ebp)
  80139b:	e8 22 fc ff ff       	call   800fc2 <fd_lookup>
  8013a0:	83 c4 08             	add    $0x8,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 0e                	js     8013b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 14             	sub    $0x14,%esp
  8013be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	53                   	push   %ebx
  8013c6:	e8 f7 fb ff ff       	call   800fc2 <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 65                	js     801439 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013de:	ff 30                	pushl  (%eax)
  8013e0:	e8 33 fc ff ff       	call   801018 <dev_lookup>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 44                	js     801430 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f3:	75 21                	jne    801416 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013f5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013fa:	8b 40 48             	mov    0x48(%eax),%eax
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	53                   	push   %ebx
  801401:	50                   	push   %eax
  801402:	68 0c 25 80 00       	push   $0x80250c
  801407:	e8 f4 ed ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801414:	eb 23                	jmp    801439 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801416:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801419:	8b 52 18             	mov    0x18(%edx),%edx
  80141c:	85 d2                	test   %edx,%edx
  80141e:	74 14                	je     801434 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 0c             	pushl  0xc(%ebp)
  801426:	50                   	push   %eax
  801427:	ff d2                	call   *%edx
  801429:	89 c2                	mov    %eax,%edx
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	eb 09                	jmp    801439 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	89 c2                	mov    %eax,%edx
  801432:	eb 05                	jmp    801439 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801434:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801439:	89 d0                	mov    %edx,%eax
  80143b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 14             	sub    $0x14,%esp
  801447:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	ff 75 08             	pushl  0x8(%ebp)
  801451:	e8 6c fb ff ff       	call   800fc2 <fd_lookup>
  801456:	83 c4 08             	add    $0x8,%esp
  801459:	89 c2                	mov    %eax,%edx
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 58                	js     8014b7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801469:	ff 30                	pushl  (%eax)
  80146b:	e8 a8 fb ff ff       	call   801018 <dev_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 37                	js     8014ae <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80147e:	74 32                	je     8014b2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801480:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801483:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80148a:	00 00 00 
	stat->st_isdir = 0;
  80148d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801494:	00 00 00 
	stat->st_dev = dev;
  801497:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	53                   	push   %ebx
  8014a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8014a4:	ff 50 14             	call   *0x14(%eax)
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb 09                	jmp    8014b7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	eb 05                	jmp    8014b7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014b7:	89 d0                	mov    %edx,%eax
  8014b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	6a 00                	push   $0x0
  8014c8:	ff 75 08             	pushl  0x8(%ebp)
  8014cb:	e8 e9 01 00 00       	call   8016b9 <open>
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 1b                	js     8014f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	ff 75 0c             	pushl  0xc(%ebp)
  8014df:	50                   	push   %eax
  8014e0:	e8 5b ff ff ff       	call   801440 <fstat>
  8014e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8014e7:	89 1c 24             	mov    %ebx,(%esp)
  8014ea:	e8 fd fb ff ff       	call   8010ec <close>
	return r;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	89 f0                	mov    %esi,%eax
}
  8014f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	89 c6                	mov    %eax,%esi
  801502:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801504:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80150b:	75 12                	jne    80151f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	6a 01                	push   $0x1
  801512:	e8 51 09 00 00       	call   801e68 <ipc_find_env>
  801517:	a3 00 40 80 00       	mov    %eax,0x804000
  80151c:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80151f:	6a 07                	push   $0x7
  801521:	68 00 50 80 00       	push   $0x805000
  801526:	56                   	push   %esi
  801527:	ff 35 00 40 80 00    	pushl  0x804000
  80152d:	e8 e2 08 00 00       	call   801e14 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801532:	83 c4 0c             	add    $0xc,%esp
  801535:	6a 00                	push   $0x0
  801537:	53                   	push   %ebx
  801538:	6a 00                	push   $0x0
  80153a:	e8 53 08 00 00       	call   801d92 <ipc_recv>
}
  80153f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801542:	5b                   	pop    %ebx
  801543:	5e                   	pop    %esi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    

00801546 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80154c:	8b 45 08             	mov    0x8(%ebp),%eax
  80154f:	8b 40 0c             	mov    0xc(%eax),%eax
  801552:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801557:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
  801564:	b8 02 00 00 00       	mov    $0x2,%eax
  801569:	e8 8d ff ff ff       	call   8014fb <fsipc>
}
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801576:	8b 45 08             	mov    0x8(%ebp),%eax
  801579:	8b 40 0c             	mov    0xc(%eax),%eax
  80157c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801581:	ba 00 00 00 00       	mov    $0x0,%edx
  801586:	b8 06 00 00 00       	mov    $0x6,%eax
  80158b:	e8 6b ff ff ff       	call   8014fb <fsipc>
}
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80159c:	8b 45 08             	mov    0x8(%ebp),%eax
  80159f:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8015b1:	e8 45 ff ff ff       	call   8014fb <fsipc>
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 2c                	js     8015e6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	68 00 50 80 00       	push   $0x805000
  8015c2:	53                   	push   %ebx
  8015c3:	e8 3c f2 ff ff       	call   800804 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015c8:	a1 80 50 80 00       	mov    0x805080,%eax
  8015cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015d3:	a1 84 50 80 00       	mov    0x805084,%eax
  8015d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015f9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015fe:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801601:	8b 55 08             	mov    0x8(%ebp),%edx
  801604:	8b 52 0c             	mov    0xc(%edx),%edx
  801607:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80160d:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801612:	50                   	push   %eax
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	68 08 50 80 00       	push   $0x805008
  80161b:	e8 76 f3 ff ff       	call   800996 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801620:	ba 00 00 00 00       	mov    $0x0,%edx
  801625:	b8 04 00 00 00       	mov    $0x4,%eax
  80162a:	e8 cc fe ff ff       	call   8014fb <fsipc>
            return r;

    return r;
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	8b 40 0c             	mov    0xc(%eax),%eax
  80163f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801644:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80164a:	ba 00 00 00 00       	mov    $0x0,%edx
  80164f:	b8 03 00 00 00       	mov    $0x3,%eax
  801654:	e8 a2 fe ff ff       	call   8014fb <fsipc>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 51                	js     8016b0 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80165f:	39 c6                	cmp    %eax,%esi
  801661:	73 19                	jae    80167c <devfile_read+0x4b>
  801663:	68 78 25 80 00       	push   $0x802578
  801668:	68 7f 25 80 00       	push   $0x80257f
  80166d:	68 82 00 00 00       	push   $0x82
  801672:	68 94 25 80 00       	push   $0x802594
  801677:	e8 d0 06 00 00       	call   801d4c <_panic>
	assert(r <= PGSIZE);
  80167c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801681:	7e 19                	jle    80169c <devfile_read+0x6b>
  801683:	68 9f 25 80 00       	push   $0x80259f
  801688:	68 7f 25 80 00       	push   $0x80257f
  80168d:	68 83 00 00 00       	push   $0x83
  801692:	68 94 25 80 00       	push   $0x802594
  801697:	e8 b0 06 00 00       	call   801d4c <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	50                   	push   %eax
  8016a0:	68 00 50 80 00       	push   $0x805000
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	e8 e9 f2 ff ff       	call   800996 <memmove>
	return r;
  8016ad:	83 c4 10             	add    $0x10,%esp
}
  8016b0:	89 d8                	mov    %ebx,%eax
  8016b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 20             	sub    $0x20,%esp
  8016c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c3:	53                   	push   %ebx
  8016c4:	e8 02 f1 ff ff       	call   8007cb <strlen>
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d1:	7f 67                	jg     80173a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	e8 94 f8 ff ff       	call   800f73 <fd_alloc>
  8016df:	83 c4 10             	add    $0x10,%esp
		return r;
  8016e2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 57                	js     80173f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	53                   	push   %ebx
  8016ec:	68 00 50 80 00       	push   $0x805000
  8016f1:	e8 0e f1 ff ff       	call   800804 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801701:	b8 01 00 00 00       	mov    $0x1,%eax
  801706:	e8 f0 fd ff ff       	call   8014fb <fsipc>
  80170b:	89 c3                	mov    %eax,%ebx
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	79 14                	jns    801728 <open+0x6f>
		fd_close(fd, 0);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	6a 00                	push   $0x0
  801719:	ff 75 f4             	pushl  -0xc(%ebp)
  80171c:	e8 4a f9 ff ff       	call   80106b <fd_close>
		return r;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	89 da                	mov    %ebx,%edx
  801726:	eb 17                	jmp    80173f <open+0x86>
	}

	return fd2num(fd);
  801728:	83 ec 0c             	sub    $0xc,%esp
  80172b:	ff 75 f4             	pushl  -0xc(%ebp)
  80172e:	e8 19 f8 ff ff       	call   800f4c <fd2num>
  801733:	89 c2                	mov    %eax,%edx
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	eb 05                	jmp    80173f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80173a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80173f:	89 d0                	mov    %edx,%eax
  801741:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174c:	ba 00 00 00 00       	mov    $0x0,%edx
  801751:	b8 08 00 00 00       	mov    $0x8,%eax
  801756:	e8 a0 fd ff ff       	call   8014fb <fsipc>
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80175d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801761:	7e 37                	jle    80179a <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	53                   	push   %ebx
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80176c:	ff 70 04             	pushl  0x4(%eax)
  80176f:	8d 40 10             	lea    0x10(%eax),%eax
  801772:	50                   	push   %eax
  801773:	ff 33                	pushl  (%ebx)
  801775:	e8 88 fb ff ff       	call   801302 <write>
		if (result > 0)
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	7e 03                	jle    801784 <writebuf+0x27>
			b->result += result;
  801781:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801784:	3b 43 04             	cmp    0x4(%ebx),%eax
  801787:	74 0d                	je     801796 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801789:	85 c0                	test   %eax,%eax
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	0f 4f c2             	cmovg  %edx,%eax
  801793:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801799:	c9                   	leave  
  80179a:	f3 c3                	repz ret 

0080179c <putch>:

static void
putch(int ch, void *thunk)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 04             	sub    $0x4,%esp
  8017a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017a6:	8b 53 04             	mov    0x4(%ebx),%edx
  8017a9:	8d 42 01             	lea    0x1(%edx),%eax
  8017ac:	89 43 04             	mov    %eax,0x4(%ebx)
  8017af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b2:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017b6:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017bb:	75 0e                	jne    8017cb <putch+0x2f>
		writebuf(b);
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	e8 99 ff ff ff       	call   80175d <writebuf>
		b->idx = 0;
  8017c4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017cb:	83 c4 04             	add    $0x4,%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017e3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017ea:	00 00 00 
	b.result = 0;
  8017ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017f4:	00 00 00 
	b.error = 1;
  8017f7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017fe:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801801:	ff 75 10             	pushl  0x10(%ebp)
  801804:	ff 75 0c             	pushl  0xc(%ebp)
  801807:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80180d:	50                   	push   %eax
  80180e:	68 9c 17 80 00       	push   $0x80179c
  801813:	e8 e5 ea ff ff       	call   8002fd <vprintfmt>
	if (b.idx > 0)
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801822:	7e 0b                	jle    80182f <vfprintf+0x5e>
		writebuf(&b);
  801824:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80182a:	e8 2e ff ff ff       	call   80175d <writebuf>

	return (b.result ? b.result : b.error);
  80182f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801835:	85 c0                	test   %eax,%eax
  801837:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801846:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801849:	50                   	push   %eax
  80184a:	ff 75 0c             	pushl  0xc(%ebp)
  80184d:	ff 75 08             	pushl  0x8(%ebp)
  801850:	e8 7c ff ff ff       	call   8017d1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <printf>:

int
printf(const char *fmt, ...)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80185d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801860:	50                   	push   %eax
  801861:	ff 75 08             	pushl  0x8(%ebp)
  801864:	6a 01                	push   $0x1
  801866:	e8 66 ff ff ff       	call   8017d1 <vfprintf>
	va_end(ap);

	return cnt;
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	56                   	push   %esi
  801871:	53                   	push   %ebx
  801872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801875:	83 ec 0c             	sub    $0xc,%esp
  801878:	ff 75 08             	pushl  0x8(%ebp)
  80187b:	e8 dc f6 ff ff       	call   800f5c <fd2data>
  801880:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801882:	83 c4 08             	add    $0x8,%esp
  801885:	68 ab 25 80 00       	push   $0x8025ab
  80188a:	53                   	push   %ebx
  80188b:	e8 74 ef ff ff       	call   800804 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801890:	8b 46 04             	mov    0x4(%esi),%eax
  801893:	2b 06                	sub    (%esi),%eax
  801895:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80189b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a2:	00 00 00 
	stat->st_dev = &devpipe;
  8018a5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ac:	30 80 00 
	return 0;
}
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018c5:	53                   	push   %ebx
  8018c6:	6a 00                	push   $0x0
  8018c8:	e8 bf f3 ff ff       	call   800c8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018cd:	89 1c 24             	mov    %ebx,(%esp)
  8018d0:	e8 87 f6 ff ff       	call   800f5c <fd2data>
  8018d5:	83 c4 08             	add    $0x8,%esp
  8018d8:	50                   	push   %eax
  8018d9:	6a 00                	push   $0x0
  8018db:	e8 ac f3 ff ff       	call   800c8c <sys_page_unmap>
}
  8018e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	57                   	push   %edi
  8018e9:	56                   	push   %esi
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 1c             	sub    $0x1c,%esp
  8018ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801901:	e8 9b 05 00 00       	call   801ea1 <pageref>
  801906:	89 c3                	mov    %eax,%ebx
  801908:	89 3c 24             	mov    %edi,(%esp)
  80190b:	e8 91 05 00 00       	call   801ea1 <pageref>
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	39 c3                	cmp    %eax,%ebx
  801915:	0f 94 c1             	sete   %cl
  801918:	0f b6 c9             	movzbl %cl,%ecx
  80191b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80191e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801924:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801927:	39 ce                	cmp    %ecx,%esi
  801929:	74 1b                	je     801946 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80192b:	39 c3                	cmp    %eax,%ebx
  80192d:	75 c4                	jne    8018f3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80192f:	8b 42 58             	mov    0x58(%edx),%eax
  801932:	ff 75 e4             	pushl  -0x1c(%ebp)
  801935:	50                   	push   %eax
  801936:	56                   	push   %esi
  801937:	68 b2 25 80 00       	push   $0x8025b2
  80193c:	e8 bf e8 ff ff       	call   800200 <cprintf>
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	eb ad                	jmp    8018f3 <_pipeisclosed+0xe>
	}
}
  801946:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5f                   	pop    %edi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	57                   	push   %edi
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	83 ec 28             	sub    $0x28,%esp
  80195a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80195d:	56                   	push   %esi
  80195e:	e8 f9 f5 ff ff       	call   800f5c <fd2data>
  801963:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	bf 00 00 00 00       	mov    $0x0,%edi
  80196d:	eb 4b                	jmp    8019ba <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80196f:	89 da                	mov    %ebx,%edx
  801971:	89 f0                	mov    %esi,%eax
  801973:	e8 6d ff ff ff       	call   8018e5 <_pipeisclosed>
  801978:	85 c0                	test   %eax,%eax
  80197a:	75 48                	jne    8019c4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80197c:	e8 67 f2 ff ff       	call   800be8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801981:	8b 43 04             	mov    0x4(%ebx),%eax
  801984:	8b 0b                	mov    (%ebx),%ecx
  801986:	8d 51 20             	lea    0x20(%ecx),%edx
  801989:	39 d0                	cmp    %edx,%eax
  80198b:	73 e2                	jae    80196f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80198d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801990:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801994:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801997:	89 c2                	mov    %eax,%edx
  801999:	c1 fa 1f             	sar    $0x1f,%edx
  80199c:	89 d1                	mov    %edx,%ecx
  80199e:	c1 e9 1b             	shr    $0x1b,%ecx
  8019a1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019a4:	83 e2 1f             	and    $0x1f,%edx
  8019a7:	29 ca                	sub    %ecx,%edx
  8019a9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019b1:	83 c0 01             	add    $0x1,%eax
  8019b4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b7:	83 c7 01             	add    $0x1,%edi
  8019ba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019bd:	75 c2                	jne    801981 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c2:	eb 05                	jmp    8019c9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5f                   	pop    %edi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	57                   	push   %edi
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 18             	sub    $0x18,%esp
  8019da:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019dd:	57                   	push   %edi
  8019de:	e8 79 f5 ff ff       	call   800f5c <fd2data>
  8019e3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ed:	eb 3d                	jmp    801a2c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ef:	85 db                	test   %ebx,%ebx
  8019f1:	74 04                	je     8019f7 <devpipe_read+0x26>
				return i;
  8019f3:	89 d8                	mov    %ebx,%eax
  8019f5:	eb 44                	jmp    801a3b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019f7:	89 f2                	mov    %esi,%edx
  8019f9:	89 f8                	mov    %edi,%eax
  8019fb:	e8 e5 fe ff ff       	call   8018e5 <_pipeisclosed>
  801a00:	85 c0                	test   %eax,%eax
  801a02:	75 32                	jne    801a36 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a04:	e8 df f1 ff ff       	call   800be8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a09:	8b 06                	mov    (%esi),%eax
  801a0b:	3b 46 04             	cmp    0x4(%esi),%eax
  801a0e:	74 df                	je     8019ef <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a10:	99                   	cltd   
  801a11:	c1 ea 1b             	shr    $0x1b,%edx
  801a14:	01 d0                	add    %edx,%eax
  801a16:	83 e0 1f             	and    $0x1f,%eax
  801a19:	29 d0                	sub    %edx,%eax
  801a1b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a23:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a26:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a29:	83 c3 01             	add    $0x1,%ebx
  801a2c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a2f:	75 d8                	jne    801a09 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a31:	8b 45 10             	mov    0x10(%ebp),%eax
  801a34:	eb 05                	jmp    801a3b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a36:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3e:	5b                   	pop    %ebx
  801a3f:	5e                   	pop    %esi
  801a40:	5f                   	pop    %edi
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	e8 1f f5 ff ff       	call   800f73 <fd_alloc>
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	0f 88 2c 01 00 00    	js     801b8d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	68 07 04 00 00       	push   $0x407
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 94 f1 ff ff       	call   800c07 <sys_page_alloc>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	0f 88 0d 01 00 00    	js     801b8d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a86:	50                   	push   %eax
  801a87:	e8 e7 f4 ff ff       	call   800f73 <fd_alloc>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	0f 88 e2 00 00 00    	js     801b7b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a99:	83 ec 04             	sub    $0x4,%esp
  801a9c:	68 07 04 00 00       	push   $0x407
  801aa1:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa4:	6a 00                	push   $0x0
  801aa6:	e8 5c f1 ff ff       	call   800c07 <sys_page_alloc>
  801aab:	89 c3                	mov    %eax,%ebx
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	0f 88 c3 00 00 00    	js     801b7b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	ff 75 f4             	pushl  -0xc(%ebp)
  801abe:	e8 99 f4 ff ff       	call   800f5c <fd2data>
  801ac3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac5:	83 c4 0c             	add    $0xc,%esp
  801ac8:	68 07 04 00 00       	push   $0x407
  801acd:	50                   	push   %eax
  801ace:	6a 00                	push   $0x0
  801ad0:	e8 32 f1 ff ff       	call   800c07 <sys_page_alloc>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	0f 88 89 00 00 00    	js     801b6b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae8:	e8 6f f4 ff ff       	call   800f5c <fd2data>
  801aed:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801af4:	50                   	push   %eax
  801af5:	6a 00                	push   $0x0
  801af7:	56                   	push   %esi
  801af8:	6a 00                	push   $0x0
  801afa:	e8 4b f1 ff ff       	call   800c4a <sys_page_map>
  801aff:	89 c3                	mov    %eax,%ebx
  801b01:	83 c4 20             	add    $0x20,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 55                	js     801b5d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b16:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b26:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	ff 75 f4             	pushl  -0xc(%ebp)
  801b38:	e8 0f f4 ff ff       	call   800f4c <fd2num>
  801b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b40:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b42:	83 c4 04             	add    $0x4,%esp
  801b45:	ff 75 f0             	pushl  -0x10(%ebp)
  801b48:	e8 ff f3 ff ff       	call   800f4c <fd2num>
  801b4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b50:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5b:	eb 30                	jmp    801b8d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	56                   	push   %esi
  801b61:	6a 00                	push   $0x0
  801b63:	e8 24 f1 ff ff       	call   800c8c <sys_page_unmap>
  801b68:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b71:	6a 00                	push   $0x0
  801b73:	e8 14 f1 ff ff       	call   800c8c <sys_page_unmap>
  801b78:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b7b:	83 ec 08             	sub    $0x8,%esp
  801b7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b81:	6a 00                	push   $0x0
  801b83:	e8 04 f1 ff ff       	call   800c8c <sys_page_unmap>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b8d:	89 d0                	mov    %edx,%eax
  801b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9f:	50                   	push   %eax
  801ba0:	ff 75 08             	pushl  0x8(%ebp)
  801ba3:	e8 1a f4 ff ff       	call   800fc2 <fd_lookup>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 18                	js     801bc7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb5:	e8 a2 f3 ff ff       	call   800f5c <fd2data>
	return _pipeisclosed(fd, p);
  801bba:	89 c2                	mov    %eax,%edx
  801bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbf:	e8 21 fd ff ff       	call   8018e5 <_pipeisclosed>
  801bc4:	83 c4 10             	add    $0x10,%esp
}
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bd9:	68 ca 25 80 00       	push   $0x8025ca
  801bde:	ff 75 0c             	pushl  0xc(%ebp)
  801be1:	e8 1e ec ff ff       	call   800804 <strcpy>
	return 0;
}
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    

00801bed <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	57                   	push   %edi
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bfe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c04:	eb 2d                	jmp    801c33 <devcons_write+0x46>
		m = n - tot;
  801c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c09:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c0b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c0e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c13:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	53                   	push   %ebx
  801c1a:	03 45 0c             	add    0xc(%ebp),%eax
  801c1d:	50                   	push   %eax
  801c1e:	57                   	push   %edi
  801c1f:	e8 72 ed ff ff       	call   800996 <memmove>
		sys_cputs(buf, m);
  801c24:	83 c4 08             	add    $0x8,%esp
  801c27:	53                   	push   %ebx
  801c28:	57                   	push   %edi
  801c29:	e8 1d ef ff ff       	call   800b4b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2e:	01 de                	add    %ebx,%esi
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c38:	72 cc                	jb     801c06 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c51:	74 2a                	je     801c7d <devcons_read+0x3b>
  801c53:	eb 05                	jmp    801c5a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c55:	e8 8e ef ff ff       	call   800be8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c5a:	e8 0a ef ff ff       	call   800b69 <sys_cgetc>
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	74 f2                	je     801c55 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 16                	js     801c7d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c67:	83 f8 04             	cmp    $0x4,%eax
  801c6a:	74 0c                	je     801c78 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6f:	88 02                	mov    %al,(%edx)
	return 1;
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	eb 05                	jmp    801c7d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c78:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c85:	8b 45 08             	mov    0x8(%ebp),%eax
  801c88:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c8b:	6a 01                	push   $0x1
  801c8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c90:	50                   	push   %eax
  801c91:	e8 b5 ee ff ff       	call   800b4b <sys_cputs>
}
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <getchar>:

int
getchar(void)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ca1:	6a 01                	push   $0x1
  801ca3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 7a f5 ff ff       	call   801228 <read>
	if (r < 0)
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 0f                	js     801cc4 <getchar+0x29>
		return r;
	if (r < 1)
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	7e 06                	jle    801cbf <getchar+0x24>
		return -E_EOF;
	return c;
  801cb9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cbd:	eb 05                	jmp    801cc4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cbf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ccc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	ff 75 08             	pushl  0x8(%ebp)
  801cd3:	e8 ea f2 ff ff       	call   800fc2 <fd_lookup>
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	78 11                	js     801cf0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce8:	39 10                	cmp    %edx,(%eax)
  801cea:	0f 94 c0             	sete   %al
  801ced:	0f b6 c0             	movzbl %al,%eax
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <opencons>:

int
opencons(void)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfb:	50                   	push   %eax
  801cfc:	e8 72 f2 ff ff       	call   800f73 <fd_alloc>
  801d01:	83 c4 10             	add    $0x10,%esp
		return r;
  801d04:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 3e                	js     801d48 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0a:	83 ec 04             	sub    $0x4,%esp
  801d0d:	68 07 04 00 00       	push   $0x407
  801d12:	ff 75 f4             	pushl  -0xc(%ebp)
  801d15:	6a 00                	push   $0x0
  801d17:	e8 eb ee ff ff       	call   800c07 <sys_page_alloc>
  801d1c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d1f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 23                	js     801d48 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	50                   	push   %eax
  801d3e:	e8 09 f2 ff ff       	call   800f4c <fd2num>
  801d43:	89 c2                	mov    %eax,%edx
  801d45:	83 c4 10             	add    $0x10,%esp
}
  801d48:	89 d0                	mov    %edx,%eax
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	56                   	push   %esi
  801d50:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d51:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d54:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d5a:	e8 6a ee ff ff       	call   800bc9 <sys_getenvid>
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 0c             	pushl  0xc(%ebp)
  801d65:	ff 75 08             	pushl  0x8(%ebp)
  801d68:	56                   	push   %esi
  801d69:	50                   	push   %eax
  801d6a:	68 d8 25 80 00       	push   $0x8025d8
  801d6f:	e8 8c e4 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d74:	83 c4 18             	add    $0x18,%esp
  801d77:	53                   	push   %ebx
  801d78:	ff 75 10             	pushl  0x10(%ebp)
  801d7b:	e8 2f e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801d80:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  801d87:	e8 74 e4 ff ff       	call   800200 <cprintf>
  801d8c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d8f:	cc                   	int3   
  801d90:	eb fd                	jmp    801d8f <_panic+0x43>

00801d92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801da4:	85 f6                	test   %esi,%esi
  801da6:	74 06                	je     801dae <ipc_recv+0x1c>
		*from_env_store = 0;
  801da8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801dae:	85 db                	test   %ebx,%ebx
  801db0:	74 06                	je     801db8 <ipc_recv+0x26>
		*perm_store = 0;
  801db2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801db8:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801dba:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801dbf:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	50                   	push   %eax
  801dc6:	e8 ec ef ff ff       	call   800db7 <sys_ipc_recv>
  801dcb:	89 c7                	mov    %eax,%edi
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	79 14                	jns    801de8 <ipc_recv+0x56>
		cprintf("im dead");
  801dd4:	83 ec 0c             	sub    $0xc,%esp
  801dd7:	68 fc 25 80 00       	push   $0x8025fc
  801ddc:	e8 1f e4 ff ff       	call   800200 <cprintf>
		return r;
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	89 f8                	mov    %edi,%eax
  801de6:	eb 24                	jmp    801e0c <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801de8:	85 f6                	test   %esi,%esi
  801dea:	74 0a                	je     801df6 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801dec:	a1 04 40 80 00       	mov    0x804004,%eax
  801df1:	8b 40 74             	mov    0x74(%eax),%eax
  801df4:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801df6:	85 db                	test   %ebx,%ebx
  801df8:	74 0a                	je     801e04 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801dfa:	a1 04 40 80 00       	mov    0x804004,%eax
  801dff:	8b 40 78             	mov    0x78(%eax),%eax
  801e02:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801e04:	a1 04 40 80 00       	mov    0x804004,%eax
  801e09:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e20:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801e26:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e2d:	0f 44 d8             	cmove  %eax,%ebx
  801e30:	eb 1c                	jmp    801e4e <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801e32:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e35:	74 12                	je     801e49 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801e37:	50                   	push   %eax
  801e38:	68 04 26 80 00       	push   $0x802604
  801e3d:	6a 4e                	push   $0x4e
  801e3f:	68 11 26 80 00       	push   $0x802611
  801e44:	e8 03 ff ff ff       	call   801d4c <_panic>
		sys_yield();
  801e49:	e8 9a ed ff ff       	call   800be8 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e4e:	ff 75 14             	pushl  0x14(%ebp)
  801e51:	53                   	push   %ebx
  801e52:	56                   	push   %esi
  801e53:	57                   	push   %edi
  801e54:	e8 3b ef ff ff       	call   800d94 <sys_ipc_try_send>
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 d2                	js     801e32 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e6e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e73:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e76:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e7c:	8b 52 50             	mov    0x50(%edx),%edx
  801e7f:	39 ca                	cmp    %ecx,%edx
  801e81:	75 0d                	jne    801e90 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e83:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e86:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e8b:	8b 40 48             	mov    0x48(%eax),%eax
  801e8e:	eb 0f                	jmp    801e9f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e90:	83 c0 01             	add    $0x1,%eax
  801e93:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e98:	75 d9                	jne    801e73 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ea7:	89 d0                	mov    %edx,%eax
  801ea9:	c1 e8 16             	shr    $0x16,%eax
  801eac:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eb8:	f6 c1 01             	test   $0x1,%cl
  801ebb:	74 1d                	je     801eda <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ebd:	c1 ea 0c             	shr    $0xc,%edx
  801ec0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ec7:	f6 c2 01             	test   $0x1,%dl
  801eca:	74 0e                	je     801eda <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ecc:	c1 ea 0c             	shr    $0xc,%edx
  801ecf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ed6:	ef 
  801ed7:	0f b7 c0             	movzwl %ax,%eax
}
  801eda:	5d                   	pop    %ebp
  801edb:	c3                   	ret    
  801edc:	66 90                	xchg   %ax,%ax
  801ede:	66 90                	xchg   %ax,%ax

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	89 ca                	mov    %ecx,%edx
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	75 3d                	jne    801f40 <__udivdi3+0x60>
  801f03:	39 cf                	cmp    %ecx,%edi
  801f05:	0f 87 c5 00 00 00    	ja     801fd0 <__udivdi3+0xf0>
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	89 fd                	mov    %edi,%ebp
  801f0f:	75 0b                	jne    801f1c <__udivdi3+0x3c>
  801f11:	b8 01 00 00 00       	mov    $0x1,%eax
  801f16:	31 d2                	xor    %edx,%edx
  801f18:	f7 f7                	div    %edi
  801f1a:	89 c5                	mov    %eax,%ebp
  801f1c:	89 c8                	mov    %ecx,%eax
  801f1e:	31 d2                	xor    %edx,%edx
  801f20:	f7 f5                	div    %ebp
  801f22:	89 c1                	mov    %eax,%ecx
  801f24:	89 d8                	mov    %ebx,%eax
  801f26:	89 cf                	mov    %ecx,%edi
  801f28:	f7 f5                	div    %ebp
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	39 ce                	cmp    %ecx,%esi
  801f42:	77 74                	ja     801fb8 <__udivdi3+0xd8>
  801f44:	0f bd fe             	bsr    %esi,%edi
  801f47:	83 f7 1f             	xor    $0x1f,%edi
  801f4a:	0f 84 98 00 00 00    	je     801fe8 <__udivdi3+0x108>
  801f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	89 c5                	mov    %eax,%ebp
  801f59:	29 fb                	sub    %edi,%ebx
  801f5b:	d3 e6                	shl    %cl,%esi
  801f5d:	89 d9                	mov    %ebx,%ecx
  801f5f:	d3 ed                	shr    %cl,%ebp
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e0                	shl    %cl,%eax
  801f65:	09 ee                	or     %ebp,%esi
  801f67:	89 d9                	mov    %ebx,%ecx
  801f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6d:	89 d5                	mov    %edx,%ebp
  801f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f73:	d3 ed                	shr    %cl,%ebp
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	d3 e2                	shl    %cl,%edx
  801f79:	89 d9                	mov    %ebx,%ecx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	09 c2                	or     %eax,%edx
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	89 ea                	mov    %ebp,%edx
  801f83:	f7 f6                	div    %esi
  801f85:	89 d5                	mov    %edx,%ebp
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	72 10                	jb     801fa1 <__udivdi3+0xc1>
  801f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e6                	shl    %cl,%esi
  801f99:	39 c6                	cmp    %eax,%esi
  801f9b:	73 07                	jae    801fa4 <__udivdi3+0xc4>
  801f9d:	39 d5                	cmp    %edx,%ebp
  801f9f:	75 03                	jne    801fa4 <__udivdi3+0xc4>
  801fa1:	83 eb 01             	sub    $0x1,%ebx
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	89 fa                	mov    %edi,%edx
  801faa:	83 c4 1c             	add    $0x1c,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	31 db                	xor    %ebx,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	f7 f7                	div    %edi
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	89 fa                	mov    %edi,%edx
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	39 ce                	cmp    %ecx,%esi
  801fea:	72 0c                	jb     801ff8 <__udivdi3+0x118>
  801fec:	31 db                	xor    %ebx,%ebx
  801fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ff2:	0f 87 34 ff ff ff    	ja     801f2c <__udivdi3+0x4c>
  801ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ffd:	e9 2a ff ff ff       	jmp    801f2c <__udivdi3+0x4c>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80201b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80201f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 d2                	test   %edx,%edx
  802029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f3                	mov    %esi,%ebx
  802033:	89 3c 24             	mov    %edi,(%esp)
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	75 1c                	jne    802058 <__umoddi3+0x48>
  80203c:	39 f7                	cmp    %esi,%edi
  80203e:	76 50                	jbe    802090 <__umoddi3+0x80>
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	f7 f7                	div    %edi
  802046:	89 d0                	mov    %edx,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	77 52                	ja     8020b0 <__umoddi3+0xa0>
  80205e:	0f bd ea             	bsr    %edx,%ebp
  802061:	83 f5 1f             	xor    $0x1f,%ebp
  802064:	75 5a                	jne    8020c0 <__umoddi3+0xb0>
  802066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80206a:	0f 82 e0 00 00 00    	jb     802150 <__umoddi3+0x140>
  802070:	39 0c 24             	cmp    %ecx,(%esp)
  802073:	0f 86 d7 00 00 00    	jbe    802150 <__umoddi3+0x140>
  802079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80207d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	85 ff                	test   %edi,%edi
  802092:	89 fd                	mov    %edi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f7                	div    %edi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	89 f0                	mov    %esi,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f5                	div    %ebp
  8020a7:	89 c8                	mov    %ecx,%eax
  8020a9:	f7 f5                	div    %ebp
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	eb 99                	jmp    802048 <__umoddi3+0x38>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 34 24             	mov    (%esp),%esi
  8020c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ef                	sub    %ebp,%edi
  8020cc:	d3 e0                	shl    %cl,%eax
  8020ce:	89 f9                	mov    %edi,%ecx
  8020d0:	89 f2                	mov    %esi,%edx
  8020d2:	d3 ea                	shr    %cl,%edx
  8020d4:	89 e9                	mov    %ebp,%ecx
  8020d6:	09 c2                	or     %eax,%edx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 14 24             	mov    %edx,(%esp)
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	d3 e2                	shl    %cl,%edx
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	89 e9                	mov    %ebp,%ecx
  8020ef:	89 c6                	mov    %eax,%esi
  8020f1:	d3 e3                	shl    %cl,%ebx
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	09 d8                	or     %ebx,%eax
  8020fd:	89 d3                	mov    %edx,%ebx
  8020ff:	89 f2                	mov    %esi,%edx
  802101:	f7 34 24             	divl   (%esp)
  802104:	89 d6                	mov    %edx,%esi
  802106:	d3 e3                	shl    %cl,%ebx
  802108:	f7 64 24 04          	mull   0x4(%esp)
  80210c:	39 d6                	cmp    %edx,%esi
  80210e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802112:	89 d1                	mov    %edx,%ecx
  802114:	89 c3                	mov    %eax,%ebx
  802116:	72 08                	jb     802120 <__umoddi3+0x110>
  802118:	75 11                	jne    80212b <__umoddi3+0x11b>
  80211a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80211e:	73 0b                	jae    80212b <__umoddi3+0x11b>
  802120:	2b 44 24 04          	sub    0x4(%esp),%eax
  802124:	1b 14 24             	sbb    (%esp),%edx
  802127:	89 d1                	mov    %edx,%ecx
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80212f:	29 da                	sub    %ebx,%edx
  802131:	19 ce                	sbb    %ecx,%esi
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 f0                	mov    %esi,%eax
  802137:	d3 e0                	shl    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	d3 ea                	shr    %cl,%edx
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	09 d0                	or     %edx,%eax
  802143:	89 f2                	mov    %esi,%edx
  802145:	83 c4 1c             	add    $0x1c,%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	29 f9                	sub    %edi,%ecx
  802152:	19 d6                	sbb    %edx,%esi
  802154:	89 74 24 04          	mov    %esi,0x4(%esp)
  802158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80215c:	e9 18 ff ff ff       	jmp    802079 <__umoddi3+0x69>
