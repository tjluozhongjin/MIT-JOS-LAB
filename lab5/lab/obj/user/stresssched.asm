
obj/user/stresssched.debug:     file format elf32-i386


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
  800038:	e8 b2 0b 00 00       	call   800bef <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 cf 0e 00 00       	call   800f18 <fork>
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
  80005c:	e8 ad 0b 00 00       	call   800c0e <sys_yield>
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
  800085:	e8 84 0b 00 00       	call   800c0e <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 80 22 80 00       	push   $0x802280
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 a8 22 80 00       	push   $0x8022a8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 bb 22 80 00       	push   $0x8022bb
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
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
  8000f8:	e8 f2 0a 00 00       	call   800bef <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 a3 11 00 00       	call   8012e1 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 66 0a 00 00       	call   800bae <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 8f 0a 00 00       	call   800bef <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 e4 22 80 00       	push   $0x8022e4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 d7 22 80 00 	movl   $0x8022d7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 ae 09 00 00       	call   800b71 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 1a 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 53 09 00 00       	call   800b71 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 62 1d 00 00       	call   801ff0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 4f 1e 00 00       	call   802120 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 07 23 80 00 	movsbl 0x802307(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
}
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 42 04 00 00    	je     800781 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 d0             	movzbl %al,%edx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 d3 03 00 00    	ja     800766 <vprintfmt+0x443>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 3f                	ja     800402 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 2a                	jmp    800408 <vprintfmt+0xe5>
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	0f 49 d0             	cmovns %eax,%edx
  8003eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	eb 89                	jmp    80037c <vprintfmt+0x59>
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fd:	e9 7a ff ff ff       	jmp    80037c <vprintfmt+0x59>
  800402:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040c:	0f 89 6a ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  800412:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800418:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041f:	e9 58 ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042a:	e9 4d ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	ff 30                	pushl  (%eax)
  80043b:	ff d6                	call   *%esi
			break;
  80043d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800446:	e9 fe fe ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 78 04             	lea    0x4(%eax),%edi
  800451:	8b 00                	mov    (%eax),%eax
  800453:	99                   	cltd   
  800454:	31 d0                	xor    %edx,%eax
  800456:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800458:	83 f8 0f             	cmp    $0xf,%eax
  80045b:	7f 0b                	jg     800468 <vprintfmt+0x145>
  80045d:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	75 1b                	jne    800483 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800468:	50                   	push   %eax
  800469:	68 1f 23 80 00       	push   $0x80231f
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 91 fe ff ff       	call   800306 <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 c6 fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 a5 27 80 00       	push   $0x8027a5
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 76 fe ff ff       	call   800306 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800493:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 ab fe ff ff       	jmp    800349 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	83 c0 04             	add    $0x4,%eax
  8004a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 18 23 80 00       	mov    $0x802318,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x231>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 33 03 00 00       	call   800809 <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1cc>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x21f>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x21f>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x24b>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x24b>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x27c>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1fe>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1fe>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x284>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b4:	e9 90 fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 19                	jle    8005d7 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 08             	lea    0x8(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb 38                	jmp    80060f <vprintfmt+0x2ec>
	else if (lflag)
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	74 1b                	je     8005f6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	eb 19                	jmp    80060f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 c1                	mov    %eax,%ecx
  800600:	c1 f9 1f             	sar    $0x1f,%ecx
  800603:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800612:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	0f 89 0e 01 00 00    	jns    800732 <vprintfmt+0x40f>
				putch('-', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 2d                	push   $0x2d
  80062a:	ff d6                	call   *%esi
				num = -(long long) num;
  80062c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800632:	f7 da                	neg    %edx
  800634:	83 d1 00             	adc    $0x0,%ecx
  800637:	f7 d9                	neg    %ecx
  800639:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800641:	e9 ec 00 00 00       	jmp    800732 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800646:	83 f9 01             	cmp    $0x1,%ecx
  800649:	7e 18                	jle    800663 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8b 48 04             	mov    0x4(%eax),%ecx
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 cf 00 00 00       	jmp    800732 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 1a                	je     800681 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 b1 00 00 00       	jmp    800732 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	e9 97 00 00 00       	jmp    800732 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 58                	push   $0x58
  8006a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 58                	push   $0x58
  8006a9:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 58                	push   $0x58
  8006b1:	ff d6                	call   *%esi
			break;
  8006b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b9:	e9 8b fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 30                	push   $0x30
  8006c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c6:	83 c4 08             	add    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 78                	push   $0x78
  8006cc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e6:	eb 4a                	jmp    800732 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	7e 15                	jle    800702 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f5:	8d 40 08             	lea    0x8(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800700:	eb 30                	jmp    800732 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800702:	85 c9                	test   %ecx,%ecx
  800704:	74 17                	je     80071d <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	eb 15                	jmp    800732 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800732:	83 ec 0c             	sub    $0xc,%esp
  800735:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800739:	57                   	push   %edi
  80073a:	ff 75 e0             	pushl  -0x20(%ebp)
  80073d:	50                   	push   %eax
  80073e:	51                   	push   %ecx
  80073f:	52                   	push   %edx
  800740:	89 da                	mov    %ebx,%edx
  800742:	89 f0                	mov    %esi,%eax
  800744:	e8 f1 fa ff ff       	call   80023a <printnum>
			break;
  800749:	83 c4 20             	add    $0x20,%esp
  80074c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074f:	e9 f5 fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	52                   	push   %edx
  800759:	ff d6                	call   *%esi
			break;
  80075b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800761:	e9 e3 fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 25                	push   $0x25
  80076c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 03                	jmp    800776 <vprintfmt+0x453>
  800773:	83 ef 01             	sub    $0x1,%edi
  800776:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077a:	75 f7                	jne    800773 <vprintfmt+0x450>
  80077c:	e9 c8 fb ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5f                   	pop    %edi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800795:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800798:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 26                	je     8007d0 <vsnprintf+0x47>
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	7e 22                	jle    8007d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ae:	ff 75 14             	pushl  0x14(%ebp)
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b7:	50                   	push   %eax
  8007b8:	68 e9 02 80 00       	push   $0x8002e9
  8007bd:	e8 61 fb ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 05                	jmp    8007d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	ff 75 08             	pushl  0x8(%ebp)
  8007ea:	e8 9a ff ff ff       	call   800789 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 03                	jmp    800801 <strlen+0x10>
		n++;
  8007fe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800805:	75 f7                	jne    8007fe <strlen+0xd>
		n++;
	return n;
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800812:	ba 00 00 00 00       	mov    $0x0,%edx
  800817:	eb 03                	jmp    80081c <strnlen+0x13>
		n++;
  800819:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	39 c2                	cmp    %eax,%edx
  80081e:	74 08                	je     800828 <strnlen+0x1f>
  800820:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800824:	75 f3                	jne    800819 <strnlen+0x10>
  800826:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800840:	88 5a ff             	mov    %bl,-0x1(%edx)
  800843:	84 db                	test   %bl,%bl
  800845:	75 ef                	jne    800836 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	53                   	push   %ebx
  800852:	e8 9a ff ff ff       	call   8007f1 <strlen>
  800857:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	01 d8                	add    %ebx,%eax
  80085f:	50                   	push   %eax
  800860:	e8 c5 ff ff ff       	call   80082a <strcpy>
	return dst;
}
  800865:	89 d8                	mov    %ebx,%eax
  800867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	89 f3                	mov    %esi,%ebx
  800879:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 0f                	jmp    80088f <strncpy+0x23>
		*dst++ = *src;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	0f b6 01             	movzbl (%ecx),%eax
  800886:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 39 01             	cmpb   $0x1,(%ecx)
  80088c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088f:	39 da                	cmp    %ebx,%edx
  800891:	75 ed                	jne    800880 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800893:	89 f0                	mov    %esi,%eax
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	74 21                	je     8008ce <strlcpy+0x35>
  8008ad:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b1:	89 f2                	mov    %esi,%edx
  8008b3:	eb 09                	jmp    8008be <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b5:	83 c2 01             	add    $0x1,%edx
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008be:	39 c2                	cmp    %eax,%edx
  8008c0:	74 09                	je     8008cb <strlcpy+0x32>
  8008c2:	0f b6 19             	movzbl (%ecx),%ebx
  8008c5:	84 db                	test   %bl,%bl
  8008c7:	75 ec                	jne    8008b5 <strlcpy+0x1c>
  8008c9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ce:	29 f0                	sub    %esi,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dd:	eb 06                	jmp    8008e5 <strcmp+0x11>
		p++, q++;
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e5:	0f b6 01             	movzbl (%ecx),%eax
  8008e8:	84 c0                	test   %al,%al
  8008ea:	74 04                	je     8008f0 <strcmp+0x1c>
  8008ec:	3a 02                	cmp    (%edx),%al
  8008ee:	74 ef                	je     8008df <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 c0             	movzbl %al,%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	89 c3                	mov    %eax,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800909:	eb 06                	jmp    800911 <strncmp+0x17>
		n--, p++, q++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800911:	39 d8                	cmp    %ebx,%eax
  800913:	74 15                	je     80092a <strncmp+0x30>
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x26>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 eb                	je     80090b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
  800928:	eb 05                	jmp    80092f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	eb 07                	jmp    800945 <strchr+0x13>
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 0f                	je     800951 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f2                	jne    80093e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095d:	eb 03                	jmp    800962 <strfind+0xf>
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 04                	je     80096d <strfind+0x1a>
  800969:	84 d2                	test   %dl,%dl
  80096b:	75 f2                	jne    80095f <strfind+0xc>
			break;
	return (char *) s;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097b:	85 c9                	test   %ecx,%ecx
  80097d:	74 36                	je     8009b5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800985:	75 28                	jne    8009af <memset+0x40>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 23                	jne    8009af <memset+0x40>
		c &= 0xFF;
  80098c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800990:	89 d3                	mov    %edx,%ebx
  800992:	c1 e3 08             	shl    $0x8,%ebx
  800995:	89 d6                	mov    %edx,%esi
  800997:	c1 e6 18             	shl    $0x18,%esi
  80099a:	89 d0                	mov    %edx,%eax
  80099c:	c1 e0 10             	shl    $0x10,%eax
  80099f:	09 f0                	or     %esi,%eax
  8009a1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a3:	89 d8                	mov    %ebx,%eax
  8009a5:	09 d0                	or     %edx,%eax
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	fc                   	cld    
  8009ab:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ad:	eb 06                	jmp    8009b5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	fc                   	cld    
  8009b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ca:	39 c6                	cmp    %eax,%esi
  8009cc:	73 35                	jae    800a03 <memmove+0x47>
  8009ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d1:	39 d0                	cmp    %edx,%eax
  8009d3:	73 2e                	jae    800a03 <memmove+0x47>
		s += n;
		d += n;
  8009d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	09 fe                	or     %edi,%esi
  8009dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e2:	75 13                	jne    8009f7 <memmove+0x3b>
  8009e4:	f6 c1 03             	test   $0x3,%cl
  8009e7:	75 0e                	jne    8009f7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e9:	83 ef 04             	sub    $0x4,%edi
  8009ec:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
  8009f2:	fd                   	std    
  8009f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f5:	eb 09                	jmp    800a00 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f7:	83 ef 01             	sub    $0x1,%edi
  8009fa:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009fd:	fd                   	std    
  8009fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a00:	fc                   	cld    
  800a01:	eb 1d                	jmp    800a20 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a03:	89 f2                	mov    %esi,%edx
  800a05:	09 c2                	or     %eax,%edx
  800a07:	f6 c2 03             	test   $0x3,%dl
  800a0a:	75 0f                	jne    800a1b <memmove+0x5f>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0a                	jne    800a1b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 05                	jmp    800a20 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1b:	89 c7                	mov    %eax,%edi
  800a1d:	fc                   	cld    
  800a1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a27:	ff 75 10             	pushl  0x10(%ebp)
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	ff 75 08             	pushl  0x8(%ebp)
  800a30:	e8 87 ff ff ff       	call   8009bc <memmove>
}
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a42:	89 c6                	mov    %eax,%esi
  800a44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	eb 1a                	jmp    800a63 <memcmp+0x2c>
		if (*s1 != *s2)
  800a49:	0f b6 08             	movzbl (%eax),%ecx
  800a4c:	0f b6 1a             	movzbl (%edx),%ebx
  800a4f:	38 d9                	cmp    %bl,%cl
  800a51:	74 0a                	je     800a5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a53:	0f b6 c1             	movzbl %cl,%eax
  800a56:	0f b6 db             	movzbl %bl,%ebx
  800a59:	29 d8                	sub    %ebx,%eax
  800a5b:	eb 0f                	jmp    800a6c <memcmp+0x35>
		s1++, s2++;
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	39 f0                	cmp    %esi,%eax
  800a65:	75 e2                	jne    800a49 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a77:	89 c1                	mov    %eax,%ecx
  800a79:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a80:	eb 0a                	jmp    800a8c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	0f b6 10             	movzbl (%eax),%edx
  800a85:	39 da                	cmp    %ebx,%edx
  800a87:	74 07                	je     800a90 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	39 c8                	cmp    %ecx,%eax
  800a8e:	72 f2                	jb     800a82 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9f:	eb 03                	jmp    800aa4 <strtol+0x11>
		s++;
  800aa1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa4:	0f b6 01             	movzbl (%ecx),%eax
  800aa7:	3c 20                	cmp    $0x20,%al
  800aa9:	74 f6                	je     800aa1 <strtol+0xe>
  800aab:	3c 09                	cmp    $0x9,%al
  800aad:	74 f2                	je     800aa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aaf:	3c 2b                	cmp    $0x2b,%al
  800ab1:	75 0a                	jne    800abd <strtol+0x2a>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
  800abb:	eb 11                	jmp    800ace <strtol+0x3b>
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac2:	3c 2d                	cmp    $0x2d,%al
  800ac4:	75 08                	jne    800ace <strtol+0x3b>
		s++, neg = 1;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad4:	75 15                	jne    800aeb <strtol+0x58>
  800ad6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad9:	75 10                	jne    800aeb <strtol+0x58>
  800adb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800adf:	75 7c                	jne    800b5d <strtol+0xca>
		s += 2, base = 16;
  800ae1:	83 c1 02             	add    $0x2,%ecx
  800ae4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae9:	eb 16                	jmp    800b01 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	75 12                	jne    800b01 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	80 39 30             	cmpb   $0x30,(%ecx)
  800af7:	75 08                	jne    800b01 <strtol+0x6e>
		s++, base = 8;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b09:	0f b6 11             	movzbl (%ecx),%edx
  800b0c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0f:	89 f3                	mov    %esi,%ebx
  800b11:	80 fb 09             	cmp    $0x9,%bl
  800b14:	77 08                	ja     800b1e <strtol+0x8b>
			dig = *s - '0';
  800b16:	0f be d2             	movsbl %dl,%edx
  800b19:	83 ea 30             	sub    $0x30,%edx
  800b1c:	eb 22                	jmp    800b40 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b1e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b21:	89 f3                	mov    %esi,%ebx
  800b23:	80 fb 19             	cmp    $0x19,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b28:	0f be d2             	movsbl %dl,%edx
  800b2b:	83 ea 57             	sub    $0x57,%edx
  800b2e:	eb 10                	jmp    800b40 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b33:	89 f3                	mov    %esi,%ebx
  800b35:	80 fb 19             	cmp    $0x19,%bl
  800b38:	77 16                	ja     800b50 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3a:	0f be d2             	movsbl %dl,%edx
  800b3d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b40:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b43:	7d 0b                	jge    800b50 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b4e:	eb b9                	jmp    800b09 <strtol+0x76>

	if (endptr)
  800b50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b54:	74 0d                	je     800b63 <strtol+0xd0>
		*endptr = (char *) s;
  800b56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b59:	89 0e                	mov    %ecx,(%esi)
  800b5b:	eb 06                	jmp    800b63 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	74 98                	je     800af9 <strtol+0x66>
  800b61:	eb 9e                	jmp    800b01 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b63:	89 c2                	mov    %eax,%edx
  800b65:	f7 da                	neg    %edx
  800b67:	85 ff                	test   %edi,%edi
  800b69:	0f 45 c2             	cmovne %edx,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	89 c3                	mov    %eax,%ebx
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	89 c6                	mov    %eax,%esi
  800b88:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	89 cb                	mov    %ecx,%ebx
  800bc6:	89 cf                	mov    %ecx,%edi
  800bc8:	89 ce                	mov    %ecx,%esi
  800bca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 03                	push   $0x3
  800bd6:	68 ff 25 80 00       	push   $0x8025ff
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 1c 26 80 00       	push   $0x80261c
  800be2:	e8 66 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_yield>:

void
sys_yield(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	be 00 00 00 00       	mov    $0x0,%esi
  800c3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c49:	89 f7                	mov    %esi,%edi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 04                	push   $0x4
  800c57:	68 ff 25 80 00       	push   $0x8025ff
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 1c 26 80 00       	push   $0x80261c
  800c63:	e8 e5 f4 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 05                	push   $0x5
  800c99:	68 ff 25 80 00       	push   $0x8025ff
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 1c 26 80 00       	push   $0x80261c
  800ca5:	e8 a3 f4 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 06                	push   $0x6
  800cdb:	68 ff 25 80 00       	push   $0x8025ff
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 1c 26 80 00       	push   $0x80261c
  800ce7:	e8 61 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 08 00 00 00       	mov    $0x8,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 17                	jle    800d2e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 08                	push   $0x8
  800d1d:	68 ff 25 80 00       	push   $0x8025ff
  800d22:	6a 23                	push   $0x23
  800d24:	68 1c 26 80 00       	push   $0x80261c
  800d29:	e8 1f f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 17                	jle    800d70 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 09                	push   $0x9
  800d5f:	68 ff 25 80 00       	push   $0x8025ff
  800d64:	6a 23                	push   $0x23
  800d66:	68 1c 26 80 00       	push   $0x80261c
  800d6b:	e8 dd f3 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	89 df                	mov    %ebx,%edi
  800d93:	89 de                	mov    %ebx,%esi
  800d95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 17                	jle    800db2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	6a 0a                	push   $0xa
  800da1:	68 ff 25 80 00       	push   $0x8025ff
  800da6:	6a 23                	push   $0x23
  800da8:	68 1c 26 80 00       	push   $0x80261c
  800dad:	e8 9b f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	be 00 00 00 00       	mov    $0x0,%esi
  800dc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800deb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 cb                	mov    %ecx,%ebx
  800df5:	89 cf                	mov    %ecx,%edi
  800df7:	89 ce                	mov    %ecx,%esi
  800df9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 17                	jle    800e16 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	50                   	push   %eax
  800e03:	6a 0d                	push   $0xd
  800e05:	68 ff 25 80 00       	push   $0x8025ff
  800e0a:	6a 23                	push   $0x23
  800e0c:	68 1c 26 80 00       	push   $0x80261c
  800e11:	e8 37 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800e26:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e28:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2c:	74 11                	je     800e3f <pgfault+0x21>
  800e2e:	89 d8                	mov    %ebx,%eax
  800e30:	c1 e8 0c             	shr    $0xc,%eax
  800e33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e3a:	f6 c4 08             	test   $0x8,%ah
  800e3d:	75 14                	jne    800e53 <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800e3f:	83 ec 04             	sub    $0x4,%esp
  800e42:	68 2c 26 80 00       	push   $0x80262c
  800e47:	6a 1f                	push   $0x1f
  800e49:	68 8f 26 80 00       	push   $0x80268f
  800e4e:	e8 fa f2 ff ff       	call   80014d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800e53:	e8 97 fd ff ff       	call   800bef <sys_getenvid>
  800e58:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	6a 07                	push   $0x7
  800e5f:	68 00 f0 7f 00       	push   $0x7ff000
  800e64:	50                   	push   %eax
  800e65:	e8 c3 fd ff ff       	call   800c2d <sys_page_alloc>
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	79 12                	jns    800e83 <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800e71:	50                   	push   %eax
  800e72:	68 6c 26 80 00       	push   $0x80266c
  800e77:	6a 2c                	push   $0x2c
  800e79:	68 8f 26 80 00       	push   $0x80268f
  800e7e:	e8 ca f2 ff ff       	call   80014d <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e83:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	68 00 10 00 00       	push   $0x1000
  800e91:	53                   	push   %ebx
  800e92:	68 00 f0 7f 00       	push   $0x7ff000
  800e97:	e8 20 fb ff ff       	call   8009bc <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800e9c:	83 c4 08             	add    $0x8,%esp
  800e9f:	53                   	push   %ebx
  800ea0:	56                   	push   %esi
  800ea1:	e8 0c fe ff ff       	call   800cb2 <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 12                	jns    800ebf <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800ead:	50                   	push   %eax
  800eae:	68 9a 26 80 00       	push   $0x80269a
  800eb3:	6a 32                	push   $0x32
  800eb5:	68 8f 26 80 00       	push   $0x80268f
  800eba:	e8 8e f2 ff ff       	call   80014d <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	6a 07                	push   $0x7
  800ec4:	53                   	push   %ebx
  800ec5:	56                   	push   %esi
  800ec6:	68 00 f0 7f 00       	push   $0x7ff000
  800ecb:	56                   	push   %esi
  800ecc:	e8 9f fd ff ff       	call   800c70 <sys_page_map>
  800ed1:	83 c4 20             	add    $0x20,%esp
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	79 12                	jns    800eea <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800ed8:	50                   	push   %eax
  800ed9:	68 b8 26 80 00       	push   $0x8026b8
  800ede:	6a 35                	push   $0x35
  800ee0:	68 8f 26 80 00       	push   $0x80268f
  800ee5:	e8 63 f2 ff ff       	call   80014d <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800eea:	83 ec 08             	sub    $0x8,%esp
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	56                   	push   %esi
  800ef3:	e8 ba fd ff ff       	call   800cb2 <sys_page_unmap>
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 12                	jns    800f11 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800eff:	50                   	push   %eax
  800f00:	68 9a 26 80 00       	push   $0x80269a
  800f05:	6a 38                	push   $0x38
  800f07:	68 8f 26 80 00       	push   $0x80268f
  800f0c:	e8 3c f2 ff ff       	call   80014d <_panic>
	//panic("pgfault not implemented");
}
  800f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800f21:	68 1e 0e 80 00       	push   $0x800e1e
  800f26:	e8 db 0e 00 00       	call   801e06 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f2b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f30:	cd 30                	int    $0x30
  800f32:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	0f 88 38 01 00 00    	js     801078 <fork+0x160>
  800f40:	89 c7                	mov    %eax,%edi
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800f47:	85 c0                	test   %eax,%eax
  800f49:	75 21                	jne    800f6c <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f4b:	e8 9f fc ff ff       	call   800bef <sys_getenvid>
  800f50:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f55:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f5d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	e9 86 01 00 00       	jmp    8010f2 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f6c:	89 d8                	mov    %ebx,%eax
  800f6e:	c1 e8 16             	shr    $0x16,%eax
  800f71:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f78:	a8 01                	test   $0x1,%al
  800f7a:	0f 84 90 00 00 00    	je     801010 <fork+0xf8>
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	c1 e8 0c             	shr    $0xc,%eax
  800f85:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8c:	f6 c2 01             	test   $0x1,%dl
  800f8f:	74 7f                	je     801010 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f91:	89 c6                	mov    %eax,%esi
  800f93:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800f96:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9d:	f6 c6 04             	test   $0x4,%dh
  800fa0:	74 33                	je     800fd5 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb1:	50                   	push   %eax
  800fb2:	56                   	push   %esi
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 b4 fc ff ff       	call   800c70 <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	79 4d                	jns    801010 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  800fc3:	50                   	push   %eax
  800fc4:	68 d4 26 80 00       	push   $0x8026d4
  800fc9:	6a 54                	push   $0x54
  800fcb:	68 8f 26 80 00       	push   $0x80268f
  800fd0:	e8 78 f1 ff ff       	call   80014d <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800fd5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdc:	a9 02 08 00 00       	test   $0x802,%eax
  800fe1:	0f 85 c6 00 00 00    	jne    8010ad <fork+0x195>
  800fe7:	e9 e3 00 00 00       	jmp    8010cf <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800fec:	50                   	push   %eax
  800fed:	68 d4 26 80 00       	push   $0x8026d4
  800ff2:	6a 5d                	push   $0x5d
  800ff4:	68 8f 26 80 00       	push   $0x80268f
  800ff9:	e8 4f f1 ff ff       	call   80014d <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800ffe:	50                   	push   %eax
  800fff:	68 d4 26 80 00       	push   $0x8026d4
  801004:	6a 64                	push   $0x64
  801006:	68 8f 26 80 00       	push   $0x80268f
  80100b:	e8 3d f1 ff ff       	call   80014d <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  801010:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801016:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80101c:	0f 85 4a ff ff ff    	jne    800f6c <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	6a 07                	push   $0x7
  801027:	68 00 f0 bf ee       	push   $0xeebff000
  80102c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80102f:	57                   	push   %edi
  801030:	e8 f8 fb ff ff       	call   800c2d <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801035:	83 c4 10             	add    $0x10,%esp
		return ret;
  801038:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	0f 88 b0 00 00 00    	js     8010f2 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801042:	a1 08 40 80 00       	mov    0x804008,%eax
  801047:	8b 40 64             	mov    0x64(%eax),%eax
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	50                   	push   %eax
  80104e:	57                   	push   %edi
  80104f:	e8 24 fd ff ff       	call   800d78 <sys_env_set_pgfault_upcall>
  801054:	83 c4 10             	add    $0x10,%esp
		return ret;
  801057:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	0f 88 91 00 00 00    	js     8010f2 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	6a 02                	push   $0x2
  801066:	57                   	push   %edi
  801067:	e8 88 fc ff ff       	call   800cf4 <sys_env_set_status>
  80106c:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  80106f:	85 c0                	test   %eax,%eax
  801071:	89 fa                	mov    %edi,%edx
  801073:	0f 48 d0             	cmovs  %eax,%edx
  801076:	eb 7a                	jmp    8010f2 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801078:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80107b:	eb 75                	jmp    8010f2 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  80107d:	e8 6d fb ff ff       	call   800bef <sys_getenvid>
  801082:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801085:	e8 65 fb ff ff       	call   800bef <sys_getenvid>
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	68 05 08 00 00       	push   $0x805
  801092:	56                   	push   %esi
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	56                   	push   %esi
  801097:	50                   	push   %eax
  801098:	e8 d3 fb ff ff       	call   800c70 <sys_page_map>
  80109d:	83 c4 20             	add    $0x20,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	0f 89 68 ff ff ff    	jns    801010 <fork+0xf8>
  8010a8:	e9 51 ff ff ff       	jmp    800ffe <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  8010ad:	e8 3d fb ff ff       	call   800bef <sys_getenvid>
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	68 05 08 00 00       	push   $0x805
  8010ba:	56                   	push   %esi
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	50                   	push   %eax
  8010be:	e8 ad fb ff ff       	call   800c70 <sys_page_map>
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 b3                	jns    80107d <fork+0x165>
  8010ca:	e9 1d ff ff ff       	jmp    800fec <fork+0xd4>
  8010cf:	e8 1b fb ff ff       	call   800bef <sys_getenvid>
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	6a 05                	push   $0x5
  8010d9:	56                   	push   %esi
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	50                   	push   %eax
  8010dd:	e8 8e fb ff ff       	call   800c70 <sys_page_map>
  8010e2:	83 c4 20             	add    $0x20,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	0f 89 23 ff ff ff    	jns    801010 <fork+0xf8>
  8010ed:	e9 fa fe ff ff       	jmp    800fec <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8010f2:	89 d0                	mov    %edx,%eax
  8010f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sfork>:

// Challenge!
int
sfork(void)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801102:	68 e5 26 80 00       	push   $0x8026e5
  801107:	68 ac 00 00 00       	push   $0xac
  80110c:	68 8f 26 80 00       	push   $0x80268f
  801111:	e8 37 f0 ff ff       	call   80014d <_panic>

00801116 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801119:	8b 45 08             	mov    0x8(%ebp),%eax
  80111c:	05 00 00 00 30       	add    $0x30000000,%eax
  801121:	c1 e8 0c             	shr    $0xc,%eax
}
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	05 00 00 00 30       	add    $0x30000000,%eax
  801131:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801136:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801143:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801148:	89 c2                	mov    %eax,%edx
  80114a:	c1 ea 16             	shr    $0x16,%edx
  80114d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801154:	f6 c2 01             	test   $0x1,%dl
  801157:	74 11                	je     80116a <fd_alloc+0x2d>
  801159:	89 c2                	mov    %eax,%edx
  80115b:	c1 ea 0c             	shr    $0xc,%edx
  80115e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801165:	f6 c2 01             	test   $0x1,%dl
  801168:	75 09                	jne    801173 <fd_alloc+0x36>
			*fd_store = fd;
  80116a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116c:	b8 00 00 00 00       	mov    $0x0,%eax
  801171:	eb 17                	jmp    80118a <fd_alloc+0x4d>
  801173:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801178:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117d:	75 c9                	jne    801148 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801185:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801192:	83 f8 1f             	cmp    $0x1f,%eax
  801195:	77 36                	ja     8011cd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801197:	c1 e0 0c             	shl    $0xc,%eax
  80119a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	c1 ea 16             	shr    $0x16,%edx
  8011a4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ab:	f6 c2 01             	test   $0x1,%dl
  8011ae:	74 24                	je     8011d4 <fd_lookup+0x48>
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 0c             	shr    $0xc,%edx
  8011b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	74 1a                	je     8011db <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c4:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cb:	eb 13                	jmp    8011e0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d2:	eb 0c                	jmp    8011e0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d9:	eb 05                	jmp    8011e0 <fd_lookup+0x54>
  8011db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011eb:	ba 7c 27 80 00       	mov    $0x80277c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f0:	eb 13                	jmp    801205 <dev_lookup+0x23>
  8011f2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f5:	39 08                	cmp    %ecx,(%eax)
  8011f7:	75 0c                	jne    801205 <dev_lookup+0x23>
			*dev = devtab[i];
  8011f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801203:	eb 2e                	jmp    801233 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801205:	8b 02                	mov    (%edx),%eax
  801207:	85 c0                	test   %eax,%eax
  801209:	75 e7                	jne    8011f2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80120b:	a1 08 40 80 00       	mov    0x804008,%eax
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	51                   	push   %ecx
  801217:	50                   	push   %eax
  801218:	68 fc 26 80 00       	push   $0x8026fc
  80121d:	e8 04 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801222:	8b 45 0c             	mov    0xc(%ebp),%eax
  801225:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 10             	sub    $0x10,%esp
  80123d:	8b 75 08             	mov    0x8(%ebp),%esi
  801240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80124d:	c1 e8 0c             	shr    $0xc,%eax
  801250:	50                   	push   %eax
  801251:	e8 36 ff ff ff       	call   80118c <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 05                	js     801262 <fd_close+0x2d>
	    || fd != fd2)
  80125d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801260:	74 0c                	je     80126e <fd_close+0x39>
		return (must_exist ? r : 0);
  801262:	84 db                	test   %bl,%bl
  801264:	ba 00 00 00 00       	mov    $0x0,%edx
  801269:	0f 44 c2             	cmove  %edx,%eax
  80126c:	eb 41                	jmp    8012af <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	ff 36                	pushl  (%esi)
  801277:	e8 66 ff ff ff       	call   8011e2 <dev_lookup>
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 1a                	js     80129f <fd_close+0x6a>
		if (dev->dev_close)
  801285:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801288:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80128b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801290:	85 c0                	test   %eax,%eax
  801292:	74 0b                	je     80129f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801294:	83 ec 0c             	sub    $0xc,%esp
  801297:	56                   	push   %esi
  801298:	ff d0                	call   *%eax
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	56                   	push   %esi
  8012a3:	6a 00                	push   $0x0
  8012a5:	e8 08 fa ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	89 d8                	mov    %ebx,%eax
}
  8012af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b2:	5b                   	pop    %ebx
  8012b3:	5e                   	pop    %esi
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	ff 75 08             	pushl  0x8(%ebp)
  8012c3:	e8 c4 fe ff ff       	call   80118c <fd_lookup>
  8012c8:	83 c4 08             	add    $0x8,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 10                	js     8012df <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	6a 01                	push   $0x1
  8012d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d7:	e8 59 ff ff ff       	call   801235 <fd_close>
  8012dc:	83 c4 10             	add    $0x10,%esp
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <close_all>:

void
close_all(void)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	53                   	push   %ebx
  8012f1:	e8 c0 ff ff ff       	call   8012b6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f6:	83 c3 01             	add    $0x1,%ebx
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	83 fb 20             	cmp    $0x20,%ebx
  8012ff:	75 ec                	jne    8012ed <close_all+0xc>
		close(i);
}
  801301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	57                   	push   %edi
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
  80130c:	83 ec 2c             	sub    $0x2c,%esp
  80130f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801312:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	ff 75 08             	pushl  0x8(%ebp)
  801319:	e8 6e fe ff ff       	call   80118c <fd_lookup>
  80131e:	83 c4 08             	add    $0x8,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	0f 88 c1 00 00 00    	js     8013ea <dup+0xe4>
		return r;
	close(newfdnum);
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	56                   	push   %esi
  80132d:	e8 84 ff ff ff       	call   8012b6 <close>

	newfd = INDEX2FD(newfdnum);
  801332:	89 f3                	mov    %esi,%ebx
  801334:	c1 e3 0c             	shl    $0xc,%ebx
  801337:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80133d:	83 c4 04             	add    $0x4,%esp
  801340:	ff 75 e4             	pushl  -0x1c(%ebp)
  801343:	e8 de fd ff ff       	call   801126 <fd2data>
  801348:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80134a:	89 1c 24             	mov    %ebx,(%esp)
  80134d:	e8 d4 fd ff ff       	call   801126 <fd2data>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801358:	89 f8                	mov    %edi,%eax
  80135a:	c1 e8 16             	shr    $0x16,%eax
  80135d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801364:	a8 01                	test   $0x1,%al
  801366:	74 37                	je     80139f <dup+0x99>
  801368:	89 f8                	mov    %edi,%eax
  80136a:	c1 e8 0c             	shr    $0xc,%eax
  80136d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801374:	f6 c2 01             	test   $0x1,%dl
  801377:	74 26                	je     80139f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801379:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	25 07 0e 00 00       	and    $0xe07,%eax
  801388:	50                   	push   %eax
  801389:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138c:	6a 00                	push   $0x0
  80138e:	57                   	push   %edi
  80138f:	6a 00                	push   $0x0
  801391:	e8 da f8 ff ff       	call   800c70 <sys_page_map>
  801396:	89 c7                	mov    %eax,%edi
  801398:	83 c4 20             	add    $0x20,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 2e                	js     8013cd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a2:	89 d0                	mov    %edx,%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
  8013a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b6:	50                   	push   %eax
  8013b7:	53                   	push   %ebx
  8013b8:	6a 00                	push   $0x0
  8013ba:	52                   	push   %edx
  8013bb:	6a 00                	push   $0x0
  8013bd:	e8 ae f8 ff ff       	call   800c70 <sys_page_map>
  8013c2:	89 c7                	mov    %eax,%edi
  8013c4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013c7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c9:	85 ff                	test   %edi,%edi
  8013cb:	79 1d                	jns    8013ea <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 da f8 ff ff       	call   800cb2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d8:	83 c4 08             	add    $0x8,%esp
  8013db:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 cd f8 ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	89 f8                	mov    %edi,%eax
}
  8013ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5f                   	pop    %edi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	53                   	push   %ebx
  8013f6:	83 ec 14             	sub    $0x14,%esp
  8013f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	53                   	push   %ebx
  801401:	e8 86 fd ff ff       	call   80118c <fd_lookup>
  801406:	83 c4 08             	add    $0x8,%esp
  801409:	89 c2                	mov    %eax,%edx
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 6d                	js     80147c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801419:	ff 30                	pushl  (%eax)
  80141b:	e8 c2 fd ff ff       	call   8011e2 <dev_lookup>
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 4c                	js     801473 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801427:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80142a:	8b 42 08             	mov    0x8(%edx),%eax
  80142d:	83 e0 03             	and    $0x3,%eax
  801430:	83 f8 01             	cmp    $0x1,%eax
  801433:	75 21                	jne    801456 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801435:	a1 08 40 80 00       	mov    0x804008,%eax
  80143a:	8b 40 48             	mov    0x48(%eax),%eax
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	53                   	push   %ebx
  801441:	50                   	push   %eax
  801442:	68 40 27 80 00       	push   $0x802740
  801447:	e8 da ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801454:	eb 26                	jmp    80147c <read+0x8a>
	}
	if (!dev->dev_read)
  801456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801459:	8b 40 08             	mov    0x8(%eax),%eax
  80145c:	85 c0                	test   %eax,%eax
  80145e:	74 17                	je     801477 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	ff 75 10             	pushl  0x10(%ebp)
  801466:	ff 75 0c             	pushl  0xc(%ebp)
  801469:	52                   	push   %edx
  80146a:	ff d0                	call   *%eax
  80146c:	89 c2                	mov    %eax,%edx
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	eb 09                	jmp    80147c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801473:	89 c2                	mov    %eax,%edx
  801475:	eb 05                	jmp    80147c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801477:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80147c:	89 d0                	mov    %edx,%eax
  80147e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801481:	c9                   	leave  
  801482:	c3                   	ret    

00801483 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	57                   	push   %edi
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	83 ec 0c             	sub    $0xc,%esp
  80148c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801492:	bb 00 00 00 00       	mov    $0x0,%ebx
  801497:	eb 21                	jmp    8014ba <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	89 f0                	mov    %esi,%eax
  80149e:	29 d8                	sub    %ebx,%eax
  8014a0:	50                   	push   %eax
  8014a1:	89 d8                	mov    %ebx,%eax
  8014a3:	03 45 0c             	add    0xc(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	57                   	push   %edi
  8014a8:	e8 45 ff ff ff       	call   8013f2 <read>
		if (m < 0)
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 10                	js     8014c4 <readn+0x41>
			return m;
		if (m == 0)
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	74 0a                	je     8014c2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b8:	01 c3                	add    %eax,%ebx
  8014ba:	39 f3                	cmp    %esi,%ebx
  8014bc:	72 db                	jb     801499 <readn+0x16>
  8014be:	89 d8                	mov    %ebx,%eax
  8014c0:	eb 02                	jmp    8014c4 <readn+0x41>
  8014c2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5f                   	pop    %edi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  8014db:	e8 ac fc ff ff       	call   80118c <fd_lookup>
  8014e0:	83 c4 08             	add    $0x8,%esp
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 68                	js     801551 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f3:	ff 30                	pushl  (%eax)
  8014f5:	e8 e8 fc ff ff       	call   8011e2 <dev_lookup>
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 47                	js     801548 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801504:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801508:	75 21                	jne    80152b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150a:	a1 08 40 80 00       	mov    0x804008,%eax
  80150f:	8b 40 48             	mov    0x48(%eax),%eax
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	53                   	push   %ebx
  801516:	50                   	push   %eax
  801517:	68 5c 27 80 00       	push   $0x80275c
  80151c:	e8 05 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801529:	eb 26                	jmp    801551 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80152b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152e:	8b 52 0c             	mov    0xc(%edx),%edx
  801531:	85 d2                	test   %edx,%edx
  801533:	74 17                	je     80154c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	ff 75 10             	pushl  0x10(%ebp)
  80153b:	ff 75 0c             	pushl  0xc(%ebp)
  80153e:	50                   	push   %eax
  80153f:	ff d2                	call   *%edx
  801541:	89 c2                	mov    %eax,%edx
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	eb 09                	jmp    801551 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801548:	89 c2                	mov    %eax,%edx
  80154a:	eb 05                	jmp    801551 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80154c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801551:	89 d0                	mov    %edx,%eax
  801553:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <seek>:

int
seek(int fdnum, off_t offset)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	e8 22 fc ff ff       	call   80118c <fd_lookup>
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 0e                	js     80157f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801571:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801574:	8b 55 0c             	mov    0xc(%ebp),%edx
  801577:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80157a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
  801585:	83 ec 14             	sub    $0x14,%esp
  801588:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158e:	50                   	push   %eax
  80158f:	53                   	push   %ebx
  801590:	e8 f7 fb ff ff       	call   80118c <fd_lookup>
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	89 c2                	mov    %eax,%edx
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 65                	js     801603 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a8:	ff 30                	pushl  (%eax)
  8015aa:	e8 33 fc ff ff       	call   8011e2 <dev_lookup>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 44                	js     8015fa <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015bd:	75 21                	jne    8015e0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bf:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c4:	8b 40 48             	mov    0x48(%eax),%eax
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	50                   	push   %eax
  8015cc:	68 1c 27 80 00       	push   $0x80271c
  8015d1:	e8 50 ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015de:	eb 23                	jmp    801603 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e3:	8b 52 18             	mov    0x18(%edx),%edx
  8015e6:	85 d2                	test   %edx,%edx
  8015e8:	74 14                	je     8015fe <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	50                   	push   %eax
  8015f1:	ff d2                	call   *%edx
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	eb 09                	jmp    801603 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	eb 05                	jmp    801603 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801603:	89 d0                	mov    %edx,%eax
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 14             	sub    $0x14,%esp
  801611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	ff 75 08             	pushl  0x8(%ebp)
  80161b:	e8 6c fb ff ff       	call   80118c <fd_lookup>
  801620:	83 c4 08             	add    $0x8,%esp
  801623:	89 c2                	mov    %eax,%edx
  801625:	85 c0                	test   %eax,%eax
  801627:	78 58                	js     801681 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801633:	ff 30                	pushl  (%eax)
  801635:	e8 a8 fb ff ff       	call   8011e2 <dev_lookup>
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 37                	js     801678 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801641:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801644:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801648:	74 32                	je     80167c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80164a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80164d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801654:	00 00 00 
	stat->st_isdir = 0;
  801657:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165e:	00 00 00 
	stat->st_dev = dev;
  801661:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	53                   	push   %ebx
  80166b:	ff 75 f0             	pushl  -0x10(%ebp)
  80166e:	ff 50 14             	call   *0x14(%eax)
  801671:	89 c2                	mov    %eax,%edx
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	eb 09                	jmp    801681 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801678:	89 c2                	mov    %eax,%edx
  80167a:	eb 05                	jmp    801681 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80167c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801681:	89 d0                	mov    %edx,%eax
  801683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	6a 00                	push   $0x0
  801692:	ff 75 08             	pushl  0x8(%ebp)
  801695:	e8 e9 01 00 00       	call   801883 <open>
  80169a:	89 c3                	mov    %eax,%ebx
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 1b                	js     8016be <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	ff 75 0c             	pushl  0xc(%ebp)
  8016a9:	50                   	push   %eax
  8016aa:	e8 5b ff ff ff       	call   80160a <fstat>
  8016af:	89 c6                	mov    %eax,%esi
	close(fd);
  8016b1:	89 1c 24             	mov    %ebx,(%esp)
  8016b4:	e8 fd fb ff ff       	call   8012b6 <close>
	return r;
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	89 f0                	mov    %esi,%eax
}
  8016be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
  8016ca:	89 c6                	mov    %eax,%esi
  8016cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ce:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d5:	75 12                	jne    8016e9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	6a 01                	push   $0x1
  8016dc:	e8 95 08 00 00       	call   801f76 <ipc_find_env>
  8016e1:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e6:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e9:	6a 07                	push   $0x7
  8016eb:	68 00 50 80 00       	push   $0x805000
  8016f0:	56                   	push   %esi
  8016f1:	ff 35 00 40 80 00    	pushl  0x804000
  8016f7:	e8 26 08 00 00       	call   801f22 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8016fc:	83 c4 0c             	add    $0xc,%esp
  8016ff:	6a 00                	push   $0x0
  801701:	53                   	push   %ebx
  801702:	6a 00                	push   $0x0
  801704:	e8 97 07 00 00       	call   801ea0 <ipc_recv>
}
  801709:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	8b 40 0c             	mov    0xc(%eax),%eax
  80171c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801721:	8b 45 0c             	mov    0xc(%ebp),%eax
  801724:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	b8 02 00 00 00       	mov    $0x2,%eax
  801733:	e8 8d ff ff ff       	call   8016c5 <fsipc>
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801740:	8b 45 08             	mov    0x8(%ebp),%eax
  801743:	8b 40 0c             	mov    0xc(%eax),%eax
  801746:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 06 00 00 00       	mov    $0x6,%eax
  801755:	e8 6b ff ff ff       	call   8016c5 <fsipc>
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 04             	sub    $0x4,%esp
  801763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 40 0c             	mov    0xc(%eax),%eax
  80176c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 05 00 00 00       	mov    $0x5,%eax
  80177b:	e8 45 ff ff ff       	call   8016c5 <fsipc>
  801780:	85 c0                	test   %eax,%eax
  801782:	78 2c                	js     8017b0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801784:	83 ec 08             	sub    $0x8,%esp
  801787:	68 00 50 80 00       	push   $0x805000
  80178c:	53                   	push   %ebx
  80178d:	e8 98 f0 ff ff       	call   80082a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801792:	a1 80 50 80 00       	mov    0x805080,%eax
  801797:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179d:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 0c             	sub    $0xc,%esp
  8017bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8017be:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017c8:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d1:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8017d7:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8017dc:	50                   	push   %eax
  8017dd:	ff 75 0c             	pushl  0xc(%ebp)
  8017e0:	68 08 50 80 00       	push   $0x805008
  8017e5:	e8 d2 f1 ff ff       	call   8009bc <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f4:	e8 cc fe ff ff       	call   8016c5 <fsipc>
            return r;

    return r;
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 40 0c             	mov    0xc(%eax),%eax
  801809:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180e:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 03 00 00 00       	mov    $0x3,%eax
  80181e:	e8 a2 fe ff ff       	call   8016c5 <fsipc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 51                	js     80187a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801829:	39 c6                	cmp    %eax,%esi
  80182b:	73 19                	jae    801846 <devfile_read+0x4b>
  80182d:	68 8c 27 80 00       	push   $0x80278c
  801832:	68 93 27 80 00       	push   $0x802793
  801837:	68 82 00 00 00       	push   $0x82
  80183c:	68 a8 27 80 00       	push   $0x8027a8
  801841:	e8 07 e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801846:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80184b:	7e 19                	jle    801866 <devfile_read+0x6b>
  80184d:	68 b3 27 80 00       	push   $0x8027b3
  801852:	68 93 27 80 00       	push   $0x802793
  801857:	68 83 00 00 00       	push   $0x83
  80185c:	68 a8 27 80 00       	push   $0x8027a8
  801861:	e8 e7 e8 ff ff       	call   80014d <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	50                   	push   %eax
  80186a:	68 00 50 80 00       	push   $0x805000
  80186f:	ff 75 0c             	pushl  0xc(%ebp)
  801872:	e8 45 f1 ff ff       	call   8009bc <memmove>
	return r;
  801877:	83 c4 10             	add    $0x10,%esp
}
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	53                   	push   %ebx
  801887:	83 ec 20             	sub    $0x20,%esp
  80188a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80188d:	53                   	push   %ebx
  80188e:	e8 5e ef ff ff       	call   8007f1 <strlen>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80189b:	7f 67                	jg     801904 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a3:	50                   	push   %eax
  8018a4:	e8 94 f8 ff ff       	call   80113d <fd_alloc>
  8018a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ac:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 57                	js     801909 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	53                   	push   %ebx
  8018b6:	68 00 50 80 00       	push   $0x805000
  8018bb:	e8 6a ef ff ff       	call   80082a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d0:	e8 f0 fd ff ff       	call   8016c5 <fsipc>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	79 14                	jns    8018f2 <open+0x6f>
		fd_close(fd, 0);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	6a 00                	push   $0x0
  8018e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e6:	e8 4a f9 ff ff       	call   801235 <fd_close>
		return r;
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	89 da                	mov    %ebx,%edx
  8018f0:	eb 17                	jmp    801909 <open+0x86>
	}

	return fd2num(fd);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f8:	e8 19 f8 ff ff       	call   801116 <fd2num>
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	eb 05                	jmp    801909 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801904:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801909:	89 d0                	mov    %edx,%eax
  80190b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801916:	ba 00 00 00 00       	mov    $0x0,%edx
  80191b:	b8 08 00 00 00       	mov    $0x8,%eax
  801920:	e8 a0 fd ff ff       	call   8016c5 <fsipc>
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	ff 75 08             	pushl  0x8(%ebp)
  801935:	e8 ec f7 ff ff       	call   801126 <fd2data>
  80193a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80193c:	83 c4 08             	add    $0x8,%esp
  80193f:	68 bf 27 80 00       	push   $0x8027bf
  801944:	53                   	push   %ebx
  801945:	e8 e0 ee ff ff       	call   80082a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80194a:	8b 46 04             	mov    0x4(%esi),%eax
  80194d:	2b 06                	sub    (%esi),%eax
  80194f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801955:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80195c:	00 00 00 
	stat->st_dev = &devpipe;
  80195f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801966:	30 80 00 
	return 0;
}
  801969:	b8 00 00 00 00       	mov    $0x0,%eax
  80196e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801971:	5b                   	pop    %ebx
  801972:	5e                   	pop    %esi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	53                   	push   %ebx
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80197f:	53                   	push   %ebx
  801980:	6a 00                	push   $0x0
  801982:	e8 2b f3 ff ff       	call   800cb2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801987:	89 1c 24             	mov    %ebx,(%esp)
  80198a:	e8 97 f7 ff ff       	call   801126 <fd2data>
  80198f:	83 c4 08             	add    $0x8,%esp
  801992:	50                   	push   %eax
  801993:	6a 00                	push   $0x0
  801995:	e8 18 f3 ff ff       	call   800cb2 <sys_page_unmap>
}
  80199a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	57                   	push   %edi
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 1c             	sub    $0x1c,%esp
  8019a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ab:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8019b2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019b5:	83 ec 0c             	sub    $0xc,%esp
  8019b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8019bb:	e8 ef 05 00 00       	call   801faf <pageref>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	89 3c 24             	mov    %edi,(%esp)
  8019c5:	e8 e5 05 00 00       	call   801faf <pageref>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	39 c3                	cmp    %eax,%ebx
  8019cf:	0f 94 c1             	sete   %cl
  8019d2:	0f b6 c9             	movzbl %cl,%ecx
  8019d5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019d8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019de:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e1:	39 ce                	cmp    %ecx,%esi
  8019e3:	74 1b                	je     801a00 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019e5:	39 c3                	cmp    %eax,%ebx
  8019e7:	75 c4                	jne    8019ad <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019e9:	8b 42 58             	mov    0x58(%edx),%eax
  8019ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019ef:	50                   	push   %eax
  8019f0:	56                   	push   %esi
  8019f1:	68 c6 27 80 00       	push   $0x8027c6
  8019f6:	e8 2b e8 ff ff       	call   800226 <cprintf>
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	eb ad                	jmp    8019ad <_pipeisclosed+0xe>
	}
}
  801a00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5f                   	pop    %edi
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	57                   	push   %edi
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	83 ec 28             	sub    $0x28,%esp
  801a14:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a17:	56                   	push   %esi
  801a18:	e8 09 f7 ff ff       	call   801126 <fd2data>
  801a1d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	bf 00 00 00 00       	mov    $0x0,%edi
  801a27:	eb 4b                	jmp    801a74 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a29:	89 da                	mov    %ebx,%edx
  801a2b:	89 f0                	mov    %esi,%eax
  801a2d:	e8 6d ff ff ff       	call   80199f <_pipeisclosed>
  801a32:	85 c0                	test   %eax,%eax
  801a34:	75 48                	jne    801a7e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a36:	e8 d3 f1 ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a3b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3e:	8b 0b                	mov    (%ebx),%ecx
  801a40:	8d 51 20             	lea    0x20(%ecx),%edx
  801a43:	39 d0                	cmp    %edx,%eax
  801a45:	73 e2                	jae    801a29 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a4e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a51:	89 c2                	mov    %eax,%edx
  801a53:	c1 fa 1f             	sar    $0x1f,%edx
  801a56:	89 d1                	mov    %edx,%ecx
  801a58:	c1 e9 1b             	shr    $0x1b,%ecx
  801a5b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a5e:	83 e2 1f             	and    $0x1f,%edx
  801a61:	29 ca                	sub    %ecx,%edx
  801a63:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a67:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a6b:	83 c0 01             	add    $0x1,%eax
  801a6e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a71:	83 c7 01             	add    $0x1,%edi
  801a74:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a77:	75 c2                	jne    801a3b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a79:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7c:	eb 05                	jmp    801a83 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5f                   	pop    %edi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	57                   	push   %edi
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 18             	sub    $0x18,%esp
  801a94:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a97:	57                   	push   %edi
  801a98:	e8 89 f6 ff ff       	call   801126 <fd2data>
  801a9d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa7:	eb 3d                	jmp    801ae6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	74 04                	je     801ab1 <devpipe_read+0x26>
				return i;
  801aad:	89 d8                	mov    %ebx,%eax
  801aaf:	eb 44                	jmp    801af5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab1:	89 f2                	mov    %esi,%edx
  801ab3:	89 f8                	mov    %edi,%eax
  801ab5:	e8 e5 fe ff ff       	call   80199f <_pipeisclosed>
  801aba:	85 c0                	test   %eax,%eax
  801abc:	75 32                	jne    801af0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801abe:	e8 4b f1 ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac3:	8b 06                	mov    (%esi),%eax
  801ac5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ac8:	74 df                	je     801aa9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aca:	99                   	cltd   
  801acb:	c1 ea 1b             	shr    $0x1b,%edx
  801ace:	01 d0                	add    %edx,%eax
  801ad0:	83 e0 1f             	and    $0x1f,%eax
  801ad3:	29 d0                	sub    %edx,%eax
  801ad5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801add:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ae0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae3:	83 c3 01             	add    $0x1,%ebx
  801ae6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ae9:	75 d8                	jne    801ac3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aeb:	8b 45 10             	mov    0x10(%ebp),%eax
  801aee:	eb 05                	jmp    801af5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5f                   	pop    %edi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b08:	50                   	push   %eax
  801b09:	e8 2f f6 ff ff       	call   80113d <fd_alloc>
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	89 c2                	mov    %eax,%edx
  801b13:	85 c0                	test   %eax,%eax
  801b15:	0f 88 2c 01 00 00    	js     801c47 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	68 07 04 00 00       	push   $0x407
  801b23:	ff 75 f4             	pushl  -0xc(%ebp)
  801b26:	6a 00                	push   $0x0
  801b28:	e8 00 f1 ff ff       	call   800c2d <sys_page_alloc>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	89 c2                	mov    %eax,%edx
  801b32:	85 c0                	test   %eax,%eax
  801b34:	0f 88 0d 01 00 00    	js     801c47 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b40:	50                   	push   %eax
  801b41:	e8 f7 f5 ff ff       	call   80113d <fd_alloc>
  801b46:	89 c3                	mov    %eax,%ebx
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	0f 88 e2 00 00 00    	js     801c35 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	68 07 04 00 00       	push   $0x407
  801b5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 c8 f0 ff ff       	call   800c2d <sys_page_alloc>
  801b65:	89 c3                	mov    %eax,%ebx
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	0f 88 c3 00 00 00    	js     801c35 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 a9 f5 ff ff       	call   801126 <fd2data>
  801b7d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7f:	83 c4 0c             	add    $0xc,%esp
  801b82:	68 07 04 00 00       	push   $0x407
  801b87:	50                   	push   %eax
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 9e f0 ff ff       	call   800c2d <sys_page_alloc>
  801b8f:	89 c3                	mov    %eax,%ebx
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	85 c0                	test   %eax,%eax
  801b96:	0f 88 89 00 00 00    	js     801c25 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba2:	e8 7f f5 ff ff       	call   801126 <fd2data>
  801ba7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bae:	50                   	push   %eax
  801baf:	6a 00                	push   $0x0
  801bb1:	56                   	push   %esi
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 b7 f0 ff ff       	call   800c70 <sys_page_map>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	83 c4 20             	add    $0x20,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 55                	js     801c17 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bc2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bd7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf2:	e8 1f f5 ff ff       	call   801116 <fd2num>
  801bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bfc:	83 c4 04             	add    $0x4,%esp
  801bff:	ff 75 f0             	pushl  -0x10(%ebp)
  801c02:	e8 0f f5 ff ff       	call   801116 <fd2num>
  801c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	ba 00 00 00 00       	mov    $0x0,%edx
  801c15:	eb 30                	jmp    801c47 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c17:	83 ec 08             	sub    $0x8,%esp
  801c1a:	56                   	push   %esi
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 90 f0 ff ff       	call   800cb2 <sys_page_unmap>
  801c22:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c25:	83 ec 08             	sub    $0x8,%esp
  801c28:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 80 f0 ff ff       	call   800cb2 <sys_page_unmap>
  801c32:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 70 f0 ff ff       	call   800cb2 <sys_page_unmap>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c47:	89 d0                	mov    %edx,%eax
  801c49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4c:	5b                   	pop    %ebx
  801c4d:	5e                   	pop    %esi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c59:	50                   	push   %eax
  801c5a:	ff 75 08             	pushl  0x8(%ebp)
  801c5d:	e8 2a f5 ff ff       	call   80118c <fd_lookup>
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 18                	js     801c81 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6f:	e8 b2 f4 ff ff       	call   801126 <fd2data>
	return _pipeisclosed(fd, p);
  801c74:	89 c2                	mov    %eax,%edx
  801c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c79:	e8 21 fd ff ff       	call   80199f <_pipeisclosed>
  801c7e:	83 c4 10             	add    $0x10,%esp
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    

00801c8d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c93:	68 de 27 80 00       	push   $0x8027de
  801c98:	ff 75 0c             	pushl  0xc(%ebp)
  801c9b:	e8 8a eb ff ff       	call   80082a <strcpy>
	return 0;
}
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	57                   	push   %edi
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cb8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cbe:	eb 2d                	jmp    801ced <devcons_write+0x46>
		m = n - tot;
  801cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cc3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cc5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cc8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ccd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd0:	83 ec 04             	sub    $0x4,%esp
  801cd3:	53                   	push   %ebx
  801cd4:	03 45 0c             	add    0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	57                   	push   %edi
  801cd9:	e8 de ec ff ff       	call   8009bc <memmove>
		sys_cputs(buf, m);
  801cde:	83 c4 08             	add    $0x8,%esp
  801ce1:	53                   	push   %ebx
  801ce2:	57                   	push   %edi
  801ce3:	e8 89 ee ff ff       	call   800b71 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce8:	01 de                	add    %ebx,%esi
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	89 f0                	mov    %esi,%eax
  801cef:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf2:	72 cc                	jb     801cc0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0b:	74 2a                	je     801d37 <devcons_read+0x3b>
  801d0d:	eb 05                	jmp    801d14 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d0f:	e8 fa ee ff ff       	call   800c0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d14:	e8 76 ee ff ff       	call   800b8f <sys_cgetc>
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	74 f2                	je     801d0f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 16                	js     801d37 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d21:	83 f8 04             	cmp    $0x4,%eax
  801d24:	74 0c                	je     801d32 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d29:	88 02                	mov    %al,(%edx)
	return 1;
  801d2b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d30:	eb 05                	jmp    801d37 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d45:	6a 01                	push   $0x1
  801d47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	e8 21 ee ff ff       	call   800b71 <sys_cputs>
}
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <getchar>:

int
getchar(void)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d5b:	6a 01                	push   $0x1
  801d5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	6a 00                	push   $0x0
  801d63:	e8 8a f6 ff ff       	call   8013f2 <read>
	if (r < 0)
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 0f                	js     801d7e <getchar+0x29>
		return r;
	if (r < 1)
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	7e 06                	jle    801d79 <getchar+0x24>
		return -E_EOF;
	return c;
  801d73:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d77:	eb 05                	jmp    801d7e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d79:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	ff 75 08             	pushl  0x8(%ebp)
  801d8d:	e8 fa f3 ff ff       	call   80118c <fd_lookup>
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 11                	js     801daa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da2:	39 10                	cmp    %edx,(%eax)
  801da4:	0f 94 c0             	sete   %al
  801da7:	0f b6 c0             	movzbl %al,%eax
}
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <opencons>:

int
opencons(void)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	e8 82 f3 ff ff       	call   80113d <fd_alloc>
  801dbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbe:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 3e                	js     801e02 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	68 07 04 00 00       	push   $0x407
  801dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 57 ee ff ff       	call   800c2d <sys_page_alloc>
  801dd6:	83 c4 10             	add    $0x10,%esp
		return r;
  801dd9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 23                	js     801e02 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ddf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	50                   	push   %eax
  801df8:	e8 19 f3 ff ff       	call   801116 <fd2num>
  801dfd:	89 c2                	mov    %eax,%edx
  801dff:	83 c4 10             	add    $0x10,%esp
}
  801e02:	89 d0                	mov    %edx,%eax
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	53                   	push   %ebx
  801e0a:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801e0d:	e8 dd ed ff ff       	call   800bef <sys_getenvid>
  801e12:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801e14:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e1b:	75 29                	jne    801e46 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801e1d:	83 ec 04             	sub    $0x4,%esp
  801e20:	6a 07                	push   $0x7
  801e22:	68 00 f0 bf ee       	push   $0xeebff000
  801e27:	50                   	push   %eax
  801e28:	e8 00 ee ff ff       	call   800c2d <sys_page_alloc>
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	79 12                	jns    801e46 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801e34:	50                   	push   %eax
  801e35:	68 ea 27 80 00       	push   $0x8027ea
  801e3a:	6a 24                	push   $0x24
  801e3c:	68 03 28 80 00       	push   $0x802803
  801e41:	e8 07 e3 ff ff       	call   80014d <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801e46:	8b 45 08             	mov    0x8(%ebp),%eax
  801e49:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801e4e:	83 ec 08             	sub    $0x8,%esp
  801e51:	68 7a 1e 80 00       	push   $0x801e7a
  801e56:	53                   	push   %ebx
  801e57:	e8 1c ef ff ff       	call   800d78 <sys_env_set_pgfault_upcall>
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	79 12                	jns    801e75 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801e63:	50                   	push   %eax
  801e64:	68 ea 27 80 00       	push   $0x8027ea
  801e69:	6a 2e                	push   $0x2e
  801e6b:	68 03 28 80 00       	push   $0x802803
  801e70:	e8 d8 e2 ff ff       	call   80014d <_panic>
}
  801e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e7a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e7b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e80:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e82:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801e85:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801e89:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801e8c:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801e90:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801e92:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801e96:	83 c4 08             	add    $0x8,%esp
	popal
  801e99:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e9a:	83 c4 04             	add    $0x4,%esp
	popfl
  801e9d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801e9e:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e9f:	c3                   	ret    

00801ea0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	57                   	push   %edi
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	8b 75 08             	mov    0x8(%ebp),%esi
  801eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801eb2:	85 f6                	test   %esi,%esi
  801eb4:	74 06                	je     801ebc <ipc_recv+0x1c>
		*from_env_store = 0;
  801eb6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801ebc:	85 db                	test   %ebx,%ebx
  801ebe:	74 06                	je     801ec6 <ipc_recv+0x26>
		*perm_store = 0;
  801ec0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801ec6:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801ec8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ecd:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	50                   	push   %eax
  801ed4:	e8 04 ef ff ff       	call   800ddd <sys_ipc_recv>
  801ed9:	89 c7                	mov    %eax,%edi
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	79 14                	jns    801ef6 <ipc_recv+0x56>
		cprintf("im dead");
  801ee2:	83 ec 0c             	sub    $0xc,%esp
  801ee5:	68 11 28 80 00       	push   $0x802811
  801eea:	e8 37 e3 ff ff       	call   800226 <cprintf>
		return r;
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	89 f8                	mov    %edi,%eax
  801ef4:	eb 24                	jmp    801f1a <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ef6:	85 f6                	test   %esi,%esi
  801ef8:	74 0a                	je     801f04 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801efa:	a1 08 40 80 00       	mov    0x804008,%eax
  801eff:	8b 40 74             	mov    0x74(%eax),%eax
  801f02:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801f04:	85 db                	test   %ebx,%ebx
  801f06:	74 0a                	je     801f12 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801f08:	a1 08 40 80 00       	mov    0x804008,%eax
  801f0d:	8b 40 78             	mov    0x78(%eax),%eax
  801f10:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801f12:	a1 08 40 80 00       	mov    0x804008,%eax
  801f17:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	57                   	push   %edi
  801f26:	56                   	push   %esi
  801f27:	53                   	push   %ebx
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801f34:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801f36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f3b:	0f 44 d8             	cmove  %eax,%ebx
  801f3e:	eb 1c                	jmp    801f5c <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801f40:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f43:	74 12                	je     801f57 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801f45:	50                   	push   %eax
  801f46:	68 19 28 80 00       	push   $0x802819
  801f4b:	6a 4e                	push   $0x4e
  801f4d:	68 26 28 80 00       	push   $0x802826
  801f52:	e8 f6 e1 ff ff       	call   80014d <_panic>
		sys_yield();
  801f57:	e8 b2 ec ff ff       	call   800c0e <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f5c:	ff 75 14             	pushl  0x14(%ebp)
  801f5f:	53                   	push   %ebx
  801f60:	56                   	push   %esi
  801f61:	57                   	push   %edi
  801f62:	e8 53 ee ff ff       	call   800dba <sys_ipc_try_send>
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 d2                	js     801f40 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5e                   	pop    %esi
  801f73:	5f                   	pop    %edi
  801f74:	5d                   	pop    %ebp
  801f75:	c3                   	ret    

00801f76 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f81:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f84:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8a:	8b 52 50             	mov    0x50(%edx),%edx
  801f8d:	39 ca                	cmp    %ecx,%edx
  801f8f:	75 0d                	jne    801f9e <ipc_find_env+0x28>
			return envs[i].env_id;
  801f91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f99:	8b 40 48             	mov    0x48(%eax),%eax
  801f9c:	eb 0f                	jmp    801fad <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9e:	83 c0 01             	add    $0x1,%eax
  801fa1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa6:	75 d9                	jne    801f81 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	c1 e8 16             	shr    $0x16,%eax
  801fba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc6:	f6 c1 01             	test   $0x1,%cl
  801fc9:	74 1d                	je     801fe8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fcb:	c1 ea 0c             	shr    $0xc,%edx
  801fce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd5:	f6 c2 01             	test   $0x1,%dl
  801fd8:	74 0e                	je     801fe8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fda:	c1 ea 0c             	shr    $0xc,%edx
  801fdd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe4:	ef 
  801fe5:	0f b7 c0             	movzwl %ax,%eax
}
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
