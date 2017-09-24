
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 e0 10 80 00       	push   $0x8010e0
  800045:	e8 9c 01 00 00       	call   8001e6 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 8f 0b 00 00       	call   800bed <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 00 11 80 00       	push   $0x801100
  80006f:	6a 0f                	push   $0xf
  800071:	68 ea 10 80 00       	push   $0x8010ea
  800076:	e8 92 00 00 00       	call   80010d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 2c 11 80 00       	push   $0x80112c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 0e 07 00 00       	call   800797 <snprintf>
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
  80009c:	e8 fb 0c 00 00       	call   800d9c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 81 0a 00 00       	call   800b31 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 ea 0a 00 00       	call   800baf <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 66 0a 00 00       	call   800b6e <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 8f 0a 00 00       	call   800baf <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 58 11 80 00       	push   $0x801158
  800130:	e8 b1 00 00 00       	call   8001e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 54 00 00 00       	call   800195 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 06 14 80 00 	movl   $0x801406,(%esp)
  800148:	e8 99 00 00 00       	call   8001e6 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	75 1a                	jne    80018c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	68 ff 00 00 00       	push   $0xff
  80017a:	8d 43 08             	lea    0x8(%ebx),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 ae 09 00 00       	call   800b31 <sys_cputs>
		b->idx = 0;
  800183:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800189:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a5:	00 00 00 
	b.cnt = 0;
  8001a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b2:	ff 75 0c             	pushl  0xc(%ebp)
  8001b5:	ff 75 08             	pushl  0x8(%ebp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	68 53 01 80 00       	push   $0x800153
  8001c4:	e8 1a 01 00 00       	call   8002e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c9:	83 c4 08             	add    $0x8,%esp
  8001cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	e8 53 09 00 00       	call   800b31 <sys_cputs>

	return b.cnt;
}
  8001de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 9d ff ff ff       	call   800195 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	83 ec 1c             	sub    $0x1c,%esp
  800203:	89 c7                	mov    %eax,%edi
  800205:	89 d6                	mov    %edx,%esi
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800210:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80021e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800221:	39 d3                	cmp    %edx,%ebx
  800223:	72 05                	jb     80022a <printnum+0x30>
  800225:	39 45 10             	cmp    %eax,0x10(%ebp)
  800228:	77 45                	ja     80026f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	ff 75 18             	pushl  0x18(%ebp)
  800230:	8b 45 14             	mov    0x14(%ebp),%eax
  800233:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800236:	53                   	push   %ebx
  800237:	ff 75 10             	pushl  0x10(%ebp)
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 f2 0b 00 00       	call   800e40 <__udivdi3>
  80024e:	83 c4 18             	add    $0x18,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	89 f2                	mov    %esi,%edx
  800255:	89 f8                	mov    %edi,%eax
  800257:	e8 9e ff ff ff       	call   8001fa <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 18                	jmp    800279 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	ff d7                	call   *%edi
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	eb 03                	jmp    800272 <printnum+0x78>
  80026f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800272:	83 eb 01             	sub    $0x1,%ebx
  800275:	85 db                	test   %ebx,%ebx
  800277:	7f e8                	jg     800261 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 df 0c 00 00       	call   800f70 <__umoddi3>
  800291:	83 c4 14             	add    $0x14,%esp
  800294:	0f be 80 7c 11 80 00 	movsbl 0x80117c(%eax),%eax
  80029b:	50                   	push   %eax
  80029c:	ff d7                	call   *%edi
}
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	50                   	push   %eax
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 05 00 00 00       	call   8002e3 <vprintfmt>
	va_end(ap);
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	c9                   	leave  
  8002e2:	c3                   	ret    

008002e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 2c             	sub    $0x2c,%esp
  8002ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f5:	eb 12                	jmp    800309 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	0f 84 42 04 00 00    	je     800741 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	53                   	push   %ebx
  800303:	50                   	push   %eax
  800304:	ff d6                	call   *%esi
  800306:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	83 c7 01             	add    $0x1,%edi
  80030c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800310:	83 f8 25             	cmp    $0x25,%eax
  800313:	75 e2                	jne    8002f7 <vprintfmt+0x14>
  800315:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800319:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800320:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800333:	eb 07                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800338:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8d 47 01             	lea    0x1(%edi),%eax
  80033f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800342:	0f b6 07             	movzbl (%edi),%eax
  800345:	0f b6 d0             	movzbl %al,%edx
  800348:	83 e8 23             	sub    $0x23,%eax
  80034b:	3c 55                	cmp    $0x55,%al
  80034d:	0f 87 d3 03 00 00    	ja     800726 <vprintfmt+0x443>
  800353:	0f b6 c0             	movzbl %al,%eax
  800356:	ff 24 85 40 12 80 00 	jmp    *0x801240(,%eax,4)
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800364:	eb d6                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80037e:	83 f9 09             	cmp    $0x9,%ecx
  800381:	77 3f                	ja     8003c2 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb e9                	jmp    800371 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 40 04             	lea    0x4(%eax),%eax
  800396:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039c:	eb 2a                	jmp    8003c8 <vprintfmt+0xe5>
  80039e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a8:	0f 49 d0             	cmovns %eax,%edx
  8003ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b1:	eb 89                	jmp    80033c <vprintfmt+0x59>
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bd:	e9 7a ff ff ff       	jmp    80033c <vprintfmt+0x59>
  8003c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cc:	0f 89 6a ff ff ff    	jns    80033c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003df:	e9 58 ff ff ff       	jmp    80033c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ea:	e9 4d ff ff ff       	jmp    80033c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 78 04             	lea    0x4(%eax),%edi
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	53                   	push   %ebx
  8003f9:	ff 30                	pushl  (%eax)
  8003fb:	ff d6                	call   *%esi
			break;
  8003fd:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800406:	e9 fe fe ff ff       	jmp    800309 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 78 04             	lea    0x4(%eax),%edi
  800411:	8b 00                	mov    (%eax),%eax
  800413:	99                   	cltd   
  800414:	31 d0                	xor    %edx,%eax
  800416:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800418:	83 f8 08             	cmp    $0x8,%eax
  80041b:	7f 0b                	jg     800428 <vprintfmt+0x145>
  80041d:	8b 14 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%edx
  800424:	85 d2                	test   %edx,%edx
  800426:	75 1b                	jne    800443 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800428:	50                   	push   %eax
  800429:	68 94 11 80 00       	push   $0x801194
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 91 fe ff ff       	call   8002c6 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800438:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043e:	e9 c6 fe ff ff       	jmp    800309 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 9d 11 80 00       	push   $0x80119d
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 76 fe ff ff       	call   8002c6 <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800459:	e9 ab fe ff ff       	jmp    800309 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	83 c0 04             	add    $0x4,%eax
  800464:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046c:	85 ff                	test   %edi,%edi
  80046e:	b8 8d 11 80 00       	mov    $0x80118d,%eax
  800473:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	0f 8e 94 00 00 00    	jle    800514 <vprintfmt+0x231>
  800480:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800484:	0f 84 98 00 00 00    	je     800522 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 d0             	pushl  -0x30(%ebp)
  800490:	57                   	push   %edi
  800491:	e8 33 03 00 00       	call   8007c9 <strnlen>
  800496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800499:	29 c1                	sub    %eax,%ecx
  80049b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80049e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	eb 0f                	jmp    8004be <vprintfmt+0x1db>
					putch(padc, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	53                   	push   %ebx
  8004b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	83 ef 01             	sub    $0x1,%edi
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	85 ff                	test   %edi,%edi
  8004c0:	7f ed                	jg     8004af <vprintfmt+0x1cc>
  8004c2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	0f 49 c1             	cmovns %ecx,%eax
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dd:	89 cb                	mov    %ecx,%ebx
  8004df:	eb 4d                	jmp    80052e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e5:	74 1b                	je     800502 <vprintfmt+0x21f>
  8004e7:	0f be c0             	movsbl %al,%eax
  8004ea:	83 e8 20             	sub    $0x20,%eax
  8004ed:	83 f8 5e             	cmp    $0x5e,%eax
  8004f0:	76 10                	jbe    800502 <vprintfmt+0x21f>
					putch('?', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	6a 3f                	push   $0x3f
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb 0d                	jmp    80050f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	52                   	push   %edx
  800509:	ff 55 08             	call   *0x8(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 eb 01             	sub    $0x1,%ebx
  800512:	eb 1a                	jmp    80052e <vprintfmt+0x24b>
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800520:	eb 0c                	jmp    80052e <vprintfmt+0x24b>
  800522:	89 75 08             	mov    %esi,0x8(%ebp)
  800525:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	0f be d0             	movsbl %al,%edx
  800538:	85 d2                	test   %edx,%edx
  80053a:	74 23                	je     80055f <vprintfmt+0x27c>
  80053c:	85 f6                	test   %esi,%esi
  80053e:	78 a1                	js     8004e1 <vprintfmt+0x1fe>
  800540:	83 ee 01             	sub    $0x1,%esi
  800543:	79 9c                	jns    8004e1 <vprintfmt+0x1fe>
  800545:	89 df                	mov    %ebx,%edi
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	eb 18                	jmp    800567 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 20                	push   $0x20
  800555:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 08                	jmp    800567 <vprintfmt+0x284>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	85 ff                	test   %edi,%edi
  800569:	7f e4                	jg     80054f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800574:	e9 90 fd ff ff       	jmp    800309 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800579:	83 f9 01             	cmp    $0x1,%ecx
  80057c:	7e 19                	jle    800597 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 50 04             	mov    0x4(%eax),%edx
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 08             	lea    0x8(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	eb 38                	jmp    8005cf <vprintfmt+0x2ec>
	else if (lflag)
  800597:	85 c9                	test   %ecx,%ecx
  800599:	74 1b                	je     8005b6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	89 c1                	mov    %eax,%ecx
  8005a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 40 04             	lea    0x4(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b4:	eb 19                	jmp    8005cf <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 c1                	mov    %eax,%ecx
  8005c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 40 04             	lea    0x4(%eax),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005de:	0f 89 0e 01 00 00    	jns    8006f2 <vprintfmt+0x40f>
				putch('-', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	53                   	push   %ebx
  8005e8:	6a 2d                	push   $0x2d
  8005ea:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005f2:	f7 da                	neg    %edx
  8005f4:	83 d1 00             	adc    $0x0,%ecx
  8005f7:	f7 d9                	neg    %ecx
  8005f9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800601:	e9 ec 00 00 00       	jmp    8006f2 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800606:	83 f9 01             	cmp    $0x1,%ecx
  800609:	7e 18                	jle    800623 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	8b 48 04             	mov    0x4(%eax),%ecx
  800613:	8d 40 08             	lea    0x8(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 cf 00 00 00       	jmp    8006f2 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800623:	85 c9                	test   %ecx,%ecx
  800625:	74 1a                	je     800641 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063c:	e9 b1 00 00 00       	jmp    8006f2 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
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
  800656:	e9 97 00 00 00       	jmp    8006f2 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 58                	push   $0x58
  800661:	ff d6                	call   *%esi
			putch('X', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 58                	push   $0x58
  800669:	ff d6                	call   *%esi
			putch('X', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 58                	push   $0x58
  800671:	ff d6                	call   *%esi
			break;
  800673:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800679:	e9 8b fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 30                	push   $0x30
  800684:	ff d6                	call   *%esi
			putch('x', putdat);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 78                	push   $0x78
  80068c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 10                	mov    (%eax),%edx
  800693:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800698:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069b:	8d 40 04             	lea    0x4(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a6:	eb 4a                	jmp    8006f2 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a8:	83 f9 01             	cmp    $0x1,%ecx
  8006ab:	7e 15                	jle    8006c2 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b5:	8d 40 08             	lea    0x8(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c0:	eb 30                	jmp    8006f2 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006c2:	85 c9                	test   %ecx,%ecx
  8006c4:	74 17                	je     8006dd <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006db:	eb 15                	jmp    8006f2 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ed:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f2:	83 ec 0c             	sub    $0xc,%esp
  8006f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f9:	57                   	push   %edi
  8006fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fd:	50                   	push   %eax
  8006fe:	51                   	push   %ecx
  8006ff:	52                   	push   %edx
  800700:	89 da                	mov    %ebx,%edx
  800702:	89 f0                	mov    %esi,%eax
  800704:	e8 f1 fa ff ff       	call   8001fa <printnum>
			break;
  800709:	83 c4 20             	add    $0x20,%esp
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070f:	e9 f5 fb ff ff       	jmp    800309 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	52                   	push   %edx
  800719:	ff d6                	call   *%esi
			break;
  80071b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800721:	e9 e3 fb ff ff       	jmp    800309 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 25                	push   $0x25
  80072c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 03                	jmp    800736 <vprintfmt+0x453>
  800733:	83 ef 01             	sub    $0x1,%edi
  800736:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073a:	75 f7                	jne    800733 <vprintfmt+0x450>
  80073c:	e9 c8 fb ff ff       	jmp    800309 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800758:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800766:	85 c0                	test   %eax,%eax
  800768:	74 26                	je     800790 <vsnprintf+0x47>
  80076a:	85 d2                	test   %edx,%edx
  80076c:	7e 22                	jle    800790 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076e:	ff 75 14             	pushl  0x14(%ebp)
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	68 a9 02 80 00       	push   $0x8002a9
  80077d:	e8 61 fb ff ff       	call   8002e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800782:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800785:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 05                	jmp    800795 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a0:	50                   	push   %eax
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 9a ff ff ff       	call   800749 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	eb 03                	jmp    8007c1 <strlen+0x10>
		n++;
  8007be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c5:	75 f7                	jne    8007be <strlen+0xd>
		n++;
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	eb 03                	jmp    8007dc <strnlen+0x13>
		n++;
  8007d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	39 c2                	cmp    %eax,%edx
  8007de:	74 08                	je     8007e8 <strnlen+0x1f>
  8007e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e4:	75 f3                	jne    8007d9 <strnlen+0x10>
  8007e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800800:	88 5a ff             	mov    %bl,-0x1(%edx)
  800803:	84 db                	test   %bl,%bl
  800805:	75 ef                	jne    8007f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	53                   	push   %ebx
  800812:	e8 9a ff ff ff       	call   8007b1 <strlen>
  800817:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081a:	ff 75 0c             	pushl  0xc(%ebp)
  80081d:	01 d8                	add    %ebx,%eax
  80081f:	50                   	push   %eax
  800820:	e8 c5 ff ff ff       	call   8007ea <strcpy>
	return dst;
}
  800825:	89 d8                	mov    %ebx,%eax
  800827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	89 f3                	mov    %esi,%ebx
  800839:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 0f                	jmp    80084f <strncpy+0x23>
		*dst++ = *src;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800849:	80 39 01             	cmpb   $0x1,(%ecx)
  80084c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084f:	39 da                	cmp    %ebx,%edx
  800851:	75 ed                	jne    800840 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800853:	89 f0                	mov    %esi,%eax
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	8b 55 10             	mov    0x10(%ebp),%edx
  800867:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 21                	je     80088e <strlcpy+0x35>
  80086d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800871:	89 f2                	mov    %esi,%edx
  800873:	eb 09                	jmp    80087e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800875:	83 c2 01             	add    $0x1,%edx
  800878:	83 c1 01             	add    $0x1,%ecx
  80087b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087e:	39 c2                	cmp    %eax,%edx
  800880:	74 09                	je     80088b <strlcpy+0x32>
  800882:	0f b6 19             	movzbl (%ecx),%ebx
  800885:	84 db                	test   %bl,%bl
  800887:	75 ec                	jne    800875 <strlcpy+0x1c>
  800889:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088e:	29 f0                	sub    %esi,%eax
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strcmp+0x11>
		p++, q++;
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a5:	0f b6 01             	movzbl (%ecx),%eax
  8008a8:	84 c0                	test   %al,%al
  8008aa:	74 04                	je     8008b0 <strcmp+0x1c>
  8008ac:	3a 02                	cmp    (%edx),%al
  8008ae:	74 ef                	je     80089f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 c0             	movzbl %al,%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c4:	89 c3                	mov    %eax,%ebx
  8008c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c9:	eb 06                	jmp    8008d1 <strncmp+0x17>
		n--, p++, q++;
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	39 d8                	cmp    %ebx,%eax
  8008d3:	74 15                	je     8008ea <strncmp+0x30>
  8008d5:	0f b6 08             	movzbl (%eax),%ecx
  8008d8:	84 c9                	test   %cl,%cl
  8008da:	74 04                	je     8008e0 <strncmp+0x26>
  8008dc:	3a 0a                	cmp    (%edx),%cl
  8008de:	74 eb                	je     8008cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e0:	0f b6 00             	movzbl (%eax),%eax
  8008e3:	0f b6 12             	movzbl (%edx),%edx
  8008e6:	29 d0                	sub    %edx,%eax
  8008e8:	eb 05                	jmp    8008ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	eb 07                	jmp    800905 <strchr+0x13>
		if (*s == c)
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	74 0f                	je     800911 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	75 f2                	jne    8008fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	eb 03                	jmp    800922 <strfind+0xf>
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 04                	je     80092d <strfind+0x1a>
  800929:	84 d2                	test   %dl,%dl
  80092b:	75 f2                	jne    80091f <strfind+0xc>
			break;
	return (char *) s;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 36                	je     800975 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800945:	75 28                	jne    80096f <memset+0x40>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 23                	jne    80096f <memset+0x40>
		c &= 0xFF;
  80094c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800950:	89 d3                	mov    %edx,%ebx
  800952:	c1 e3 08             	shl    $0x8,%ebx
  800955:	89 d6                	mov    %edx,%esi
  800957:	c1 e6 18             	shl    $0x18,%esi
  80095a:	89 d0                	mov    %edx,%eax
  80095c:	c1 e0 10             	shl    $0x10,%eax
  80095f:	09 f0                	or     %esi,%eax
  800961:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800963:	89 d8                	mov    %ebx,%eax
  800965:	09 d0                	or     %edx,%eax
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	fc                   	cld    
  80096b:	f3 ab                	rep stos %eax,%es:(%edi)
  80096d:	eb 06                	jmp    800975 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 35                	jae    8009c3 <memmove+0x47>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 d0                	cmp    %edx,%eax
  800993:	73 2e                	jae    8009c3 <memmove+0x47>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	89 d6                	mov    %edx,%esi
  80099a:	09 fe                	or     %edi,%esi
  80099c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a2:	75 13                	jne    8009b7 <memmove+0x3b>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0e                	jne    8009b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 09                	jmp    8009c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b7:	83 ef 01             	sub    $0x1,%edi
  8009ba:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bd:	fd                   	std    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c0:	fc                   	cld    
  8009c1:	eb 1d                	jmp    8009e0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	09 c2                	or     %eax,%edx
  8009c7:	f6 c2 03             	test   $0x3,%dl
  8009ca:	75 0f                	jne    8009db <memmove+0x5f>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0a                	jne    8009db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	fc                   	cld    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb 05                	jmp    8009e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e7:	ff 75 10             	pushl  0x10(%ebp)
  8009ea:	ff 75 0c             	pushl  0xc(%ebp)
  8009ed:	ff 75 08             	pushl  0x8(%ebp)
  8009f0:	e8 87 ff ff ff       	call   80097c <memmove>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	eb 1a                	jmp    800a23 <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	0f b6 08             	movzbl (%eax),%ecx
  800a0c:	0f b6 1a             	movzbl (%edx),%ebx
  800a0f:	38 d9                	cmp    %bl,%cl
  800a11:	74 0a                	je     800a1d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a13:	0f b6 c1             	movzbl %cl,%eax
  800a16:	0f b6 db             	movzbl %bl,%ebx
  800a19:	29 d8                	sub    %ebx,%eax
  800a1b:	eb 0f                	jmp    800a2c <memcmp+0x35>
		s1++, s2++;
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	39 f0                	cmp    %esi,%eax
  800a25:	75 e2                	jne    800a09 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a37:	89 c1                	mov    %eax,%ecx
  800a39:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a40:	eb 0a                	jmp    800a4c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a42:	0f b6 10             	movzbl (%eax),%edx
  800a45:	39 da                	cmp    %ebx,%edx
  800a47:	74 07                	je     800a50 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	39 c8                	cmp    %ecx,%eax
  800a4e:	72 f2                	jb     800a42 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	eb 03                	jmp    800a64 <strtol+0x11>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	3c 20                	cmp    $0x20,%al
  800a69:	74 f6                	je     800a61 <strtol+0xe>
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f2                	je     800a61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	75 0a                	jne    800a7d <strtol+0x2a>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb 11                	jmp    800a8e <strtol+0x3b>
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a82:	3c 2d                	cmp    $0x2d,%al
  800a84:	75 08                	jne    800a8e <strtol+0x3b>
		s++, neg = 1;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a94:	75 15                	jne    800aab <strtol+0x58>
  800a96:	80 39 30             	cmpb   $0x30,(%ecx)
  800a99:	75 10                	jne    800aab <strtol+0x58>
  800a9b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9f:	75 7c                	jne    800b1d <strtol+0xca>
		s += 2, base = 16;
  800aa1:	83 c1 02             	add    $0x2,%ecx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 16                	jmp    800ac1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 12                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aaf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	75 08                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac9:	0f b6 11             	movzbl (%ecx),%edx
  800acc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x8b>
			dig = *s - '0';
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 30             	sub    $0x30,%edx
  800adc:	eb 22                	jmp    800b00 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 57             	sub    $0x57,%edx
  800aee:	eb 10                	jmp    800b00 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 16                	ja     800b10 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b00:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b03:	7d 0b                	jge    800b10 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0e:	eb b9                	jmp    800ac9 <strtol+0x76>

	if (endptr)
  800b10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b14:	74 0d                	je     800b23 <strtol+0xd0>
		*endptr = (char *) s;
  800b16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b19:	89 0e                	mov    %ecx,(%esi)
  800b1b:	eb 06                	jmp    800b23 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1d:	85 db                	test   %ebx,%ebx
  800b1f:	74 98                	je     800ab9 <strtol+0x66>
  800b21:	eb 9e                	jmp    800ac1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	f7 da                	neg    %edx
  800b27:	85 ff                	test   %edi,%edi
  800b29:	0f 45 c2             	cmovne %edx,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	89 c6                	mov    %eax,%esi
  800b48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b81:	8b 55 08             	mov    0x8(%ebp),%edx
  800b84:	89 cb                	mov    %ecx,%ebx
  800b86:	89 cf                	mov    %ecx,%edi
  800b88:	89 ce                	mov    %ecx,%esi
  800b8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 17                	jle    800ba7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 03                	push   $0x3
  800b96:	68 c4 13 80 00       	push   $0x8013c4
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 e1 13 80 00       	push   $0x8013e1
  800ba2:	e8 66 f5 ff ff       	call   80010d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 17                	jle    800c28 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 04                	push   $0x4
  800c17:	68 c4 13 80 00       	push   $0x8013c4
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 e1 13 80 00       	push   $0x8013e1
  800c23:	e8 e5 f4 ff ff       	call   80010d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 05                	push   $0x5
  800c59:	68 c4 13 80 00       	push   $0x8013c4
  800c5e:	6a 23                	push   $0x23
  800c60:	68 e1 13 80 00       	push   $0x8013e1
  800c65:	e8 a3 f4 ff ff       	call   80010d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	b8 06 00 00 00       	mov    $0x6,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 06                	push   $0x6
  800c9b:	68 c4 13 80 00       	push   $0x8013c4
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 e1 13 80 00       	push   $0x8013e1
  800ca7:	e8 61 f4 ff ff       	call   80010d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 08                	push   $0x8
  800cdd:	68 c4 13 80 00       	push   $0x8013c4
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 e1 13 80 00       	push   $0x8013e1
  800ce9:	e8 1f f4 ff ff       	call   80010d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	b8 09 00 00 00       	mov    $0x9,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 17                	jle    800d30 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 09                	push   $0x9
  800d1f:	68 c4 13 80 00       	push   $0x8013c4
  800d24:	6a 23                	push   $0x23
  800d26:	68 e1 13 80 00       	push   $0x8013e1
  800d2b:	e8 dd f3 ff ff       	call   80010d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	be 00 00 00 00       	mov    $0x0,%esi
  800d43:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d54:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d69:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 cb                	mov    %ecx,%ebx
  800d73:	89 cf                	mov    %ecx,%edi
  800d75:	89 ce                	mov    %ecx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 0c                	push   $0xc
  800d83:	68 c4 13 80 00       	push   $0x8013c4
  800d88:	6a 23                	push   $0x23
  800d8a:	68 e1 13 80 00       	push   $0x8013e1
  800d8f:	e8 79 f3 ff ff       	call   80010d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  800da3:	e8 07 fe ff ff       	call   800baf <sys_getenvid>
  800da8:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800daa:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800db1:	75 29                	jne    800ddc <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	6a 07                	push   $0x7
  800db8:	68 00 f0 bf ee       	push   $0xeebff000
  800dbd:	50                   	push   %eax
  800dbe:	e8 2a fe ff ff       	call   800bed <sys_page_alloc>
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	79 12                	jns    800ddc <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  800dca:	50                   	push   %eax
  800dcb:	68 ef 13 80 00       	push   $0x8013ef
  800dd0:	6a 24                	push   $0x24
  800dd2:	68 08 14 80 00       	push   $0x801408
  800dd7:	e8 31 f3 ff ff       	call   80010d <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	a3 08 20 80 00       	mov    %eax,0x802008
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	68 10 0e 80 00       	push   $0x800e10
  800dec:	53                   	push   %ebx
  800ded:	e8 04 ff ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	79 12                	jns    800e0b <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  800df9:	50                   	push   %eax
  800dfa:	68 ef 13 80 00       	push   $0x8013ef
  800dff:	6a 2e                	push   $0x2e
  800e01:	68 08 14 80 00       	push   $0x801408
  800e06:	e8 02 f3 ff ff       	call   80010d <_panic>
}
  800e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    

00800e10 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e10:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e11:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e16:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e18:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800e1b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800e1f:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  800e22:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800e26:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  800e28:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e2c:	83 c4 08             	add    $0x8,%esp
	popal
  800e2f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e30:	83 c4 04             	add    $0x4,%esp
	popfl
  800e33:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  800e34:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e35:	c3                   	ret    
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__udivdi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 f6                	test   %esi,%esi
  800e59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e5d:	89 ca                	mov    %ecx,%edx
  800e5f:	89 f8                	mov    %edi,%eax
  800e61:	75 3d                	jne    800ea0 <__udivdi3+0x60>
  800e63:	39 cf                	cmp    %ecx,%edi
  800e65:	0f 87 c5 00 00 00    	ja     800f30 <__udivdi3+0xf0>
  800e6b:	85 ff                	test   %edi,%edi
  800e6d:	89 fd                	mov    %edi,%ebp
  800e6f:	75 0b                	jne    800e7c <__udivdi3+0x3c>
  800e71:	b8 01 00 00 00       	mov    $0x1,%eax
  800e76:	31 d2                	xor    %edx,%edx
  800e78:	f7 f7                	div    %edi
  800e7a:	89 c5                	mov    %eax,%ebp
  800e7c:	89 c8                	mov    %ecx,%eax
  800e7e:	31 d2                	xor    %edx,%edx
  800e80:	f7 f5                	div    %ebp
  800e82:	89 c1                	mov    %eax,%ecx
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	89 cf                	mov    %ecx,%edi
  800e88:	f7 f5                	div    %ebp
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	89 d8                	mov    %ebx,%eax
  800e8e:	89 fa                	mov    %edi,%edx
  800e90:	83 c4 1c             	add    $0x1c,%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    
  800e98:	90                   	nop
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 ce                	cmp    %ecx,%esi
  800ea2:	77 74                	ja     800f18 <__udivdi3+0xd8>
  800ea4:	0f bd fe             	bsr    %esi,%edi
  800ea7:	83 f7 1f             	xor    $0x1f,%edi
  800eaa:	0f 84 98 00 00 00    	je     800f48 <__udivdi3+0x108>
  800eb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	89 c5                	mov    %eax,%ebp
  800eb9:	29 fb                	sub    %edi,%ebx
  800ebb:	d3 e6                	shl    %cl,%esi
  800ebd:	89 d9                	mov    %ebx,%ecx
  800ebf:	d3 ed                	shr    %cl,%ebp
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	d3 e0                	shl    %cl,%eax
  800ec5:	09 ee                	or     %ebp,%esi
  800ec7:	89 d9                	mov    %ebx,%ecx
  800ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ecd:	89 d5                	mov    %edx,%ebp
  800ecf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ed3:	d3 ed                	shr    %cl,%ebp
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 e2                	shl    %cl,%edx
  800ed9:	89 d9                	mov    %ebx,%ecx
  800edb:	d3 e8                	shr    %cl,%eax
  800edd:	09 c2                	or     %eax,%edx
  800edf:	89 d0                	mov    %edx,%eax
  800ee1:	89 ea                	mov    %ebp,%edx
  800ee3:	f7 f6                	div    %esi
  800ee5:	89 d5                	mov    %edx,%ebp
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	f7 64 24 0c          	mull   0xc(%esp)
  800eed:	39 d5                	cmp    %edx,%ebp
  800eef:	72 10                	jb     800f01 <__udivdi3+0xc1>
  800ef1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ef5:	89 f9                	mov    %edi,%ecx
  800ef7:	d3 e6                	shl    %cl,%esi
  800ef9:	39 c6                	cmp    %eax,%esi
  800efb:	73 07                	jae    800f04 <__udivdi3+0xc4>
  800efd:	39 d5                	cmp    %edx,%ebp
  800eff:	75 03                	jne    800f04 <__udivdi3+0xc4>
  800f01:	83 eb 01             	sub    $0x1,%ebx
  800f04:	31 ff                	xor    %edi,%edi
  800f06:	89 d8                	mov    %ebx,%eax
  800f08:	89 fa                	mov    %edi,%edx
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
  800f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f18:	31 ff                	xor    %edi,%edi
  800f1a:	31 db                	xor    %ebx,%ebx
  800f1c:	89 d8                	mov    %ebx,%eax
  800f1e:	89 fa                	mov    %edi,%edx
  800f20:	83 c4 1c             	add    $0x1c,%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
  800f28:	90                   	nop
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	f7 f7                	div    %edi
  800f34:	31 ff                	xor    %edi,%edi
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	89 fa                	mov    %edi,%edx
  800f3c:	83 c4 1c             	add    $0x1c,%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	39 ce                	cmp    %ecx,%esi
  800f4a:	72 0c                	jb     800f58 <__udivdi3+0x118>
  800f4c:	31 db                	xor    %ebx,%ebx
  800f4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f52:	0f 87 34 ff ff ff    	ja     800e8c <__udivdi3+0x4c>
  800f58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f5d:	e9 2a ff ff ff       	jmp    800e8c <__udivdi3+0x4c>
  800f62:	66 90                	xchg   %ax,%ax
  800f64:	66 90                	xchg   %ax,%ax
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 1c             	sub    $0x1c,%esp
  800f77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f87:	85 d2                	test   %edx,%edx
  800f89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f91:	89 f3                	mov    %esi,%ebx
  800f93:	89 3c 24             	mov    %edi,(%esp)
  800f96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9a:	75 1c                	jne    800fb8 <__umoddi3+0x48>
  800f9c:	39 f7                	cmp    %esi,%edi
  800f9e:	76 50                	jbe    800ff0 <__umoddi3+0x80>
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	f7 f7                	div    %edi
  800fa6:	89 d0                	mov    %edx,%eax
  800fa8:	31 d2                	xor    %edx,%edx
  800faa:	83 c4 1c             	add    $0x1c,%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	39 f2                	cmp    %esi,%edx
  800fba:	89 d0                	mov    %edx,%eax
  800fbc:	77 52                	ja     801010 <__umoddi3+0xa0>
  800fbe:	0f bd ea             	bsr    %edx,%ebp
  800fc1:	83 f5 1f             	xor    $0x1f,%ebp
  800fc4:	75 5a                	jne    801020 <__umoddi3+0xb0>
  800fc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fca:	0f 82 e0 00 00 00    	jb     8010b0 <__umoddi3+0x140>
  800fd0:	39 0c 24             	cmp    %ecx,(%esp)
  800fd3:	0f 86 d7 00 00 00    	jbe    8010b0 <__umoddi3+0x140>
  800fd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fe1:	83 c4 1c             	add    $0x1c,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    
  800fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	85 ff                	test   %edi,%edi
  800ff2:	89 fd                	mov    %edi,%ebp
  800ff4:	75 0b                	jne    801001 <__umoddi3+0x91>
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f7                	div    %edi
  800fff:	89 c5                	mov    %eax,%ebp
  801001:	89 f0                	mov    %esi,%eax
  801003:	31 d2                	xor    %edx,%edx
  801005:	f7 f5                	div    %ebp
  801007:	89 c8                	mov    %ecx,%eax
  801009:	f7 f5                	div    %ebp
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	eb 99                	jmp    800fa8 <__umoddi3+0x38>
  80100f:	90                   	nop
  801010:	89 c8                	mov    %ecx,%eax
  801012:	89 f2                	mov    %esi,%edx
  801014:	83 c4 1c             	add    $0x1c,%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	8b 34 24             	mov    (%esp),%esi
  801023:	bf 20 00 00 00       	mov    $0x20,%edi
  801028:	89 e9                	mov    %ebp,%ecx
  80102a:	29 ef                	sub    %ebp,%edi
  80102c:	d3 e0                	shl    %cl,%eax
  80102e:	89 f9                	mov    %edi,%ecx
  801030:	89 f2                	mov    %esi,%edx
  801032:	d3 ea                	shr    %cl,%edx
  801034:	89 e9                	mov    %ebp,%ecx
  801036:	09 c2                	or     %eax,%edx
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	89 14 24             	mov    %edx,(%esp)
  80103d:	89 f2                	mov    %esi,%edx
  80103f:	d3 e2                	shl    %cl,%edx
  801041:	89 f9                	mov    %edi,%ecx
  801043:	89 54 24 04          	mov    %edx,0x4(%esp)
  801047:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80104b:	d3 e8                	shr    %cl,%eax
  80104d:	89 e9                	mov    %ebp,%ecx
  80104f:	89 c6                	mov    %eax,%esi
  801051:	d3 e3                	shl    %cl,%ebx
  801053:	89 f9                	mov    %edi,%ecx
  801055:	89 d0                	mov    %edx,%eax
  801057:	d3 e8                	shr    %cl,%eax
  801059:	89 e9                	mov    %ebp,%ecx
  80105b:	09 d8                	or     %ebx,%eax
  80105d:	89 d3                	mov    %edx,%ebx
  80105f:	89 f2                	mov    %esi,%edx
  801061:	f7 34 24             	divl   (%esp)
  801064:	89 d6                	mov    %edx,%esi
  801066:	d3 e3                	shl    %cl,%ebx
  801068:	f7 64 24 04          	mull   0x4(%esp)
  80106c:	39 d6                	cmp    %edx,%esi
  80106e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801072:	89 d1                	mov    %edx,%ecx
  801074:	89 c3                	mov    %eax,%ebx
  801076:	72 08                	jb     801080 <__umoddi3+0x110>
  801078:	75 11                	jne    80108b <__umoddi3+0x11b>
  80107a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80107e:	73 0b                	jae    80108b <__umoddi3+0x11b>
  801080:	2b 44 24 04          	sub    0x4(%esp),%eax
  801084:	1b 14 24             	sbb    (%esp),%edx
  801087:	89 d1                	mov    %edx,%ecx
  801089:	89 c3                	mov    %eax,%ebx
  80108b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80108f:	29 da                	sub    %ebx,%edx
  801091:	19 ce                	sbb    %ecx,%esi
  801093:	89 f9                	mov    %edi,%ecx
  801095:	89 f0                	mov    %esi,%eax
  801097:	d3 e0                	shl    %cl,%eax
  801099:	89 e9                	mov    %ebp,%ecx
  80109b:	d3 ea                	shr    %cl,%edx
  80109d:	89 e9                	mov    %ebp,%ecx
  80109f:	d3 ee                	shr    %cl,%esi
  8010a1:	09 d0                	or     %edx,%eax
  8010a3:	89 f2                	mov    %esi,%edx
  8010a5:	83 c4 1c             	add    $0x1c,%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    
  8010ad:	8d 76 00             	lea    0x0(%esi),%esi
  8010b0:	29 f9                	sub    %edi,%ecx
  8010b2:	19 d6                	sbb    %edx,%esi
  8010b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010bc:	e9 18 ff ff ff       	jmp    800fd9 <__umoddi3+0x69>
