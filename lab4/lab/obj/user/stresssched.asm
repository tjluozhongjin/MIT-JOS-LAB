
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 aa 0b 00 00       	call   800be7 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 85 0e 00 00       	call   800ece <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 a5 0b 00 00       	call   800c06 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 7c 0b 00 00       	call   800c06 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 c0 13 80 00       	push   $0x8013c0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 e8 13 80 00       	push   $0x8013e8
  8000c4:	e8 7c 00 00 00       	call   800145 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 fb 13 80 00       	push   $0x8013fb
  8000de:	e8 3b 01 00 00       	call   80021e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 ea 0a 00 00       	call   800be7 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 66 0a 00 00       	call   800ba6 <sys_env_destroy>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800153:	e8 8f 0a 00 00       	call   800be7 <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	56                   	push   %esi
  800162:	50                   	push   %eax
  800163:	68 24 14 80 00       	push   $0x801424
  800168:	e8 b1 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	pushl  0x10(%ebp)
  800174:	e8 54 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 17 14 80 00 	movl   $0x801417,(%esp)
  800180:	e8 99 00 00 00       	call   80021e <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800188:	cc                   	int3   
  800189:	eb fd                	jmp    800188 <_panic+0x43>

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 13                	mov    (%ebx),%edx
  800197:	8d 42 01             	lea    0x1(%edx),%eax
  80019a:	89 03                	mov    %eax,(%ebx)
  80019c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	75 1a                	jne    8001c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 ae 09 00 00       	call   800b69 <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 8b 01 80 00       	push   $0x80018b
  8001fc:	e8 1a 01 00 00       	call   80031b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 53 09 00 00       	call   800b69 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	pushl  0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800256:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800259:	39 d3                	cmp    %edx,%ebx
  80025b:	72 05                	jb     800262 <printnum+0x30>
  80025d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800260:	77 45                	ja     8002a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	8b 45 14             	mov    0x14(%ebp),%eax
  80026b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026e:	53                   	push   %ebx
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 9a 0e 00 00       	call   801120 <__udivdi3>
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	89 f2                	mov    %esi,%edx
  80028d:	89 f8                	mov    %edi,%eax
  80028f:	e8 9e ff ff ff       	call   800232 <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 18                	jmp    8002b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	ff 75 18             	pushl  0x18(%ebp)
  8002a0:	ff d7                	call   *%edi
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	eb 03                	jmp    8002aa <printnum+0x78>
  8002a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f e8                	jg     800299 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 87 0f 00 00       	call   801250 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 47 14 80 00 	movsbl 0x801447(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 02                	mov    %al,(%edx)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800304:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800307:	50                   	push   %eax
  800308:	ff 75 10             	pushl  0x10(%ebp)
  80030b:	ff 75 0c             	pushl  0xc(%ebp)
  80030e:	ff 75 08             	pushl  0x8(%ebp)
  800311:	e8 05 00 00 00       	call   80031b <vprintfmt>
	va_end(ap);
}
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 2c             	sub    $0x2c,%esp
  800324:	8b 75 08             	mov    0x8(%ebp),%esi
  800327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032d:	eb 12                	jmp    800341 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032f:	85 c0                	test   %eax,%eax
  800331:	0f 84 42 04 00 00    	je     800779 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	53                   	push   %ebx
  80033b:	50                   	push   %eax
  80033c:	ff d6                	call   *%esi
  80033e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	83 c7 01             	add    $0x1,%edi
  800344:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800348:	83 f8 25             	cmp    $0x25,%eax
  80034b:	75 e2                	jne    80032f <vprintfmt+0x14>
  80034d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800351:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800358:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036b:	eb 07                	jmp    800374 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800370:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8d 47 01             	lea    0x1(%edi),%eax
  800377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037a:	0f b6 07             	movzbl (%edi),%eax
  80037d:	0f b6 d0             	movzbl %al,%edx
  800380:	83 e8 23             	sub    $0x23,%eax
  800383:	3c 55                	cmp    $0x55,%al
  800385:	0f 87 d3 03 00 00    	ja     80075e <vprintfmt+0x443>
  80038b:	0f b6 c0             	movzbl %al,%eax
  80038e:	ff 24 85 00 15 80 00 	jmp    *0x801500(,%eax,4)
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039c:	eb d6                	jmp    800374 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ac:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b6:	83 f9 09             	cmp    $0x9,%ecx
  8003b9:	77 3f                	ja     8003fa <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003be:	eb e9                	jmp    8003a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8b 00                	mov    (%eax),%eax
  8003c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 40 04             	lea    0x4(%eax),%eax
  8003ce:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d4:	eb 2a                	jmp    800400 <vprintfmt+0xe5>
  8003d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e0:	0f 49 d0             	cmovns %eax,%edx
  8003e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e9:	eb 89                	jmp    800374 <vprintfmt+0x59>
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f5:	e9 7a ff ff ff       	jmp    800374 <vprintfmt+0x59>
  8003fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800400:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800404:	0f 89 6a ff ff ff    	jns    800374 <vprintfmt+0x59>
				width = precision, precision = -1;
  80040a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800410:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800417:	e9 58 ff ff ff       	jmp    800374 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800422:	e9 4d ff ff ff       	jmp    800374 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 78 04             	lea    0x4(%eax),%edi
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	ff 30                	pushl  (%eax)
  800433:	ff d6                	call   *%esi
			break;
  800435:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043e:	e9 fe fe ff ff       	jmp    800341 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 78 04             	lea    0x4(%eax),%edi
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	99                   	cltd   
  80044c:	31 d0                	xor    %edx,%eax
  80044e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800450:	83 f8 08             	cmp    $0x8,%eax
  800453:	7f 0b                	jg     800460 <vprintfmt+0x145>
  800455:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  80045c:	85 d2                	test   %edx,%edx
  80045e:	75 1b                	jne    80047b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800460:	50                   	push   %eax
  800461:	68 5f 14 80 00       	push   $0x80145f
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 91 fe ff ff       	call   8002fe <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800476:	e9 c6 fe ff ff       	jmp    800341 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047b:	52                   	push   %edx
  80047c:	68 68 14 80 00       	push   $0x801468
  800481:	53                   	push   %ebx
  800482:	56                   	push   %esi
  800483:	e8 76 fe ff ff       	call   8002fe <printfmt>
  800488:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800491:	e9 ab fe ff ff       	jmp    800341 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	83 c0 04             	add    $0x4,%eax
  80049c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a4:	85 ff                	test   %edi,%edi
  8004a6:	b8 58 14 80 00       	mov    $0x801458,%eax
  8004ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b2:	0f 8e 94 00 00 00    	jle    80054c <vprintfmt+0x231>
  8004b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bc:	0f 84 98 00 00 00    	je     80055a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c8:	57                   	push   %edi
  8004c9:	e8 33 03 00 00       	call   800801 <strnlen>
  8004ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d1:	29 c1                	sub    %eax,%ecx
  8004d3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1cc>
  8004fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800500:	85 c9                	test   %ecx,%ecx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c1             	cmovns %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 4d                	jmp    800566 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1b                	je     80053a <vprintfmt+0x21f>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 10                	jbe    80053a <vprintfmt+0x21f>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	6a 3f                	push   $0x3f
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb 0d                	jmp    800547 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	52                   	push   %edx
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	83 eb 01             	sub    $0x1,%ebx
  80054a:	eb 1a                	jmp    800566 <vprintfmt+0x24b>
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800558:	eb 0c                	jmp    800566 <vprintfmt+0x24b>
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	83 c7 01             	add    $0x1,%edi
  800569:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056d:	0f be d0             	movsbl %al,%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	74 23                	je     800597 <vprintfmt+0x27c>
  800574:	85 f6                	test   %esi,%esi
  800576:	78 a1                	js     800519 <vprintfmt+0x1fe>
  800578:	83 ee 01             	sub    $0x1,%esi
  80057b:	79 9c                	jns    800519 <vprintfmt+0x1fe>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb 18                	jmp    80059f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	6a 20                	push   $0x20
  80058d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb 08                	jmp    80059f <vprintfmt+0x284>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	85 ff                	test   %edi,%edi
  8005a1:	7f e4                	jg     800587 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ac:	e9 90 fd ff ff       	jmp    800341 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b1:	83 f9 01             	cmp    $0x1,%ecx
  8005b4:	7e 19                	jle    8005cf <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cd:	eb 38                	jmp    800607 <vprintfmt+0x2ec>
	else if (lflag)
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	74 1b                	je     8005ee <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ec:	eb 19                	jmp    800607 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f6:	89 c1                	mov    %eax,%ecx
  8005f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 40 04             	lea    0x4(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800607:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800616:	0f 89 0e 01 00 00    	jns    80072a <vprintfmt+0x40f>
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 2d                	push   $0x2d
  800622:	ff d6                	call   *%esi
				num = -(long long) num;
  800624:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800627:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062a:	f7 da                	neg    %edx
  80062c:	83 d1 00             	adc    $0x0,%ecx
  80062f:	f7 d9                	neg    %ecx
  800631:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
  800639:	e9 ec 00 00 00       	jmp    80072a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063e:	83 f9 01             	cmp    $0x1,%ecx
  800641:	7e 18                	jle    80065b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	8b 48 04             	mov    0x4(%eax),%ecx
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	e9 cf 00 00 00       	jmp    80072a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80065b:	85 c9                	test   %ecx,%ecx
  80065d:	74 1a                	je     800679 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	b9 00 00 00 00       	mov    $0x0,%ecx
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 b1 00 00 00       	jmp    80072a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800689:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068e:	e9 97 00 00 00       	jmp    80072a <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 58                	push   $0x58
  800699:	ff d6                	call   *%esi
			putch('X', putdat);
  80069b:	83 c4 08             	add    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 58                	push   $0x58
  8006a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 58                	push   $0x58
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b1:	e9 8b fc ff ff       	jmp    800341 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 30                	push   $0x30
  8006bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 78                	push   $0x78
  8006c4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006de:	eb 4a                	jmp    80072a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e0:	83 f9 01             	cmp    $0x1,%ecx
  8006e3:	7e 15                	jle    8006fa <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ed:	8d 40 08             	lea    0x8(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	eb 30                	jmp    80072a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	74 17                	je     800715 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
  800713:	eb 15                	jmp    80072a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071f:	8d 40 04             	lea    0x4(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800725:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800731:	57                   	push   %edi
  800732:	ff 75 e0             	pushl  -0x20(%ebp)
  800735:	50                   	push   %eax
  800736:	51                   	push   %ecx
  800737:	52                   	push   %edx
  800738:	89 da                	mov    %ebx,%edx
  80073a:	89 f0                	mov    %esi,%eax
  80073c:	e8 f1 fa ff ff       	call   800232 <printnum>
			break;
  800741:	83 c4 20             	add    $0x20,%esp
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	e9 f5 fb ff ff       	jmp    800341 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	52                   	push   %edx
  800751:	ff d6                	call   *%esi
			break;
  800753:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800759:	e9 e3 fb ff ff       	jmp    800341 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 03                	jmp    80076e <vprintfmt+0x453>
  80076b:	83 ef 01             	sub    $0x1,%edi
  80076e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800772:	75 f7                	jne    80076b <vprintfmt+0x450>
  800774:	e9 c8 fb ff ff       	jmp    800341 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800779:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5f                   	pop    %edi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 18             	sub    $0x18,%esp
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800790:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800794:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800797:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	74 26                	je     8007c8 <vsnprintf+0x47>
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	7e 22                	jle    8007c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a6:	ff 75 14             	pushl  0x14(%ebp)
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007af:	50                   	push   %eax
  8007b0:	68 e1 02 80 00       	push   $0x8002e1
  8007b5:	e8 61 fb ff ff       	call   80031b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb 05                	jmp    8007cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d8:	50                   	push   %eax
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 9a ff ff ff       	call   800781 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 03                	jmp    8007f9 <strlen+0x10>
		n++;
  8007f6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fd:	75 f7                	jne    8007f6 <strlen+0xd>
		n++;
	return n;
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080a:	ba 00 00 00 00       	mov    $0x0,%edx
  80080f:	eb 03                	jmp    800814 <strnlen+0x13>
		n++;
  800811:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 08                	je     800820 <strnlen+0x1f>
  800818:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80081c:	75 f3                	jne    800811 <strnlen+0x10>
  80081e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800838:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ef                	jne    80082e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083f:	5b                   	pop    %ebx
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800849:	53                   	push   %ebx
  80084a:	e8 9a ff ff ff       	call   8007e9 <strlen>
  80084f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800852:	ff 75 0c             	pushl  0xc(%ebp)
  800855:	01 d8                	add    %ebx,%eax
  800857:	50                   	push   %eax
  800858:	e8 c5 ff ff ff       	call   800822 <strcpy>
	return dst;
}
  80085d:	89 d8                	mov    %ebx,%eax
  80085f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	89 f3                	mov    %esi,%ebx
  800871:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	89 f2                	mov    %esi,%edx
  800876:	eb 0f                	jmp    800887 <strncpy+0x23>
		*dst++ = *src;
  800878:	83 c2 01             	add    $0x1,%edx
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800881:	80 39 01             	cmpb   $0x1,(%ecx)
  800884:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	39 da                	cmp    %ebx,%edx
  800889:	75 ed                	jne    800878 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089c:	8b 55 10             	mov    0x10(%ebp),%edx
  80089f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	74 21                	je     8008c6 <strlcpy+0x35>
  8008a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a9:	89 f2                	mov    %esi,%edx
  8008ab:	eb 09                	jmp    8008b6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b6:	39 c2                	cmp    %eax,%edx
  8008b8:	74 09                	je     8008c3 <strlcpy+0x32>
  8008ba:	0f b6 19             	movzbl (%ecx),%ebx
  8008bd:	84 db                	test   %bl,%bl
  8008bf:	75 ec                	jne    8008ad <strlcpy+0x1c>
  8008c1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d5:	eb 06                	jmp    8008dd <strcmp+0x11>
		p++, q++;
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008dd:	0f b6 01             	movzbl (%ecx),%eax
  8008e0:	84 c0                	test   %al,%al
  8008e2:	74 04                	je     8008e8 <strcmp+0x1c>
  8008e4:	3a 02                	cmp    (%edx),%al
  8008e6:	74 ef                	je     8008d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 c0             	movzbl %al,%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800901:	eb 06                	jmp    800909 <strncmp+0x17>
		n--, p++, q++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800909:	39 d8                	cmp    %ebx,%eax
  80090b:	74 15                	je     800922 <strncmp+0x30>
  80090d:	0f b6 08             	movzbl (%eax),%ecx
  800910:	84 c9                	test   %cl,%cl
  800912:	74 04                	je     800918 <strncmp+0x26>
  800914:	3a 0a                	cmp    (%edx),%cl
  800916:	74 eb                	je     800903 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 00             	movzbl (%eax),%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
  800920:	eb 05                	jmp    800927 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800934:	eb 07                	jmp    80093d <strchr+0x13>
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 0f                	je     800949 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f2                	jne    800936 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 03                	jmp    80095a <strfind+0xf>
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095d:	38 ca                	cmp    %cl,%dl
  80095f:	74 04                	je     800965 <strfind+0x1a>
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strfind+0xc>
			break;
	return (char *) s;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	74 36                	je     8009ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800977:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097d:	75 28                	jne    8009a7 <memset+0x40>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 23                	jne    8009a7 <memset+0x40>
		c &= 0xFF;
  800984:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800988:	89 d3                	mov    %edx,%ebx
  80098a:	c1 e3 08             	shl    $0x8,%ebx
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 18             	shl    $0x18,%esi
  800992:	89 d0                	mov    %edx,%eax
  800994:	c1 e0 10             	shl    $0x10,%eax
  800997:	09 f0                	or     %esi,%eax
  800999:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80099b:	89 d8                	mov    %ebx,%eax
  80099d:	09 d0                	or     %edx,%eax
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	fc                   	cld    
  8009a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a5:	eb 06                	jmp    8009ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	fc                   	cld    
  8009ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c2:	39 c6                	cmp    %eax,%esi
  8009c4:	73 35                	jae    8009fb <memmove+0x47>
  8009c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c9:	39 d0                	cmp    %edx,%eax
  8009cb:	73 2e                	jae    8009fb <memmove+0x47>
		s += n;
		d += n;
  8009cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	89 d6                	mov    %edx,%esi
  8009d2:	09 fe                	or     %edi,%esi
  8009d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009da:	75 13                	jne    8009ef <memmove+0x3b>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0e                	jne    8009ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e1:	83 ef 04             	sub    $0x4,%edi
  8009e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
  8009ea:	fd                   	std    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 09                	jmp    8009f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ef:	83 ef 01             	sub    $0x1,%edi
  8009f2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f5:	fd                   	std    
  8009f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f8:	fc                   	cld    
  8009f9:	eb 1d                	jmp    800a18 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fb:	89 f2                	mov    %esi,%edx
  8009fd:	09 c2                	or     %eax,%edx
  8009ff:	f6 c2 03             	test   $0x3,%dl
  800a02:	75 0f                	jne    800a13 <memmove+0x5f>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 0a                	jne    800a13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a09:	c1 e9 02             	shr    $0x2,%ecx
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 05                	jmp    800a18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1f:	ff 75 10             	pushl  0x10(%ebp)
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	ff 75 08             	pushl  0x8(%ebp)
  800a28:	e8 87 ff ff ff       	call   8009b4 <memmove>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	eb 1a                	jmp    800a5b <memcmp+0x2c>
		if (*s1 != *s2)
  800a41:	0f b6 08             	movzbl (%eax),%ecx
  800a44:	0f b6 1a             	movzbl (%edx),%ebx
  800a47:	38 d9                	cmp    %bl,%cl
  800a49:	74 0a                	je     800a55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a4b:	0f b6 c1             	movzbl %cl,%eax
  800a4e:	0f b6 db             	movzbl %bl,%ebx
  800a51:	29 d8                	sub    %ebx,%eax
  800a53:	eb 0f                	jmp    800a64 <memcmp+0x35>
		s1++, s2++;
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 f0                	cmp    %esi,%eax
  800a5d:	75 e2                	jne    800a41 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6f:	89 c1                	mov    %eax,%ecx
  800a71:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a74:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a78:	eb 0a                	jmp    800a84 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7a:	0f b6 10             	movzbl (%eax),%edx
  800a7d:	39 da                	cmp    %ebx,%edx
  800a7f:	74 07                	je     800a88 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	39 c8                	cmp    %ecx,%eax
  800a86:	72 f2                	jb     800a7a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a97:	eb 03                	jmp    800a9c <strtol+0x11>
		s++;
  800a99:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9c:	0f b6 01             	movzbl (%ecx),%eax
  800a9f:	3c 20                	cmp    $0x20,%al
  800aa1:	74 f6                	je     800a99 <strtol+0xe>
  800aa3:	3c 09                	cmp    $0x9,%al
  800aa5:	74 f2                	je     800a99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa7:	3c 2b                	cmp    $0x2b,%al
  800aa9:	75 0a                	jne    800ab5 <strtol+0x2a>
		s++;
  800aab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aae:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab3:	eb 11                	jmp    800ac6 <strtol+0x3b>
  800ab5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aba:	3c 2d                	cmp    $0x2d,%al
  800abc:	75 08                	jne    800ac6 <strtol+0x3b>
		s++, neg = 1;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800acc:	75 15                	jne    800ae3 <strtol+0x58>
  800ace:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad1:	75 10                	jne    800ae3 <strtol+0x58>
  800ad3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad7:	75 7c                	jne    800b55 <strtol+0xca>
		s += 2, base = 16;
  800ad9:	83 c1 02             	add    $0x2,%ecx
  800adc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae1:	eb 16                	jmp    800af9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ae3:	85 db                	test   %ebx,%ebx
  800ae5:	75 12                	jne    800af9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aec:	80 39 30             	cmpb   $0x30,(%ecx)
  800aef:	75 08                	jne    800af9 <strtol+0x6e>
		s++, base = 8;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b01:	0f b6 11             	movzbl (%ecx),%edx
  800b04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 09             	cmp    $0x9,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0x8b>
			dig = *s - '0';
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 30             	sub    $0x30,%edx
  800b14:	eb 22                	jmp    800b38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 57             	sub    $0x57,%edx
  800b26:	eb 10                	jmp    800b38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2b:	89 f3                	mov    %esi,%ebx
  800b2d:	80 fb 19             	cmp    $0x19,%bl
  800b30:	77 16                	ja     800b48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b32:	0f be d2             	movsbl %dl,%edx
  800b35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3b:	7d 0b                	jge    800b48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b3d:	83 c1 01             	add    $0x1,%ecx
  800b40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b46:	eb b9                	jmp    800b01 <strtol+0x76>

	if (endptr)
  800b48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4c:	74 0d                	je     800b5b <strtol+0xd0>
		*endptr = (char *) s;
  800b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b51:	89 0e                	mov    %ecx,(%esi)
  800b53:	eb 06                	jmp    800b5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	74 98                	je     800af1 <strtol+0x66>
  800b59:	eb 9e                	jmp    800af9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	f7 da                	neg    %edx
  800b5f:	85 ff                	test   %edi,%edi
  800b61:	0f 45 c2             	cmovne %edx,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	89 c3                	mov    %eax,%ebx
  800b7c:	89 c7                	mov    %eax,%edi
  800b7e:	89 c6                	mov    %eax,%esi
  800b80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 01 00 00 00       	mov    $0x1,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb4:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	89 cb                	mov    %ecx,%ebx
  800bbe:	89 cf                	mov    %ecx,%edi
  800bc0:	89 ce                	mov    %ecx,%esi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 03                	push   $0x3
  800bce:	68 84 16 80 00       	push   $0x801684
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 a1 16 80 00       	push   $0x8016a1
  800bda:	e8 66 f5 ff ff       	call   800145 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf7:	89 d1                	mov    %edx,%ecx
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	89 d7                	mov    %edx,%edi
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_yield>:

void
sys_yield(void)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c16:	89 d1                	mov    %edx,%ecx
  800c18:	89 d3                	mov    %edx,%ebx
  800c1a:	89 d7                	mov    %edx,%edi
  800c1c:	89 d6                	mov    %edx,%esi
  800c1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	be 00 00 00 00       	mov    $0x0,%esi
  800c33:	b8 04 00 00 00       	mov    $0x4,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c41:	89 f7                	mov    %esi,%edi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 04                	push   $0x4
  800c4f:	68 84 16 80 00       	push   $0x801684
  800c54:	6a 23                	push   $0x23
  800c56:	68 a1 16 80 00       	push   $0x8016a1
  800c5b:	e8 e5 f4 ff ff       	call   800145 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	b8 05 00 00 00       	mov    $0x5,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c82:	8b 75 18             	mov    0x18(%ebp),%esi
  800c85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 05                	push   $0x5
  800c91:	68 84 16 80 00       	push   $0x801684
  800c96:	6a 23                	push   $0x23
  800c98:	68 a1 16 80 00       	push   $0x8016a1
  800c9d:	e8 a3 f4 ff ff       	call   800145 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 06                	push   $0x6
  800cd3:	68 84 16 80 00       	push   $0x801684
  800cd8:	6a 23                	push   $0x23
  800cda:	68 a1 16 80 00       	push   $0x8016a1
  800cdf:	e8 61 f4 ff ff       	call   800145 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 17                	jle    800d26 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 08                	push   $0x8
  800d15:	68 84 16 80 00       	push   $0x801684
  800d1a:	6a 23                	push   $0x23
  800d1c:	68 a1 16 80 00       	push   $0x8016a1
  800d21:	e8 1f f4 ff ff       	call   800145 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 17                	jle    800d68 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 09                	push   $0x9
  800d57:	68 84 16 80 00       	push   $0x801684
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 a1 16 80 00       	push   $0x8016a1
  800d63:	e8 dd f3 ff ff       	call   800145 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	be 00 00 00 00       	mov    $0x0,%esi
  800d7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 cb                	mov    %ecx,%ebx
  800dab:	89 cf                	mov    %ecx,%edi
  800dad:	89 ce                	mov    %ecx,%esi
  800daf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 17                	jle    800dcc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 0c                	push   $0xc
  800dbb:	68 84 16 80 00       	push   $0x801684
  800dc0:	6a 23                	push   $0x23
  800dc2:	68 a1 16 80 00       	push   $0x8016a1
  800dc7:	e8 79 f3 ff ff       	call   800145 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800ddc:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800dde:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de2:	74 11                	je     800df5 <pgfault+0x21>
  800de4:	89 d8                	mov    %ebx,%eax
  800de6:	c1 e8 0c             	shr    $0xc,%eax
  800de9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df0:	f6 c4 08             	test   $0x8,%ah
  800df3:	75 14                	jne    800e09 <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	68 b0 16 80 00       	push   $0x8016b0
  800dfd:	6a 1f                	push   $0x1f
  800dff:	68 14 17 80 00       	push   $0x801714
  800e04:	e8 3c f3 ff ff       	call   800145 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800e09:	e8 d9 fd ff ff       	call   800be7 <sys_getenvid>
  800e0e:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	6a 07                	push   $0x7
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	50                   	push   %eax
  800e1b:	e8 05 fe ff ff       	call   800c25 <sys_page_alloc>
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 12                	jns    800e39 <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 f0 16 80 00       	push   $0x8016f0
  800e2d:	6a 2c                	push   $0x2c
  800e2f:	68 14 17 80 00       	push   $0x801714
  800e34:	e8 0c f3 ff ff       	call   800145 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e39:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e3f:	83 ec 04             	sub    $0x4,%esp
  800e42:	68 00 10 00 00       	push   $0x1000
  800e47:	53                   	push   %ebx
  800e48:	68 00 f0 7f 00       	push   $0x7ff000
  800e4d:	e8 62 fb ff ff       	call   8009b4 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800e52:	83 c4 08             	add    $0x8,%esp
  800e55:	53                   	push   %ebx
  800e56:	56                   	push   %esi
  800e57:	e8 4e fe ff ff       	call   800caa <sys_page_unmap>
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 12                	jns    800e75 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800e63:	50                   	push   %eax
  800e64:	68 1f 17 80 00       	push   $0x80171f
  800e69:	6a 32                	push   $0x32
  800e6b:	68 14 17 80 00       	push   $0x801714
  800e70:	e8 d0 f2 ff ff       	call   800145 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	6a 07                	push   $0x7
  800e7a:	53                   	push   %ebx
  800e7b:	56                   	push   %esi
  800e7c:	68 00 f0 7f 00       	push   $0x7ff000
  800e81:	56                   	push   %esi
  800e82:	e8 e1 fd ff ff       	call   800c68 <sys_page_map>
  800e87:	83 c4 20             	add    $0x20,%esp
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	79 12                	jns    800ea0 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800e8e:	50                   	push   %eax
  800e8f:	68 3d 17 80 00       	push   $0x80173d
  800e94:	6a 35                	push   $0x35
  800e96:	68 14 17 80 00       	push   $0x801714
  800e9b:	e8 a5 f2 ff ff       	call   800145 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	68 00 f0 7f 00       	push   $0x7ff000
  800ea8:	56                   	push   %esi
  800ea9:	e8 fc fd ff ff       	call   800caa <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	79 12                	jns    800ec7 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800eb5:	50                   	push   %eax
  800eb6:	68 1f 17 80 00       	push   $0x80171f
  800ebb:	6a 38                	push   $0x38
  800ebd:	68 14 17 80 00       	push   $0x801714
  800ec2:	e8 7e f2 ff ff       	call   800145 <_panic>
	//panic("pgfault not implemented");
}
  800ec7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800ed7:	68 d4 0d 80 00       	push   $0x800dd4
  800edc:	e8 a4 01 00 00       	call   801085 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee6:	cd 30                	int    $0x30
  800ee8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	0f 88 f1 00 00 00    	js     800fe7 <fork+0x119>
  800ef6:	89 c7                	mov    %eax,%edi
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800efd:	85 c0                	test   %eax,%eax
  800eff:	75 21                	jne    800f22 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f01:	e8 e1 fc ff ff       	call   800be7 <sys_getenvid>
  800f06:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f0e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f13:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f18:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1d:	e9 3f 01 00 00       	jmp    801061 <fork+0x193>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f22:	89 d8                	mov    %ebx,%eax
  800f24:	c1 e8 16             	shr    $0x16,%eax
  800f27:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2e:	a8 01                	test   $0x1,%al
  800f30:	74 51                	je     800f83 <fork+0xb5>
  800f32:	89 d8                	mov    %ebx,%eax
  800f34:	c1 e8 0c             	shr    $0xc,%eax
  800f37:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3e:	f6 c2 01             	test   $0x1,%dl
  800f41:	74 40                	je     800f83 <fork+0xb5>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f43:	89 c6                	mov    %eax,%esi
  800f45:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800f48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4f:	a9 02 08 00 00       	test   $0x802,%eax
  800f54:	0f 85 e5 00 00 00    	jne    80103f <fork+0x171>
  800f5a:	e9 8d 00 00 00       	jmp    800fec <fork+0x11e>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f5f:	50                   	push   %eax
  800f60:	68 59 17 80 00       	push   $0x801759
  800f65:	6a 57                	push   $0x57
  800f67:	68 14 17 80 00       	push   $0x801714
  800f6c:	e8 d4 f1 ff ff       	call   800145 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f71:	50                   	push   %eax
  800f72:	68 59 17 80 00       	push   $0x801759
  800f77:	6a 5e                	push   $0x5e
  800f79:	68 14 17 80 00       	push   $0x801714
  800f7e:	e8 c2 f1 ff ff       	call   800145 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800f83:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f89:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800f8f:	75 91                	jne    800f22 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	6a 07                	push   $0x7
  800f96:	68 00 f0 bf ee       	push   $0xeebff000
  800f9b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800f9e:	57                   	push   %edi
  800f9f:	e8 81 fc ff ff       	call   800c25 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fa4:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fa7:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	0f 88 b0 00 00 00    	js     801061 <fork+0x193>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800fb1:	a1 08 20 80 00       	mov    0x802008,%eax
  800fb6:	8b 40 64             	mov    0x64(%eax),%eax
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	50                   	push   %eax
  800fbd:	57                   	push   %edi
  800fbe:	e8 6b fd ff ff       	call   800d2e <sys_env_set_pgfault_upcall>
  800fc3:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fc6:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	0f 88 91 00 00 00    	js     801061 <fork+0x193>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	6a 02                	push   $0x2
  800fd5:	57                   	push   %edi
  800fd6:	e8 11 fd ff ff       	call   800cec <sys_env_set_status>
  800fdb:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	89 fa                	mov    %edi,%edx
  800fe2:	0f 48 d0             	cmovs  %eax,%edx
  800fe5:	eb 7a                	jmp    801061 <fork+0x193>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  800fe7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fea:	eb 75                	jmp    801061 <fork+0x193>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  800fec:	e8 f6 fb ff ff       	call   800be7 <sys_getenvid>
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	6a 05                	push   $0x5
  800ff6:	56                   	push   %esi
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	50                   	push   %eax
  800ffa:	e8 69 fc ff ff       	call   800c68 <sys_page_map>
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	0f 89 79 ff ff ff    	jns    800f83 <fork+0xb5>
  80100a:	e9 50 ff ff ff       	jmp    800f5f <fork+0x91>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  80100f:	e8 d3 fb ff ff       	call   800be7 <sys_getenvid>
  801014:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801017:	e8 cb fb ff ff       	call   800be7 <sys_getenvid>
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	68 05 08 00 00       	push   $0x805
  801024:	56                   	push   %esi
  801025:	ff 75 e4             	pushl  -0x1c(%ebp)
  801028:	56                   	push   %esi
  801029:	50                   	push   %eax
  80102a:	e8 39 fc ff ff       	call   800c68 <sys_page_map>
  80102f:	83 c4 20             	add    $0x20,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	0f 89 49 ff ff ff    	jns    800f83 <fork+0xb5>
  80103a:	e9 32 ff ff ff       	jmp    800f71 <fork+0xa3>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  80103f:	e8 a3 fb ff ff       	call   800be7 <sys_getenvid>
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	68 05 08 00 00       	push   $0x805
  80104c:	56                   	push   %esi
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	50                   	push   %eax
  801050:	e8 13 fc ff ff       	call   800c68 <sys_page_map>
  801055:	83 c4 20             	add    $0x20,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	79 b3                	jns    80100f <fork+0x141>
  80105c:	e9 fe fe ff ff       	jmp    800f5f <fork+0x91>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  801061:	89 d0                	mov    %edx,%eax
  801063:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sfork>:

// Challenge!
int
sfork(void)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801071:	68 6a 17 80 00       	push   $0x80176a
  801076:	68 a6 00 00 00       	push   $0xa6
  80107b:	68 14 17 80 00       	push   $0x801714
  801080:	e8 c0 f0 ff ff       	call   800145 <_panic>

00801085 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	53                   	push   %ebx
  801089:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  80108c:	e8 56 fb ff ff       	call   800be7 <sys_getenvid>
  801091:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801093:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80109a:	75 29                	jne    8010c5 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	6a 07                	push   $0x7
  8010a1:	68 00 f0 bf ee       	push   $0xeebff000
  8010a6:	50                   	push   %eax
  8010a7:	e8 79 fb ff ff       	call   800c25 <sys_page_alloc>
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 12                	jns    8010c5 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  8010b3:	50                   	push   %eax
  8010b4:	68 80 17 80 00       	push   $0x801780
  8010b9:	6a 24                	push   $0x24
  8010bb:	68 99 17 80 00       	push   $0x801799
  8010c0:	e8 80 f0 ff ff       	call   800145 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	a3 0c 20 80 00       	mov    %eax,0x80200c
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	68 f9 10 80 00       	push   $0x8010f9
  8010d5:	53                   	push   %ebx
  8010d6:	e8 53 fc ff ff       	call   800d2e <sys_env_set_pgfault_upcall>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 12                	jns    8010f4 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  8010e2:	50                   	push   %eax
  8010e3:	68 80 17 80 00       	push   $0x801780
  8010e8:	6a 2e                	push   $0x2e
  8010ea:	68 99 17 80 00       	push   $0x801799
  8010ef:	e8 51 f0 ff ff       	call   800145 <_panic>
}
  8010f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f7:	c9                   	leave  
  8010f8:	c3                   	ret    

008010f9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010f9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010fa:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8010ff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801101:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801104:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801108:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  80110b:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80110f:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801111:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801115:	83 c4 08             	add    $0x8,%esp
	popal
  801118:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801119:	83 c4 04             	add    $0x4,%esp
	popfl
  80111c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  80111d:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80111e:	c3                   	ret    
  80111f:	90                   	nop

00801120 <__udivdi3>:
  801120:	55                   	push   %ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80112b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80112f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801137:	85 f6                	test   %esi,%esi
  801139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80113d:	89 ca                	mov    %ecx,%edx
  80113f:	89 f8                	mov    %edi,%eax
  801141:	75 3d                	jne    801180 <__udivdi3+0x60>
  801143:	39 cf                	cmp    %ecx,%edi
  801145:	0f 87 c5 00 00 00    	ja     801210 <__udivdi3+0xf0>
  80114b:	85 ff                	test   %edi,%edi
  80114d:	89 fd                	mov    %edi,%ebp
  80114f:	75 0b                	jne    80115c <__udivdi3+0x3c>
  801151:	b8 01 00 00 00       	mov    $0x1,%eax
  801156:	31 d2                	xor    %edx,%edx
  801158:	f7 f7                	div    %edi
  80115a:	89 c5                	mov    %eax,%ebp
  80115c:	89 c8                	mov    %ecx,%eax
  80115e:	31 d2                	xor    %edx,%edx
  801160:	f7 f5                	div    %ebp
  801162:	89 c1                	mov    %eax,%ecx
  801164:	89 d8                	mov    %ebx,%eax
  801166:	89 cf                	mov    %ecx,%edi
  801168:	f7 f5                	div    %ebp
  80116a:	89 c3                	mov    %eax,%ebx
  80116c:	89 d8                	mov    %ebx,%eax
  80116e:	89 fa                	mov    %edi,%edx
  801170:	83 c4 1c             	add    $0x1c,%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    
  801178:	90                   	nop
  801179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801180:	39 ce                	cmp    %ecx,%esi
  801182:	77 74                	ja     8011f8 <__udivdi3+0xd8>
  801184:	0f bd fe             	bsr    %esi,%edi
  801187:	83 f7 1f             	xor    $0x1f,%edi
  80118a:	0f 84 98 00 00 00    	je     801228 <__udivdi3+0x108>
  801190:	bb 20 00 00 00       	mov    $0x20,%ebx
  801195:	89 f9                	mov    %edi,%ecx
  801197:	89 c5                	mov    %eax,%ebp
  801199:	29 fb                	sub    %edi,%ebx
  80119b:	d3 e6                	shl    %cl,%esi
  80119d:	89 d9                	mov    %ebx,%ecx
  80119f:	d3 ed                	shr    %cl,%ebp
  8011a1:	89 f9                	mov    %edi,%ecx
  8011a3:	d3 e0                	shl    %cl,%eax
  8011a5:	09 ee                	or     %ebp,%esi
  8011a7:	89 d9                	mov    %ebx,%ecx
  8011a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ad:	89 d5                	mov    %edx,%ebp
  8011af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011b3:	d3 ed                	shr    %cl,%ebp
  8011b5:	89 f9                	mov    %edi,%ecx
  8011b7:	d3 e2                	shl    %cl,%edx
  8011b9:	89 d9                	mov    %ebx,%ecx
  8011bb:	d3 e8                	shr    %cl,%eax
  8011bd:	09 c2                	or     %eax,%edx
  8011bf:	89 d0                	mov    %edx,%eax
  8011c1:	89 ea                	mov    %ebp,%edx
  8011c3:	f7 f6                	div    %esi
  8011c5:	89 d5                	mov    %edx,%ebp
  8011c7:	89 c3                	mov    %eax,%ebx
  8011c9:	f7 64 24 0c          	mull   0xc(%esp)
  8011cd:	39 d5                	cmp    %edx,%ebp
  8011cf:	72 10                	jb     8011e1 <__udivdi3+0xc1>
  8011d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011d5:	89 f9                	mov    %edi,%ecx
  8011d7:	d3 e6                	shl    %cl,%esi
  8011d9:	39 c6                	cmp    %eax,%esi
  8011db:	73 07                	jae    8011e4 <__udivdi3+0xc4>
  8011dd:	39 d5                	cmp    %edx,%ebp
  8011df:	75 03                	jne    8011e4 <__udivdi3+0xc4>
  8011e1:	83 eb 01             	sub    $0x1,%ebx
  8011e4:	31 ff                	xor    %edi,%edi
  8011e6:	89 d8                	mov    %ebx,%eax
  8011e8:	89 fa                	mov    %edi,%edx
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    
  8011f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f8:	31 ff                	xor    %edi,%edi
  8011fa:	31 db                	xor    %ebx,%ebx
  8011fc:	89 d8                	mov    %ebx,%eax
  8011fe:	89 fa                	mov    %edi,%edx
  801200:	83 c4 1c             	add    $0x1c,%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    
  801208:	90                   	nop
  801209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 d8                	mov    %ebx,%eax
  801212:	f7 f7                	div    %edi
  801214:	31 ff                	xor    %edi,%edi
  801216:	89 c3                	mov    %eax,%ebx
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	89 fa                	mov    %edi,%edx
  80121c:	83 c4 1c             	add    $0x1c,%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	39 ce                	cmp    %ecx,%esi
  80122a:	72 0c                	jb     801238 <__udivdi3+0x118>
  80122c:	31 db                	xor    %ebx,%ebx
  80122e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801232:	0f 87 34 ff ff ff    	ja     80116c <__udivdi3+0x4c>
  801238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80123d:	e9 2a ff ff ff       	jmp    80116c <__udivdi3+0x4c>
  801242:	66 90                	xchg   %ax,%ax
  801244:	66 90                	xchg   %ax,%ax
  801246:	66 90                	xchg   %ax,%ax
  801248:	66 90                	xchg   %ax,%ax
  80124a:	66 90                	xchg   %ax,%ax
  80124c:	66 90                	xchg   %ax,%ax
  80124e:	66 90                	xchg   %ax,%ax

00801250 <__umoddi3>:
  801250:	55                   	push   %ebp
  801251:	57                   	push   %edi
  801252:	56                   	push   %esi
  801253:	53                   	push   %ebx
  801254:	83 ec 1c             	sub    $0x1c,%esp
  801257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80125b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80125f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801267:	85 d2                	test   %edx,%edx
  801269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80126d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801271:	89 f3                	mov    %esi,%ebx
  801273:	89 3c 24             	mov    %edi,(%esp)
  801276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80127a:	75 1c                	jne    801298 <__umoddi3+0x48>
  80127c:	39 f7                	cmp    %esi,%edi
  80127e:	76 50                	jbe    8012d0 <__umoddi3+0x80>
  801280:	89 c8                	mov    %ecx,%eax
  801282:	89 f2                	mov    %esi,%edx
  801284:	f7 f7                	div    %edi
  801286:	89 d0                	mov    %edx,%eax
  801288:	31 d2                	xor    %edx,%edx
  80128a:	83 c4 1c             	add    $0x1c,%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	39 f2                	cmp    %esi,%edx
  80129a:	89 d0                	mov    %edx,%eax
  80129c:	77 52                	ja     8012f0 <__umoddi3+0xa0>
  80129e:	0f bd ea             	bsr    %edx,%ebp
  8012a1:	83 f5 1f             	xor    $0x1f,%ebp
  8012a4:	75 5a                	jne    801300 <__umoddi3+0xb0>
  8012a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012aa:	0f 82 e0 00 00 00    	jb     801390 <__umoddi3+0x140>
  8012b0:	39 0c 24             	cmp    %ecx,(%esp)
  8012b3:	0f 86 d7 00 00 00    	jbe    801390 <__umoddi3+0x140>
  8012b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012c1:	83 c4 1c             	add    $0x1c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    
  8012c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	85 ff                	test   %edi,%edi
  8012d2:	89 fd                	mov    %edi,%ebp
  8012d4:	75 0b                	jne    8012e1 <__umoddi3+0x91>
  8012d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	f7 f7                	div    %edi
  8012df:	89 c5                	mov    %eax,%ebp
  8012e1:	89 f0                	mov    %esi,%eax
  8012e3:	31 d2                	xor    %edx,%edx
  8012e5:	f7 f5                	div    %ebp
  8012e7:	89 c8                	mov    %ecx,%eax
  8012e9:	f7 f5                	div    %ebp
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	eb 99                	jmp    801288 <__umoddi3+0x38>
  8012ef:	90                   	nop
  8012f0:	89 c8                	mov    %ecx,%eax
  8012f2:	89 f2                	mov    %esi,%edx
  8012f4:	83 c4 1c             	add    $0x1c,%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	8b 34 24             	mov    (%esp),%esi
  801303:	bf 20 00 00 00       	mov    $0x20,%edi
  801308:	89 e9                	mov    %ebp,%ecx
  80130a:	29 ef                	sub    %ebp,%edi
  80130c:	d3 e0                	shl    %cl,%eax
  80130e:	89 f9                	mov    %edi,%ecx
  801310:	89 f2                	mov    %esi,%edx
  801312:	d3 ea                	shr    %cl,%edx
  801314:	89 e9                	mov    %ebp,%ecx
  801316:	09 c2                	or     %eax,%edx
  801318:	89 d8                	mov    %ebx,%eax
  80131a:	89 14 24             	mov    %edx,(%esp)
  80131d:	89 f2                	mov    %esi,%edx
  80131f:	d3 e2                	shl    %cl,%edx
  801321:	89 f9                	mov    %edi,%ecx
  801323:	89 54 24 04          	mov    %edx,0x4(%esp)
  801327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80132b:	d3 e8                	shr    %cl,%eax
  80132d:	89 e9                	mov    %ebp,%ecx
  80132f:	89 c6                	mov    %eax,%esi
  801331:	d3 e3                	shl    %cl,%ebx
  801333:	89 f9                	mov    %edi,%ecx
  801335:	89 d0                	mov    %edx,%eax
  801337:	d3 e8                	shr    %cl,%eax
  801339:	89 e9                	mov    %ebp,%ecx
  80133b:	09 d8                	or     %ebx,%eax
  80133d:	89 d3                	mov    %edx,%ebx
  80133f:	89 f2                	mov    %esi,%edx
  801341:	f7 34 24             	divl   (%esp)
  801344:	89 d6                	mov    %edx,%esi
  801346:	d3 e3                	shl    %cl,%ebx
  801348:	f7 64 24 04          	mull   0x4(%esp)
  80134c:	39 d6                	cmp    %edx,%esi
  80134e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801352:	89 d1                	mov    %edx,%ecx
  801354:	89 c3                	mov    %eax,%ebx
  801356:	72 08                	jb     801360 <__umoddi3+0x110>
  801358:	75 11                	jne    80136b <__umoddi3+0x11b>
  80135a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80135e:	73 0b                	jae    80136b <__umoddi3+0x11b>
  801360:	2b 44 24 04          	sub    0x4(%esp),%eax
  801364:	1b 14 24             	sbb    (%esp),%edx
  801367:	89 d1                	mov    %edx,%ecx
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80136f:	29 da                	sub    %ebx,%edx
  801371:	19 ce                	sbb    %ecx,%esi
  801373:	89 f9                	mov    %edi,%ecx
  801375:	89 f0                	mov    %esi,%eax
  801377:	d3 e0                	shl    %cl,%eax
  801379:	89 e9                	mov    %ebp,%ecx
  80137b:	d3 ea                	shr    %cl,%edx
  80137d:	89 e9                	mov    %ebp,%ecx
  80137f:	d3 ee                	shr    %cl,%esi
  801381:	09 d0                	or     %edx,%eax
  801383:	89 f2                	mov    %esi,%edx
  801385:	83 c4 1c             	add    $0x1c,%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5f                   	pop    %edi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    
  80138d:	8d 76 00             	lea    0x0(%esi),%esi
  801390:	29 f9                	sub    %edi,%ecx
  801392:	19 d6                	sbb    %edx,%esi
  801394:	89 74 24 04          	mov    %esi,0x4(%esp)
  801398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139c:	e9 18 ff ff ff       	jmp    8012b9 <__umoddi3+0x69>
