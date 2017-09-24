
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 c9 00 00 00       	call   800117 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800056:	c1 e0 05             	shl    $0x5,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 ee 0d 80 00       	push   $0x800dee
  800103:	6a 23                	push   $0x23
  800105:	68 0b 0e 80 00       	push   $0x800e0b
  80010a:	e8 27 00 00 00       	call   800136 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800144:	e8 ce ff ff ff       	call   800117 <sys_getenvid>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	ff 75 0c             	pushl  0xc(%ebp)
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	56                   	push   %esi
  800153:	50                   	push   %eax
  800154:	68 1c 0e 80 00       	push   $0x800e1c
  800159:	e8 b1 00 00 00       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015e:	83 c4 18             	add    $0x18,%esp
  800161:	53                   	push   %ebx
  800162:	ff 75 10             	pushl  0x10(%ebp)
  800165:	e8 54 00 00 00       	call   8001be <vcprintf>
	cprintf("\n");
  80016a:	c7 04 24 40 0e 80 00 	movl   $0x800e40,(%esp)
  800171:	e8 99 00 00 00       	call   80020f <cprintf>
  800176:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800179:	cc                   	int3   
  80017a:	eb fd                	jmp    800179 <_panic+0x43>

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 04             	sub    $0x4,%esp
  800183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800186:	8b 13                	mov    (%ebx),%edx
  800188:	8d 42 01             	lea    0x1(%edx),%eax
  80018b:	89 03                	mov    %eax,(%ebx)
  80018d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800190:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800194:	3d ff 00 00 00       	cmp    $0xff,%eax
  800199:	75 1a                	jne    8001b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 ed fe ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ce:	00 00 00 
	b.cnt = 0;
  8001d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	68 7c 01 80 00       	push   $0x80017c
  8001ed:	e8 1a 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	83 c4 08             	add    $0x8,%esp
  8001f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	e8 92 fe ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 9d ff ff ff       	call   8001be <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 1c             	sub    $0x1c,%esp
  80022c:	89 c7                	mov    %eax,%edi
  80022e:	89 d6                	mov    %edx,%esi
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	8b 55 0c             	mov    0xc(%ebp),%edx
  800236:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800239:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800244:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800247:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024a:	39 d3                	cmp    %edx,%ebx
  80024c:	72 05                	jb     800253 <printnum+0x30>
  80024e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800251:	77 45                	ja     800298 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 18             	pushl  0x18(%ebp)
  800259:	8b 45 14             	mov    0x14(%ebp),%eax
  80025c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025f:	53                   	push   %ebx
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 e9 08 00 00       	call   800b60 <__udivdi3>
  800277:	83 c4 18             	add    $0x18,%esp
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	89 f2                	mov    %esi,%edx
  80027e:	89 f8                	mov    %edi,%eax
  800280:	e8 9e ff ff ff       	call   800223 <printnum>
  800285:	83 c4 20             	add    $0x20,%esp
  800288:	eb 18                	jmp    8002a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	eb 03                	jmp    80029b <printnum+0x78>
  800298:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	83 eb 01             	sub    $0x1,%ebx
  80029e:	85 db                	test   %ebx,%ebx
  8002a0:	7f e8                	jg     80028a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	56                   	push   %esi
  8002a6:	83 ec 04             	sub    $0x4,%esp
  8002a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8002af:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b5:	e8 d6 09 00 00       	call   800c90 <__umoddi3>
  8002ba:	83 c4 14             	add    $0x14,%esp
  8002bd:	0f be 80 42 0e 80 00 	movsbl 0x800e42(%eax),%eax
  8002c4:	50                   	push   %eax
  8002c5:	ff d7                	call   *%edi
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e1:	73 0a                	jae    8002ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	88 02                	mov    %al,(%edx)
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f8:	50                   	push   %eax
  8002f9:	ff 75 10             	pushl  0x10(%ebp)
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	e8 05 00 00 00       	call   80030c <vprintfmt>
	va_end(ap);
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 2c             	sub    $0x2c,%esp
  800315:	8b 75 08             	mov    0x8(%ebp),%esi
  800318:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031e:	eb 12                	jmp    800332 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800320:	85 c0                	test   %eax,%eax
  800322:	0f 84 42 04 00 00    	je     80076a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	53                   	push   %ebx
  80032c:	50                   	push   %eax
  80032d:	ff d6                	call   *%esi
  80032f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	83 c7 01             	add    $0x1,%edi
  800335:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e2                	jne    800320 <vprintfmt+0x14>
  80033e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800342:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800349:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800350:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035c:	eb 07                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800361:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 07             	movzbl (%edi),%eax
  80036e:	0f b6 d0             	movzbl %al,%edx
  800371:	83 e8 23             	sub    $0x23,%eax
  800374:	3c 55                	cmp    $0x55,%al
  800376:	0f 87 d3 03 00 00    	ja     80074f <vprintfmt+0x443>
  80037c:	0f b6 c0             	movzbl %al,%eax
  80037f:	ff 24 85 d0 0e 80 00 	jmp    *0x800ed0(,%eax,4)
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800389:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038d:	eb d6                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
  800397:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a7:	83 f9 09             	cmp    $0x9,%ecx
  8003aa:	77 3f                	ja     8003eb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003af:	eb e9                	jmp    80039a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 40 04             	lea    0x4(%eax),%eax
  8003bf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c5:	eb 2a                	jmp    8003f1 <vprintfmt+0xe5>
  8003c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	0f 49 d0             	cmovns %eax,%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003da:	eb 89                	jmp    800365 <vprintfmt+0x59>
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e6:	e9 7a ff ff ff       	jmp    800365 <vprintfmt+0x59>
  8003eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f5:	0f 89 6a ff ff ff    	jns    800365 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800401:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800408:	e9 58 ff ff ff       	jmp    800365 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800413:	e9 4d ff ff ff       	jmp    800365 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 78 04             	lea    0x4(%eax),%edi
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	53                   	push   %ebx
  800422:	ff 30                	pushl  (%eax)
  800424:	ff d6                	call   *%esi
			break;
  800426:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800429:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042f:	e9 fe fe ff ff       	jmp    800332 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 78 04             	lea    0x4(%eax),%edi
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	99                   	cltd   
  80043d:	31 d0                	xor    %edx,%eax
  80043f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800441:	83 f8 06             	cmp    $0x6,%eax
  800444:	7f 0b                	jg     800451 <vprintfmt+0x145>
  800446:	8b 14 85 28 10 80 00 	mov    0x801028(,%eax,4),%edx
  80044d:	85 d2                	test   %edx,%edx
  80044f:	75 1b                	jne    80046c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800451:	50                   	push   %eax
  800452:	68 5a 0e 80 00       	push   $0x800e5a
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 91 fe ff ff       	call   8002ef <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800461:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800467:	e9 c6 fe ff ff       	jmp    800332 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046c:	52                   	push   %edx
  80046d:	68 63 0e 80 00       	push   $0x800e63
  800472:	53                   	push   %ebx
  800473:	56                   	push   %esi
  800474:	e8 76 fe ff ff       	call   8002ef <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800482:	e9 ab fe ff ff       	jmp    800332 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	83 c0 04             	add    $0x4,%eax
  80048d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800495:	85 ff                	test   %edi,%edi
  800497:	b8 53 0e 80 00       	mov    $0x800e53,%eax
  80049c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a3:	0f 8e 94 00 00 00    	jle    80053d <vprintfmt+0x231>
  8004a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ad:	0f 84 98 00 00 00    	je     80054b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b9:	57                   	push   %edi
  8004ba:	e8 33 03 00 00       	call   8007f2 <strnlen>
  8004bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	eb 0f                	jmp    8004e7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ef 01             	sub    $0x1,%edi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	7f ed                	jg     8004d8 <vprintfmt+0x1cc>
  8004eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f1:	85 c9                	test   %ecx,%ecx
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	0f 49 c1             	cmovns %ecx,%eax
  8004fb:	29 c1                	sub    %eax,%ecx
  8004fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800503:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800506:	89 cb                	mov    %ecx,%ebx
  800508:	eb 4d                	jmp    800557 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050e:	74 1b                	je     80052b <vprintfmt+0x21f>
  800510:	0f be c0             	movsbl %al,%eax
  800513:	83 e8 20             	sub    $0x20,%eax
  800516:	83 f8 5e             	cmp    $0x5e,%eax
  800519:	76 10                	jbe    80052b <vprintfmt+0x21f>
					putch('?', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	ff 75 0c             	pushl  0xc(%ebp)
  800521:	6a 3f                	push   $0x3f
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	eb 0d                	jmp    800538 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	52                   	push   %edx
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800538:	83 eb 01             	sub    $0x1,%ebx
  80053b:	eb 1a                	jmp    800557 <vprintfmt+0x24b>
  80053d:	89 75 08             	mov    %esi,0x8(%ebp)
  800540:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800546:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800549:	eb 0c                	jmp    800557 <vprintfmt+0x24b>
  80054b:	89 75 08             	mov    %esi,0x8(%ebp)
  80054e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800551:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800554:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800557:	83 c7 01             	add    $0x1,%edi
  80055a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055e:	0f be d0             	movsbl %al,%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	74 23                	je     800588 <vprintfmt+0x27c>
  800565:	85 f6                	test   %esi,%esi
  800567:	78 a1                	js     80050a <vprintfmt+0x1fe>
  800569:	83 ee 01             	sub    $0x1,%esi
  80056c:	79 9c                	jns    80050a <vprintfmt+0x1fe>
  80056e:	89 df                	mov    %ebx,%edi
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800576:	eb 18                	jmp    800590 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	6a 20                	push   $0x20
  80057e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800580:	83 ef 01             	sub    $0x1,%edi
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	eb 08                	jmp    800590 <vprintfmt+0x284>
  800588:	89 df                	mov    %ebx,%edi
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	85 ff                	test   %edi,%edi
  800592:	7f e4                	jg     800578 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800594:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059d:	e9 90 fd ff ff       	jmp    800332 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a2:	83 f9 01             	cmp    $0x1,%ecx
  8005a5:	7e 19                	jle    8005c0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 50 04             	mov    0x4(%eax),%edx
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 08             	lea    0x8(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005be:	eb 38                	jmp    8005f8 <vprintfmt+0x2ec>
	else if (lflag)
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	74 1b                	je     8005df <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb 19                	jmp    8005f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 c1                	mov    %eax,%ecx
  8005e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800603:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800607:	0f 89 0e 01 00 00    	jns    80071b <vprintfmt+0x40f>
				putch('-', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 2d                	push   $0x2d
  800613:	ff d6                	call   *%esi
				num = -(long long) num;
  800615:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800618:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061b:	f7 da                	neg    %edx
  80061d:	83 d1 00             	adc    $0x0,%ecx
  800620:	f7 d9                	neg    %ecx
  800622:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 ec 00 00 00       	jmp    80071b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062f:	83 f9 01             	cmp    $0x1,%ecx
  800632:	7e 18                	jle    80064c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	8b 48 04             	mov    0x4(%eax),%ecx
  80063c:	8d 40 08             	lea    0x8(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 cf 00 00 00       	jmp    80071b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064c:	85 c9                	test   %ecx,%ecx
  80064e:	74 1a                	je     80066a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
  800665:	e9 b1 00 00 00       	jmp    80071b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067f:	e9 97 00 00 00       	jmp    80071b <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 58                	push   $0x58
  80068a:	ff d6                	call   *%esi
			putch('X', putdat);
  80068c:	83 c4 08             	add    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 58                	push   $0x58
  800692:	ff d6                	call   *%esi
			putch('X', putdat);
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 58                	push   $0x58
  80069a:	ff d6                	call   *%esi
			break;
  80069c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a2:	e9 8b fc ff ff       	jmp    800332 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 30                	push   $0x30
  8006ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 78                	push   $0x78
  8006b5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c1:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cf:	eb 4a                	jmp    80071b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 15                	jle    8006eb <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e9:	eb 30                	jmp    80071b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	74 17                	je     800706 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800704:	eb 15                	jmp    80071b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
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
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071b:	83 ec 0c             	sub    $0xc,%esp
  80071e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800722:	57                   	push   %edi
  800723:	ff 75 e0             	pushl  -0x20(%ebp)
  800726:	50                   	push   %eax
  800727:	51                   	push   %ecx
  800728:	52                   	push   %edx
  800729:	89 da                	mov    %ebx,%edx
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	e8 f1 fa ff ff       	call   800223 <printnum>
			break;
  800732:	83 c4 20             	add    $0x20,%esp
  800735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800738:	e9 f5 fb ff ff       	jmp    800332 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	53                   	push   %ebx
  800741:	52                   	push   %edx
  800742:	ff d6                	call   *%esi
			break;
  800744:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074a:	e9 e3 fb ff ff       	jmp    800332 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 25                	push   $0x25
  800755:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 03                	jmp    80075f <vprintfmt+0x453>
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800763:	75 f7                	jne    80075c <vprintfmt+0x450>
  800765:	e9 c8 fb ff ff       	jmp    800332 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 18             	sub    $0x18,%esp
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800781:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800785:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800788:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078f:	85 c0                	test   %eax,%eax
  800791:	74 26                	je     8007b9 <vsnprintf+0x47>
  800793:	85 d2                	test   %edx,%edx
  800795:	7e 22                	jle    8007b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800797:	ff 75 14             	pushl  0x14(%ebp)
  80079a:	ff 75 10             	pushl  0x10(%ebp)
  80079d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a0:	50                   	push   %eax
  8007a1:	68 d2 02 80 00       	push   $0x8002d2
  8007a6:	e8 61 fb ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 05                	jmp    8007be <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	ff 75 08             	pushl  0x8(%ebp)
  8007d3:	e8 9a ff ff ff       	call   800772 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 03                	jmp    8007ea <strlen+0x10>
		n++;
  8007e7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f7                	jne    8007e7 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800800:	eb 03                	jmp    800805 <strnlen+0x13>
		n++;
  800802:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	39 c2                	cmp    %eax,%edx
  800807:	74 08                	je     800811 <strnlen+0x1f>
  800809:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080d:	75 f3                	jne    800802 <strnlen+0x10>
  80080f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081d:	89 c2                	mov    %eax,%edx
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082c:	84 db                	test   %bl,%bl
  80082e:	75 ef                	jne    80081f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800830:	5b                   	pop    %ebx
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 9a ff ff ff       	call   8007da <strlen>
  800840:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	01 d8                	add    %ebx,%eax
  800848:	50                   	push   %eax
  800849:	e8 c5 ff ff ff       	call   800813 <strcpy>
	return dst;
}
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	89 f3                	mov    %esi,%ebx
  800862:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	89 f2                	mov    %esi,%edx
  800867:	eb 0f                	jmp    800878 <strncpy+0x23>
		*dst++ = *src;
  800869:	83 c2 01             	add    $0x1,%edx
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800872:	80 39 01             	cmpb   $0x1,(%ecx)
  800875:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800878:	39 da                	cmp    %ebx,%edx
  80087a:	75 ed                	jne    800869 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087c:	89 f0                	mov    %esi,%eax
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 10             	mov    0x10(%ebp),%edx
  800890:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	74 21                	je     8008b7 <strlcpy+0x35>
  800896:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089a:	89 f2                	mov    %esi,%edx
  80089c:	eb 09                	jmp    8008a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	83 c1 01             	add    $0x1,%ecx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 09                	je     8008b4 <strlcpy+0x32>
  8008ab:	0f b6 19             	movzbl (%ecx),%ebx
  8008ae:	84 db                	test   %bl,%bl
  8008b0:	75 ec                	jne    80089e <strlcpy+0x1c>
  8008b2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strcmp+0x11>
		p++, q++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x1c>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 ef                	je     8008c8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strncmp+0x17>
		n--, p++, q++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 15                	je     800913 <strncmp+0x30>
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 04                	je     800909 <strncmp+0x26>
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 eb                	je     8008f4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 00             	movzbl (%eax),%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
  800911:	eb 05                	jmp    800918 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strchr+0x13>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0f                	je     80093a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800946:	eb 03                	jmp    80094b <strfind+0xf>
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 04                	je     800956 <strfind+0x1a>
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strfind+0xc>
			break;
	return (char *) s;
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800964:	85 c9                	test   %ecx,%ecx
  800966:	74 36                	je     80099e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 28                	jne    800998 <memset+0x40>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 23                	jne    800998 <memset+0x40>
		c &= 0xFF;
  800975:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800979:	89 d3                	mov    %edx,%ebx
  80097b:	c1 e3 08             	shl    $0x8,%ebx
  80097e:	89 d6                	mov    %edx,%esi
  800980:	c1 e6 18             	shl    $0x18,%esi
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e0 10             	shl    $0x10,%eax
  800988:	09 f0                	or     %esi,%eax
  80098a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098c:	89 d8                	mov    %ebx,%eax
  80098e:	09 d0                	or     %edx,%eax
  800990:	c1 e9 02             	shr    $0x2,%ecx
  800993:	fc                   	cld    
  800994:	f3 ab                	rep stos %eax,%es:(%edi)
  800996:	eb 06                	jmp    80099e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099b:	fc                   	cld    
  80099c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099e:	89 f8                	mov    %edi,%eax
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b3:	39 c6                	cmp    %eax,%esi
  8009b5:	73 35                	jae    8009ec <memmove+0x47>
  8009b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ba:	39 d0                	cmp    %edx,%eax
  8009bc:	73 2e                	jae    8009ec <memmove+0x47>
		s += n;
		d += n;
  8009be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 d6                	mov    %edx,%esi
  8009c3:	09 fe                	or     %edi,%esi
  8009c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cb:	75 13                	jne    8009e0 <memmove+0x3b>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 0e                	jne    8009e0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d2:	83 ef 04             	sub    $0x4,%edi
  8009d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
  8009db:	fd                   	std    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 09                	jmp    8009e9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e0:	83 ef 01             	sub    $0x1,%edi
  8009e3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e6:	fd                   	std    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e9:	fc                   	cld    
  8009ea:	eb 1d                	jmp    800a09 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	89 f2                	mov    %esi,%edx
  8009ee:	09 c2                	or     %eax,%edx
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	75 0f                	jne    800a04 <memmove+0x5f>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0a                	jne    800a04 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	fc                   	cld    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb 05                	jmp    800a09 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a04:	89 c7                	mov    %eax,%edi
  800a06:	fc                   	cld    
  800a07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a10:	ff 75 10             	pushl  0x10(%ebp)
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	ff 75 08             	pushl  0x8(%ebp)
  800a19:	e8 87 ff ff ff       	call   8009a5 <memmove>
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	89 c6                	mov    %eax,%esi
  800a2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	eb 1a                	jmp    800a4c <memcmp+0x2c>
		if (*s1 != *s2)
  800a32:	0f b6 08             	movzbl (%eax),%ecx
  800a35:	0f b6 1a             	movzbl (%edx),%ebx
  800a38:	38 d9                	cmp    %bl,%cl
  800a3a:	74 0a                	je     800a46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3c:	0f b6 c1             	movzbl %cl,%eax
  800a3f:	0f b6 db             	movzbl %bl,%ebx
  800a42:	29 d8                	sub    %ebx,%eax
  800a44:	eb 0f                	jmp    800a55 <memcmp+0x35>
		s1++, s2++;
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4c:	39 f0                	cmp    %esi,%eax
  800a4e:	75 e2                	jne    800a32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	53                   	push   %ebx
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a60:	89 c1                	mov    %eax,%ecx
  800a62:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a65:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a69:	eb 0a                	jmp    800a75 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6b:	0f b6 10             	movzbl (%eax),%edx
  800a6e:	39 da                	cmp    %ebx,%edx
  800a70:	74 07                	je     800a79 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	39 c8                	cmp    %ecx,%eax
  800a77:	72 f2                	jb     800a6b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a88:	eb 03                	jmp    800a8d <strtol+0x11>
		s++;
  800a8a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8d:	0f b6 01             	movzbl (%ecx),%eax
  800a90:	3c 20                	cmp    $0x20,%al
  800a92:	74 f6                	je     800a8a <strtol+0xe>
  800a94:	3c 09                	cmp    $0x9,%al
  800a96:	74 f2                	je     800a8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a98:	3c 2b                	cmp    $0x2b,%al
  800a9a:	75 0a                	jne    800aa6 <strtol+0x2a>
		s++;
  800a9c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa4:	eb 11                	jmp    800ab7 <strtol+0x3b>
  800aa6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aab:	3c 2d                	cmp    $0x2d,%al
  800aad:	75 08                	jne    800ab7 <strtol+0x3b>
		s++, neg = 1;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abd:	75 15                	jne    800ad4 <strtol+0x58>
  800abf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac2:	75 10                	jne    800ad4 <strtol+0x58>
  800ac4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac8:	75 7c                	jne    800b46 <strtol+0xca>
		s += 2, base = 16;
  800aca:	83 c1 02             	add    $0x2,%ecx
  800acd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad2:	eb 16                	jmp    800aea <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad4:	85 db                	test   %ebx,%ebx
  800ad6:	75 12                	jne    800aea <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800add:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae0:	75 08                	jne    800aea <strtol+0x6e>
		s++, base = 8;
  800ae2:	83 c1 01             	add    $0x1,%ecx
  800ae5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af2:	0f b6 11             	movzbl (%ecx),%edx
  800af5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 09             	cmp    $0x9,%bl
  800afd:	77 08                	ja     800b07 <strtol+0x8b>
			dig = *s - '0';
  800aff:	0f be d2             	movsbl %dl,%edx
  800b02:	83 ea 30             	sub    $0x30,%edx
  800b05:	eb 22                	jmp    800b29 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b07:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 19             	cmp    $0x19,%bl
  800b0f:	77 08                	ja     800b19 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b11:	0f be d2             	movsbl %dl,%edx
  800b14:	83 ea 57             	sub    $0x57,%edx
  800b17:	eb 10                	jmp    800b29 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 16                	ja     800b39 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b29:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2c:	7d 0b                	jge    800b39 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2e:	83 c1 01             	add    $0x1,%ecx
  800b31:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b37:	eb b9                	jmp    800af2 <strtol+0x76>

	if (endptr)
  800b39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3d:	74 0d                	je     800b4c <strtol+0xd0>
		*endptr = (char *) s;
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	89 0e                	mov    %ecx,(%esi)
  800b44:	eb 06                	jmp    800b4c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b46:	85 db                	test   %ebx,%ebx
  800b48:	74 98                	je     800ae2 <strtol+0x66>
  800b4a:	eb 9e                	jmp    800aea <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	f7 da                	neg    %edx
  800b50:	85 ff                	test   %edi,%edi
  800b52:	0f 45 c2             	cmovne %edx,%eax
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    
  800b5a:	66 90                	xchg   %ax,%ax
  800b5c:	66 90                	xchg   %ax,%ax
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
