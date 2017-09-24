
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 c9 00 00 00       	call   80011b <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005a:	c1 e0 05             	shl    $0x5,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0a 00 00 00       	call   80008b <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 42 00 00 00       	call   8000da <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	89 c3                	mov    %eax,%ebx
  8000b0:	89 c7                	mov    %eax,%edi
  8000b2:	89 c6                	mov    %eax,%esi
  8000b4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	89 d3                	mov    %edx,%ebx
  8000cf:	89 d7                	mov    %edx,%edi
  8000d1:	89 d6                	mov    %edx,%esi
  8000d3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	89 cb                	mov    %ecx,%ebx
  8000f2:	89 cf                	mov    %ecx,%edi
  8000f4:	89 ce                	mov    %ecx,%esi
  8000f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	7e 17                	jle    800113 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	6a 03                	push   $0x3
  800102:	68 ee 0d 80 00       	push   $0x800dee
  800107:	6a 23                	push   $0x23
  800109:	68 0b 0e 80 00       	push   $0x800e0b
  80010e:	e8 27 00 00 00       	call   80013a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800121:	ba 00 00 00 00       	mov    $0x0,%edx
  800126:	b8 02 00 00 00       	mov    $0x2,%eax
  80012b:	89 d1                	mov    %edx,%ecx
  80012d:	89 d3                	mov    %edx,%ebx
  80012f:	89 d7                	mov    %edx,%edi
  800131:	89 d6                	mov    %edx,%esi
  800133:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800142:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800148:	e8 ce ff ff ff       	call   80011b <sys_getenvid>
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	ff 75 0c             	pushl  0xc(%ebp)
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	56                   	push   %esi
  800157:	50                   	push   %eax
  800158:	68 1c 0e 80 00       	push   $0x800e1c
  80015d:	e8 b1 00 00 00       	call   800213 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800162:	83 c4 18             	add    $0x18,%esp
  800165:	53                   	push   %ebx
  800166:	ff 75 10             	pushl  0x10(%ebp)
  800169:	e8 54 00 00 00       	call   8001c2 <vcprintf>
	cprintf("\n");
  80016e:	c7 04 24 40 0e 80 00 	movl   $0x800e40,(%esp)
  800175:	e8 99 00 00 00       	call   800213 <cprintf>
  80017a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017d:	cc                   	int3   
  80017e:	eb fd                	jmp    80017d <_panic+0x43>

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 13                	mov    (%ebx),%edx
  80018c:	8d 42 01             	lea    0x1(%edx),%eax
  80018f:	89 03                	mov    %eax,(%ebx)
  800191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	75 1a                	jne    8001b9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	68 ff 00 00 00       	push   $0xff
  8001a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 ed fe ff ff       	call   80009d <sys_cputs>
		b->idx = 0;
  8001b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d2:	00 00 00 
	b.cnt = 0;
  8001d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001eb:	50                   	push   %eax
  8001ec:	68 80 01 80 00       	push   $0x800180
  8001f1:	e8 1a 01 00 00       	call   800310 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f6:	83 c4 08             	add    $0x8,%esp
  8001f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	e8 92 fe ff ff       	call   80009d <sys_cputs>

	return b.cnt;
}
  80020b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800219:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021c:	50                   	push   %eax
  80021d:	ff 75 08             	pushl  0x8(%ebp)
  800220:	e8 9d ff ff ff       	call   8001c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 1c             	sub    $0x1c,%esp
  800230:	89 c7                	mov    %eax,%edi
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800243:	bb 00 00 00 00       	mov    $0x0,%ebx
  800248:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024e:	39 d3                	cmp    %edx,%ebx
  800250:	72 05                	jb     800257 <printnum+0x30>
  800252:	39 45 10             	cmp    %eax,0x10(%ebp)
  800255:	77 45                	ja     80029c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 18             	pushl  0x18(%ebp)
  80025d:	8b 45 14             	mov    0x14(%ebp),%eax
  800260:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800263:	53                   	push   %ebx
  800264:	ff 75 10             	pushl  0x10(%ebp)
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 e5 08 00 00       	call   800b60 <__udivdi3>
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	52                   	push   %edx
  80027f:	50                   	push   %eax
  800280:	89 f2                	mov    %esi,%edx
  800282:	89 f8                	mov    %edi,%eax
  800284:	e8 9e ff ff ff       	call   800227 <printnum>
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 18                	jmp    8002a6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	ff d7                	call   *%edi
  800297:	83 c4 10             	add    $0x10,%esp
  80029a:	eb 03                	jmp    80029f <printnum+0x78>
  80029c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	83 eb 01             	sub    $0x1,%ebx
  8002a2:	85 db                	test   %ebx,%ebx
  8002a4:	7f e8                	jg     80028e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	56                   	push   %esi
  8002aa:	83 ec 04             	sub    $0x4,%esp
  8002ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	e8 d2 09 00 00       	call   800c90 <__umoddi3>
  8002be:	83 c4 14             	add    $0x14,%esp
  8002c1:	0f be 80 42 0e 80 00 	movsbl 0x800e42(%eax),%eax
  8002c8:	50                   	push   %eax
  8002c9:	ff d7                	call   *%edi
}
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e5:	73 0a                	jae    8002f1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	88 02                	mov    %al,(%edx)
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fc:	50                   	push   %eax
  8002fd:	ff 75 10             	pushl  0x10(%ebp)
  800300:	ff 75 0c             	pushl  0xc(%ebp)
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 05 00 00 00       	call   800310 <vprintfmt>
	va_end(ap);
}
  80030b:	83 c4 10             	add    $0x10,%esp
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 2c             	sub    $0x2c,%esp
  800319:	8b 75 08             	mov    0x8(%ebp),%esi
  80031c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800322:	eb 12                	jmp    800336 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800324:	85 c0                	test   %eax,%eax
  800326:	0f 84 42 04 00 00    	je     80076e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	53                   	push   %ebx
  800330:	50                   	push   %eax
  800331:	ff d6                	call   *%esi
  800333:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800336:	83 c7 01             	add    $0x1,%edi
  800339:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033d:	83 f8 25             	cmp    $0x25,%eax
  800340:	75 e2                	jne    800324 <vprintfmt+0x14>
  800342:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800346:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800354:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800360:	eb 07                	jmp    800369 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800365:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8d 47 01             	lea    0x1(%edi),%eax
  80036c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036f:	0f b6 07             	movzbl (%edi),%eax
  800372:	0f b6 d0             	movzbl %al,%edx
  800375:	83 e8 23             	sub    $0x23,%eax
  800378:	3c 55                	cmp    $0x55,%al
  80037a:	0f 87 d3 03 00 00    	ja     800753 <vprintfmt+0x443>
  800380:	0f b6 c0             	movzbl %al,%eax
  800383:	ff 24 85 d0 0e 80 00 	jmp    *0x800ed0(,%eax,4)
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800391:	eb d6                	jmp    800369 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	b8 00 00 00 00       	mov    $0x0,%eax
  80039b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ab:	83 f9 09             	cmp    $0x9,%ecx
  8003ae:	77 3f                	ja     8003ef <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b3:	eb e9                	jmp    80039e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 40 04             	lea    0x4(%eax),%eax
  8003c3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c9:	eb 2a                	jmp    8003f5 <vprintfmt+0xe5>
  8003cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d5:	0f 49 d0             	cmovns %eax,%edx
  8003d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003de:	eb 89                	jmp    800369 <vprintfmt+0x59>
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ea:	e9 7a ff ff ff       	jmp    800369 <vprintfmt+0x59>
  8003ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f9:	0f 89 6a ff ff ff    	jns    800369 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800402:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800405:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040c:	e9 58 ff ff ff       	jmp    800369 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800411:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800417:	e9 4d ff ff ff       	jmp    800369 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	53                   	push   %ebx
  800426:	ff 30                	pushl  (%eax)
  800428:	ff d6                	call   *%esi
			break;
  80042a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800433:	e9 fe fe ff ff       	jmp    800336 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 78 04             	lea    0x4(%eax),%edi
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	99                   	cltd   
  800441:	31 d0                	xor    %edx,%eax
  800443:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800445:	83 f8 06             	cmp    $0x6,%eax
  800448:	7f 0b                	jg     800455 <vprintfmt+0x145>
  80044a:	8b 14 85 28 10 80 00 	mov    0x801028(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	75 1b                	jne    800470 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800455:	50                   	push   %eax
  800456:	68 5a 0e 80 00       	push   $0x800e5a
  80045b:	53                   	push   %ebx
  80045c:	56                   	push   %esi
  80045d:	e8 91 fe ff ff       	call   8002f3 <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800465:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046b:	e9 c6 fe ff ff       	jmp    800336 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800470:	52                   	push   %edx
  800471:	68 63 0e 80 00       	push   $0x800e63
  800476:	53                   	push   %ebx
  800477:	56                   	push   %esi
  800478:	e8 76 fe ff ff       	call   8002f3 <printfmt>
  80047d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800486:	e9 ab fe ff ff       	jmp    800336 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	83 c0 04             	add    $0x4,%eax
  800491:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800499:	85 ff                	test   %edi,%edi
  80049b:	b8 53 0e 80 00       	mov    $0x800e53,%eax
  8004a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a7:	0f 8e 94 00 00 00    	jle    800541 <vprintfmt+0x231>
  8004ad:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b1:	0f 84 98 00 00 00    	je     80054f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bd:	57                   	push   %edi
  8004be:	e8 33 03 00 00       	call   8007f6 <strnlen>
  8004c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c6:	29 c1                	sub    %eax,%ecx
  8004c8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ce:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	eb 0f                	jmp    8004eb <vprintfmt+0x1db>
					putch(padc, putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	83 ef 01             	sub    $0x1,%edi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	85 ff                	test   %edi,%edi
  8004ed:	7f ed                	jg     8004dc <vprintfmt+0x1cc>
  8004ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f5:	85 c9                	test   %ecx,%ecx
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	0f 49 c1             	cmovns %ecx,%eax
  8004ff:	29 c1                	sub    %eax,%ecx
  800501:	89 75 08             	mov    %esi,0x8(%ebp)
  800504:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800507:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050a:	89 cb                	mov    %ecx,%ebx
  80050c:	eb 4d                	jmp    80055b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800512:	74 1b                	je     80052f <vprintfmt+0x21f>
  800514:	0f be c0             	movsbl %al,%eax
  800517:	83 e8 20             	sub    $0x20,%eax
  80051a:	83 f8 5e             	cmp    $0x5e,%eax
  80051d:	76 10                	jbe    80052f <vprintfmt+0x21f>
					putch('?', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	6a 3f                	push   $0x3f
  800527:	ff 55 08             	call   *0x8(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	eb 0d                	jmp    80053c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	52                   	push   %edx
  800536:	ff 55 08             	call   *0x8(%ebp)
  800539:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053c:	83 eb 01             	sub    $0x1,%ebx
  80053f:	eb 1a                	jmp    80055b <vprintfmt+0x24b>
  800541:	89 75 08             	mov    %esi,0x8(%ebp)
  800544:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800547:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054d:	eb 0c                	jmp    80055b <vprintfmt+0x24b>
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055b:	83 c7 01             	add    $0x1,%edi
  80055e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800562:	0f be d0             	movsbl %al,%edx
  800565:	85 d2                	test   %edx,%edx
  800567:	74 23                	je     80058c <vprintfmt+0x27c>
  800569:	85 f6                	test   %esi,%esi
  80056b:	78 a1                	js     80050e <vprintfmt+0x1fe>
  80056d:	83 ee 01             	sub    $0x1,%esi
  800570:	79 9c                	jns    80050e <vprintfmt+0x1fe>
  800572:	89 df                	mov    %ebx,%edi
  800574:	8b 75 08             	mov    0x8(%ebp),%esi
  800577:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057a:	eb 18                	jmp    800594 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	53                   	push   %ebx
  800580:	6a 20                	push   $0x20
  800582:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800584:	83 ef 01             	sub    $0x1,%edi
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	eb 08                	jmp    800594 <vprintfmt+0x284>
  80058c:	89 df                	mov    %ebx,%edi
  80058e:	8b 75 08             	mov    0x8(%ebp),%esi
  800591:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800594:	85 ff                	test   %edi,%edi
  800596:	7f e4                	jg     80057c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800598:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	e9 90 fd ff ff       	jmp    800336 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a6:	83 f9 01             	cmp    $0x1,%ecx
  8005a9:	7e 19                	jle    8005c4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 50 04             	mov    0x4(%eax),%edx
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 08             	lea    0x8(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c2:	eb 38                	jmp    8005fc <vprintfmt+0x2ec>
	else if (lflag)
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	74 1b                	je     8005e3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	89 c1                	mov    %eax,%ecx
  8005d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e1:	eb 19                	jmp    8005fc <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800607:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060b:	0f 89 0e 01 00 00    	jns    80071f <vprintfmt+0x40f>
				putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 2d                	push   $0x2d
  800617:	ff d6                	call   *%esi
				num = -(long long) num;
  800619:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061f:	f7 da                	neg    %edx
  800621:	83 d1 00             	adc    $0x0,%ecx
  800624:	f7 d9                	neg    %ecx
  800626:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062e:	e9 ec 00 00 00       	jmp    80071f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800633:	83 f9 01             	cmp    $0x1,%ecx
  800636:	7e 18                	jle    800650 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8b 48 04             	mov    0x4(%eax),%ecx
  800640:	8d 40 08             	lea    0x8(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 cf 00 00 00       	jmp    80071f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800650:	85 c9                	test   %ecx,%ecx
  800652:	74 1a                	je     80066e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065e:	8d 40 04             	lea    0x4(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800664:	b8 0a 00 00 00       	mov    $0xa,%eax
  800669:	e9 b1 00 00 00       	jmp    80071f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	b9 00 00 00 00       	mov    $0x0,%ecx
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80067e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800683:	e9 97 00 00 00       	jmp    80071f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 58                	push   $0x58
  80068e:	ff d6                	call   *%esi
			putch('X', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 58                	push   $0x58
  800696:	ff d6                	call   *%esi
			putch('X', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 58                	push   $0x58
  80069e:	ff d6                	call   *%esi
			break;
  8006a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a6:	e9 8b fc ff ff       	jmp    800336 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 30                	push   $0x30
  8006b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 78                	push   $0x78
  8006b9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d3:	eb 4a                	jmp    80071f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d5:	83 f9 01             	cmp    $0x1,%ecx
  8006d8:	7e 15                	jle    8006ef <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e2:	8d 40 08             	lea    0x8(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ed:	eb 30                	jmp    80071f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	74 17                	je     80070a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
  800708:	eb 15                	jmp    80071f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071f:	83 ec 0c             	sub    $0xc,%esp
  800722:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800726:	57                   	push   %edi
  800727:	ff 75 e0             	pushl  -0x20(%ebp)
  80072a:	50                   	push   %eax
  80072b:	51                   	push   %ecx
  80072c:	52                   	push   %edx
  80072d:	89 da                	mov    %ebx,%edx
  80072f:	89 f0                	mov    %esi,%eax
  800731:	e8 f1 fa ff ff       	call   800227 <printnum>
			break;
  800736:	83 c4 20             	add    $0x20,%esp
  800739:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073c:	e9 f5 fb ff ff       	jmp    800336 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	52                   	push   %edx
  800746:	ff d6                	call   *%esi
			break;
  800748:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074e:	e9 e3 fb ff ff       	jmp    800336 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 25                	push   $0x25
  800759:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 03                	jmp    800763 <vprintfmt+0x453>
  800760:	83 ef 01             	sub    $0x1,%edi
  800763:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800767:	75 f7                	jne    800760 <vprintfmt+0x450>
  800769:	e9 c8 fb ff ff       	jmp    800336 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800771:	5b                   	pop    %ebx
  800772:	5e                   	pop    %esi
  800773:	5f                   	pop    %edi
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 18             	sub    $0x18,%esp
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800782:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800785:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800789:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800793:	85 c0                	test   %eax,%eax
  800795:	74 26                	je     8007bd <vsnprintf+0x47>
  800797:	85 d2                	test   %edx,%edx
  800799:	7e 22                	jle    8007bd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079b:	ff 75 14             	pushl  0x14(%ebp)
  80079e:	ff 75 10             	pushl  0x10(%ebp)
  8007a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	68 d6 02 80 00       	push   $0x8002d6
  8007aa:	e8 61 fb ff ff       	call   800310 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b8:	83 c4 10             	add    $0x10,%esp
  8007bb:	eb 05                	jmp    8007c2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cd:	50                   	push   %eax
  8007ce:	ff 75 10             	pushl  0x10(%ebp)
  8007d1:	ff 75 0c             	pushl  0xc(%ebp)
  8007d4:	ff 75 08             	pushl  0x8(%ebp)
  8007d7:	e8 9a ff ff ff       	call   800776 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	eb 03                	jmp    8007ee <strlen+0x10>
		n++;
  8007eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f2:	75 f7                	jne    8007eb <strlen+0xd>
		n++;
	return n;
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800804:	eb 03                	jmp    800809 <strnlen+0x13>
		n++;
  800806:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800809:	39 c2                	cmp    %eax,%edx
  80080b:	74 08                	je     800815 <strnlen+0x1f>
  80080d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800811:	75 f3                	jne    800806 <strnlen+0x10>
  800813:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	89 c2                	mov    %eax,%edx
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800830:	84 db                	test   %bl,%bl
  800832:	75 ef                	jne    800823 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	53                   	push   %ebx
  80083f:	e8 9a ff ff ff       	call   8007de <strlen>
  800844:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	01 d8                	add    %ebx,%eax
  80084c:	50                   	push   %eax
  80084d:	e8 c5 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  800852:	89 d8                	mov    %ebx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	89 f3                	mov    %esi,%ebx
  800866:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	89 f2                	mov    %esi,%edx
  80086b:	eb 0f                	jmp    80087c <strncpy+0x23>
		*dst++ = *src;
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800876:	80 39 01             	cmpb   $0x1,(%ecx)
  800879:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	39 da                	cmp    %ebx,%edx
  80087e:	75 ed                	jne    80086d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	89 f0                	mov    %esi,%eax
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800891:	8b 55 10             	mov    0x10(%ebp),%edx
  800894:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800896:	85 d2                	test   %edx,%edx
  800898:	74 21                	je     8008bb <strlcpy+0x35>
  80089a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089e:	89 f2                	mov    %esi,%edx
  8008a0:	eb 09                	jmp    8008ab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a2:	83 c2 01             	add    $0x1,%edx
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ab:	39 c2                	cmp    %eax,%edx
  8008ad:	74 09                	je     8008b8 <strlcpy+0x32>
  8008af:	0f b6 19             	movzbl (%ecx),%ebx
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	75 ec                	jne    8008a2 <strlcpy+0x1c>
  8008b6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008bb:	29 f0                	sub    %esi,%eax
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ca:	eb 06                	jmp    8008d2 <strcmp+0x11>
		p++, q++;
  8008cc:	83 c1 01             	add    $0x1,%ecx
  8008cf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d2:	0f b6 01             	movzbl (%ecx),%eax
  8008d5:	84 c0                	test   %al,%al
  8008d7:	74 04                	je     8008dd <strcmp+0x1c>
  8008d9:	3a 02                	cmp    (%edx),%al
  8008db:	74 ef                	je     8008cc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dd:	0f b6 c0             	movzbl %al,%eax
  8008e0:	0f b6 12             	movzbl (%edx),%edx
  8008e3:	29 d0                	sub    %edx,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	89 c3                	mov    %eax,%ebx
  8008f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f6:	eb 06                	jmp    8008fe <strncmp+0x17>
		n--, p++, q++;
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fe:	39 d8                	cmp    %ebx,%eax
  800900:	74 15                	je     800917 <strncmp+0x30>
  800902:	0f b6 08             	movzbl (%eax),%ecx
  800905:	84 c9                	test   %cl,%cl
  800907:	74 04                	je     80090d <strncmp+0x26>
  800909:	3a 0a                	cmp    (%edx),%cl
  80090b:	74 eb                	je     8008f8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090d:	0f b6 00             	movzbl (%eax),%eax
  800910:	0f b6 12             	movzbl (%edx),%edx
  800913:	29 d0                	sub    %edx,%eax
  800915:	eb 05                	jmp    80091c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091c:	5b                   	pop    %ebx
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800929:	eb 07                	jmp    800932 <strchr+0x13>
		if (*s == c)
  80092b:	38 ca                	cmp    %cl,%dl
  80092d:	74 0f                	je     80093e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	0f b6 10             	movzbl (%eax),%edx
  800935:	84 d2                	test   %dl,%dl
  800937:	75 f2                	jne    80092b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	eb 03                	jmp    80094f <strfind+0xf>
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800952:	38 ca                	cmp    %cl,%dl
  800954:	74 04                	je     80095a <strfind+0x1a>
  800956:	84 d2                	test   %dl,%dl
  800958:	75 f2                	jne    80094c <strfind+0xc>
			break;
	return (char *) s;
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 7d 08             	mov    0x8(%ebp),%edi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 36                	je     8009a2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800972:	75 28                	jne    80099c <memset+0x40>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 23                	jne    80099c <memset+0x40>
		c &= 0xFF;
  800979:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097d:	89 d3                	mov    %edx,%ebx
  80097f:	c1 e3 08             	shl    $0x8,%ebx
  800982:	89 d6                	mov    %edx,%esi
  800984:	c1 e6 18             	shl    $0x18,%esi
  800987:	89 d0                	mov    %edx,%eax
  800989:	c1 e0 10             	shl    $0x10,%eax
  80098c:	09 f0                	or     %esi,%eax
  80098e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800990:	89 d8                	mov    %ebx,%eax
  800992:	09 d0                	or     %edx,%eax
  800994:	c1 e9 02             	shr    $0x2,%ecx
  800997:	fc                   	cld    
  800998:	f3 ab                	rep stos %eax,%es:(%edi)
  80099a:	eb 06                	jmp    8009a2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	fc                   	cld    
  8009a0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a2:	89 f8                	mov    %edi,%eax
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b7:	39 c6                	cmp    %eax,%esi
  8009b9:	73 35                	jae    8009f0 <memmove+0x47>
  8009bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	73 2e                	jae    8009f0 <memmove+0x47>
		s += n;
		d += n;
  8009c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	89 d6                	mov    %edx,%esi
  8009c7:	09 fe                	or     %edi,%esi
  8009c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cf:	75 13                	jne    8009e4 <memmove+0x3b>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 0e                	jne    8009e4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d6:	83 ef 04             	sub    $0x4,%edi
  8009d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
  8009df:	fd                   	std    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 09                	jmp    8009ed <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e4:	83 ef 01             	sub    $0x1,%edi
  8009e7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ea:	fd                   	std    
  8009eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ed:	fc                   	cld    
  8009ee:	eb 1d                	jmp    800a0d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	89 f2                	mov    %esi,%edx
  8009f2:	09 c2                	or     %eax,%edx
  8009f4:	f6 c2 03             	test   $0x3,%dl
  8009f7:	75 0f                	jne    800a08 <memmove+0x5f>
  8009f9:	f6 c1 03             	test   $0x3,%cl
  8009fc:	75 0a                	jne    800a08 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 05                	jmp    800a0d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a08:	89 c7                	mov    %eax,%edi
  800a0a:	fc                   	cld    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 87 ff ff ff       	call   8009a9 <memmove>
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2f:	89 c6                	mov    %eax,%esi
  800a31:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a34:	eb 1a                	jmp    800a50 <memcmp+0x2c>
		if (*s1 != *s2)
  800a36:	0f b6 08             	movzbl (%eax),%ecx
  800a39:	0f b6 1a             	movzbl (%edx),%ebx
  800a3c:	38 d9                	cmp    %bl,%cl
  800a3e:	74 0a                	je     800a4a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a40:	0f b6 c1             	movzbl %cl,%eax
  800a43:	0f b6 db             	movzbl %bl,%ebx
  800a46:	29 d8                	sub    %ebx,%eax
  800a48:	eb 0f                	jmp    800a59 <memcmp+0x35>
		s1++, s2++;
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a50:	39 f0                	cmp    %esi,%eax
  800a52:	75 e2                	jne    800a36 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a64:	89 c1                	mov    %eax,%ecx
  800a66:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6d:	eb 0a                	jmp    800a79 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6f:	0f b6 10             	movzbl (%eax),%edx
  800a72:	39 da                	cmp    %ebx,%edx
  800a74:	74 07                	je     800a7d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	39 c8                	cmp    %ecx,%eax
  800a7b:	72 f2                	jb     800a6f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8c:	eb 03                	jmp    800a91 <strtol+0x11>
		s++;
  800a8e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a91:	0f b6 01             	movzbl (%ecx),%eax
  800a94:	3c 20                	cmp    $0x20,%al
  800a96:	74 f6                	je     800a8e <strtol+0xe>
  800a98:	3c 09                	cmp    $0x9,%al
  800a9a:	74 f2                	je     800a8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9c:	3c 2b                	cmp    $0x2b,%al
  800a9e:	75 0a                	jne    800aaa <strtol+0x2a>
		s++;
  800aa0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa8:	eb 11                	jmp    800abb <strtol+0x3b>
  800aaa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aaf:	3c 2d                	cmp    $0x2d,%al
  800ab1:	75 08                	jne    800abb <strtol+0x3b>
		s++, neg = 1;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac1:	75 15                	jne    800ad8 <strtol+0x58>
  800ac3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac6:	75 10                	jne    800ad8 <strtol+0x58>
  800ac8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acc:	75 7c                	jne    800b4a <strtol+0xca>
		s += 2, base = 16;
  800ace:	83 c1 02             	add    $0x2,%ecx
  800ad1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad6:	eb 16                	jmp    800aee <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad8:	85 db                	test   %ebx,%ebx
  800ada:	75 12                	jne    800aee <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae4:	75 08                	jne    800aee <strtol+0x6e>
		s++, base = 8;
  800ae6:	83 c1 01             	add    $0x1,%ecx
  800ae9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af6:	0f b6 11             	movzbl (%ecx),%edx
  800af9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 09             	cmp    $0x9,%bl
  800b01:	77 08                	ja     800b0b <strtol+0x8b>
			dig = *s - '0';
  800b03:	0f be d2             	movsbl %dl,%edx
  800b06:	83 ea 30             	sub    $0x30,%edx
  800b09:	eb 22                	jmp    800b2d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 08                	ja     800b1d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b15:	0f be d2             	movsbl %dl,%edx
  800b18:	83 ea 57             	sub    $0x57,%edx
  800b1b:	eb 10                	jmp    800b2d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b20:	89 f3                	mov    %esi,%ebx
  800b22:	80 fb 19             	cmp    $0x19,%bl
  800b25:	77 16                	ja     800b3d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b27:	0f be d2             	movsbl %dl,%edx
  800b2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b30:	7d 0b                	jge    800b3d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b3b:	eb b9                	jmp    800af6 <strtol+0x76>

	if (endptr)
  800b3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b41:	74 0d                	je     800b50 <strtol+0xd0>
		*endptr = (char *) s;
  800b43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b46:	89 0e                	mov    %ecx,(%esi)
  800b48:	eb 06                	jmp    800b50 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4a:	85 db                	test   %ebx,%ebx
  800b4c:	74 98                	je     800ae6 <strtol+0x66>
  800b4e:	eb 9e                	jmp    800aee <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b50:	89 c2                	mov    %eax,%edx
  800b52:	f7 da                	neg    %edx
  800b54:	85 ff                	test   %edi,%edi
  800b56:	0f 45 c2             	cmovne %edx,%eax
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    
  800b5e:	66 90                	xchg   %ax,%ax

00800b60 <__udivdi3>:
  800b60:	55                   	push   %ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 1c             	sub    $0x1c,%esp
  800b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b77:	85 f6                	test   %esi,%esi
  800b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b7d:	89 ca                	mov    %ecx,%edx
  800b7f:	89 f8                	mov    %edi,%eax
  800b81:	75 3d                	jne    800bc0 <__udivdi3+0x60>
  800b83:	39 cf                	cmp    %ecx,%edi
  800b85:	0f 87 c5 00 00 00    	ja     800c50 <__udivdi3+0xf0>
  800b8b:	85 ff                	test   %edi,%edi
  800b8d:	89 fd                	mov    %edi,%ebp
  800b8f:	75 0b                	jne    800b9c <__udivdi3+0x3c>
  800b91:	b8 01 00 00 00       	mov    $0x1,%eax
  800b96:	31 d2                	xor    %edx,%edx
  800b98:	f7 f7                	div    %edi
  800b9a:	89 c5                	mov    %eax,%ebp
  800b9c:	89 c8                	mov    %ecx,%eax
  800b9e:	31 d2                	xor    %edx,%edx
  800ba0:	f7 f5                	div    %ebp
  800ba2:	89 c1                	mov    %eax,%ecx
  800ba4:	89 d8                	mov    %ebx,%eax
  800ba6:	89 cf                	mov    %ecx,%edi
  800ba8:	f7 f5                	div    %ebp
  800baa:	89 c3                	mov    %eax,%ebx
  800bac:	89 d8                	mov    %ebx,%eax
  800bae:	89 fa                	mov    %edi,%edx
  800bb0:	83 c4 1c             	add    $0x1c,%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    
  800bb8:	90                   	nop
  800bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bc0:	39 ce                	cmp    %ecx,%esi
  800bc2:	77 74                	ja     800c38 <__udivdi3+0xd8>
  800bc4:	0f bd fe             	bsr    %esi,%edi
  800bc7:	83 f7 1f             	xor    $0x1f,%edi
  800bca:	0f 84 98 00 00 00    	je     800c68 <__udivdi3+0x108>
  800bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	89 c5                	mov    %eax,%ebp
  800bd9:	29 fb                	sub    %edi,%ebx
  800bdb:	d3 e6                	shl    %cl,%esi
  800bdd:	89 d9                	mov    %ebx,%ecx
  800bdf:	d3 ed                	shr    %cl,%ebp
  800be1:	89 f9                	mov    %edi,%ecx
  800be3:	d3 e0                	shl    %cl,%eax
  800be5:	09 ee                	or     %ebp,%esi
  800be7:	89 d9                	mov    %ebx,%ecx
  800be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bed:	89 d5                	mov    %edx,%ebp
  800bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bf3:	d3 ed                	shr    %cl,%ebp
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	d3 e2                	shl    %cl,%edx
  800bf9:	89 d9                	mov    %ebx,%ecx
  800bfb:	d3 e8                	shr    %cl,%eax
  800bfd:	09 c2                	or     %eax,%edx
  800bff:	89 d0                	mov    %edx,%eax
  800c01:	89 ea                	mov    %ebp,%edx
  800c03:	f7 f6                	div    %esi
  800c05:	89 d5                	mov    %edx,%ebp
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	f7 64 24 0c          	mull   0xc(%esp)
  800c0d:	39 d5                	cmp    %edx,%ebp
  800c0f:	72 10                	jb     800c21 <__udivdi3+0xc1>
  800c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c15:	89 f9                	mov    %edi,%ecx
  800c17:	d3 e6                	shl    %cl,%esi
  800c19:	39 c6                	cmp    %eax,%esi
  800c1b:	73 07                	jae    800c24 <__udivdi3+0xc4>
  800c1d:	39 d5                	cmp    %edx,%ebp
  800c1f:	75 03                	jne    800c24 <__udivdi3+0xc4>
  800c21:	83 eb 01             	sub    $0x1,%ebx
  800c24:	31 ff                	xor    %edi,%edi
  800c26:	89 d8                	mov    %ebx,%eax
  800c28:	89 fa                	mov    %edi,%edx
  800c2a:	83 c4 1c             	add    $0x1c,%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
  800c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c38:	31 ff                	xor    %edi,%edi
  800c3a:	31 db                	xor    %ebx,%ebx
  800c3c:	89 d8                	mov    %ebx,%eax
  800c3e:	89 fa                	mov    %edi,%edx
  800c40:	83 c4 1c             	add    $0x1c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    
  800c48:	90                   	nop
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	89 d8                	mov    %ebx,%eax
  800c52:	f7 f7                	div    %edi
  800c54:	31 ff                	xor    %edi,%edi
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	89 d8                	mov    %ebx,%eax
  800c5a:	89 fa                	mov    %edi,%edx
  800c5c:	83 c4 1c             	add    $0x1c,%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    
  800c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c68:	39 ce                	cmp    %ecx,%esi
  800c6a:	72 0c                	jb     800c78 <__udivdi3+0x118>
  800c6c:	31 db                	xor    %ebx,%ebx
  800c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c72:	0f 87 34 ff ff ff    	ja     800bac <__udivdi3+0x4c>
  800c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c7d:	e9 2a ff ff ff       	jmp    800bac <__udivdi3+0x4c>
  800c82:	66 90                	xchg   %ax,%ax
  800c84:	66 90                	xchg   %ax,%ax
  800c86:	66 90                	xchg   %ax,%ax
  800c88:	66 90                	xchg   %ax,%ax
  800c8a:	66 90                	xchg   %ax,%ax
  800c8c:	66 90                	xchg   %ax,%ax
  800c8e:	66 90                	xchg   %ax,%ax

00800c90 <__umoddi3>:
  800c90:	55                   	push   %ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 1c             	sub    $0x1c,%esp
  800c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ca7:	85 d2                	test   %edx,%edx
  800ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	89 3c 24             	mov    %edi,(%esp)
  800cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cba:	75 1c                	jne    800cd8 <__umoddi3+0x48>
  800cbc:	39 f7                	cmp    %esi,%edi
  800cbe:	76 50                	jbe    800d10 <__umoddi3+0x80>
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	f7 f7                	div    %edi
  800cc6:	89 d0                	mov    %edx,%eax
  800cc8:	31 d2                	xor    %edx,%edx
  800cca:	83 c4 1c             	add    $0x1c,%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
  800cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cd8:	39 f2                	cmp    %esi,%edx
  800cda:	89 d0                	mov    %edx,%eax
  800cdc:	77 52                	ja     800d30 <__umoddi3+0xa0>
  800cde:	0f bd ea             	bsr    %edx,%ebp
  800ce1:	83 f5 1f             	xor    $0x1f,%ebp
  800ce4:	75 5a                	jne    800d40 <__umoddi3+0xb0>
  800ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cea:	0f 82 e0 00 00 00    	jb     800dd0 <__umoddi3+0x140>
  800cf0:	39 0c 24             	cmp    %ecx,(%esp)
  800cf3:	0f 86 d7 00 00 00    	jbe    800dd0 <__umoddi3+0x140>
  800cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d01:	83 c4 1c             	add    $0x1c,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	85 ff                	test   %edi,%edi
  800d12:	89 fd                	mov    %edi,%ebp
  800d14:	75 0b                	jne    800d21 <__umoddi3+0x91>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f7                	div    %edi
  800d1f:	89 c5                	mov    %eax,%ebp
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	31 d2                	xor    %edx,%edx
  800d25:	f7 f5                	div    %ebp
  800d27:	89 c8                	mov    %ecx,%eax
  800d29:	f7 f5                	div    %ebp
  800d2b:	89 d0                	mov    %edx,%eax
  800d2d:	eb 99                	jmp    800cc8 <__umoddi3+0x38>
  800d2f:	90                   	nop
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	83 c4 1c             	add    $0x1c,%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
  800d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d40:	8b 34 24             	mov    (%esp),%esi
  800d43:	bf 20 00 00 00       	mov    $0x20,%edi
  800d48:	89 e9                	mov    %ebp,%ecx
  800d4a:	29 ef                	sub    %ebp,%edi
  800d4c:	d3 e0                	shl    %cl,%eax
  800d4e:	89 f9                	mov    %edi,%ecx
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	d3 ea                	shr    %cl,%edx
  800d54:	89 e9                	mov    %ebp,%ecx
  800d56:	09 c2                	or     %eax,%edx
  800d58:	89 d8                	mov    %ebx,%eax
  800d5a:	89 14 24             	mov    %edx,(%esp)
  800d5d:	89 f2                	mov    %esi,%edx
  800d5f:	d3 e2                	shl    %cl,%edx
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	89 c6                	mov    %eax,%esi
  800d71:	d3 e3                	shl    %cl,%ebx
  800d73:	89 f9                	mov    %edi,%ecx
  800d75:	89 d0                	mov    %edx,%eax
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	89 e9                	mov    %ebp,%ecx
  800d7b:	09 d8                	or     %ebx,%eax
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 f2                	mov    %esi,%edx
  800d81:	f7 34 24             	divl   (%esp)
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	d3 e3                	shl    %cl,%ebx
  800d88:	f7 64 24 04          	mull   0x4(%esp)
  800d8c:	39 d6                	cmp    %edx,%esi
  800d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	72 08                	jb     800da0 <__umoddi3+0x110>
  800d98:	75 11                	jne    800dab <__umoddi3+0x11b>
  800d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d9e:	73 0b                	jae    800dab <__umoddi3+0x11b>
  800da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800da4:	1b 14 24             	sbb    (%esp),%edx
  800da7:	89 d1                	mov    %edx,%ecx
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800daf:	29 da                	sub    %ebx,%edx
  800db1:	19 ce                	sbb    %ecx,%esi
  800db3:	89 f9                	mov    %edi,%ecx
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	d3 e0                	shl    %cl,%eax
  800db9:	89 e9                	mov    %ebp,%ecx
  800dbb:	d3 ea                	shr    %cl,%edx
  800dbd:	89 e9                	mov    %ebp,%ecx
  800dbf:	d3 ee                	shr    %cl,%esi
  800dc1:	09 d0                	or     %edx,%eax
  800dc3:	89 f2                	mov    %esi,%edx
  800dc5:	83 c4 1c             	add    $0x1c,%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi
  800dd0:	29 f9                	sub    %edi,%ecx
  800dd2:	19 d6                	sbb    %edx,%esi
  800dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddc:	e9 18 ff ff ff       	jmp    800cf9 <__umoddi3+0x69>
