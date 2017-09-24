
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 1f 80 00       	push   $0x801f60
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ac 0b 00 00       	call   800c0a <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 1f 80 00       	push   $0x801f80
  80006f:	6a 0e                	push   $0xe
  800071:	68 6a 1f 80 00       	push   $0x801f6a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 1f 80 00       	push   $0x801fac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 2b 07 00 00       	call   8007b4 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 5a 0d 00 00       	call   800dfb <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 1f 80 00       	push   $0x801f7c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 1f 80 00       	push   $0x801f7c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 f2 0a 00 00       	call   800bcc <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 45 0f 00 00       	call   801060 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 66 0a 00 00       	call   800b8b <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 8f 0a 00 00       	call   800bcc <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 d8 1f 80 00       	push   $0x801fd8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 2f 24 80 00 	movl   $0x80242f,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 ae 09 00 00       	call   800b4e <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 1a 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 53 09 00 00       	call   800b4e <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 65 1a 00 00       	call   801cd0 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 52 1b 00 00       	call   801e00 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 fb 1f 80 00 	movsbl 0x801ffb(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	ff 75 0c             	pushl  0xc(%ebp)
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
	va_end(ap);
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 2c             	sub    $0x2c,%esp
  800309:	8b 75 08             	mov    0x8(%ebp),%esi
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 12                	jmp    800326 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800314:	85 c0                	test   %eax,%eax
  800316:	0f 84 42 04 00 00    	je     80075e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	53                   	push   %ebx
  800320:	50                   	push   %eax
  800321:	ff d6                	call   *%esi
  800323:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800326:	83 c7 01             	add    $0x1,%edi
  800329:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e2                	jne    800314 <vprintfmt+0x14>
  800332:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800336:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	eb 07                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8d 47 01             	lea    0x1(%edi),%eax
  80035c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035f:	0f b6 07             	movzbl (%edi),%eax
  800362:	0f b6 d0             	movzbl %al,%edx
  800365:	83 e8 23             	sub    $0x23,%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 d3 03 00 00    	ja     800743 <vprintfmt+0x443>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800381:	eb d6                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800391:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 3f                	ja     8003df <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a3:	eb e9                	jmp    80038e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 40 04             	lea    0x4(%eax),%eax
  8003b3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 2a                	jmp    8003e5 <vprintfmt+0xe5>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	0f 49 d0             	cmovns %eax,%edx
  8003c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 89                	jmp    800359 <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	e9 7a ff ff ff       	jmp    800359 <vprintfmt+0x59>
  8003df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 6a ff ff ff    	jns    800359 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 58 ff ff ff       	jmp    800359 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 4d ff ff ff       	jmp    800359 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 fe fe ff ff       	jmp    800326 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x145>
  80043a:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 1b                	jne    800460 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 13 20 80 00       	push   $0x802013
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 91 fe ff ff       	call   8002e3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 c6 fe ff ff       	jmp    800326 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 fd 23 80 00       	push   $0x8023fd
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 76 fe ff ff       	call   8002e3 <printfmt>
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
  800476:	e9 ab fe ff ff       	jmp    800326 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	83 c0 04             	add    $0x4,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x231>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 33 03 00 00       	call   8007e6 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1cc>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x21f>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x21f>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x24b>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x24b>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x27c>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1fe>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1fe>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x284>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800588:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	e9 90 fd ff ff       	jmp    800326 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800596:	83 f9 01             	cmp    $0x1,%ecx
  800599:	7e 19                	jle    8005b4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b2:	eb 38                	jmp    8005ec <vprintfmt+0x2ec>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 1b                	je     8005d3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	eb 19                	jmp    8005ec <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fb:	0f 89 0e 01 00 00    	jns    80070f <vprintfmt+0x40f>
				putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 2d                	push   $0x2d
  800607:	ff d6                	call   *%esi
				num = -(long long) num;
  800609:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060f:	f7 da                	neg    %edx
  800611:	83 d1 00             	adc    $0x0,%ecx
  800614:	f7 d9                	neg    %ecx
  800616:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 ec 00 00 00       	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 18                	jle    800640 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 cf 00 00 00       	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 1a                	je     80065e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	e9 b1 00 00 00       	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800673:	e9 97 00 00 00       	jmp    80070f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 58                	push   $0x58
  80067e:	ff d6                	call   *%esi
			putch('X', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 58                	push   $0x58
  800686:	ff d6                	call   *%esi
			putch('X', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 58                	push   $0x58
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800696:	e9 8b fc ff ff       	jmp    800326 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 4a                	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c5:	83 f9 01             	cmp    $0x1,%ecx
  8006c8:	7e 15                	jle    8006df <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d2:	8d 40 08             	lea    0x8(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006dd:	eb 30                	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	74 17                	je     8006fa <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	eb 15                	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070f:	83 ec 0c             	sub    $0xc,%esp
  800712:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800716:	57                   	push   %edi
  800717:	ff 75 e0             	pushl  -0x20(%ebp)
  80071a:	50                   	push   %eax
  80071b:	51                   	push   %ecx
  80071c:	52                   	push   %edx
  80071d:	89 da                	mov    %ebx,%edx
  80071f:	89 f0                	mov    %esi,%eax
  800721:	e8 f1 fa ff ff       	call   800217 <printnum>
			break;
  800726:	83 c4 20             	add    $0x20,%esp
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072c:	e9 f5 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	52                   	push   %edx
  800736:	ff d6                	call   *%esi
			break;
  800738:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073e:	e9 e3 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 25                	push   $0x25
  800749:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	eb 03                	jmp    800753 <vprintfmt+0x453>
  800750:	83 ef 01             	sub    $0x1,%edi
  800753:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800757:	75 f7                	jne    800750 <vprintfmt+0x450>
  800759:	e9 c8 fb ff ff       	jmp    800326 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 26                	je     8007ad <vsnprintf+0x47>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 22                	jle    8007ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	pushl  0x14(%ebp)
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	68 c6 02 80 00       	push   $0x8002c6
  80079a:	e8 61 fb ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 05                	jmp    8007b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 9a ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 03                	jmp    8007de <strlen+0x10>
		n++;
  8007db:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f7                	jne    8007db <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f4:	eb 03                	jmp    8007f9 <strnlen+0x13>
		n++;
  8007f6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	39 c2                	cmp    %eax,%edx
  8007fb:	74 08                	je     800805 <strnlen+0x1f>
  8007fd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800801:	75 f3                	jne    8007f6 <strnlen+0x10>
  800803:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 9a ff ff ff       	call   8007ce <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	01 d8                	add    %ebx,%eax
  80083c:	50                   	push   %eax
  80083d:	e8 c5 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	89 f3                	mov    %esi,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	89 f2                	mov    %esi,%edx
  80085b:	eb 0f                	jmp    80086c <strncpy+0x23>
		*dst++ = *src;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 39 01             	cmpb   $0x1,(%ecx)
  800869:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	39 da                	cmp    %ebx,%edx
  80086e:	75 ed                	jne    80085d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
  800884:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	74 21                	je     8008ab <strlcpy+0x35>
  80088a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088e:	89 f2                	mov    %esi,%edx
  800890:	eb 09                	jmp    80089b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089b:	39 c2                	cmp    %eax,%edx
  80089d:	74 09                	je     8008a8 <strlcpy+0x32>
  80089f:	0f b6 19             	movzbl (%ecx),%ebx
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 ec                	jne    800892 <strlcpy+0x1c>
  8008a6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ab:	29 f0                	sub    %esi,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ba:	eb 06                	jmp    8008c2 <strcmp+0x11>
		p++, q++;
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x1c>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 ef                	je     8008bc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e6:	eb 06                	jmp    8008ee <strncmp+0x17>
		n--, p++, q++;
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ee:	39 d8                	cmp    %ebx,%eax
  8008f0:	74 15                	je     800907 <strncmp+0x30>
  8008f2:	0f b6 08             	movzbl (%eax),%ecx
  8008f5:	84 c9                	test   %cl,%cl
  8008f7:	74 04                	je     8008fd <strncmp+0x26>
  8008f9:	3a 0a                	cmp    (%edx),%cl
  8008fb:	74 eb                	je     8008e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 00             	movzbl (%eax),%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
  800905:	eb 05                	jmp    80090c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800919:	eb 07                	jmp    800922 <strchr+0x13>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 0f                	je     80092e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f2                	jne    80091b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093a:	eb 03                	jmp    80093f <strfind+0xf>
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 04                	je     80094a <strfind+0x1a>
  800946:	84 d2                	test   %dl,%dl
  800948:	75 f2                	jne    80093c <strfind+0xc>
			break;
	return (char *) s;
}
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 36                	je     800992 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800962:	75 28                	jne    80098c <memset+0x40>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 23                	jne    80098c <memset+0x40>
		c &= 0xFF;
  800969:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800980:	89 d8                	mov    %ebx,%eax
  800982:	09 d0                	or     %edx,%eax
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	fc                   	cld    
  800988:	f3 ab                	rep stos %eax,%es:(%edi)
  80098a:	eb 06                	jmp    800992 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	fc                   	cld    
  800990:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800992:	89 f8                	mov    %edi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a7:	39 c6                	cmp    %eax,%esi
  8009a9:	73 35                	jae    8009e0 <memmove+0x47>
  8009ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	73 2e                	jae    8009e0 <memmove+0x47>
		s += n;
		d += n;
  8009b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	09 fe                	or     %edi,%esi
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x3b>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 09                	jmp    8009dd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	83 ef 01             	sub    $0x1,%edi
  8009d7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009da:	fd                   	std    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009dd:	fc                   	cld    
  8009de:	eb 1d                	jmp    8009fd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	89 f2                	mov    %esi,%edx
  8009e2:	09 c2                	or     %eax,%edx
  8009e4:	f6 c2 03             	test   $0x3,%dl
  8009e7:	75 0f                	jne    8009f8 <memmove+0x5f>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	ff 75 08             	pushl  0x8(%ebp)
  800a0d:	e8 87 ff ff ff       	call   800999 <memmove>
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	89 c6                	mov    %eax,%esi
  800a21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	eb 1a                	jmp    800a40 <memcmp+0x2c>
		if (*s1 != *s2)
  800a26:	0f b6 08             	movzbl (%eax),%ecx
  800a29:	0f b6 1a             	movzbl (%edx),%ebx
  800a2c:	38 d9                	cmp    %bl,%cl
  800a2e:	74 0a                	je     800a3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a30:	0f b6 c1             	movzbl %cl,%eax
  800a33:	0f b6 db             	movzbl %bl,%ebx
  800a36:	29 d8                	sub    %ebx,%eax
  800a38:	eb 0f                	jmp    800a49 <memcmp+0x35>
		s1++, s2++;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	39 f0                	cmp    %esi,%eax
  800a42:	75 e2                	jne    800a26 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	53                   	push   %ebx
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a54:	89 c1                	mov    %eax,%ecx
  800a56:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	eb 0a                	jmp    800a69 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5f:	0f b6 10             	movzbl (%eax),%edx
  800a62:	39 da                	cmp    %ebx,%edx
  800a64:	74 07                	je     800a6d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	39 c8                	cmp    %ecx,%eax
  800a6b:	72 f2                	jb     800a5f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 03                	jmp    800a81 <strtol+0x11>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 01             	movzbl (%ecx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0xe>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	75 0a                	jne    800a9a <strtol+0x2a>
		s++;
  800a90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb 11                	jmp    800aab <strtol+0x3b>
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 08                	jne    800aab <strtol+0x3b>
		s++, neg = 1;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab1:	75 15                	jne    800ac8 <strtol+0x58>
  800ab3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab6:	75 10                	jne    800ac8 <strtol+0x58>
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	75 7c                	jne    800b3a <strtol+0xca>
		s += 2, base = 16;
  800abe:	83 c1 02             	add    $0x2,%ecx
  800ac1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac6:	eb 16                	jmp    800ade <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	75 12                	jne    800ade <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad4:	75 08                	jne    800ade <strtol+0x6e>
		s++, base = 8;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae6:	0f b6 11             	movzbl (%ecx),%edx
  800ae9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 09             	cmp    $0x9,%bl
  800af1:	77 08                	ja     800afb <strtol+0x8b>
			dig = *s - '0';
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 30             	sub    $0x30,%edx
  800af9:	eb 22                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800afb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 08                	ja     800b0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 57             	sub    $0x57,%edx
  800b0b:	eb 10                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 16                	ja     800b2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b20:	7d 0b                	jge    800b2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b2b:	eb b9                	jmp    800ae6 <strtol+0x76>

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 0d                	je     800b40 <strtol+0xd0>
		*endptr = (char *) s;
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	89 0e                	mov    %ecx,(%esi)
  800b38:	eb 06                	jmp    800b40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	74 98                	je     800ad6 <strtol+0x66>
  800b3e:	eb 9e                	jmp    800ade <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b40:	89 c2                	mov    %eax,%edx
  800b42:	f7 da                	neg    %edx
  800b44:	85 ff                	test   %edi,%edi
  800b46:	0f 45 c2             	cmovne %edx,%eax
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	89 c3                	mov    %eax,%ebx
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b99:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 cb                	mov    %ecx,%ebx
  800ba3:	89 cf                	mov    %ecx,%edi
  800ba5:	89 ce                	mov    %ecx,%esi
  800ba7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 17                	jle    800bc4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 03                	push   $0x3
  800bb3:	68 ff 22 80 00       	push   $0x8022ff
  800bb8:	6a 23                	push   $0x23
  800bba:	68 1c 23 80 00       	push   $0x80231c
  800bbf:	e8 66 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_yield>:

void
sys_yield(void)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfb:	89 d1                	mov    %edx,%ecx
  800bfd:	89 d3                	mov    %edx,%ebx
  800bff:	89 d7                	mov    %edx,%edi
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	be 00 00 00 00       	mov    $0x0,%esi
  800c18:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c26:	89 f7                	mov    %esi,%edi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 04                	push   $0x4
  800c34:	68 ff 22 80 00       	push   $0x8022ff
  800c39:	6a 23                	push   $0x23
  800c3b:	68 1c 23 80 00       	push   $0x80231c
  800c40:	e8 e5 f4 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 05                	push   $0x5
  800c76:	68 ff 22 80 00       	push   $0x8022ff
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 1c 23 80 00       	push   $0x80231c
  800c82:	e8 a3 f4 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 06                	push   $0x6
  800cb8:	68 ff 22 80 00       	push   $0x8022ff
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 1c 23 80 00       	push   $0x80231c
  800cc4:	e8 61 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 08                	push   $0x8
  800cfa:	68 ff 22 80 00       	push   $0x8022ff
  800cff:	6a 23                	push   $0x23
  800d01:	68 1c 23 80 00       	push   $0x80231c
  800d06:	e8 1f f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 09 00 00 00       	mov    $0x9,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 09                	push   $0x9
  800d3c:	68 ff 22 80 00       	push   $0x8022ff
  800d41:	6a 23                	push   $0x23
  800d43:	68 1c 23 80 00       	push   $0x80231c
  800d48:	e8 dd f3 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 0a                	push   $0xa
  800d7e:	68 ff 22 80 00       	push   $0x8022ff
  800d83:	6a 23                	push   $0x23
  800d85:	68 1c 23 80 00       	push   $0x80231c
  800d8a:	e8 9b f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9d:	be 00 00 00 00       	mov    $0x0,%esi
  800da2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 cb                	mov    %ecx,%ebx
  800dd2:	89 cf                	mov    %ecx,%edi
  800dd4:	89 ce                	mov    %ecx,%esi
  800dd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	7e 17                	jle    800df3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 0d                	push   $0xd
  800de2:	68 ff 22 80 00       	push   $0x8022ff
  800de7:	6a 23                	push   $0x23
  800de9:	68 1c 23 80 00       	push   $0x80231c
  800dee:	e8 37 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  800e02:	e8 c5 fd ff ff       	call   800bcc <sys_getenvid>
  800e07:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800e09:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e10:	75 29                	jne    800e3b <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	6a 07                	push   $0x7
  800e17:	68 00 f0 bf ee       	push   $0xeebff000
  800e1c:	50                   	push   %eax
  800e1d:	e8 e8 fd ff ff       	call   800c0a <sys_page_alloc>
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 12                	jns    800e3b <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  800e29:	50                   	push   %eax
  800e2a:	68 2a 23 80 00       	push   $0x80232a
  800e2f:	6a 24                	push   $0x24
  800e31:	68 43 23 80 00       	push   $0x802343
  800e36:	e8 ef f2 ff ff       	call   80012a <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	68 6f 0e 80 00       	push   $0x800e6f
  800e4b:	53                   	push   %ebx
  800e4c:	e8 04 ff ff ff       	call   800d55 <sys_env_set_pgfault_upcall>
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	79 12                	jns    800e6a <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  800e58:	50                   	push   %eax
  800e59:	68 2a 23 80 00       	push   $0x80232a
  800e5e:	6a 2e                	push   $0x2e
  800e60:	68 43 23 80 00       	push   $0x802343
  800e65:	e8 c0 f2 ff ff       	call   80012a <_panic>
}
  800e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e6f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e70:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e75:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e77:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800e7a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800e7e:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  800e81:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e85:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  800e87:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e8b:	83 c4 08             	add    $0x8,%esp
	popal
  800e8e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e8f:	83 c4 04             	add    $0x4,%esp
	popfl
  800e92:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  800e93:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e94:	c3                   	ret    

00800e95 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea0:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec7:	89 c2                	mov    %eax,%edx
  800ec9:	c1 ea 16             	shr    $0x16,%edx
  800ecc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed3:	f6 c2 01             	test   $0x1,%dl
  800ed6:	74 11                	je     800ee9 <fd_alloc+0x2d>
  800ed8:	89 c2                	mov    %eax,%edx
  800eda:	c1 ea 0c             	shr    $0xc,%edx
  800edd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee4:	f6 c2 01             	test   $0x1,%dl
  800ee7:	75 09                	jne    800ef2 <fd_alloc+0x36>
			*fd_store = fd;
  800ee9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef0:	eb 17                	jmp    800f09 <fd_alloc+0x4d>
  800ef2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800efc:	75 c9                	jne    800ec7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f04:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f11:	83 f8 1f             	cmp    $0x1f,%eax
  800f14:	77 36                	ja     800f4c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f16:	c1 e0 0c             	shl    $0xc,%eax
  800f19:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1e:	89 c2                	mov    %eax,%edx
  800f20:	c1 ea 16             	shr    $0x16,%edx
  800f23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	74 24                	je     800f53 <fd_lookup+0x48>
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	c1 ea 0c             	shr    $0xc,%edx
  800f34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3b:	f6 c2 01             	test   $0x1,%dl
  800f3e:	74 1a                	je     800f5a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f43:	89 02                	mov    %eax,(%edx)
	return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4a:	eb 13                	jmp    800f5f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f51:	eb 0c                	jmp    800f5f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f58:	eb 05                	jmp    800f5f <fd_lookup+0x54>
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6a:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f6f:	eb 13                	jmp    800f84 <dev_lookup+0x23>
  800f71:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f74:	39 08                	cmp    %ecx,(%eax)
  800f76:	75 0c                	jne    800f84 <dev_lookup+0x23>
			*dev = devtab[i];
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f82:	eb 2e                	jmp    800fb2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f84:	8b 02                	mov    (%edx),%eax
  800f86:	85 c0                	test   %eax,%eax
  800f88:	75 e7                	jne    800f71 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f8a:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8f:	8b 40 48             	mov    0x48(%eax),%eax
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	51                   	push   %ecx
  800f96:	50                   	push   %eax
  800f97:	68 54 23 80 00       	push   $0x802354
  800f9c:	e8 62 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 10             	sub    $0x10,%esp
  800fbc:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc5:	50                   	push   %eax
  800fc6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fcc:	c1 e8 0c             	shr    $0xc,%eax
  800fcf:	50                   	push   %eax
  800fd0:	e8 36 ff ff ff       	call   800f0b <fd_lookup>
  800fd5:	83 c4 08             	add    $0x8,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 05                	js     800fe1 <fd_close+0x2d>
	    || fd != fd2)
  800fdc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fdf:	74 0c                	je     800fed <fd_close+0x39>
		return (must_exist ? r : 0);
  800fe1:	84 db                	test   %bl,%bl
  800fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe8:	0f 44 c2             	cmove  %edx,%eax
  800feb:	eb 41                	jmp    80102e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff3:	50                   	push   %eax
  800ff4:	ff 36                	pushl  (%esi)
  800ff6:	e8 66 ff ff ff       	call   800f61 <dev_lookup>
  800ffb:	89 c3                	mov    %eax,%ebx
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 1a                	js     80101e <fd_close+0x6a>
		if (dev->dev_close)
  801004:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801007:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80100a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80100f:	85 c0                	test   %eax,%eax
  801011:	74 0b                	je     80101e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	56                   	push   %esi
  801017:	ff d0                	call   *%eax
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	56                   	push   %esi
  801022:	6a 00                	push   $0x0
  801024:	e8 66 fc ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	89 d8                	mov    %ebx,%eax
}
  80102e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103e:	50                   	push   %eax
  80103f:	ff 75 08             	pushl  0x8(%ebp)
  801042:	e8 c4 fe ff ff       	call   800f0b <fd_lookup>
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 10                	js     80105e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	6a 01                	push   $0x1
  801053:	ff 75 f4             	pushl  -0xc(%ebp)
  801056:	e8 59 ff ff ff       	call   800fb4 <fd_close>
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <close_all>:

void
close_all(void)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	53                   	push   %ebx
  801064:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801067:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	53                   	push   %ebx
  801070:	e8 c0 ff ff ff       	call   801035 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801075:	83 c3 01             	add    $0x1,%ebx
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	83 fb 20             	cmp    $0x20,%ebx
  80107e:	75 ec                	jne    80106c <close_all+0xc>
		close(i);
}
  801080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 2c             	sub    $0x2c,%esp
  80108e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	ff 75 08             	pushl  0x8(%ebp)
  801098:	e8 6e fe ff ff       	call   800f0b <fd_lookup>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	0f 88 c1 00 00 00    	js     801169 <dup+0xe4>
		return r;
	close(newfdnum);
  8010a8:	83 ec 0c             	sub    $0xc,%esp
  8010ab:	56                   	push   %esi
  8010ac:	e8 84 ff ff ff       	call   801035 <close>

	newfd = INDEX2FD(newfdnum);
  8010b1:	89 f3                	mov    %esi,%ebx
  8010b3:	c1 e3 0c             	shl    $0xc,%ebx
  8010b6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010bc:	83 c4 04             	add    $0x4,%esp
  8010bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c2:	e8 de fd ff ff       	call   800ea5 <fd2data>
  8010c7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010c9:	89 1c 24             	mov    %ebx,(%esp)
  8010cc:	e8 d4 fd ff ff       	call   800ea5 <fd2data>
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d7:	89 f8                	mov    %edi,%eax
  8010d9:	c1 e8 16             	shr    $0x16,%eax
  8010dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e3:	a8 01                	test   $0x1,%al
  8010e5:	74 37                	je     80111e <dup+0x99>
  8010e7:	89 f8                	mov    %edi,%eax
  8010e9:	c1 e8 0c             	shr    $0xc,%eax
  8010ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	74 26                	je     80111e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ff:	83 ec 0c             	sub    $0xc,%esp
  801102:	25 07 0e 00 00       	and    $0xe07,%eax
  801107:	50                   	push   %eax
  801108:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110b:	6a 00                	push   $0x0
  80110d:	57                   	push   %edi
  80110e:	6a 00                	push   $0x0
  801110:	e8 38 fb ff ff       	call   800c4d <sys_page_map>
  801115:	89 c7                	mov    %eax,%edi
  801117:	83 c4 20             	add    $0x20,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 2e                	js     80114c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801121:	89 d0                	mov    %edx,%eax
  801123:	c1 e8 0c             	shr    $0xc,%eax
  801126:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	25 07 0e 00 00       	and    $0xe07,%eax
  801135:	50                   	push   %eax
  801136:	53                   	push   %ebx
  801137:	6a 00                	push   $0x0
  801139:	52                   	push   %edx
  80113a:	6a 00                	push   $0x0
  80113c:	e8 0c fb ff ff       	call   800c4d <sys_page_map>
  801141:	89 c7                	mov    %eax,%edi
  801143:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801146:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801148:	85 ff                	test   %edi,%edi
  80114a:	79 1d                	jns    801169 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	53                   	push   %ebx
  801150:	6a 00                	push   $0x0
  801152:	e8 38 fb ff ff       	call   800c8f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801157:	83 c4 08             	add    $0x8,%esp
  80115a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115d:	6a 00                	push   $0x0
  80115f:	e8 2b fb ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	89 f8                	mov    %edi,%eax
}
  801169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	53                   	push   %ebx
  801175:	83 ec 14             	sub    $0x14,%esp
  801178:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	53                   	push   %ebx
  801180:	e8 86 fd ff ff       	call   800f0b <fd_lookup>
  801185:	83 c4 08             	add    $0x8,%esp
  801188:	89 c2                	mov    %eax,%edx
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 6d                	js     8011fb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801198:	ff 30                	pushl  (%eax)
  80119a:	e8 c2 fd ff ff       	call   800f61 <dev_lookup>
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 4c                	js     8011f2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a9:	8b 42 08             	mov    0x8(%edx),%eax
  8011ac:	83 e0 03             	and    $0x3,%eax
  8011af:	83 f8 01             	cmp    $0x1,%eax
  8011b2:	75 21                	jne    8011d5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b9:	8b 40 48             	mov    0x48(%eax),%eax
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	53                   	push   %ebx
  8011c0:	50                   	push   %eax
  8011c1:	68 98 23 80 00       	push   $0x802398
  8011c6:	e8 38 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d3:	eb 26                	jmp    8011fb <read+0x8a>
	}
	if (!dev->dev_read)
  8011d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d8:	8b 40 08             	mov    0x8(%eax),%eax
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	74 17                	je     8011f6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	ff 75 10             	pushl  0x10(%ebp)
  8011e5:	ff 75 0c             	pushl  0xc(%ebp)
  8011e8:	52                   	push   %edx
  8011e9:	ff d0                	call   *%eax
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	eb 09                	jmp    8011fb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	eb 05                	jmp    8011fb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011fb:	89 d0                	mov    %edx,%eax
  8011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
  801216:	eb 21                	jmp    801239 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	89 f0                	mov    %esi,%eax
  80121d:	29 d8                	sub    %ebx,%eax
  80121f:	50                   	push   %eax
  801220:	89 d8                	mov    %ebx,%eax
  801222:	03 45 0c             	add    0xc(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	57                   	push   %edi
  801227:	e8 45 ff ff ff       	call   801171 <read>
		if (m < 0)
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 10                	js     801243 <readn+0x41>
			return m;
		if (m == 0)
  801233:	85 c0                	test   %eax,%eax
  801235:	74 0a                	je     801241 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801237:	01 c3                	add    %eax,%ebx
  801239:	39 f3                	cmp    %esi,%ebx
  80123b:	72 db                	jb     801218 <readn+0x16>
  80123d:	89 d8                	mov    %ebx,%eax
  80123f:	eb 02                	jmp    801243 <readn+0x41>
  801241:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	53                   	push   %ebx
  80124f:	83 ec 14             	sub    $0x14,%esp
  801252:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801255:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	53                   	push   %ebx
  80125a:	e8 ac fc ff ff       	call   800f0b <fd_lookup>
  80125f:	83 c4 08             	add    $0x8,%esp
  801262:	89 c2                	mov    %eax,%edx
  801264:	85 c0                	test   %eax,%eax
  801266:	78 68                	js     8012d0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801272:	ff 30                	pushl  (%eax)
  801274:	e8 e8 fc ff ff       	call   800f61 <dev_lookup>
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 47                	js     8012c7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801283:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801287:	75 21                	jne    8012aa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801289:	a1 04 40 80 00       	mov    0x804004,%eax
  80128e:	8b 40 48             	mov    0x48(%eax),%eax
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	53                   	push   %ebx
  801295:	50                   	push   %eax
  801296:	68 b4 23 80 00       	push   $0x8023b4
  80129b:	e8 63 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a8:	eb 26                	jmp    8012d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8012b0:	85 d2                	test   %edx,%edx
  8012b2:	74 17                	je     8012cb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	ff 75 10             	pushl  0x10(%ebp)
  8012ba:	ff 75 0c             	pushl  0xc(%ebp)
  8012bd:	50                   	push   %eax
  8012be:	ff d2                	call   *%edx
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	eb 09                	jmp    8012d0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c7:	89 c2                	mov    %eax,%edx
  8012c9:	eb 05                	jmp    8012d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012d0:	89 d0                	mov    %edx,%eax
  8012d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    

008012d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	ff 75 08             	pushl  0x8(%ebp)
  8012e4:	e8 22 fc ff ff       	call   800f0b <fd_lookup>
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 0e                	js     8012fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	53                   	push   %ebx
  801304:	83 ec 14             	sub    $0x14,%esp
  801307:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	53                   	push   %ebx
  80130f:	e8 f7 fb ff ff       	call   800f0b <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	89 c2                	mov    %eax,%edx
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 65                	js     801382 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	ff 30                	pushl  (%eax)
  801329:	e8 33 fc ff ff       	call   800f61 <dev_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 44                	js     801379 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133c:	75 21                	jne    80135f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80133e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801343:	8b 40 48             	mov    0x48(%eax),%eax
  801346:	83 ec 04             	sub    $0x4,%esp
  801349:	53                   	push   %ebx
  80134a:	50                   	push   %eax
  80134b:	68 74 23 80 00       	push   $0x802374
  801350:	e8 ae ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135d:	eb 23                	jmp    801382 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80135f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801362:	8b 52 18             	mov    0x18(%edx),%edx
  801365:	85 d2                	test   %edx,%edx
  801367:	74 14                	je     80137d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	ff 75 0c             	pushl  0xc(%ebp)
  80136f:	50                   	push   %eax
  801370:	ff d2                	call   *%edx
  801372:	89 c2                	mov    %eax,%edx
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	eb 09                	jmp    801382 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	89 c2                	mov    %eax,%edx
  80137b:	eb 05                	jmp    801382 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80137d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801382:	89 d0                	mov    %edx,%eax
  801384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 14             	sub    $0x14,%esp
  801390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801393:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	ff 75 08             	pushl  0x8(%ebp)
  80139a:	e8 6c fb ff ff       	call   800f0b <fd_lookup>
  80139f:	83 c4 08             	add    $0x8,%esp
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 58                	js     801400 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	ff 30                	pushl  (%eax)
  8013b4:	e8 a8 fb ff ff       	call   800f61 <dev_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 37                	js     8013f7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c7:	74 32                	je     8013fb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d3:	00 00 00 
	stat->st_isdir = 0;
  8013d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013dd:	00 00 00 
	stat->st_dev = dev;
  8013e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ed:	ff 50 14             	call   *0x14(%eax)
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	eb 09                	jmp    801400 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f7:	89 c2                	mov    %eax,%edx
  8013f9:	eb 05                	jmp    801400 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801400:	89 d0                	mov    %edx,%eax
  801402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	6a 00                	push   $0x0
  801411:	ff 75 08             	pushl  0x8(%ebp)
  801414:	e8 e9 01 00 00       	call   801602 <open>
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 1b                	js     80143d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801422:	83 ec 08             	sub    $0x8,%esp
  801425:	ff 75 0c             	pushl  0xc(%ebp)
  801428:	50                   	push   %eax
  801429:	e8 5b ff ff ff       	call   801389 <fstat>
  80142e:	89 c6                	mov    %eax,%esi
	close(fd);
  801430:	89 1c 24             	mov    %ebx,(%esp)
  801433:	e8 fd fb ff ff       	call   801035 <close>
	return r;
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	89 f0                	mov    %esi,%eax
}
  80143d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	89 c6                	mov    %eax,%esi
  80144b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80144d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801454:	75 12                	jne    801468 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	6a 01                	push   $0x1
  80145b:	e8 fb 07 00 00       	call   801c5b <ipc_find_env>
  801460:	a3 00 40 80 00       	mov    %eax,0x804000
  801465:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801468:	6a 07                	push   $0x7
  80146a:	68 00 50 80 00       	push   $0x805000
  80146f:	56                   	push   %esi
  801470:	ff 35 00 40 80 00    	pushl  0x804000
  801476:	e8 8c 07 00 00       	call   801c07 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80147b:	83 c4 0c             	add    $0xc,%esp
  80147e:	6a 00                	push   $0x0
  801480:	53                   	push   %ebx
  801481:	6a 00                	push   $0x0
  801483:	e8 fd 06 00 00       	call   801b85 <ipc_recv>
}
  801488:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    

0080148f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	8b 40 0c             	mov    0xc(%eax),%eax
  80149b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ad:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b2:	e8 8d ff ff ff       	call   801444 <fsipc>
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d4:	e8 6b ff ff ff       	call   801444 <fsipc>
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014fa:	e8 45 ff ff ff       	call   801444 <fsipc>
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 2c                	js     80152f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	68 00 50 80 00       	push   $0x805000
  80150b:	53                   	push   %ebx
  80150c:	e8 f6 f2 ff ff       	call   800807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801511:	a1 80 50 80 00       	mov    0x805080,%eax
  801516:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151c:	a1 84 50 80 00       	mov    0x805084,%eax
  801521:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	8b 45 10             	mov    0x10(%ebp),%eax
  80153d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801542:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801547:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80154a:	8b 55 08             	mov    0x8(%ebp),%edx
  80154d:	8b 52 0c             	mov    0xc(%edx),%edx
  801550:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801556:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80155b:	50                   	push   %eax
  80155c:	ff 75 0c             	pushl  0xc(%ebp)
  80155f:	68 08 50 80 00       	push   $0x805008
  801564:	e8 30 f4 ff ff       	call   800999 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 04 00 00 00       	mov    $0x4,%eax
  801573:	e8 cc fe ff ff       	call   801444 <fsipc>
            return r;

    return r;
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	56                   	push   %esi
  80157e:	53                   	push   %ebx
  80157f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
  801585:	8b 40 0c             	mov    0xc(%eax),%eax
  801588:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80158d:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801593:	ba 00 00 00 00       	mov    $0x0,%edx
  801598:	b8 03 00 00 00       	mov    $0x3,%eax
  80159d:	e8 a2 fe ff ff       	call   801444 <fsipc>
  8015a2:	89 c3                	mov    %eax,%ebx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 51                	js     8015f9 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8015a8:	39 c6                	cmp    %eax,%esi
  8015aa:	73 19                	jae    8015c5 <devfile_read+0x4b>
  8015ac:	68 e4 23 80 00       	push   $0x8023e4
  8015b1:	68 eb 23 80 00       	push   $0x8023eb
  8015b6:	68 82 00 00 00       	push   $0x82
  8015bb:	68 00 24 80 00       	push   $0x802400
  8015c0:	e8 65 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ca:	7e 19                	jle    8015e5 <devfile_read+0x6b>
  8015cc:	68 0b 24 80 00       	push   $0x80240b
  8015d1:	68 eb 23 80 00       	push   $0x8023eb
  8015d6:	68 83 00 00 00       	push   $0x83
  8015db:	68 00 24 80 00       	push   $0x802400
  8015e0:	e8 45 eb ff ff       	call   80012a <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	50                   	push   %eax
  8015e9:	68 00 50 80 00       	push   $0x805000
  8015ee:	ff 75 0c             	pushl  0xc(%ebp)
  8015f1:	e8 a3 f3 ff ff       	call   800999 <memmove>
	return r;
  8015f6:	83 c4 10             	add    $0x10,%esp
}
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	53                   	push   %ebx
  801606:	83 ec 20             	sub    $0x20,%esp
  801609:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80160c:	53                   	push   %ebx
  80160d:	e8 bc f1 ff ff       	call   8007ce <strlen>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80161a:	7f 67                	jg     801683 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	e8 94 f8 ff ff       	call   800ebc <fd_alloc>
  801628:	83 c4 10             	add    $0x10,%esp
		return r;
  80162b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 57                	js     801688 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	53                   	push   %ebx
  801635:	68 00 50 80 00       	push   $0x805000
  80163a:	e8 c8 f1 ff ff       	call   800807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80163f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801642:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	b8 01 00 00 00       	mov    $0x1,%eax
  80164f:	e8 f0 fd ff ff       	call   801444 <fsipc>
  801654:	89 c3                	mov    %eax,%ebx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	79 14                	jns    801671 <open+0x6f>
		fd_close(fd, 0);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	6a 00                	push   $0x0
  801662:	ff 75 f4             	pushl  -0xc(%ebp)
  801665:	e8 4a f9 ff ff       	call   800fb4 <fd_close>
		return r;
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	89 da                	mov    %ebx,%edx
  80166f:	eb 17                	jmp    801688 <open+0x86>
	}

	return fd2num(fd);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	ff 75 f4             	pushl  -0xc(%ebp)
  801677:	e8 19 f8 ff ff       	call   800e95 <fd2num>
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	eb 05                	jmp    801688 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801683:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801688:	89 d0                	mov    %edx,%eax
  80168a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	b8 08 00 00 00       	mov    $0x8,%eax
  80169f:	e8 a0 fd ff ff       	call   801444 <fsipc>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	ff 75 08             	pushl  0x8(%ebp)
  8016b4:	e8 ec f7 ff ff       	call   800ea5 <fd2data>
  8016b9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016bb:	83 c4 08             	add    $0x8,%esp
  8016be:	68 17 24 80 00       	push   $0x802417
  8016c3:	53                   	push   %ebx
  8016c4:	e8 3e f1 ff ff       	call   800807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016c9:	8b 46 04             	mov    0x4(%esi),%eax
  8016cc:	2b 06                	sub    (%esi),%eax
  8016ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016db:	00 00 00 
	stat->st_dev = &devpipe;
  8016de:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016e5:	30 80 00 
	return 0;
}
  8016e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016fe:	53                   	push   %ebx
  8016ff:	6a 00                	push   $0x0
  801701:	e8 89 f5 ff ff       	call   800c8f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 97 f7 ff ff       	call   800ea5 <fd2data>
  80170e:	83 c4 08             	add    $0x8,%esp
  801711:	50                   	push   %eax
  801712:	6a 00                	push   $0x0
  801714:	e8 76 f5 ff ff       	call   800c8f <sys_page_unmap>
}
  801719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 1c             	sub    $0x1c,%esp
  801727:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80172a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80172c:	a1 04 40 80 00       	mov    0x804004,%eax
  801731:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801734:	83 ec 0c             	sub    $0xc,%esp
  801737:	ff 75 e0             	pushl  -0x20(%ebp)
  80173a:	e8 55 05 00 00       	call   801c94 <pageref>
  80173f:	89 c3                	mov    %eax,%ebx
  801741:	89 3c 24             	mov    %edi,(%esp)
  801744:	e8 4b 05 00 00       	call   801c94 <pageref>
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	39 c3                	cmp    %eax,%ebx
  80174e:	0f 94 c1             	sete   %cl
  801751:	0f b6 c9             	movzbl %cl,%ecx
  801754:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801757:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80175d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801760:	39 ce                	cmp    %ecx,%esi
  801762:	74 1b                	je     80177f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801764:	39 c3                	cmp    %eax,%ebx
  801766:	75 c4                	jne    80172c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801768:	8b 42 58             	mov    0x58(%edx),%eax
  80176b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80176e:	50                   	push   %eax
  80176f:	56                   	push   %esi
  801770:	68 1e 24 80 00       	push   $0x80241e
  801775:	e8 89 ea ff ff       	call   800203 <cprintf>
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	eb ad                	jmp    80172c <_pipeisclosed+0xe>
	}
}
  80177f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801782:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 28             	sub    $0x28,%esp
  801793:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801796:	56                   	push   %esi
  801797:	e8 09 f7 ff ff       	call   800ea5 <fd2data>
  80179c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8017a6:	eb 4b                	jmp    8017f3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017a8:	89 da                	mov    %ebx,%edx
  8017aa:	89 f0                	mov    %esi,%eax
  8017ac:	e8 6d ff ff ff       	call   80171e <_pipeisclosed>
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	75 48                	jne    8017fd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017b5:	e8 31 f4 ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017ba:	8b 43 04             	mov    0x4(%ebx),%eax
  8017bd:	8b 0b                	mov    (%ebx),%ecx
  8017bf:	8d 51 20             	lea    0x20(%ecx),%edx
  8017c2:	39 d0                	cmp    %edx,%eax
  8017c4:	73 e2                	jae    8017a8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017cd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017d0:	89 c2                	mov    %eax,%edx
  8017d2:	c1 fa 1f             	sar    $0x1f,%edx
  8017d5:	89 d1                	mov    %edx,%ecx
  8017d7:	c1 e9 1b             	shr    $0x1b,%ecx
  8017da:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017dd:	83 e2 1f             	and    $0x1f,%edx
  8017e0:	29 ca                	sub    %ecx,%edx
  8017e2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017ea:	83 c0 01             	add    $0x1,%eax
  8017ed:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f0:	83 c7 01             	add    $0x1,%edi
  8017f3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017f6:	75 c2                	jne    8017ba <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fb:	eb 05                	jmp    801802 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801802:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5f                   	pop    %edi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	57                   	push   %edi
  80180e:	56                   	push   %esi
  80180f:	53                   	push   %ebx
  801810:	83 ec 18             	sub    $0x18,%esp
  801813:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801816:	57                   	push   %edi
  801817:	e8 89 f6 ff ff       	call   800ea5 <fd2data>
  80181c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	bb 00 00 00 00       	mov    $0x0,%ebx
  801826:	eb 3d                	jmp    801865 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801828:	85 db                	test   %ebx,%ebx
  80182a:	74 04                	je     801830 <devpipe_read+0x26>
				return i;
  80182c:	89 d8                	mov    %ebx,%eax
  80182e:	eb 44                	jmp    801874 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801830:	89 f2                	mov    %esi,%edx
  801832:	89 f8                	mov    %edi,%eax
  801834:	e8 e5 fe ff ff       	call   80171e <_pipeisclosed>
  801839:	85 c0                	test   %eax,%eax
  80183b:	75 32                	jne    80186f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80183d:	e8 a9 f3 ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801842:	8b 06                	mov    (%esi),%eax
  801844:	3b 46 04             	cmp    0x4(%esi),%eax
  801847:	74 df                	je     801828 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801849:	99                   	cltd   
  80184a:	c1 ea 1b             	shr    $0x1b,%edx
  80184d:	01 d0                	add    %edx,%eax
  80184f:	83 e0 1f             	and    $0x1f,%eax
  801852:	29 d0                	sub    %edx,%eax
  801854:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80185c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80185f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801862:	83 c3 01             	add    $0x1,%ebx
  801865:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801868:	75 d8                	jne    801842 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80186a:	8b 45 10             	mov    0x10(%ebp),%eax
  80186d:	eb 05                	jmp    801874 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801874:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5f                   	pop    %edi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801887:	50                   	push   %eax
  801888:	e8 2f f6 ff ff       	call   800ebc <fd_alloc>
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	89 c2                	mov    %eax,%edx
  801892:	85 c0                	test   %eax,%eax
  801894:	0f 88 2c 01 00 00    	js     8019c6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	68 07 04 00 00       	push   $0x407
  8018a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 5e f3 ff ff       	call   800c0a <sys_page_alloc>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	89 c2                	mov    %eax,%edx
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	0f 88 0d 01 00 00    	js     8019c6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bf:	50                   	push   %eax
  8018c0:	e8 f7 f5 ff ff       	call   800ebc <fd_alloc>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	0f 88 e2 00 00 00    	js     8019b4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d2:	83 ec 04             	sub    $0x4,%esp
  8018d5:	68 07 04 00 00       	push   $0x407
  8018da:	ff 75 f0             	pushl  -0x10(%ebp)
  8018dd:	6a 00                	push   $0x0
  8018df:	e8 26 f3 ff ff       	call   800c0a <sys_page_alloc>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	0f 88 c3 00 00 00    	js     8019b4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f7:	e8 a9 f5 ff ff       	call   800ea5 <fd2data>
  8018fc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018fe:	83 c4 0c             	add    $0xc,%esp
  801901:	68 07 04 00 00       	push   $0x407
  801906:	50                   	push   %eax
  801907:	6a 00                	push   $0x0
  801909:	e8 fc f2 ff ff       	call   800c0a <sys_page_alloc>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	0f 88 89 00 00 00    	js     8019a4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	ff 75 f0             	pushl  -0x10(%ebp)
  801921:	e8 7f f5 ff ff       	call   800ea5 <fd2data>
  801926:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80192d:	50                   	push   %eax
  80192e:	6a 00                	push   $0x0
  801930:	56                   	push   %esi
  801931:	6a 00                	push   $0x0
  801933:	e8 15 f3 ff ff       	call   800c4d <sys_page_map>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	83 c4 20             	add    $0x20,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 55                	js     801996 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801941:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801956:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801964:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80196b:	83 ec 0c             	sub    $0xc,%esp
  80196e:	ff 75 f4             	pushl  -0xc(%ebp)
  801971:	e8 1f f5 ff ff       	call   800e95 <fd2num>
  801976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801979:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80197b:	83 c4 04             	add    $0x4,%esp
  80197e:	ff 75 f0             	pushl  -0x10(%ebp)
  801981:	e8 0f f5 ff ff       	call   800e95 <fd2num>
  801986:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801989:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	eb 30                	jmp    8019c6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	56                   	push   %esi
  80199a:	6a 00                	push   $0x0
  80199c:	e8 ee f2 ff ff       	call   800c8f <sys_page_unmap>
  8019a1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 de f2 ff ff       	call   800c8f <sys_page_unmap>
  8019b1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 ce f2 ff ff       	call   800c8f <sys_page_unmap>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019c6:	89 d0                	mov    %edx,%eax
  8019c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5e                   	pop    %esi
  8019cd:	5d                   	pop    %ebp
  8019ce:	c3                   	ret    

008019cf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d8:	50                   	push   %eax
  8019d9:	ff 75 08             	pushl  0x8(%ebp)
  8019dc:	e8 2a f5 ff ff       	call   800f0b <fd_lookup>
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 18                	js     801a00 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ee:	e8 b2 f4 ff ff       	call   800ea5 <fd2data>
	return _pipeisclosed(fd, p);
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f8:	e8 21 fd ff ff       	call   80171e <_pipeisclosed>
  8019fd:	83 c4 10             	add    $0x10,%esp
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a05:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a12:	68 36 24 80 00       	push   $0x802436
  801a17:	ff 75 0c             	pushl  0xc(%ebp)
  801a1a:	e8 e8 ed ff ff       	call   800807 <strcpy>
	return 0;
}
  801a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	57                   	push   %edi
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a32:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a37:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a3d:	eb 2d                	jmp    801a6c <devcons_write+0x46>
		m = n - tot;
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a42:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a44:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a47:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a4c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a4f:	83 ec 04             	sub    $0x4,%esp
  801a52:	53                   	push   %ebx
  801a53:	03 45 0c             	add    0xc(%ebp),%eax
  801a56:	50                   	push   %eax
  801a57:	57                   	push   %edi
  801a58:	e8 3c ef ff ff       	call   800999 <memmove>
		sys_cputs(buf, m);
  801a5d:	83 c4 08             	add    $0x8,%esp
  801a60:	53                   	push   %ebx
  801a61:	57                   	push   %edi
  801a62:	e8 e7 f0 ff ff       	call   800b4e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a67:	01 de                	add    %ebx,%esi
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	89 f0                	mov    %esi,%eax
  801a6e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a71:	72 cc                	jb     801a3f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a8a:	74 2a                	je     801ab6 <devcons_read+0x3b>
  801a8c:	eb 05                	jmp    801a93 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a8e:	e8 58 f1 ff ff       	call   800beb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a93:	e8 d4 f0 ff ff       	call   800b6c <sys_cgetc>
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	74 f2                	je     801a8e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 16                	js     801ab6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aa0:	83 f8 04             	cmp    $0x4,%eax
  801aa3:	74 0c                	je     801ab1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa8:	88 02                	mov    %al,(%edx)
	return 1;
  801aaa:	b8 01 00 00 00       	mov    $0x1,%eax
  801aaf:	eb 05                	jmp    801ab6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ab1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ac4:	6a 01                	push   $0x1
  801ac6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ac9:	50                   	push   %eax
  801aca:	e8 7f f0 ff ff       	call   800b4e <sys_cputs>
}
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    

00801ad4 <getchar>:

int
getchar(void)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ada:	6a 01                	push   $0x1
  801adc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	6a 00                	push   $0x0
  801ae2:	e8 8a f6 ff ff       	call   801171 <read>
	if (r < 0)
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 0f                	js     801afd <getchar+0x29>
		return r;
	if (r < 1)
  801aee:	85 c0                	test   %eax,%eax
  801af0:	7e 06                	jle    801af8 <getchar+0x24>
		return -E_EOF;
	return c;
  801af2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801af6:	eb 05                	jmp    801afd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801af8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b08:	50                   	push   %eax
  801b09:	ff 75 08             	pushl  0x8(%ebp)
  801b0c:	e8 fa f3 ff ff       	call   800f0b <fd_lookup>
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 11                	js     801b29 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b21:	39 10                	cmp    %edx,(%eax)
  801b23:	0f 94 c0             	sete   %al
  801b26:	0f b6 c0             	movzbl %al,%eax
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <opencons>:

int
opencons(void)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b34:	50                   	push   %eax
  801b35:	e8 82 f3 ff ff       	call   800ebc <fd_alloc>
  801b3a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b3d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 3e                	js     801b81 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b43:	83 ec 04             	sub    $0x4,%esp
  801b46:	68 07 04 00 00       	push   $0x407
  801b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 b5 f0 ff ff       	call   800c0a <sys_page_alloc>
  801b55:	83 c4 10             	add    $0x10,%esp
		return r;
  801b58:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 23                	js     801b81 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b67:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	50                   	push   %eax
  801b77:	e8 19 f3 ff ff       	call   800e95 <fd2num>
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	83 c4 10             	add    $0x10,%esp
}
  801b81:	89 d0                	mov    %edx,%eax
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	57                   	push   %edi
  801b89:	56                   	push   %esi
  801b8a:	53                   	push   %ebx
  801b8b:	83 ec 0c             	sub    $0xc,%esp
  801b8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801b97:	85 f6                	test   %esi,%esi
  801b99:	74 06                	je     801ba1 <ipc_recv+0x1c>
		*from_env_store = 0;
  801b9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801ba1:	85 db                	test   %ebx,%ebx
  801ba3:	74 06                	je     801bab <ipc_recv+0x26>
		*perm_store = 0;
  801ba5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801bab:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801bad:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801bb2:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	50                   	push   %eax
  801bb9:	e8 fc f1 ff ff       	call   800dba <sys_ipc_recv>
  801bbe:	89 c7                	mov    %eax,%edi
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	79 14                	jns    801bdb <ipc_recv+0x56>
		cprintf("im dead");
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	68 42 24 80 00       	push   $0x802442
  801bcf:	e8 2f e6 ff ff       	call   800203 <cprintf>
		return r;
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	89 f8                	mov    %edi,%eax
  801bd9:	eb 24                	jmp    801bff <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801bdb:	85 f6                	test   %esi,%esi
  801bdd:	74 0a                	je     801be9 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801bdf:	a1 04 40 80 00       	mov    0x804004,%eax
  801be4:	8b 40 74             	mov    0x74(%eax),%eax
  801be7:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801be9:	85 db                	test   %ebx,%ebx
  801beb:	74 0a                	je     801bf7 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801bed:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf2:	8b 40 78             	mov    0x78(%eax),%eax
  801bf5:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801bf7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bfc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	57                   	push   %edi
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801c19:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801c1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c20:	0f 44 d8             	cmove  %eax,%ebx
  801c23:	eb 1c                	jmp    801c41 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801c25:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c28:	74 12                	je     801c3c <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801c2a:	50                   	push   %eax
  801c2b:	68 4a 24 80 00       	push   $0x80244a
  801c30:	6a 4e                	push   $0x4e
  801c32:	68 57 24 80 00       	push   $0x802457
  801c37:	e8 ee e4 ff ff       	call   80012a <_panic>
		sys_yield();
  801c3c:	e8 aa ef ff ff       	call   800beb <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c41:	ff 75 14             	pushl  0x14(%ebp)
  801c44:	53                   	push   %ebx
  801c45:	56                   	push   %esi
  801c46:	57                   	push   %edi
  801c47:	e8 4b f1 ff ff       	call   800d97 <sys_ipc_try_send>
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 d2                	js     801c25 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c66:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c69:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c6f:	8b 52 50             	mov    0x50(%edx),%edx
  801c72:	39 ca                	cmp    %ecx,%edx
  801c74:	75 0d                	jne    801c83 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c76:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c79:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c7e:	8b 40 48             	mov    0x48(%eax),%eax
  801c81:	eb 0f                	jmp    801c92 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c83:	83 c0 01             	add    $0x1,%eax
  801c86:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c8b:	75 d9                	jne    801c66 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c9a:	89 d0                	mov    %edx,%eax
  801c9c:	c1 e8 16             	shr    $0x16,%eax
  801c9f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ca6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cab:	f6 c1 01             	test   $0x1,%cl
  801cae:	74 1d                	je     801ccd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cb0:	c1 ea 0c             	shr    $0xc,%edx
  801cb3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cba:	f6 c2 01             	test   $0x1,%dl
  801cbd:	74 0e                	je     801ccd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cbf:	c1 ea 0c             	shr    $0xc,%edx
  801cc2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cc9:	ef 
  801cca:	0f b7 c0             	movzwl %ax,%eax
}
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    
  801ccf:	90                   	nop

00801cd0 <__udivdi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 f6                	test   %esi,%esi
  801ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ced:	89 ca                	mov    %ecx,%edx
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	75 3d                	jne    801d30 <__udivdi3+0x60>
  801cf3:	39 cf                	cmp    %ecx,%edi
  801cf5:	0f 87 c5 00 00 00    	ja     801dc0 <__udivdi3+0xf0>
  801cfb:	85 ff                	test   %edi,%edi
  801cfd:	89 fd                	mov    %edi,%ebp
  801cff:	75 0b                	jne    801d0c <__udivdi3+0x3c>
  801d01:	b8 01 00 00 00       	mov    $0x1,%eax
  801d06:	31 d2                	xor    %edx,%edx
  801d08:	f7 f7                	div    %edi
  801d0a:	89 c5                	mov    %eax,%ebp
  801d0c:	89 c8                	mov    %ecx,%eax
  801d0e:	31 d2                	xor    %edx,%edx
  801d10:	f7 f5                	div    %ebp
  801d12:	89 c1                	mov    %eax,%ecx
  801d14:	89 d8                	mov    %ebx,%eax
  801d16:	89 cf                	mov    %ecx,%edi
  801d18:	f7 f5                	div    %ebp
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	39 ce                	cmp    %ecx,%esi
  801d32:	77 74                	ja     801da8 <__udivdi3+0xd8>
  801d34:	0f bd fe             	bsr    %esi,%edi
  801d37:	83 f7 1f             	xor    $0x1f,%edi
  801d3a:	0f 84 98 00 00 00    	je     801dd8 <__udivdi3+0x108>
  801d40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	89 c5                	mov    %eax,%ebp
  801d49:	29 fb                	sub    %edi,%ebx
  801d4b:	d3 e6                	shl    %cl,%esi
  801d4d:	89 d9                	mov    %ebx,%ecx
  801d4f:	d3 ed                	shr    %cl,%ebp
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	d3 e0                	shl    %cl,%eax
  801d55:	09 ee                	or     %ebp,%esi
  801d57:	89 d9                	mov    %ebx,%ecx
  801d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5d:	89 d5                	mov    %edx,%ebp
  801d5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d63:	d3 ed                	shr    %cl,%ebp
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e2                	shl    %cl,%edx
  801d69:	89 d9                	mov    %ebx,%ecx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	09 c2                	or     %eax,%edx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	89 ea                	mov    %ebp,%edx
  801d73:	f7 f6                	div    %esi
  801d75:	89 d5                	mov    %edx,%ebp
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	f7 64 24 0c          	mull   0xc(%esp)
  801d7d:	39 d5                	cmp    %edx,%ebp
  801d7f:	72 10                	jb     801d91 <__udivdi3+0xc1>
  801d81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d85:	89 f9                	mov    %edi,%ecx
  801d87:	d3 e6                	shl    %cl,%esi
  801d89:	39 c6                	cmp    %eax,%esi
  801d8b:	73 07                	jae    801d94 <__udivdi3+0xc4>
  801d8d:	39 d5                	cmp    %edx,%ebp
  801d8f:	75 03                	jne    801d94 <__udivdi3+0xc4>
  801d91:	83 eb 01             	sub    $0x1,%ebx
  801d94:	31 ff                	xor    %edi,%edi
  801d96:	89 d8                	mov    %ebx,%eax
  801d98:	89 fa                	mov    %edi,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	31 ff                	xor    %edi,%edi
  801daa:	31 db                	xor    %ebx,%ebx
  801dac:	89 d8                	mov    %ebx,%eax
  801dae:	89 fa                	mov    %edi,%edx
  801db0:	83 c4 1c             	add    $0x1c,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    
  801db8:	90                   	nop
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	89 d8                	mov    %ebx,%eax
  801dc2:	f7 f7                	div    %edi
  801dc4:	31 ff                	xor    %edi,%edi
  801dc6:	89 c3                	mov    %eax,%ebx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 fa                	mov    %edi,%edx
  801dcc:	83 c4 1c             	add    $0x1c,%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    
  801dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	39 ce                	cmp    %ecx,%esi
  801dda:	72 0c                	jb     801de8 <__udivdi3+0x118>
  801ddc:	31 db                	xor    %ebx,%ebx
  801dde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801de2:	0f 87 34 ff ff ff    	ja     801d1c <__udivdi3+0x4c>
  801de8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ded:	e9 2a ff ff ff       	jmp    801d1c <__udivdi3+0x4c>
  801df2:	66 90                	xchg   %ax,%ax
  801df4:	66 90                	xchg   %ax,%ax
  801df6:	66 90                	xchg   %ax,%ax
  801df8:	66 90                	xchg   %ax,%ax
  801dfa:	66 90                	xchg   %ax,%ax
  801dfc:	66 90                	xchg   %ax,%ax
  801dfe:	66 90                	xchg   %ax,%ax

00801e00 <__umoddi3>:
  801e00:	55                   	push   %ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	83 ec 1c             	sub    $0x1c,%esp
  801e07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e17:	85 d2                	test   %edx,%edx
  801e19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e21:	89 f3                	mov    %esi,%ebx
  801e23:	89 3c 24             	mov    %edi,(%esp)
  801e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e2a:	75 1c                	jne    801e48 <__umoddi3+0x48>
  801e2c:	39 f7                	cmp    %esi,%edi
  801e2e:	76 50                	jbe    801e80 <__umoddi3+0x80>
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	f7 f7                	div    %edi
  801e36:	89 d0                	mov    %edx,%eax
  801e38:	31 d2                	xor    %edx,%edx
  801e3a:	83 c4 1c             	add    $0x1c,%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    
  801e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e48:	39 f2                	cmp    %esi,%edx
  801e4a:	89 d0                	mov    %edx,%eax
  801e4c:	77 52                	ja     801ea0 <__umoddi3+0xa0>
  801e4e:	0f bd ea             	bsr    %edx,%ebp
  801e51:	83 f5 1f             	xor    $0x1f,%ebp
  801e54:	75 5a                	jne    801eb0 <__umoddi3+0xb0>
  801e56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e5a:	0f 82 e0 00 00 00    	jb     801f40 <__umoddi3+0x140>
  801e60:	39 0c 24             	cmp    %ecx,(%esp)
  801e63:	0f 86 d7 00 00 00    	jbe    801f40 <__umoddi3+0x140>
  801e69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e71:	83 c4 1c             	add    $0x1c,%esp
  801e74:	5b                   	pop    %ebx
  801e75:	5e                   	pop    %esi
  801e76:	5f                   	pop    %edi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e80:	85 ff                	test   %edi,%edi
  801e82:	89 fd                	mov    %edi,%ebp
  801e84:	75 0b                	jne    801e91 <__umoddi3+0x91>
  801e86:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	f7 f7                	div    %edi
  801e8f:	89 c5                	mov    %eax,%ebp
  801e91:	89 f0                	mov    %esi,%eax
  801e93:	31 d2                	xor    %edx,%edx
  801e95:	f7 f5                	div    %ebp
  801e97:	89 c8                	mov    %ecx,%eax
  801e99:	f7 f5                	div    %ebp
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	eb 99                	jmp    801e38 <__umoddi3+0x38>
  801e9f:	90                   	nop
  801ea0:	89 c8                	mov    %ecx,%eax
  801ea2:	89 f2                	mov    %esi,%edx
  801ea4:	83 c4 1c             	add    $0x1c,%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    
  801eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	8b 34 24             	mov    (%esp),%esi
  801eb3:	bf 20 00 00 00       	mov    $0x20,%edi
  801eb8:	89 e9                	mov    %ebp,%ecx
  801eba:	29 ef                	sub    %ebp,%edi
  801ebc:	d3 e0                	shl    %cl,%eax
  801ebe:	89 f9                	mov    %edi,%ecx
  801ec0:	89 f2                	mov    %esi,%edx
  801ec2:	d3 ea                	shr    %cl,%edx
  801ec4:	89 e9                	mov    %ebp,%ecx
  801ec6:	09 c2                	or     %eax,%edx
  801ec8:	89 d8                	mov    %ebx,%eax
  801eca:	89 14 24             	mov    %edx,(%esp)
  801ecd:	89 f2                	mov    %esi,%edx
  801ecf:	d3 e2                	shl    %cl,%edx
  801ed1:	89 f9                	mov    %edi,%ecx
  801ed3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801edb:	d3 e8                	shr    %cl,%eax
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	89 c6                	mov    %eax,%esi
  801ee1:	d3 e3                	shl    %cl,%ebx
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 d0                	mov    %edx,%eax
  801ee7:	d3 e8                	shr    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	09 d8                	or     %ebx,%eax
  801eed:	89 d3                	mov    %edx,%ebx
  801eef:	89 f2                	mov    %esi,%edx
  801ef1:	f7 34 24             	divl   (%esp)
  801ef4:	89 d6                	mov    %edx,%esi
  801ef6:	d3 e3                	shl    %cl,%ebx
  801ef8:	f7 64 24 04          	mull   0x4(%esp)
  801efc:	39 d6                	cmp    %edx,%esi
  801efe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f02:	89 d1                	mov    %edx,%ecx
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	72 08                	jb     801f10 <__umoddi3+0x110>
  801f08:	75 11                	jne    801f1b <__umoddi3+0x11b>
  801f0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f0e:	73 0b                	jae    801f1b <__umoddi3+0x11b>
  801f10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f14:	1b 14 24             	sbb    (%esp),%edx
  801f17:	89 d1                	mov    %edx,%ecx
  801f19:	89 c3                	mov    %eax,%ebx
  801f1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f1f:	29 da                	sub    %ebx,%edx
  801f21:	19 ce                	sbb    %ecx,%esi
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	89 f0                	mov    %esi,%eax
  801f27:	d3 e0                	shl    %cl,%eax
  801f29:	89 e9                	mov    %ebp,%ecx
  801f2b:	d3 ea                	shr    %cl,%edx
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	d3 ee                	shr    %cl,%esi
  801f31:	09 d0                	or     %edx,%eax
  801f33:	89 f2                	mov    %esi,%edx
  801f35:	83 c4 1c             	add    $0x1c,%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
  801f3d:	8d 76 00             	lea    0x0(%esi),%esi
  801f40:	29 f9                	sub    %edi,%ecx
  801f42:	19 d6                	sbb    %edx,%esi
  801f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f4c:	e9 18 ff ff ff       	jmp    801e69 <__umoddi3+0x69>
