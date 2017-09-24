
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 40 0f 00 00       	call   800f7e <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 20 11 00 00       	call   80117c <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 40 23 80 00       	push   $0x802340
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 d8 07 00 00       	call   800857 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 cd 08 00 00       	call   800960 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 54 23 80 00       	push   $0x802354
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 9f 07 00 00       	call   800857 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 bb 09 00 00       	call   800a8a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 1e 11 00 00       	call   8011fe <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 93 0b 00 00       	call   800c93 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 49 07 00 00       	call   800857 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 65 09 00 00       	call   800a8a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 c8 10 00 00       	call   8011fe <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 33 10 00 00       	call   80117c <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 40 23 80 00       	push   $0x802340
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 eb 06 00 00       	call   800857 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 e0 07 00 00       	call   800960 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 74 23 80 00       	push   $0x802374
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 ac 0a 00 00       	call   800c55 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 6c 12 00 00       	call   801456 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 20 0a 00 00       	call   800c14 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 ae 09 00 00       	call   800bd7 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 1a 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 53 09 00 00       	call   800bd7 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 ac 1d 00 00       	call   8020a0 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 99 1e 00 00       	call   8021d0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ec 23 80 00 	movsbl 0x8023ec(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
	va_end(ap);
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039b:	eb 12                	jmp    8003af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039d:	85 c0                	test   %eax,%eax
  80039f:	0f 84 42 04 00 00    	je     8007e7 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	50                   	push   %eax
  8003aa:	ff d6                	call   *%esi
  8003ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003af:	83 c7 01             	add    $0x1,%edi
  8003b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b6:	83 f8 25             	cmp    $0x25,%eax
  8003b9:	75 e2                	jne    80039d <vprintfmt+0x14>
  8003bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	eb 07                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8d 47 01             	lea    0x1(%edi),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	0f b6 07             	movzbl (%edi),%eax
  8003eb:	0f b6 d0             	movzbl %al,%edx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 d3 03 00 00    	ja     8007cc <vprintfmt+0x443>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800406:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040a:	eb d6                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800417:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800424:	83 f9 09             	cmp    $0x9,%ecx
  800427:	77 3f                	ja     800468 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042c:	eb e9                	jmp    800417 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 40 04             	lea    0x4(%eax),%eax
  80043c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 2a                	jmp    80046e <vprintfmt+0xe5>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	eb 89                	jmp    8003e2 <vprintfmt+0x59>
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800463:	e9 7a ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
  800468:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	0f 89 6a ff ff ff    	jns    8003e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800478:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800485:	e9 58 ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800490:	e9 4d ff ff ff       	jmp    8003e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff d6                	call   *%esi
			break;
  8004a3:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ac:	e9 fe fe ff ff       	jmp    8003af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 78 04             	lea    0x4(%eax),%edi
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	99                   	cltd   
  8004ba:	31 d0                	xor    %edx,%eax
  8004bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 0f             	cmp    $0xf,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x145>
  8004c3:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 1b                	jne    8004e9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 04 24 80 00       	push   $0x802404
  8004d4:	53                   	push   %ebx
  8004d5:	56                   	push   %esi
  8004d6:	e8 91 fe ff ff       	call   80036c <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e4:	e9 c6 fe ff ff       	jmp    8003af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e9:	52                   	push   %edx
  8004ea:	68 a1 28 80 00       	push   $0x8028a1
  8004ef:	53                   	push   %ebx
  8004f0:	56                   	push   %esi
  8004f1:	e8 76 fe ff ff       	call   80036c <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	e9 ab fe ff ff       	jmp    8003af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800512:	85 ff                	test   %edi,%edi
  800514:	b8 fd 23 80 00       	mov    $0x8023fd,%eax
  800519:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 8e 94 00 00 00    	jle    8005ba <vprintfmt+0x231>
  800526:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052a:	0f 84 98 00 00 00    	je     8005c8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 d0             	pushl  -0x30(%ebp)
  800536:	57                   	push   %edi
  800537:	e8 33 03 00 00       	call   80086f <strnlen>
  80053c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053f:	29 c1                	sub    %eax,%ecx
  800541:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800547:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800551:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0f                	jmp    800564 <vprintfmt+0x1db>
					putch(padc, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 75 e0             	pushl  -0x20(%ebp)
  80055c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ef 01             	sub    $0x1,%edi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 ff                	test   %edi,%edi
  800566:	7f ed                	jg     800555 <vprintfmt+0x1cc>
  800568:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80056e:	85 c9                	test   %ecx,%ecx
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	0f 49 c1             	cmovns %ecx,%eax
  800578:	29 c1                	sub    %eax,%ecx
  80057a:	89 75 08             	mov    %esi,0x8(%ebp)
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800580:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800583:	89 cb                	mov    %ecx,%ebx
  800585:	eb 4d                	jmp    8005d4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058b:	74 1b                	je     8005a8 <vprintfmt+0x21f>
  80058d:	0f be c0             	movsbl %al,%eax
  800590:	83 e8 20             	sub    $0x20,%eax
  800593:	83 f8 5e             	cmp    $0x5e,%eax
  800596:	76 10                	jbe    8005a8 <vprintfmt+0x21f>
					putch('?', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	6a 3f                	push   $0x3f
  8005a0:	ff 55 08             	call   *0x8(%ebp)
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	eb 0d                	jmp    8005b5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	52                   	push   %edx
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 eb 01             	sub    $0x1,%ebx
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x24b>
  8005ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c6:	eb 0c                	jmp    8005d4 <vprintfmt+0x24b>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	83 c7 01             	add    $0x1,%edi
  8005d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005db:	0f be d0             	movsbl %al,%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 23                	je     800605 <vprintfmt+0x27c>
  8005e2:	85 f6                	test   %esi,%esi
  8005e4:	78 a1                	js     800587 <vprintfmt+0x1fe>
  8005e6:	83 ee 01             	sub    $0x1,%esi
  8005e9:	79 9c                	jns    800587 <vprintfmt+0x1fe>
  8005eb:	89 df                	mov    %ebx,%edi
  8005ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f3:	eb 18                	jmp    80060d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 20                	push   $0x20
  8005fb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fd:	83 ef 01             	sub    $0x1,%edi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb 08                	jmp    80060d <vprintfmt+0x284>
  800605:	89 df                	mov    %ebx,%edi
  800607:	8b 75 08             	mov    0x8(%ebp),%esi
  80060a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060d:	85 ff                	test   %edi,%edi
  80060f:	7f e4                	jg     8005f5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800611:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061a:	e9 90 fd ff ff       	jmp    8003af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 19                	jle    80063d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 50 04             	mov    0x4(%eax),%edx
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 08             	lea    0x8(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	eb 38                	jmp    800675 <vprintfmt+0x2ec>
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 1b                	je     80065c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 c1                	mov    %eax,%ecx
  80064b:	c1 f9 1f             	sar    $0x1f,%ecx
  80064e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	eb 19                	jmp    800675 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 c1                	mov    %eax,%ecx
  800666:	c1 f9 1f             	sar    $0x1f,%ecx
  800669:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800678:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	0f 89 0e 01 00 00    	jns    800798 <vprintfmt+0x40f>
				putch('-', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 2d                	push   $0x2d
  800690:	ff d6                	call   *%esi
				num = -(long long) num;
  800692:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800695:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800698:	f7 da                	neg    %edx
  80069a:	83 d1 00             	adc    $0x0,%ecx
  80069d:	f7 d9                	neg    %ecx
  80069f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 ec 00 00 00       	jmp    800798 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 f9 01             	cmp    $0x1,%ecx
  8006af:	7e 18                	jle    8006c9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 cf 00 00 00       	jmp    800798 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 1a                	je     8006e7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	e9 b1 00 00 00       	jmp    800798 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	e9 97 00 00 00       	jmp    800798 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	6a 58                	push   $0x58
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	83 c4 08             	add    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 58                	push   $0x58
  80070f:	ff d6                	call   *%esi
			putch('X', putdat);
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 58                	push   $0x58
  800717:	ff d6                	call   *%esi
			break;
  800719:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80071f:	e9 8b fc ff ff       	jmp    8003af <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d6                	call   *%esi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d6                	call   *%esi
			num = (unsigned long long)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80074c:	eb 4a                	jmp    800798 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074e:	83 f9 01             	cmp    $0x1,%ecx
  800751:	7e 15                	jle    800768 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	8b 48 04             	mov    0x4(%eax),%ecx
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
  800766:	eb 30                	jmp    800798 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 17                	je     800783 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	8d 40 04             	lea    0x4(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80077c:	b8 10 00 00 00       	mov    $0x10,%eax
  800781:	eb 15                	jmp    800798 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800793:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079f:	57                   	push   %edi
  8007a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a3:	50                   	push   %eax
  8007a4:	51                   	push   %ecx
  8007a5:	52                   	push   %edx
  8007a6:	89 da                	mov    %ebx,%edx
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	e8 f1 fa ff ff       	call   8002a0 <printnum>
			break;
  8007af:	83 c4 20             	add    $0x20,%esp
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 f5 fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	53                   	push   %ebx
  8007be:	52                   	push   %edx
  8007bf:	ff d6                	call   *%esi
			break;
  8007c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c7:	e9 e3 fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 03                	jmp    8007dc <vprintfmt+0x453>
  8007d9:	83 ef 01             	sub    $0x1,%edi
  8007dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e0:	75 f7                	jne    8007d9 <vprintfmt+0x450>
  8007e2:	e9 c8 fb ff ff       	jmp    8003af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 18             	sub    $0x18,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 26                	je     800836 <vsnprintf+0x47>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 22                	jle    800836 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	pushl  0x14(%ebp)
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	68 4f 03 80 00       	push   $0x80034f
  800823:	e8 61 fb ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	eb 05                	jmp    80083b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	50                   	push   %eax
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 9a ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 03                	jmp    800867 <strlen+0x10>
		n++;
  800864:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	75 f7                	jne    800864 <strlen+0xd>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
  80087d:	eb 03                	jmp    800882 <strnlen+0x13>
		n++;
  80087f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	39 c2                	cmp    %eax,%edx
  800884:	74 08                	je     80088e <strnlen+0x1f>
  800886:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088a:	75 f3                	jne    80087f <strnlen+0x10>
  80088c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a9:	84 db                	test   %bl,%bl
  8008ab:	75 ef                	jne    80089c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b7:	53                   	push   %ebx
  8008b8:	e8 9a ff ff ff       	call   800857 <strlen>
  8008bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	01 d8                	add    %ebx,%eax
  8008c5:	50                   	push   %eax
  8008c6:	e8 c5 ff ff ff       	call   800890 <strcpy>
	return dst;
}
  8008cb:	89 d8                	mov    %ebx,%eax
  8008cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	8b 55 10             	mov    0x10(%ebp),%edx
  80090d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 21                	je     800934 <strlcpy+0x35>
  800913:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800917:	89 f2                	mov    %esi,%edx
  800919:	eb 09                	jmp    800924 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	83 c1 01             	add    $0x1,%ecx
  800921:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800924:	39 c2                	cmp    %eax,%edx
  800926:	74 09                	je     800931 <strlcpy+0x32>
  800928:	0f b6 19             	movzbl (%ecx),%ebx
  80092b:	84 db                	test   %bl,%bl
  80092d:	75 ec                	jne    80091b <strlcpy+0x1c>
  80092f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 06                	jmp    80094b <strcmp+0x11>
		p++, q++;
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	84 c0                	test   %al,%al
  800950:	74 04                	je     800956 <strcmp+0x1c>
  800952:	3a 02                	cmp    (%edx),%al
  800954:	74 ef                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	89 c3                	mov    %eax,%ebx
  80096c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096f:	eb 06                	jmp    800977 <strncmp+0x17>
		n--, p++, q++;
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800977:	39 d8                	cmp    %ebx,%eax
  800979:	74 15                	je     800990 <strncmp+0x30>
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	74 04                	je     800986 <strncmp+0x26>
  800982:	3a 0a                	cmp    (%edx),%cl
  800984:	74 eb                	je     800971 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 00             	movzbl (%eax),%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
  80098e:	eb 05                	jmp    800995 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a2:	eb 07                	jmp    8009ab <strchr+0x13>
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 0f                	je     8009b7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	0f b6 10             	movzbl (%eax),%edx
  8009ae:	84 d2                	test   %dl,%dl
  8009b0:	75 f2                	jne    8009a4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c3:	eb 03                	jmp    8009c8 <strfind+0xf>
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 04                	je     8009d3 <strfind+0x1a>
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	75 f2                	jne    8009c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e1:	85 c9                	test   %ecx,%ecx
  8009e3:	74 36                	je     800a1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009eb:	75 28                	jne    800a15 <memset+0x40>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 23                	jne    800a15 <memset+0x40>
		c &= 0xFF;
  8009f2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f6:	89 d3                	mov    %edx,%ebx
  8009f8:	c1 e3 08             	shl    $0x8,%ebx
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	c1 e6 18             	shl    $0x18,%esi
  800a00:	89 d0                	mov    %edx,%eax
  800a02:	c1 e0 10             	shl    $0x10,%eax
  800a05:	09 f0                	or     %esi,%eax
  800a07:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a09:	89 d8                	mov    %ebx,%eax
  800a0b:	09 d0                	or     %edx,%eax
  800a0d:	c1 e9 02             	shr    $0x2,%ecx
  800a10:	fc                   	cld    
  800a11:	f3 ab                	rep stos %eax,%es:(%edi)
  800a13:	eb 06                	jmp    800a1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	fc                   	cld    
  800a19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1b:	89 f8                	mov    %edi,%eax
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a30:	39 c6                	cmp    %eax,%esi
  800a32:	73 35                	jae    800a69 <memmove+0x47>
  800a34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	73 2e                	jae    800a69 <memmove+0x47>
		s += n;
		d += n;
  800a3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	09 fe                	or     %edi,%esi
  800a42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a48:	75 13                	jne    800a5d <memmove+0x3b>
  800a4a:	f6 c1 03             	test   $0x3,%cl
  800a4d:	75 0e                	jne    800a5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a4f:	83 ef 04             	sub    $0x4,%edi
  800a52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a55:	c1 e9 02             	shr    $0x2,%ecx
  800a58:	fd                   	std    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb 09                	jmp    800a66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a63:	fd                   	std    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a66:	fc                   	cld    
  800a67:	eb 1d                	jmp    800a86 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	09 c2                	or     %eax,%edx
  800a6d:	f6 c2 03             	test   $0x3,%dl
  800a70:	75 0f                	jne    800a81 <memmove+0x5f>
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 0a                	jne    800a81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a77:	c1 e9 02             	shr    $0x2,%ecx
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	fc                   	cld    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 05                	jmp    800a86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a8d:	ff 75 10             	pushl  0x10(%ebp)
  800a90:	ff 75 0c             	pushl  0xc(%ebp)
  800a93:	ff 75 08             	pushl  0x8(%ebp)
  800a96:	e8 87 ff ff ff       	call   800a22 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 c6                	mov    %eax,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	0f b6 1a             	movzbl (%edx),%ebx
  800ab5:	38 d9                	cmp    %bl,%cl
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c1             	movzbl %cl,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f0                	cmp    %esi,%eax
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	53                   	push   %ebx
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800add:	89 c1                	mov    %eax,%ecx
  800adf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae6:	eb 0a                	jmp    800af2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae8:	0f b6 10             	movzbl (%eax),%edx
  800aeb:	39 da                	cmp    %ebx,%edx
  800aed:	74 07                	je     800af6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	39 c8                	cmp    %ecx,%eax
  800af4:	72 f2                	jb     800ae8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af6:	5b                   	pop    %ebx
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x11>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f6                	je     800b07 <strtol+0xe>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f2                	je     800b07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	75 0a                	jne    800b23 <strtol+0x2a>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	eb 11                	jmp    800b34 <strtol+0x3b>
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b28:	3c 2d                	cmp    $0x2d,%al
  800b2a:	75 08                	jne    800b34 <strtol+0x3b>
		s++, neg = 1;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3a:	75 15                	jne    800b51 <strtol+0x58>
  800b3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3f:	75 10                	jne    800b51 <strtol+0x58>
  800b41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b45:	75 7c                	jne    800bc3 <strtol+0xca>
		s += 2, base = 16;
  800b47:	83 c1 02             	add    $0x2,%ecx
  800b4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4f:	eb 16                	jmp    800b67 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b51:	85 db                	test   %ebx,%ebx
  800b53:	75 12                	jne    800b67 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5d:	75 08                	jne    800b67 <strtol+0x6e>
		s++, base = 8;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6f:	0f b6 11             	movzbl (%ecx),%edx
  800b72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b75:	89 f3                	mov    %esi,%ebx
  800b77:	80 fb 09             	cmp    $0x9,%bl
  800b7a:	77 08                	ja     800b84 <strtol+0x8b>
			dig = *s - '0';
  800b7c:	0f be d2             	movsbl %dl,%edx
  800b7f:	83 ea 30             	sub    $0x30,%edx
  800b82:	eb 22                	jmp    800ba6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b84:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 19             	cmp    $0x19,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 57             	sub    $0x57,%edx
  800b94:	eb 10                	jmp    800ba6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b96:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 16                	ja     800bb6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba9:	7d 0b                	jge    800bb6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bab:	83 c1 01             	add    $0x1,%ecx
  800bae:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb4:	eb b9                	jmp    800b6f <strtol+0x76>

	if (endptr)
  800bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bba:	74 0d                	je     800bc9 <strtol+0xd0>
		*endptr = (char *) s;
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	89 0e                	mov    %ecx,(%esi)
  800bc1:	eb 06                	jmp    800bc9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	74 98                	je     800b5f <strtol+0x66>
  800bc7:	eb 9e                	jmp    800b67 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	f7 da                	neg    %edx
  800bcd:	85 ff                	test   %edi,%edi
  800bcf:	0f 45 c2             	cmovne %edx,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	89 c3                	mov    %eax,%ebx
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	89 c6                	mov    %eax,%esi
  800bee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 01 00 00 00       	mov    $0x1,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c22:	b8 03 00 00 00       	mov    $0x3,%eax
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	89 cb                	mov    %ecx,%ebx
  800c2c:	89 cf                	mov    %ecx,%edi
  800c2e:	89 ce                	mov    %ecx,%esi
  800c30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 03                	push   $0x3
  800c3c:	68 df 26 80 00       	push   $0x8026df
  800c41:	6a 23                	push   $0x23
  800c43:	68 fc 26 80 00       	push   $0x8026fc
  800c48:	e8 2e 13 00 00       	call   801f7b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 04                	push   $0x4
  800cbd:	68 df 26 80 00       	push   $0x8026df
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 fc 26 80 00       	push   $0x8026fc
  800cc9:	e8 ad 12 00 00       	call   801f7b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ced:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 05                	push   $0x5
  800cff:	68 df 26 80 00       	push   $0x8026df
  800d04:	6a 23                	push   $0x23
  800d06:	68 fc 26 80 00       	push   $0x8026fc
  800d0b:	e8 6b 12 00 00       	call   801f7b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7e 17                	jle    800d52 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	50                   	push   %eax
  800d3f:	6a 06                	push   $0x6
  800d41:	68 df 26 80 00       	push   $0x8026df
  800d46:	6a 23                	push   $0x23
  800d48:	68 fc 26 80 00       	push   $0x8026fc
  800d4d:	e8 29 12 00 00       	call   801f7b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 08                	push   $0x8
  800d83:	68 df 26 80 00       	push   $0x8026df
  800d88:	6a 23                	push   $0x23
  800d8a:	68 fc 26 80 00       	push   $0x8026fc
  800d8f:	e8 e7 11 00 00       	call   801f7b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	b8 09 00 00 00       	mov    $0x9,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 17                	jle    800dd6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 09                	push   $0x9
  800dc5:	68 df 26 80 00       	push   $0x8026df
  800dca:	6a 23                	push   $0x23
  800dcc:	68 fc 26 80 00       	push   $0x8026fc
  800dd1:	e8 a5 11 00 00       	call   801f7b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 17                	jle    800e18 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 0a                	push   $0xa
  800e07:	68 df 26 80 00       	push   $0x8026df
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 fc 26 80 00       	push   $0x8026fc
  800e13:	e8 63 11 00 00       	call   801f7b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 17                	jle    800e7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 0d                	push   $0xd
  800e6b:	68 df 26 80 00       	push   $0x8026df
  800e70:	6a 23                	push   $0x23
  800e72:	68 fc 26 80 00       	push   $0x8026fc
  800e77:	e8 ff 10 00 00       	call   801f7b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800e8c:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e8e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e92:	74 11                	je     800ea5 <pgfault+0x21>
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	c1 e8 0c             	shr    $0xc,%eax
  800e99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea0:	f6 c4 08             	test   $0x8,%ah
  800ea3:	75 14                	jne    800eb9 <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 0c 27 80 00       	push   $0x80270c
  800ead:	6a 1f                	push   $0x1f
  800eaf:	68 6f 27 80 00       	push   $0x80276f
  800eb4:	e8 c2 10 00 00       	call   801f7b <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800eb9:	e8 97 fd ff ff       	call   800c55 <sys_getenvid>
  800ebe:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	6a 07                	push   $0x7
  800ec5:	68 00 f0 7f 00       	push   $0x7ff000
  800eca:	50                   	push   %eax
  800ecb:	e8 c3 fd ff ff       	call   800c93 <sys_page_alloc>
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 12                	jns    800ee9 <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800ed7:	50                   	push   %eax
  800ed8:	68 4c 27 80 00       	push   $0x80274c
  800edd:	6a 2c                	push   $0x2c
  800edf:	68 6f 27 80 00       	push   $0x80276f
  800ee4:	e8 92 10 00 00       	call   801f7b <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800ee9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	68 00 10 00 00       	push   $0x1000
  800ef7:	53                   	push   %ebx
  800ef8:	68 00 f0 7f 00       	push   $0x7ff000
  800efd:	e8 20 fb ff ff       	call   800a22 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800f02:	83 c4 08             	add    $0x8,%esp
  800f05:	53                   	push   %ebx
  800f06:	56                   	push   %esi
  800f07:	e8 0c fe ff ff       	call   800d18 <sys_page_unmap>
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	79 12                	jns    800f25 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800f13:	50                   	push   %eax
  800f14:	68 7a 27 80 00       	push   $0x80277a
  800f19:	6a 32                	push   $0x32
  800f1b:	68 6f 27 80 00       	push   $0x80276f
  800f20:	e8 56 10 00 00       	call   801f7b <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	6a 07                	push   $0x7
  800f2a:	53                   	push   %ebx
  800f2b:	56                   	push   %esi
  800f2c:	68 00 f0 7f 00       	push   $0x7ff000
  800f31:	56                   	push   %esi
  800f32:	e8 9f fd ff ff       	call   800cd6 <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 12                	jns    800f50 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800f3e:	50                   	push   %eax
  800f3f:	68 98 27 80 00       	push   $0x802798
  800f44:	6a 35                	push   $0x35
  800f46:	68 6f 27 80 00       	push   $0x80276f
  800f4b:	e8 2b 10 00 00       	call   801f7b <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	68 00 f0 7f 00       	push   $0x7ff000
  800f58:	56                   	push   %esi
  800f59:	e8 ba fd ff ff       	call   800d18 <sys_page_unmap>
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 12                	jns    800f77 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800f65:	50                   	push   %eax
  800f66:	68 7a 27 80 00       	push   $0x80277a
  800f6b:	6a 38                	push   $0x38
  800f6d:	68 6f 27 80 00       	push   $0x80276f
  800f72:	e8 04 10 00 00       	call   801f7b <_panic>
	//panic("pgfault not implemented");
}
  800f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800f87:	68 84 0e 80 00       	push   $0x800e84
  800f8c:	e8 30 10 00 00       	call   801fc1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f91:	b8 07 00 00 00       	mov    $0x7,%eax
  800f96:	cd 30                	int    $0x30
  800f98:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	0f 88 38 01 00 00    	js     8010de <fork+0x160>
  800fa6:	89 c7                	mov    %eax,%edi
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800fad:	85 c0                	test   %eax,%eax
  800faf:	75 21                	jne    800fd2 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb1:	e8 9f fc ff ff       	call   800c55 <sys_getenvid>
  800fb6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fbe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc3:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcd:	e9 86 01 00 00       	jmp    801158 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800fd2:	89 d8                	mov    %ebx,%eax
  800fd4:	c1 e8 16             	shr    $0x16,%eax
  800fd7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fde:	a8 01                	test   $0x1,%al
  800fe0:	0f 84 90 00 00 00    	je     801076 <fork+0xf8>
  800fe6:	89 d8                	mov    %ebx,%eax
  800fe8:	c1 e8 0c             	shr    $0xc,%eax
  800feb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff2:	f6 c2 01             	test   $0x1,%dl
  800ff5:	74 7f                	je     801076 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800ff7:	89 c6                	mov    %eax,%esi
  800ff9:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800ffc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801003:	f6 c6 04             	test   $0x4,%dh
  801006:	74 33                	je     80103b <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  801008:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	25 07 0e 00 00       	and    $0xe07,%eax
  801017:	50                   	push   %eax
  801018:	56                   	push   %esi
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	6a 00                	push   $0x0
  80101d:	e8 b4 fc ff ff       	call   800cd6 <sys_page_map>
  801022:	83 c4 20             	add    $0x20,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 4d                	jns    801076 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  801029:	50                   	push   %eax
  80102a:	68 b4 27 80 00       	push   $0x8027b4
  80102f:	6a 54                	push   $0x54
  801031:	68 6f 27 80 00       	push   $0x80276f
  801036:	e8 40 0f 00 00       	call   801f7b <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  80103b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801042:	a9 02 08 00 00       	test   $0x802,%eax
  801047:	0f 85 c6 00 00 00    	jne    801113 <fork+0x195>
  80104d:	e9 e3 00 00 00       	jmp    801135 <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801052:	50                   	push   %eax
  801053:	68 b4 27 80 00       	push   $0x8027b4
  801058:	6a 5d                	push   $0x5d
  80105a:	68 6f 27 80 00       	push   $0x80276f
  80105f:	e8 17 0f 00 00       	call   801f7b <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801064:	50                   	push   %eax
  801065:	68 b4 27 80 00       	push   $0x8027b4
  80106a:	6a 64                	push   $0x64
  80106c:	68 6f 27 80 00       	push   $0x80276f
  801071:	e8 05 0f 00 00       	call   801f7b <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  801076:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801082:	0f 85 4a ff ff ff    	jne    800fd2 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	6a 07                	push   $0x7
  80108d:	68 00 f0 bf ee       	push   $0xeebff000
  801092:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801095:	57                   	push   %edi
  801096:	e8 f8 fb ff ff       	call   800c93 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  80109b:	83 c4 10             	add    $0x10,%esp
		return ret;
  80109e:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	0f 88 b0 00 00 00    	js     801158 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ad:	8b 40 64             	mov    0x64(%eax),%eax
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	50                   	push   %eax
  8010b4:	57                   	push   %edi
  8010b5:	e8 24 fd ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  8010ba:	83 c4 10             	add    $0x10,%esp
		return ret;
  8010bd:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	0f 88 91 00 00 00    	js     801158 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	6a 02                	push   $0x2
  8010cc:	57                   	push   %edi
  8010cd:	e8 88 fc ff ff       	call   800d5a <sys_env_set_status>
  8010d2:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	89 fa                	mov    %edi,%edx
  8010d9:	0f 48 d0             	cmovs  %eax,%edx
  8010dc:	eb 7a                	jmp    801158 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  8010de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010e1:	eb 75                	jmp    801158 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  8010e3:	e8 6d fb ff ff       	call   800c55 <sys_getenvid>
  8010e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010eb:	e8 65 fb ff ff       	call   800c55 <sys_getenvid>
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	68 05 08 00 00       	push   $0x805
  8010f8:	56                   	push   %esi
  8010f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fc:	56                   	push   %esi
  8010fd:	50                   	push   %eax
  8010fe:	e8 d3 fb ff ff       	call   800cd6 <sys_page_map>
  801103:	83 c4 20             	add    $0x20,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	0f 89 68 ff ff ff    	jns    801076 <fork+0xf8>
  80110e:	e9 51 ff ff ff       	jmp    801064 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801113:	e8 3d fb ff ff       	call   800c55 <sys_getenvid>
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	68 05 08 00 00       	push   $0x805
  801120:	56                   	push   %esi
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	50                   	push   %eax
  801124:	e8 ad fb ff ff       	call   800cd6 <sys_page_map>
  801129:	83 c4 20             	add    $0x20,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 b3                	jns    8010e3 <fork+0x165>
  801130:	e9 1d ff ff ff       	jmp    801052 <fork+0xd4>
  801135:	e8 1b fb ff ff       	call   800c55 <sys_getenvid>
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	6a 05                	push   $0x5
  80113f:	56                   	push   %esi
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	50                   	push   %eax
  801143:	e8 8e fb ff ff       	call   800cd6 <sys_page_map>
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	0f 89 23 ff ff ff    	jns    801076 <fork+0xf8>
  801153:	e9 fa fe ff ff       	jmp    801052 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  801158:	89 d0                	mov    %edx,%eax
  80115a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <sfork>:

// Challenge!
int
sfork(void)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801168:	68 c5 27 80 00       	push   $0x8027c5
  80116d:	68 ac 00 00 00       	push   $0xac
  801172:	68 6f 27 80 00       	push   $0x80276f
  801177:	e8 ff 0d 00 00       	call   801f7b <_panic>

0080117c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	83 ec 0c             	sub    $0xc,%esp
  801185:	8b 75 08             	mov    0x8(%ebp),%esi
  801188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  80118e:	85 f6                	test   %esi,%esi
  801190:	74 06                	je     801198 <ipc_recv+0x1c>
		*from_env_store = 0;
  801192:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801198:	85 db                	test   %ebx,%ebx
  80119a:	74 06                	je     8011a2 <ipc_recv+0x26>
		*perm_store = 0;
  80119c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  8011a2:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  8011a4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011a9:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	50                   	push   %eax
  8011b0:	e8 8e fc ff ff       	call   800e43 <sys_ipc_recv>
  8011b5:	89 c7                	mov    %eax,%edi
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	79 14                	jns    8011d2 <ipc_recv+0x56>
		cprintf("im dead");
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	68 db 27 80 00       	push   $0x8027db
  8011c6:	e8 c1 f0 ff ff       	call   80028c <cprintf>
		return r;
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	89 f8                	mov    %edi,%eax
  8011d0:	eb 24                	jmp    8011f6 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  8011d2:	85 f6                	test   %esi,%esi
  8011d4:	74 0a                	je     8011e0 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  8011d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011db:	8b 40 74             	mov    0x74(%eax),%eax
  8011de:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  8011e0:	85 db                	test   %ebx,%ebx
  8011e2:	74 0a                	je     8011ee <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  8011e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e9:	8b 40 78             	mov    0x78(%eax),%eax
  8011ec:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  8011ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80120d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801210:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801212:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801217:	0f 44 d8             	cmove  %eax,%ebx
  80121a:	eb 1c                	jmp    801238 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  80121c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80121f:	74 12                	je     801233 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801221:	50                   	push   %eax
  801222:	68 e3 27 80 00       	push   $0x8027e3
  801227:	6a 4e                	push   $0x4e
  801229:	68 f0 27 80 00       	push   $0x8027f0
  80122e:	e8 48 0d 00 00       	call   801f7b <_panic>
		sys_yield();
  801233:	e8 3c fa ff ff       	call   800c74 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801238:	ff 75 14             	pushl  0x14(%ebp)
  80123b:	53                   	push   %ebx
  80123c:	56                   	push   %esi
  80123d:	57                   	push   %edi
  80123e:	e8 dd fb ff ff       	call   800e20 <sys_ipc_try_send>
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 d2                	js     80121c <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801258:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80125d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801260:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801266:	8b 52 50             	mov    0x50(%edx),%edx
  801269:	39 ca                	cmp    %ecx,%edx
  80126b:	75 0d                	jne    80127a <ipc_find_env+0x28>
			return envs[i].env_id;
  80126d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801270:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801275:	8b 40 48             	mov    0x48(%eax),%eax
  801278:	eb 0f                	jmp    801289 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80127a:	83 c0 01             	add    $0x1,%eax
  80127d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801282:	75 d9                	jne    80125d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	05 00 00 00 30       	add    $0x30000000,%eax
  801296:	c1 e8 0c             	shr    $0xc,%eax
}
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ab:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	c1 ea 16             	shr    $0x16,%edx
  8012c2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	74 11                	je     8012df <fd_alloc+0x2d>
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	c1 ea 0c             	shr    $0xc,%edx
  8012d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012da:	f6 c2 01             	test   $0x1,%dl
  8012dd:	75 09                	jne    8012e8 <fd_alloc+0x36>
			*fd_store = fd;
  8012df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e6:	eb 17                	jmp    8012ff <fd_alloc+0x4d>
  8012e8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012f2:	75 c9                	jne    8012bd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012fa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801307:	83 f8 1f             	cmp    $0x1f,%eax
  80130a:	77 36                	ja     801342 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80130c:	c1 e0 0c             	shl    $0xc,%eax
  80130f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801314:	89 c2                	mov    %eax,%edx
  801316:	c1 ea 16             	shr    $0x16,%edx
  801319:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801320:	f6 c2 01             	test   $0x1,%dl
  801323:	74 24                	je     801349 <fd_lookup+0x48>
  801325:	89 c2                	mov    %eax,%edx
  801327:	c1 ea 0c             	shr    $0xc,%edx
  80132a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801331:	f6 c2 01             	test   $0x1,%dl
  801334:	74 1a                	je     801350 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801336:	8b 55 0c             	mov    0xc(%ebp),%edx
  801339:	89 02                	mov    %eax,(%edx)
	return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
  801340:	eb 13                	jmp    801355 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801347:	eb 0c                	jmp    801355 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801349:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134e:	eb 05                	jmp    801355 <fd_lookup+0x54>
  801350:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801360:	ba 78 28 80 00       	mov    $0x802878,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801365:	eb 13                	jmp    80137a <dev_lookup+0x23>
  801367:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80136a:	39 08                	cmp    %ecx,(%eax)
  80136c:	75 0c                	jne    80137a <dev_lookup+0x23>
			*dev = devtab[i];
  80136e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801371:	89 01                	mov    %eax,(%ecx)
			return 0;
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
  801378:	eb 2e                	jmp    8013a8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80137a:	8b 02                	mov    (%edx),%eax
  80137c:	85 c0                	test   %eax,%eax
  80137e:	75 e7                	jne    801367 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801380:	a1 04 40 80 00       	mov    0x804004,%eax
  801385:	8b 40 48             	mov    0x48(%eax),%eax
  801388:	83 ec 04             	sub    $0x4,%esp
  80138b:	51                   	push   %ecx
  80138c:	50                   	push   %eax
  80138d:	68 fc 27 80 00       	push   $0x8027fc
  801392:	e8 f5 ee ff ff       	call   80028c <cprintf>
	*dev = 0;
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 10             	sub    $0x10,%esp
  8013b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013c2:	c1 e8 0c             	shr    $0xc,%eax
  8013c5:	50                   	push   %eax
  8013c6:	e8 36 ff ff ff       	call   801301 <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 05                	js     8013d7 <fd_close+0x2d>
	    || fd != fd2)
  8013d2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013d5:	74 0c                	je     8013e3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013d7:	84 db                	test   %bl,%bl
  8013d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013de:	0f 44 c2             	cmove  %edx,%eax
  8013e1:	eb 41                	jmp    801424 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	ff 36                	pushl  (%esi)
  8013ec:	e8 66 ff ff ff       	call   801357 <dev_lookup>
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 1a                	js     801414 <fd_close+0x6a>
		if (dev->dev_close)
  8013fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801405:	85 c0                	test   %eax,%eax
  801407:	74 0b                	je     801414 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801409:	83 ec 0c             	sub    $0xc,%esp
  80140c:	56                   	push   %esi
  80140d:	ff d0                	call   *%eax
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	56                   	push   %esi
  801418:	6a 00                	push   $0x0
  80141a:	e8 f9 f8 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	89 d8                	mov    %ebx,%eax
}
  801424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 c4 fe ff ff       	call   801301 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 10                	js     801454 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	6a 01                	push   $0x1
  801449:	ff 75 f4             	pushl  -0xc(%ebp)
  80144c:	e8 59 ff ff ff       	call   8013aa <fd_close>
  801451:	83 c4 10             	add    $0x10,%esp
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <close_all>:

void
close_all(void)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80145d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	53                   	push   %ebx
  801466:	e8 c0 ff ff ff       	call   80142b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80146b:	83 c3 01             	add    $0x1,%ebx
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	83 fb 20             	cmp    $0x20,%ebx
  801474:	75 ec                	jne    801462 <close_all+0xc>
		close(i);
}
  801476:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	57                   	push   %edi
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	83 ec 2c             	sub    $0x2c,%esp
  801484:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801487:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 08             	pushl  0x8(%ebp)
  80148e:	e8 6e fe ff ff       	call   801301 <fd_lookup>
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	0f 88 c1 00 00 00    	js     80155f <dup+0xe4>
		return r;
	close(newfdnum);
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	56                   	push   %esi
  8014a2:	e8 84 ff ff ff       	call   80142b <close>

	newfd = INDEX2FD(newfdnum);
  8014a7:	89 f3                	mov    %esi,%ebx
  8014a9:	c1 e3 0c             	shl    $0xc,%ebx
  8014ac:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014b2:	83 c4 04             	add    $0x4,%esp
  8014b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b8:	e8 de fd ff ff       	call   80129b <fd2data>
  8014bd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014bf:	89 1c 24             	mov    %ebx,(%esp)
  8014c2:	e8 d4 fd ff ff       	call   80129b <fd2data>
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014cd:	89 f8                	mov    %edi,%eax
  8014cf:	c1 e8 16             	shr    $0x16,%eax
  8014d2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d9:	a8 01                	test   $0x1,%al
  8014db:	74 37                	je     801514 <dup+0x99>
  8014dd:	89 f8                	mov    %edi,%eax
  8014df:	c1 e8 0c             	shr    $0xc,%eax
  8014e2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e9:	f6 c2 01             	test   $0x1,%dl
  8014ec:	74 26                	je     801514 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fd:	50                   	push   %eax
  8014fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801501:	6a 00                	push   $0x0
  801503:	57                   	push   %edi
  801504:	6a 00                	push   $0x0
  801506:	e8 cb f7 ff ff       	call   800cd6 <sys_page_map>
  80150b:	89 c7                	mov    %eax,%edi
  80150d:	83 c4 20             	add    $0x20,%esp
  801510:	85 c0                	test   %eax,%eax
  801512:	78 2e                	js     801542 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801514:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801517:	89 d0                	mov    %edx,%eax
  801519:	c1 e8 0c             	shr    $0xc,%eax
  80151c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	25 07 0e 00 00       	and    $0xe07,%eax
  80152b:	50                   	push   %eax
  80152c:	53                   	push   %ebx
  80152d:	6a 00                	push   $0x0
  80152f:	52                   	push   %edx
  801530:	6a 00                	push   $0x0
  801532:	e8 9f f7 ff ff       	call   800cd6 <sys_page_map>
  801537:	89 c7                	mov    %eax,%edi
  801539:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80153c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80153e:	85 ff                	test   %edi,%edi
  801540:	79 1d                	jns    80155f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	53                   	push   %ebx
  801546:	6a 00                	push   $0x0
  801548:	e8 cb f7 ff ff       	call   800d18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	ff 75 d4             	pushl  -0x2c(%ebp)
  801553:	6a 00                	push   $0x0
  801555:	e8 be f7 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	89 f8                	mov    %edi,%eax
}
  80155f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801562:	5b                   	pop    %ebx
  801563:	5e                   	pop    %esi
  801564:	5f                   	pop    %edi
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	53                   	push   %ebx
  80156b:	83 ec 14             	sub    $0x14,%esp
  80156e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801571:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	53                   	push   %ebx
  801576:	e8 86 fd ff ff       	call   801301 <fd_lookup>
  80157b:	83 c4 08             	add    $0x8,%esp
  80157e:	89 c2                	mov    %eax,%edx
  801580:	85 c0                	test   %eax,%eax
  801582:	78 6d                	js     8015f1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158e:	ff 30                	pushl  (%eax)
  801590:	e8 c2 fd ff ff       	call   801357 <dev_lookup>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 4c                	js     8015e8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80159c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80159f:	8b 42 08             	mov    0x8(%edx),%eax
  8015a2:	83 e0 03             	and    $0x3,%eax
  8015a5:	83 f8 01             	cmp    $0x1,%eax
  8015a8:	75 21                	jne    8015cb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015af:	8b 40 48             	mov    0x48(%eax),%eax
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	50                   	push   %eax
  8015b7:	68 3d 28 80 00       	push   $0x80283d
  8015bc:	e8 cb ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c9:	eb 26                	jmp    8015f1 <read+0x8a>
	}
	if (!dev->dev_read)
  8015cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ce:	8b 40 08             	mov    0x8(%eax),%eax
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	74 17                	je     8015ec <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	52                   	push   %edx
  8015df:	ff d0                	call   *%eax
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 09                	jmp    8015f1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	eb 05                	jmp    8015f1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015f1:	89 d0                	mov    %edx,%eax
  8015f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	57                   	push   %edi
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	8b 7d 08             	mov    0x8(%ebp),%edi
  801604:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801607:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160c:	eb 21                	jmp    80162f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80160e:	83 ec 04             	sub    $0x4,%esp
  801611:	89 f0                	mov    %esi,%eax
  801613:	29 d8                	sub    %ebx,%eax
  801615:	50                   	push   %eax
  801616:	89 d8                	mov    %ebx,%eax
  801618:	03 45 0c             	add    0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	57                   	push   %edi
  80161d:	e8 45 ff ff ff       	call   801567 <read>
		if (m < 0)
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 10                	js     801639 <readn+0x41>
			return m;
		if (m == 0)
  801629:	85 c0                	test   %eax,%eax
  80162b:	74 0a                	je     801637 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162d:	01 c3                	add    %eax,%ebx
  80162f:	39 f3                	cmp    %esi,%ebx
  801631:	72 db                	jb     80160e <readn+0x16>
  801633:	89 d8                	mov    %ebx,%eax
  801635:	eb 02                	jmp    801639 <readn+0x41>
  801637:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5e                   	pop    %esi
  80163e:	5f                   	pop    %edi
  80163f:	5d                   	pop    %ebp
  801640:	c3                   	ret    

00801641 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 14             	sub    $0x14,%esp
  801648:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	53                   	push   %ebx
  801650:	e8 ac fc ff ff       	call   801301 <fd_lookup>
  801655:	83 c4 08             	add    $0x8,%esp
  801658:	89 c2                	mov    %eax,%edx
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 68                	js     8016c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	ff 30                	pushl  (%eax)
  80166a:	e8 e8 fc ff ff       	call   801357 <dev_lookup>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 47                	js     8016bd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167d:	75 21                	jne    8016a0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80167f:	a1 04 40 80 00       	mov    0x804004,%eax
  801684:	8b 40 48             	mov    0x48(%eax),%eax
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	53                   	push   %ebx
  80168b:	50                   	push   %eax
  80168c:	68 59 28 80 00       	push   $0x802859
  801691:	e8 f6 eb ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169e:	eb 26                	jmp    8016c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a6:	85 d2                	test   %edx,%edx
  8016a8:	74 17                	je     8016c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016aa:	83 ec 04             	sub    $0x4,%esp
  8016ad:	ff 75 10             	pushl  0x10(%ebp)
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	50                   	push   %eax
  8016b4:	ff d2                	call   *%edx
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 09                	jmp    8016c6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	eb 05                	jmp    8016c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016c6:	89 d0                	mov    %edx,%eax
  8016c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <seek>:

int
seek(int fdnum, off_t offset)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	ff 75 08             	pushl  0x8(%ebp)
  8016da:	e8 22 fc ff ff       	call   801301 <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 0e                	js     8016f4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 14             	sub    $0x14,%esp
  8016fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801700:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	53                   	push   %ebx
  801705:	e8 f7 fb ff ff       	call   801301 <fd_lookup>
  80170a:	83 c4 08             	add    $0x8,%esp
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 65                	js     801778 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171d:	ff 30                	pushl  (%eax)
  80171f:	e8 33 fc ff ff       	call   801357 <dev_lookup>
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 44                	js     80176f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801732:	75 21                	jne    801755 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801734:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801739:	8b 40 48             	mov    0x48(%eax),%eax
  80173c:	83 ec 04             	sub    $0x4,%esp
  80173f:	53                   	push   %ebx
  801740:	50                   	push   %eax
  801741:	68 1c 28 80 00       	push   $0x80281c
  801746:	e8 41 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801753:	eb 23                	jmp    801778 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801755:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801758:	8b 52 18             	mov    0x18(%edx),%edx
  80175b:	85 d2                	test   %edx,%edx
  80175d:	74 14                	je     801773 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	50                   	push   %eax
  801766:	ff d2                	call   *%edx
  801768:	89 c2                	mov    %eax,%edx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	eb 09                	jmp    801778 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	89 c2                	mov    %eax,%edx
  801771:	eb 05                	jmp    801778 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801773:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801778:	89 d0                	mov    %edx,%eax
  80177a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	53                   	push   %ebx
  801783:	83 ec 14             	sub    $0x14,%esp
  801786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801789:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	ff 75 08             	pushl  0x8(%ebp)
  801790:	e8 6c fb ff ff       	call   801301 <fd_lookup>
  801795:	83 c4 08             	add    $0x8,%esp
  801798:	89 c2                	mov    %eax,%edx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 58                	js     8017f6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	ff 30                	pushl  (%eax)
  8017aa:	e8 a8 fb ff ff       	call   801357 <dev_lookup>
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 37                	js     8017ed <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017bd:	74 32                	je     8017f1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c9:	00 00 00 
	stat->st_isdir = 0;
  8017cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d3:	00 00 00 
	stat->st_dev = dev;
  8017d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	53                   	push   %ebx
  8017e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e3:	ff 50 14             	call   *0x14(%eax)
  8017e6:	89 c2                	mov    %eax,%edx
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	eb 09                	jmp    8017f6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ed:	89 c2                	mov    %eax,%edx
  8017ef:	eb 05                	jmp    8017f6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017f6:	89 d0                	mov    %edx,%eax
  8017f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	6a 00                	push   $0x0
  801807:	ff 75 08             	pushl  0x8(%ebp)
  80180a:	e8 e9 01 00 00       	call   8019f8 <open>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	78 1b                	js     801833 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	ff 75 0c             	pushl  0xc(%ebp)
  80181e:	50                   	push   %eax
  80181f:	e8 5b ff ff ff       	call   80177f <fstat>
  801824:	89 c6                	mov    %eax,%esi
	close(fd);
  801826:	89 1c 24             	mov    %ebx,(%esp)
  801829:	e8 fd fb ff ff       	call   80142b <close>
	return r;
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	89 f0                	mov    %esi,%eax
}
  801833:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
  80183f:	89 c6                	mov    %eax,%esi
  801841:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801843:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80184a:	75 12                	jne    80185e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80184c:	83 ec 0c             	sub    $0xc,%esp
  80184f:	6a 01                	push   $0x1
  801851:	e8 fc f9 ff ff       	call   801252 <ipc_find_env>
  801856:	a3 00 40 80 00       	mov    %eax,0x804000
  80185b:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80185e:	6a 07                	push   $0x7
  801860:	68 00 50 80 00       	push   $0x805000
  801865:	56                   	push   %esi
  801866:	ff 35 00 40 80 00    	pushl  0x804000
  80186c:	e8 8d f9 ff ff       	call   8011fe <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801871:	83 c4 0c             	add    $0xc,%esp
  801874:	6a 00                	push   $0x0
  801876:	53                   	push   %ebx
  801877:	6a 00                	push   $0x0
  801879:	e8 fe f8 ff ff       	call   80117c <ipc_recv>
}
  80187e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 40 0c             	mov    0xc(%eax),%eax
  801891:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801896:	8b 45 0c             	mov    0xc(%ebp),%eax
  801899:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a8:	e8 8d ff ff ff       	call   80183a <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ca:	e8 6b ff ff ff       	call   80183a <fsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f0:	e8 45 ff ff ff       	call   80183a <fsipc>
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 2c                	js     801925 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	68 00 50 80 00       	push   $0x805000
  801901:	53                   	push   %ebx
  801902:	e8 89 ef ff ff       	call   800890 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801907:	a1 80 50 80 00       	mov    0x805080,%eax
  80190c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801912:	a1 84 50 80 00       	mov    0x805084,%eax
  801917:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801925:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 0c             	sub    $0xc,%esp
  801930:	8b 45 10             	mov    0x10(%ebp),%eax
  801933:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801938:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80193d:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801940:	8b 55 08             	mov    0x8(%ebp),%edx
  801943:	8b 52 0c             	mov    0xc(%edx),%edx
  801946:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80194c:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801951:	50                   	push   %eax
  801952:	ff 75 0c             	pushl  0xc(%ebp)
  801955:	68 08 50 80 00       	push   $0x805008
  80195a:	e8 c3 f0 ff ff       	call   800a22 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 04 00 00 00       	mov    $0x4,%eax
  801969:	e8 cc fe ff ff       	call   80183a <fsipc>
            return r;

    return r;
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
  801975:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	8b 40 0c             	mov    0xc(%eax),%eax
  80197e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801983:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801989:	ba 00 00 00 00       	mov    $0x0,%edx
  80198e:	b8 03 00 00 00       	mov    $0x3,%eax
  801993:	e8 a2 fe ff ff       	call   80183a <fsipc>
  801998:	89 c3                	mov    %eax,%ebx
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 51                	js     8019ef <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80199e:	39 c6                	cmp    %eax,%esi
  8019a0:	73 19                	jae    8019bb <devfile_read+0x4b>
  8019a2:	68 88 28 80 00       	push   $0x802888
  8019a7:	68 8f 28 80 00       	push   $0x80288f
  8019ac:	68 82 00 00 00       	push   $0x82
  8019b1:	68 a4 28 80 00       	push   $0x8028a4
  8019b6:	e8 c0 05 00 00       	call   801f7b <_panic>
	assert(r <= PGSIZE);
  8019bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c0:	7e 19                	jle    8019db <devfile_read+0x6b>
  8019c2:	68 af 28 80 00       	push   $0x8028af
  8019c7:	68 8f 28 80 00       	push   $0x80288f
  8019cc:	68 83 00 00 00       	push   $0x83
  8019d1:	68 a4 28 80 00       	push   $0x8028a4
  8019d6:	e8 a0 05 00 00       	call   801f7b <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	50                   	push   %eax
  8019df:	68 00 50 80 00       	push   $0x805000
  8019e4:	ff 75 0c             	pushl  0xc(%ebp)
  8019e7:	e8 36 f0 ff ff       	call   800a22 <memmove>
	return r;
  8019ec:	83 c4 10             	add    $0x10,%esp
}
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 20             	sub    $0x20,%esp
  8019ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a02:	53                   	push   %ebx
  801a03:	e8 4f ee ff ff       	call   800857 <strlen>
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a10:	7f 67                	jg     801a79 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a18:	50                   	push   %eax
  801a19:	e8 94 f8 ff ff       	call   8012b2 <fd_alloc>
  801a1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a21:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 57                	js     801a7e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	53                   	push   %ebx
  801a2b:	68 00 50 80 00       	push   $0x805000
  801a30:	e8 5b ee ff ff       	call   800890 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a38:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a40:	b8 01 00 00 00       	mov    $0x1,%eax
  801a45:	e8 f0 fd ff ff       	call   80183a <fsipc>
  801a4a:	89 c3                	mov    %eax,%ebx
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	79 14                	jns    801a67 <open+0x6f>
		fd_close(fd, 0);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	6a 00                	push   $0x0
  801a58:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5b:	e8 4a f9 ff ff       	call   8013aa <fd_close>
		return r;
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	89 da                	mov    %ebx,%edx
  801a65:	eb 17                	jmp    801a7e <open+0x86>
	}

	return fd2num(fd);
  801a67:	83 ec 0c             	sub    $0xc,%esp
  801a6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6d:	e8 19 f8 ff ff       	call   80128b <fd2num>
  801a72:	89 c2                	mov    %eax,%edx
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	eb 05                	jmp    801a7e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a79:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a7e:	89 d0                	mov    %edx,%eax
  801a80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a90:	b8 08 00 00 00       	mov    $0x8,%eax
  801a95:	e8 a0 fd ff ff       	call   80183a <fsipc>
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	ff 75 08             	pushl  0x8(%ebp)
  801aaa:	e8 ec f7 ff ff       	call   80129b <fd2data>
  801aaf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab1:	83 c4 08             	add    $0x8,%esp
  801ab4:	68 bb 28 80 00       	push   $0x8028bb
  801ab9:	53                   	push   %ebx
  801aba:	e8 d1 ed ff ff       	call   800890 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801abf:	8b 46 04             	mov    0x4(%esi),%eax
  801ac2:	2b 06                	sub    (%esi),%eax
  801ac4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad1:	00 00 00 
	stat->st_dev = &devpipe;
  801ad4:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801adb:	30 80 00 
	return 0;
}
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af4:	53                   	push   %ebx
  801af5:	6a 00                	push   $0x0
  801af7:	e8 1c f2 ff ff       	call   800d18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801afc:	89 1c 24             	mov    %ebx,(%esp)
  801aff:	e8 97 f7 ff ff       	call   80129b <fd2data>
  801b04:	83 c4 08             	add    $0x8,%esp
  801b07:	50                   	push   %eax
  801b08:	6a 00                	push   $0x0
  801b0a:	e8 09 f2 ff ff       	call   800d18 <sys_page_unmap>
}
  801b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	57                   	push   %edi
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	83 ec 1c             	sub    $0x1c,%esp
  801b1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b20:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b22:	a1 04 40 80 00       	mov    0x804004,%eax
  801b27:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b30:	e8 26 05 00 00       	call   80205b <pageref>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	89 3c 24             	mov    %edi,(%esp)
  801b3a:	e8 1c 05 00 00       	call   80205b <pageref>
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	39 c3                	cmp    %eax,%ebx
  801b44:	0f 94 c1             	sete   %cl
  801b47:	0f b6 c9             	movzbl %cl,%ecx
  801b4a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b4d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b53:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b56:	39 ce                	cmp    %ecx,%esi
  801b58:	74 1b                	je     801b75 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b5a:	39 c3                	cmp    %eax,%ebx
  801b5c:	75 c4                	jne    801b22 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b5e:	8b 42 58             	mov    0x58(%edx),%eax
  801b61:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b64:	50                   	push   %eax
  801b65:	56                   	push   %esi
  801b66:	68 c2 28 80 00       	push   $0x8028c2
  801b6b:	e8 1c e7 ff ff       	call   80028c <cprintf>
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	eb ad                	jmp    801b22 <_pipeisclosed+0xe>
	}
}
  801b75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 28             	sub    $0x28,%esp
  801b89:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b8c:	56                   	push   %esi
  801b8d:	e8 09 f7 ff ff       	call   80129b <fd2data>
  801b92:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	bf 00 00 00 00       	mov    $0x0,%edi
  801b9c:	eb 4b                	jmp    801be9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b9e:	89 da                	mov    %ebx,%edx
  801ba0:	89 f0                	mov    %esi,%eax
  801ba2:	e8 6d ff ff ff       	call   801b14 <_pipeisclosed>
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	75 48                	jne    801bf3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bab:	e8 c4 f0 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb3:	8b 0b                	mov    (%ebx),%ecx
  801bb5:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb8:	39 d0                	cmp    %edx,%eax
  801bba:	73 e2                	jae    801b9e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	c1 fa 1f             	sar    $0x1f,%edx
  801bcb:	89 d1                	mov    %edx,%ecx
  801bcd:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd3:	83 e2 1f             	and    $0x1f,%edx
  801bd6:	29 ca                	sub    %ecx,%edx
  801bd8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bdc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be0:	83 c0 01             	add    $0x1,%eax
  801be3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be6:	83 c7 01             	add    $0x1,%edi
  801be9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bec:	75 c2                	jne    801bb0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bee:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf1:	eb 05                	jmp    801bf8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	57                   	push   %edi
  801c04:	56                   	push   %esi
  801c05:	53                   	push   %ebx
  801c06:	83 ec 18             	sub    $0x18,%esp
  801c09:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c0c:	57                   	push   %edi
  801c0d:	e8 89 f6 ff ff       	call   80129b <fd2data>
  801c12:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1c:	eb 3d                	jmp    801c5b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c1e:	85 db                	test   %ebx,%ebx
  801c20:	74 04                	je     801c26 <devpipe_read+0x26>
				return i;
  801c22:	89 d8                	mov    %ebx,%eax
  801c24:	eb 44                	jmp    801c6a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c26:	89 f2                	mov    %esi,%edx
  801c28:	89 f8                	mov    %edi,%eax
  801c2a:	e8 e5 fe ff ff       	call   801b14 <_pipeisclosed>
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	75 32                	jne    801c65 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c33:	e8 3c f0 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c38:	8b 06                	mov    (%esi),%eax
  801c3a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c3d:	74 df                	je     801c1e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3f:	99                   	cltd   
  801c40:	c1 ea 1b             	shr    $0x1b,%edx
  801c43:	01 d0                	add    %edx,%eax
  801c45:	83 e0 1f             	and    $0x1f,%eax
  801c48:	29 d0                	sub    %edx,%eax
  801c4a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c52:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c55:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c58:	83 c3 01             	add    $0x1,%ebx
  801c5b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c5e:	75 d8                	jne    801c38 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c60:	8b 45 10             	mov    0x10(%ebp),%eax
  801c63:	eb 05                	jmp    801c6a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	e8 2f f6 ff ff       	call   8012b2 <fd_alloc>
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	89 c2                	mov    %eax,%edx
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 2c 01 00 00    	js     801dbc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	68 07 04 00 00       	push   $0x407
  801c98:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 f1 ef ff ff       	call   800c93 <sys_page_alloc>
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	89 c2                	mov    %eax,%edx
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 0d 01 00 00    	js     801dbc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	e8 f7 f5 ff ff       	call   8012b2 <fd_alloc>
  801cbb:	89 c3                	mov    %eax,%ebx
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	0f 88 e2 00 00 00    	js     801daa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	68 07 04 00 00       	push   $0x407
  801cd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 b9 ef ff ff       	call   800c93 <sys_page_alloc>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 c3 00 00 00    	js     801daa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	e8 a9 f5 ff ff       	call   80129b <fd2data>
  801cf2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf4:	83 c4 0c             	add    $0xc,%esp
  801cf7:	68 07 04 00 00       	push   $0x407
  801cfc:	50                   	push   %eax
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 8f ef ff ff       	call   800c93 <sys_page_alloc>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 89 00 00 00    	js     801d9a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	ff 75 f0             	pushl  -0x10(%ebp)
  801d17:	e8 7f f5 ff ff       	call   80129b <fd2data>
  801d1c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d23:	50                   	push   %eax
  801d24:	6a 00                	push   $0x0
  801d26:	56                   	push   %esi
  801d27:	6a 00                	push   $0x0
  801d29:	e8 a8 ef ff ff       	call   800cd6 <sys_page_map>
  801d2e:	89 c3                	mov    %eax,%ebx
  801d30:	83 c4 20             	add    $0x20,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 55                	js     801d8c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d37:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d40:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d45:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d4c:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	ff 75 f4             	pushl  -0xc(%ebp)
  801d67:	e8 1f f5 ff ff       	call   80128b <fd2num>
  801d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d71:	83 c4 04             	add    $0x4,%esp
  801d74:	ff 75 f0             	pushl  -0x10(%ebp)
  801d77:	e8 0f f5 ff ff       	call   80128b <fd2num>
  801d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8a:	eb 30                	jmp    801dbc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	56                   	push   %esi
  801d90:	6a 00                	push   $0x0
  801d92:	e8 81 ef ff ff       	call   800d18 <sys_page_unmap>
  801d97:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d9a:	83 ec 08             	sub    $0x8,%esp
  801d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801da0:	6a 00                	push   $0x0
  801da2:	e8 71 ef ff ff       	call   800d18 <sys_page_unmap>
  801da7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 f4             	pushl  -0xc(%ebp)
  801db0:	6a 00                	push   $0x0
  801db2:	e8 61 ef ff ff       	call   800d18 <sys_page_unmap>
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dbc:	89 d0                	mov    %edx,%eax
  801dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	ff 75 08             	pushl  0x8(%ebp)
  801dd2:	e8 2a f5 ff ff       	call   801301 <fd_lookup>
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 18                	js     801df6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	ff 75 f4             	pushl  -0xc(%ebp)
  801de4:	e8 b2 f4 ff ff       	call   80129b <fd2data>
	return _pipeisclosed(fd, p);
  801de9:	89 c2                	mov    %eax,%edx
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	e8 21 fd ff ff       	call   801b14 <_pipeisclosed>
  801df3:	83 c4 10             	add    $0x10,%esp
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e08:	68 da 28 80 00       	push   $0x8028da
  801e0d:	ff 75 0c             	pushl  0xc(%ebp)
  801e10:	e8 7b ea ff ff       	call   800890 <strcpy>
	return 0;
}
  801e15:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	57                   	push   %edi
  801e20:	56                   	push   %esi
  801e21:	53                   	push   %ebx
  801e22:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e28:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e2d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e33:	eb 2d                	jmp    801e62 <devcons_write+0x46>
		m = n - tot;
  801e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e38:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e3a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e3d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e42:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e45:	83 ec 04             	sub    $0x4,%esp
  801e48:	53                   	push   %ebx
  801e49:	03 45 0c             	add    0xc(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	57                   	push   %edi
  801e4e:	e8 cf eb ff ff       	call   800a22 <memmove>
		sys_cputs(buf, m);
  801e53:	83 c4 08             	add    $0x8,%esp
  801e56:	53                   	push   %ebx
  801e57:	57                   	push   %edi
  801e58:	e8 7a ed ff ff       	call   800bd7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5d:	01 de                	add    %ebx,%esi
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	89 f0                	mov    %esi,%eax
  801e64:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e67:	72 cc                	jb     801e35 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e6c:	5b                   	pop    %ebx
  801e6d:	5e                   	pop    %esi
  801e6e:	5f                   	pop    %edi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 08             	sub    $0x8,%esp
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e80:	74 2a                	je     801eac <devcons_read+0x3b>
  801e82:	eb 05                	jmp    801e89 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e84:	e8 eb ed ff ff       	call   800c74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e89:	e8 67 ed ff ff       	call   800bf5 <sys_cgetc>
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	74 f2                	je     801e84 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 16                	js     801eac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e96:	83 f8 04             	cmp    $0x4,%eax
  801e99:	74 0c                	je     801ea7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9e:	88 02                	mov    %al,(%edx)
	return 1;
  801ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea5:	eb 05                	jmp    801eac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eba:	6a 01                	push   $0x1
  801ebc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebf:	50                   	push   %eax
  801ec0:	e8 12 ed ff ff       	call   800bd7 <sys_cputs>
}
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <getchar>:

int
getchar(void)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ed0:	6a 01                	push   $0x1
  801ed2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed5:	50                   	push   %eax
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 8a f6 ff ff       	call   801567 <read>
	if (r < 0)
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 0f                	js     801ef3 <getchar+0x29>
		return r;
	if (r < 1)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	7e 06                	jle    801eee <getchar+0x24>
		return -E_EOF;
	return c;
  801ee8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eec:	eb 05                	jmp    801ef3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	ff 75 08             	pushl  0x8(%ebp)
  801f02:	e8 fa f3 ff ff       	call   801301 <fd_lookup>
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 11                	js     801f1f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f11:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f17:	39 10                	cmp    %edx,(%eax)
  801f19:	0f 94 c0             	sete   %al
  801f1c:	0f b6 c0             	movzbl %al,%eax
}
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <opencons>:

int
opencons(void)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2a:	50                   	push   %eax
  801f2b:	e8 82 f3 ff ff       	call   8012b2 <fd_alloc>
  801f30:	83 c4 10             	add    $0x10,%esp
		return r;
  801f33:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 3e                	js     801f77 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	68 07 04 00 00       	push   $0x407
  801f41:	ff 75 f4             	pushl  -0xc(%ebp)
  801f44:	6a 00                	push   $0x0
  801f46:	e8 48 ed ff ff       	call   800c93 <sys_page_alloc>
  801f4b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f4e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 23                	js     801f77 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f54:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f69:	83 ec 0c             	sub    $0xc,%esp
  801f6c:	50                   	push   %eax
  801f6d:	e8 19 f3 ff ff       	call   80128b <fd2num>
  801f72:	89 c2                	mov    %eax,%edx
  801f74:	83 c4 10             	add    $0x10,%esp
}
  801f77:	89 d0                	mov    %edx,%eax
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	56                   	push   %esi
  801f7f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f80:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f83:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f89:	e8 c7 ec ff ff       	call   800c55 <sys_getenvid>
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	ff 75 0c             	pushl  0xc(%ebp)
  801f94:	ff 75 08             	pushl  0x8(%ebp)
  801f97:	56                   	push   %esi
  801f98:	50                   	push   %eax
  801f99:	68 e8 28 80 00       	push   $0x8028e8
  801f9e:	e8 e9 e2 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fa3:	83 c4 18             	add    $0x18,%esp
  801fa6:	53                   	push   %ebx
  801fa7:	ff 75 10             	pushl  0x10(%ebp)
  801faa:	e8 8c e2 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801faf:	c7 04 24 d3 28 80 00 	movl   $0x8028d3,(%esp)
  801fb6:	e8 d1 e2 ff ff       	call   80028c <cprintf>
  801fbb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fbe:	cc                   	int3   
  801fbf:	eb fd                	jmp    801fbe <_panic+0x43>

00801fc1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801fc8:	e8 88 ec ff ff       	call   800c55 <sys_getenvid>
  801fcd:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801fcf:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fd6:	75 29                	jne    802001 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801fd8:	83 ec 04             	sub    $0x4,%esp
  801fdb:	6a 07                	push   $0x7
  801fdd:	68 00 f0 bf ee       	push   $0xeebff000
  801fe2:	50                   	push   %eax
  801fe3:	e8 ab ec ff ff       	call   800c93 <sys_page_alloc>
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	85 c0                	test   %eax,%eax
  801fed:	79 12                	jns    802001 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801fef:	50                   	push   %eax
  801ff0:	68 0c 29 80 00       	push   $0x80290c
  801ff5:	6a 24                	push   $0x24
  801ff7:	68 25 29 80 00       	push   $0x802925
  801ffc:	e8 7a ff ff ff       	call   801f7b <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  802009:	83 ec 08             	sub    $0x8,%esp
  80200c:	68 35 20 80 00       	push   $0x802035
  802011:	53                   	push   %ebx
  802012:	e8 c7 ed ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	79 12                	jns    802030 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  80201e:	50                   	push   %eax
  80201f:	68 0c 29 80 00       	push   $0x80290c
  802024:	6a 2e                	push   $0x2e
  802026:	68 25 29 80 00       	push   $0x802925
  80202b:	e8 4b ff ff ff       	call   801f7b <_panic>
}
  802030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802035:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802036:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80203b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80203d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  802040:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  802044:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  802047:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80204b:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  80204d:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802051:	83 c4 08             	add    $0x8,%esp
	popal
  802054:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802055:	83 c4 04             	add    $0x4,%esp
	popfl
  802058:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  802059:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80205a:	c3                   	ret    

0080205b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802061:	89 d0                	mov    %edx,%eax
  802063:	c1 e8 16             	shr    $0x16,%eax
  802066:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802072:	f6 c1 01             	test   $0x1,%cl
  802075:	74 1d                	je     802094 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802077:	c1 ea 0c             	shr    $0xc,%edx
  80207a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802081:	f6 c2 01             	test   $0x1,%dl
  802084:	74 0e                	je     802094 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802086:	c1 ea 0c             	shr    $0xc,%edx
  802089:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802090:	ef 
  802091:	0f b7 c0             	movzwl %ax,%eax
}
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
