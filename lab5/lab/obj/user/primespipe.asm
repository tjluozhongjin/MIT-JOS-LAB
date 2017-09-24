
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 7d 15 00 00       	call   8015ce <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 e0 23 80 00       	push   $0x8023e0
  80006d:	6a 15                	push   $0x15
  80006f:	68 0f 24 80 00       	push   $0x80240f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 21 24 80 00       	push   $0x802421
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 b7 1b 00 00       	call   801c48 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 25 24 80 00       	push   $0x802425
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 0f 24 80 00       	push   $0x80240f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 b1 0f 00 00       	call   801063 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 2e 24 80 00       	push   $0x80242e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 0f 24 80 00       	push   $0x80240f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 2c 13 00 00       	call   801401 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 21 13 00 00       	call   801401 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 0b 13 00 00       	call   801401 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 c3 14 00 00       	call   8015ce <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 37 24 80 00       	push   $0x802437
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 0f 24 80 00       	push   $0x80240f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 c9 14 00 00       	call   801617 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 53 24 80 00       	push   $0x802453
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 0f 24 80 00       	push   $0x80240f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 6d 	movl   $0x80246d,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 b5 1a 00 00       	call   801c48 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 25 24 80 00       	push   $0x802425
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 0f 24 80 00       	push   $0x80240f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 af 0e 00 00       	call   801063 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 2e 24 80 00       	push   $0x80242e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 0f 24 80 00       	push   $0x80240f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 28 12 00 00       	call   801401 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 12 12 00 00       	call   801401 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 0d 14 00 00       	call   801617 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 78 24 80 00       	push   $0x802478
  800226:	6a 4a                	push   $0x4a
  800228:	68 0f 24 80 00       	push   $0x80240f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 f2 0a 00 00       	call   800d3a <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 a3 11 00 00       	call   80142c <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 66 0a 00 00       	call   800cf9 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 8f 0a 00 00       	call   800d3a <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 9c 24 80 00       	push   $0x80249c
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 23 24 80 00 	movl   $0x802423,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 ae 09 00 00       	call   800cbc <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 1a 01 00 00       	call   80046e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 53 09 00 00       	call   800cbc <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 67 1d 00 00       	call   802140 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 54 1e 00 00       	call   802270 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 bf 24 80 00 	movsbl 0x8024bf(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	3b 50 04             	cmp    0x4(%eax),%edx
  800443:	73 0a                	jae    80044f <sprintputch+0x1b>
		*b->buf++ = ch;
  800445:	8d 4a 01             	lea    0x1(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	88 02                	mov    %al,(%edx)
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800457:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045a:	50                   	push   %eax
  80045b:	ff 75 10             	pushl  0x10(%ebp)
  80045e:	ff 75 0c             	pushl  0xc(%ebp)
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	e8 05 00 00 00       	call   80046e <vprintfmt>
	va_end(ap);
}
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 2c             	sub    $0x2c,%esp
  800477:	8b 75 08             	mov    0x8(%ebp),%esi
  80047a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800480:	eb 12                	jmp    800494 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800482:	85 c0                	test   %eax,%eax
  800484:	0f 84 42 04 00 00    	je     8008cc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	53                   	push   %ebx
  80048e:	50                   	push   %eax
  80048f:	ff d6                	call   *%esi
  800491:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800494:	83 c7 01             	add    $0x1,%edi
  800497:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049b:	83 f8 25             	cmp    $0x25,%eax
  80049e:	75 e2                	jne    800482 <vprintfmt+0x14>
  8004a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004be:	eb 07                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8d 47 01             	lea    0x1(%edi),%eax
  8004ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cd:	0f b6 07             	movzbl (%edi),%eax
  8004d0:	0f b6 d0             	movzbl %al,%edx
  8004d3:	83 e8 23             	sub    $0x23,%eax
  8004d6:	3c 55                	cmp    $0x55,%al
  8004d8:	0f 87 d3 03 00 00    	ja     8008b1 <vprintfmt+0x443>
  8004de:	0f b6 c0             	movzbl %al,%eax
  8004e1:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ef:	eb d6                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ff:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800503:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800506:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800509:	83 f9 09             	cmp    $0x9,%ecx
  80050c:	77 3f                	ja     80054d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800511:	eb e9                	jmp    8004fc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 2a                	jmp    800553 <vprintfmt+0xe5>
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	ba 00 00 00 00       	mov    $0x0,%edx
  800533:	0f 49 d0             	cmovns %eax,%edx
  800536:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053c:	eb 89                	jmp    8004c7 <vprintfmt+0x59>
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800541:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800548:	e9 7a ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
  80054d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800550:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800553:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800557:	0f 89 6a ff ff ff    	jns    8004c7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80055d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800563:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056a:	e9 58 ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800575:	e9 4d ff ff ff       	jmp    8004c7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 78 04             	lea    0x4(%eax),%edi
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	ff 30                	pushl  (%eax)
  800586:	ff d6                	call   *%esi
			break;
  800588:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800591:	e9 fe fe ff ff       	jmp    800494 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 78 04             	lea    0x4(%eax),%edi
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	99                   	cltd   
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 0f             	cmp    $0xf,%eax
  8005a6:	7f 0b                	jg     8005b3 <vprintfmt+0x145>
  8005a8:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 1b                	jne    8005ce <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 d7 24 80 00       	push   $0x8024d7
  8005b9:	53                   	push   %ebx
  8005ba:	56                   	push   %esi
  8005bb:	e8 91 fe ff ff       	call   800451 <printfmt>
  8005c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c9:	e9 c6 fe ff ff       	jmp    800494 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ce:	52                   	push   %edx
  8005cf:	68 65 29 80 00       	push   $0x802965
  8005d4:	53                   	push   %ebx
  8005d5:	56                   	push   %esi
  8005d6:	e8 76 fe ff ff       	call   800451 <printfmt>
  8005db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	e9 ab fe ff ff       	jmp    800494 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	83 c0 04             	add    $0x4,%eax
  8005ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	b8 d0 24 80 00       	mov    $0x8024d0,%eax
  8005fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 8e 94 00 00 00    	jle    80069f <vprintfmt+0x231>
  80060b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80060f:	0f 84 98 00 00 00    	je     8006ad <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	ff 75 d0             	pushl  -0x30(%ebp)
  80061b:	57                   	push   %edi
  80061c:	e8 33 03 00 00       	call   800954 <strnlen>
  800621:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800624:	29 c1                	sub    %eax,%ecx
  800626:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800629:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80062c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800630:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800633:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800636:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800638:	eb 0f                	jmp    800649 <vprintfmt+0x1db>
					putch(padc, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 75 e0             	pushl  -0x20(%ebp)
  800641:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ed                	jg     80063a <vprintfmt+0x1cc>
  80064d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800650:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800653:	85 c9                	test   %ecx,%ecx
  800655:	b8 00 00 00 00       	mov    $0x0,%eax
  80065a:	0f 49 c1             	cmovns %ecx,%eax
  80065d:	29 c1                	sub    %eax,%ecx
  80065f:	89 75 08             	mov    %esi,0x8(%ebp)
  800662:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800665:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800668:	89 cb                	mov    %ecx,%ebx
  80066a:	eb 4d                	jmp    8006b9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800670:	74 1b                	je     80068d <vprintfmt+0x21f>
  800672:	0f be c0             	movsbl %al,%eax
  800675:	83 e8 20             	sub    $0x20,%eax
  800678:	83 f8 5e             	cmp    $0x5e,%eax
  80067b:	76 10                	jbe    80068d <vprintfmt+0x21f>
					putch('?', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	6a 3f                	push   $0x3f
  800685:	ff 55 08             	call   *0x8(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	52                   	push   %edx
  800694:	ff 55 08             	call   *0x8(%ebp)
  800697:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	83 eb 01             	sub    $0x1,%ebx
  80069d:	eb 1a                	jmp    8006b9 <vprintfmt+0x24b>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb 0c                	jmp    8006b9 <vprintfmt+0x24b>
  8006ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b9:	83 c7 01             	add    $0x1,%edi
  8006bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c0:	0f be d0             	movsbl %al,%edx
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	74 23                	je     8006ea <vprintfmt+0x27c>
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	78 a1                	js     80066c <vprintfmt+0x1fe>
  8006cb:	83 ee 01             	sub    $0x1,%esi
  8006ce:	79 9c                	jns    80066c <vprintfmt+0x1fe>
  8006d0:	89 df                	mov    %ebx,%edi
  8006d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	eb 18                	jmp    8006f2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 20                	push   $0x20
  8006e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 08                	jmp    8006f2 <vprintfmt+0x284>
  8006ea:	89 df                	mov    %ebx,%edi
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f2:	85 ff                	test   %edi,%edi
  8006f4:	7f e4                	jg     8006da <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ff:	e9 90 fd ff ff       	jmp    800494 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800704:	83 f9 01             	cmp    $0x1,%ecx
  800707:	7e 19                	jle    800722 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 50 04             	mov    0x4(%eax),%edx
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
  800720:	eb 38                	jmp    80075a <vprintfmt+0x2ec>
	else if (lflag)
  800722:	85 c9                	test   %ecx,%ecx
  800724:	74 1b                	je     800741 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 c1                	mov    %eax,%ecx
  800730:	c1 f9 1f             	sar    $0x1f,%ecx
  800733:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
  80073f:	eb 19                	jmp    80075a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 00                	mov    (%eax),%eax
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 c1                	mov    %eax,%ecx
  80074b:	c1 f9 1f             	sar    $0x1f,%ecx
  80074e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800765:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800769:	0f 89 0e 01 00 00    	jns    80087d <vprintfmt+0x40f>
				putch('-', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 2d                	push   $0x2d
  800775:	ff d6                	call   *%esi
				num = -(long long) num;
  800777:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077d:	f7 da                	neg    %edx
  80077f:	83 d1 00             	adc    $0x0,%ecx
  800782:	f7 d9                	neg    %ecx
  800784:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 ec 00 00 00       	jmp    80087d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 18                	jle    8007ae <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a9:	e9 cf 00 00 00       	jmp    80087d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1a                	je     8007cc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 b1 00 00 00       	jmp    80087d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 97 00 00 00       	jmp    80087d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 58                	push   $0x58
  8007ec:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 58                	push   $0x58
  8007f4:	ff d6                	call   *%esi
			putch('X', putdat);
  8007f6:	83 c4 08             	add    $0x8,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	6a 58                	push   $0x58
  8007fc:	ff d6                	call   *%esi
			break;
  8007fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800804:	e9 8b fc ff ff       	jmp    800494 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	53                   	push   %ebx
  80080d:	6a 30                	push   $0x30
  80080f:	ff d6                	call   *%esi
			putch('x', putdat);
  800811:	83 c4 08             	add    $0x8,%esp
  800814:	53                   	push   %ebx
  800815:	6a 78                	push   $0x78
  800817:	ff d6                	call   *%esi
			num = (unsigned long long)
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800823:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800826:	8d 40 04             	lea    0x4(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800831:	eb 4a                	jmp    80087d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800833:	83 f9 01             	cmp    $0x1,%ecx
  800836:	7e 15                	jle    80084d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	8b 48 04             	mov    0x4(%eax),%ecx
  800840:	8d 40 08             	lea    0x8(%eax),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800846:	b8 10 00 00 00       	mov    $0x10,%eax
  80084b:	eb 30                	jmp    80087d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 17                	je     800868 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800861:	b8 10 00 00 00       	mov    $0x10,%eax
  800866:	eb 15                	jmp    80087d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8b 10                	mov    (%eax),%edx
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800878:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087d:	83 ec 0c             	sub    $0xc,%esp
  800880:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800884:	57                   	push   %edi
  800885:	ff 75 e0             	pushl  -0x20(%ebp)
  800888:	50                   	push   %eax
  800889:	51                   	push   %ecx
  80088a:	52                   	push   %edx
  80088b:	89 da                	mov    %ebx,%edx
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	e8 f1 fa ff ff       	call   800385 <printnum>
			break;
  800894:	83 c4 20             	add    $0x20,%esp
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089a:	e9 f5 fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	52                   	push   %edx
  8008a4:	ff d6                	call   *%esi
			break;
  8008a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ac:	e9 e3 fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 25                	push   $0x25
  8008b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 03                	jmp    8008c1 <vprintfmt+0x453>
  8008be:	83 ef 01             	sub    $0x1,%edi
  8008c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c5:	75 f7                	jne    8008be <vprintfmt+0x450>
  8008c7:	e9 c8 fb ff ff       	jmp    800494 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	74 26                	je     80091b <vsnprintf+0x47>
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	7e 22                	jle    80091b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f9:	ff 75 14             	pushl  0x14(%ebp)
  8008fc:	ff 75 10             	pushl  0x10(%ebp)
  8008ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800902:	50                   	push   %eax
  800903:	68 34 04 80 00       	push   $0x800434
  800908:	e8 61 fb ff ff       	call   80046e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800910:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb 05                	jmp    800920 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092b:	50                   	push   %eax
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 9a ff ff ff       	call   8008d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
  800947:	eb 03                	jmp    80094c <strlen+0x10>
		n++;
  800949:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800950:	75 f7                	jne    800949 <strlen+0xd>
		n++;
	return n;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
  800962:	eb 03                	jmp    800967 <strnlen+0x13>
		n++;
  800964:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800967:	39 c2                	cmp    %eax,%edx
  800969:	74 08                	je     800973 <strnlen+0x1f>
  80096b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096f:	75 f3                	jne    800964 <strnlen+0x10>
  800971:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097f:	89 c2                	mov    %eax,%edx
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80098b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098e:	84 db                	test   %bl,%bl
  800990:	75 ef                	jne    800981 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80099c:	53                   	push   %ebx
  80099d:	e8 9a ff ff ff       	call   80093c <strlen>
  8009a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	01 d8                	add    %ebx,%eax
  8009aa:	50                   	push   %eax
  8009ab:	e8 c5 ff ff ff       	call   800975 <strcpy>
	return dst;
}
  8009b0:	89 d8                	mov    %ebx,%eax
  8009b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c2:	89 f3                	mov    %esi,%ebx
  8009c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	eb 0f                	jmp    8009da <strncpy+0x23>
		*dst++ = *src;
  8009cb:	83 c2 01             	add    $0x1,%edx
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009da:	39 da                	cmp    %ebx,%edx
  8009dc:	75 ed                	jne    8009cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8009f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f4:	85 d2                	test   %edx,%edx
  8009f6:	74 21                	je     800a19 <strlcpy+0x35>
  8009f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009fc:	89 f2                	mov    %esi,%edx
  8009fe:	eb 09                	jmp    800a09 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	83 c1 01             	add    $0x1,%ecx
  800a06:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a09:	39 c2                	cmp    %eax,%edx
  800a0b:	74 09                	je     800a16 <strlcpy+0x32>
  800a0d:	0f b6 19             	movzbl (%ecx),%ebx
  800a10:	84 db                	test   %bl,%bl
  800a12:	75 ec                	jne    800a00 <strlcpy+0x1c>
  800a14:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a16:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a19:	29 f0                	sub    %esi,%eax
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a28:	eb 06                	jmp    800a30 <strcmp+0x11>
		p++, q++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	84 c0                	test   %al,%al
  800a35:	74 04                	je     800a3b <strcmp+0x1c>
  800a37:	3a 02                	cmp    (%edx),%al
  800a39:	74 ef                	je     800a2a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3b:	0f b6 c0             	movzbl %al,%eax
  800a3e:	0f b6 12             	movzbl (%edx),%edx
  800a41:	29 d0                	sub    %edx,%eax
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a54:	eb 06                	jmp    800a5c <strncmp+0x17>
		n--, p++, q++;
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5c:	39 d8                	cmp    %ebx,%eax
  800a5e:	74 15                	je     800a75 <strncmp+0x30>
  800a60:	0f b6 08             	movzbl (%eax),%ecx
  800a63:	84 c9                	test   %cl,%cl
  800a65:	74 04                	je     800a6b <strncmp+0x26>
  800a67:	3a 0a                	cmp    (%edx),%cl
  800a69:	74 eb                	je     800a56 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	0f b6 00             	movzbl (%eax),%eax
  800a6e:	0f b6 12             	movzbl (%edx),%edx
  800a71:	29 d0                	sub    %edx,%eax
  800a73:	eb 05                	jmp    800a7a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a87:	eb 07                	jmp    800a90 <strchr+0x13>
		if (*s == c)
  800a89:	38 ca                	cmp    %cl,%dl
  800a8b:	74 0f                	je     800a9c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	0f b6 10             	movzbl (%eax),%edx
  800a93:	84 d2                	test   %dl,%dl
  800a95:	75 f2                	jne    800a89 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa8:	eb 03                	jmp    800aad <strfind+0xf>
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	74 04                	je     800ab8 <strfind+0x1a>
  800ab4:	84 d2                	test   %dl,%dl
  800ab6:	75 f2                	jne    800aaa <strfind+0xc>
			break;
	return (char *) s;
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac6:	85 c9                	test   %ecx,%ecx
  800ac8:	74 36                	je     800b00 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad0:	75 28                	jne    800afa <memset+0x40>
  800ad2:	f6 c1 03             	test   $0x3,%cl
  800ad5:	75 23                	jne    800afa <memset+0x40>
		c &= 0xFF;
  800ad7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	c1 e3 08             	shl    $0x8,%ebx
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	c1 e6 18             	shl    $0x18,%esi
  800ae5:	89 d0                	mov    %edx,%eax
  800ae7:	c1 e0 10             	shl    $0x10,%eax
  800aea:	09 f0                	or     %esi,%eax
  800aec:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aee:	89 d8                	mov    %ebx,%eax
  800af0:	09 d0                	or     %edx,%eax
  800af2:	c1 e9 02             	shr    $0x2,%ecx
  800af5:	fc                   	cld    
  800af6:	f3 ab                	rep stos %eax,%es:(%edi)
  800af8:	eb 06                	jmp    800b00 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	fc                   	cld    
  800afe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b00:	89 f8                	mov    %edi,%eax
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b15:	39 c6                	cmp    %eax,%esi
  800b17:	73 35                	jae    800b4e <memmove+0x47>
  800b19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b1c:	39 d0                	cmp    %edx,%eax
  800b1e:	73 2e                	jae    800b4e <memmove+0x47>
		s += n;
		d += n;
  800b20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	09 fe                	or     %edi,%esi
  800b27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2d:	75 13                	jne    800b42 <memmove+0x3b>
  800b2f:	f6 c1 03             	test   $0x3,%cl
  800b32:	75 0e                	jne    800b42 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b34:	83 ef 04             	sub    $0x4,%edi
  800b37:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3a:	c1 e9 02             	shr    $0x2,%ecx
  800b3d:	fd                   	std    
  800b3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b40:	eb 09                	jmp    800b4b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b42:	83 ef 01             	sub    $0x1,%edi
  800b45:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b48:	fd                   	std    
  800b49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4b:	fc                   	cld    
  800b4c:	eb 1d                	jmp    800b6b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4e:	89 f2                	mov    %esi,%edx
  800b50:	09 c2                	or     %eax,%edx
  800b52:	f6 c2 03             	test   $0x3,%dl
  800b55:	75 0f                	jne    800b66 <memmove+0x5f>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0a                	jne    800b66 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	fc                   	cld    
  800b62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b64:	eb 05                	jmp    800b6b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b66:	89 c7                	mov    %eax,%edi
  800b68:	fc                   	cld    
  800b69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b72:	ff 75 10             	pushl  0x10(%ebp)
  800b75:	ff 75 0c             	pushl  0xc(%ebp)
  800b78:	ff 75 08             	pushl  0x8(%ebp)
  800b7b:	e8 87 ff ff ff       	call   800b07 <memmove>
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8d:	89 c6                	mov    %eax,%esi
  800b8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b92:	eb 1a                	jmp    800bae <memcmp+0x2c>
		if (*s1 != *s2)
  800b94:	0f b6 08             	movzbl (%eax),%ecx
  800b97:	0f b6 1a             	movzbl (%edx),%ebx
  800b9a:	38 d9                	cmp    %bl,%cl
  800b9c:	74 0a                	je     800ba8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9e:	0f b6 c1             	movzbl %cl,%eax
  800ba1:	0f b6 db             	movzbl %bl,%ebx
  800ba4:	29 d8                	sub    %ebx,%eax
  800ba6:	eb 0f                	jmp    800bb7 <memcmp+0x35>
		s1++, s2++;
  800ba8:	83 c0 01             	add    $0x1,%eax
  800bab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bae:	39 f0                	cmp    %esi,%eax
  800bb0:	75 e2                	jne    800b94 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc2:	89 c1                	mov    %eax,%ecx
  800bc4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcb:	eb 0a                	jmp    800bd7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	39 da                	cmp    %ebx,%edx
  800bd2:	74 07                	je     800bdb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd4:	83 c0 01             	add    $0x1,%eax
  800bd7:	39 c8                	cmp    %ecx,%eax
  800bd9:	72 f2                	jb     800bcd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	eb 03                	jmp    800bef <strtol+0x11>
		s++;
  800bec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	0f b6 01             	movzbl (%ecx),%eax
  800bf2:	3c 20                	cmp    $0x20,%al
  800bf4:	74 f6                	je     800bec <strtol+0xe>
  800bf6:	3c 09                	cmp    $0x9,%al
  800bf8:	74 f2                	je     800bec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfa:	3c 2b                	cmp    $0x2b,%al
  800bfc:	75 0a                	jne    800c08 <strtol+0x2a>
		s++;
  800bfe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c01:	bf 00 00 00 00       	mov    $0x0,%edi
  800c06:	eb 11                	jmp    800c19 <strtol+0x3b>
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0d:	3c 2d                	cmp    $0x2d,%al
  800c0f:	75 08                	jne    800c19 <strtol+0x3b>
		s++, neg = 1;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1f:	75 15                	jne    800c36 <strtol+0x58>
  800c21:	80 39 30             	cmpb   $0x30,(%ecx)
  800c24:	75 10                	jne    800c36 <strtol+0x58>
  800c26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2a:	75 7c                	jne    800ca8 <strtol+0xca>
		s += 2, base = 16;
  800c2c:	83 c1 02             	add    $0x2,%ecx
  800c2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c34:	eb 16                	jmp    800c4c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c36:	85 db                	test   %ebx,%ebx
  800c38:	75 12                	jne    800c4c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c42:	75 08                	jne    800c4c <strtol+0x6e>
		s++, base = 8;
  800c44:	83 c1 01             	add    $0x1,%ecx
  800c47:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c54:	0f b6 11             	movzbl (%ecx),%edx
  800c57:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5a:	89 f3                	mov    %esi,%ebx
  800c5c:	80 fb 09             	cmp    $0x9,%bl
  800c5f:	77 08                	ja     800c69 <strtol+0x8b>
			dig = *s - '0';
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 30             	sub    $0x30,%edx
  800c67:	eb 22                	jmp    800c8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6c:	89 f3                	mov    %esi,%ebx
  800c6e:	80 fb 19             	cmp    $0x19,%bl
  800c71:	77 08                	ja     800c7b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c73:	0f be d2             	movsbl %dl,%edx
  800c76:	83 ea 57             	sub    $0x57,%edx
  800c79:	eb 10                	jmp    800c8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7e:	89 f3                	mov    %esi,%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 16                	ja     800c9b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c85:	0f be d2             	movsbl %dl,%edx
  800c88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8e:	7d 0b                	jge    800c9b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c90:	83 c1 01             	add    $0x1,%ecx
  800c93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c99:	eb b9                	jmp    800c54 <strtol+0x76>

	if (endptr)
  800c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9f:	74 0d                	je     800cae <strtol+0xd0>
		*endptr = (char *) s;
  800ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca4:	89 0e                	mov    %ecx,(%esi)
  800ca6:	eb 06                	jmp    800cae <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	74 98                	je     800c44 <strtol+0x66>
  800cac:	eb 9e                	jmp    800c4c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	f7 da                	neg    %edx
  800cb2:	85 ff                	test   %edi,%edi
  800cb4:	0f 45 c2             	cmovne %edx,%eax
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 c3                	mov    %eax,%ebx
  800ccf:	89 c7                	mov    %eax,%edi
  800cd1:	89 c6                	mov    %eax,%esi
  800cd3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cgetc>:

int
sys_cgetc(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 03                	push   $0x3
  800d21:	68 bf 27 80 00       	push   $0x8027bf
  800d26:	6a 23                	push   $0x23
  800d28:	68 dc 27 80 00       	push   $0x8027dc
  800d2d:	e8 66 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_yield>:

void
sys_yield(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 17                	jle    800db3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 04                	push   $0x4
  800da2:	68 bf 27 80 00       	push   $0x8027bf
  800da7:	6a 23                	push   $0x23
  800da9:	68 dc 27 80 00       	push   $0x8027dc
  800dae:	e8 e5 f4 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 17                	jle    800df5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 05                	push   $0x5
  800de4:	68 bf 27 80 00       	push   $0x8027bf
  800de9:	6a 23                	push   $0x23
  800deb:	68 dc 27 80 00       	push   $0x8027dc
  800df0:	e8 a3 f4 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 06 00 00 00       	mov    $0x6,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 17                	jle    800e37 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 06                	push   $0x6
  800e26:	68 bf 27 80 00       	push   $0x8027bf
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 dc 27 80 00       	push   $0x8027dc
  800e32:	e8 61 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 17                	jle    800e79 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	50                   	push   %eax
  800e66:	6a 08                	push   $0x8
  800e68:	68 bf 27 80 00       	push   $0x8027bf
  800e6d:	6a 23                	push   $0x23
  800e6f:	68 dc 27 80 00       	push   $0x8027dc
  800e74:	e8 1f f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 17                	jle    800ebb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 09                	push   $0x9
  800eaa:	68 bf 27 80 00       	push   $0x8027bf
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 dc 27 80 00       	push   $0x8027dc
  800eb6:	e8 dd f3 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 17                	jle    800efd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 0a                	push   $0xa
  800eec:	68 bf 27 80 00       	push   $0x8027bf
  800ef1:	6a 23                	push   $0x23
  800ef3:	68 dc 27 80 00       	push   $0x8027dc
  800ef8:	e8 9b f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0b:	be 00 00 00 00       	mov    $0x0,%esi
  800f10:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f36:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 cb                	mov    %ecx,%ebx
  800f40:	89 cf                	mov    %ecx,%edi
  800f42:	89 ce                	mov    %ecx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 0d                	push   $0xd
  800f50:	68 bf 27 80 00       	push   $0x8027bf
  800f55:	6a 23                	push   $0x23
  800f57:	68 dc 27 80 00       	push   $0x8027dc
  800f5c:	e8 37 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800f71:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800f73:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f77:	74 11                	je     800f8a <pgfault+0x21>
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
  800f7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f85:	f6 c4 08             	test   $0x8,%ah
  800f88:	75 14                	jne    800f9e <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 ec 27 80 00       	push   $0x8027ec
  800f92:	6a 1f                	push   $0x1f
  800f94:	68 4f 28 80 00       	push   $0x80284f
  800f99:	e8 fa f2 ff ff       	call   800298 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800f9e:	e8 97 fd ff ff       	call   800d3a <sys_getenvid>
  800fa3:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	6a 07                	push   $0x7
  800faa:	68 00 f0 7f 00       	push   $0x7ff000
  800faf:	50                   	push   %eax
  800fb0:	e8 c3 fd ff ff       	call   800d78 <sys_page_alloc>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 12                	jns    800fce <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800fbc:	50                   	push   %eax
  800fbd:	68 2c 28 80 00       	push   $0x80282c
  800fc2:	6a 2c                	push   $0x2c
  800fc4:	68 4f 28 80 00       	push   $0x80284f
  800fc9:	e8 ca f2 ff ff       	call   800298 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800fce:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	68 00 10 00 00       	push   $0x1000
  800fdc:	53                   	push   %ebx
  800fdd:	68 00 f0 7f 00       	push   $0x7ff000
  800fe2:	e8 20 fb ff ff       	call   800b07 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800fe7:	83 c4 08             	add    $0x8,%esp
  800fea:	53                   	push   %ebx
  800feb:	56                   	push   %esi
  800fec:	e8 0c fe ff ff       	call   800dfd <sys_page_unmap>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	79 12                	jns    80100a <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800ff8:	50                   	push   %eax
  800ff9:	68 5a 28 80 00       	push   $0x80285a
  800ffe:	6a 32                	push   $0x32
  801000:	68 4f 28 80 00       	push   $0x80284f
  801005:	e8 8e f2 ff ff       	call   800298 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	6a 07                	push   $0x7
  80100f:	53                   	push   %ebx
  801010:	56                   	push   %esi
  801011:	68 00 f0 7f 00       	push   $0x7ff000
  801016:	56                   	push   %esi
  801017:	e8 9f fd ff ff       	call   800dbb <sys_page_map>
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 12                	jns    801035 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  801023:	50                   	push   %eax
  801024:	68 78 28 80 00       	push   $0x802878
  801029:	6a 35                	push   $0x35
  80102b:	68 4f 28 80 00       	push   $0x80284f
  801030:	e8 63 f2 ff ff       	call   800298 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	68 00 f0 7f 00       	push   $0x7ff000
  80103d:	56                   	push   %esi
  80103e:	e8 ba fd ff ff       	call   800dfd <sys_page_unmap>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 12                	jns    80105c <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  80104a:	50                   	push   %eax
  80104b:	68 5a 28 80 00       	push   $0x80285a
  801050:	6a 38                	push   $0x38
  801052:	68 4f 28 80 00       	push   $0x80284f
  801057:	e8 3c f2 ff ff       	call   800298 <_panic>
	//panic("pgfault not implemented");
}
  80105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  80106c:	68 69 0f 80 00       	push   $0x800f69
  801071:	e8 db 0e 00 00       	call   801f51 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801076:	b8 07 00 00 00       	mov    $0x7,%eax
  80107b:	cd 30                	int    $0x30
  80107d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	0f 88 38 01 00 00    	js     8011c3 <fork+0x160>
  80108b:	89 c7                	mov    %eax,%edi
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  801092:	85 c0                	test   %eax,%eax
  801094:	75 21                	jne    8010b7 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  801096:	e8 9f fc ff ff       	call   800d3a <sys_getenvid>
  80109b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b2:	e9 86 01 00 00       	jmp    80123d <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  8010b7:	89 d8                	mov    %ebx,%eax
  8010b9:	c1 e8 16             	shr    $0x16,%eax
  8010bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c3:	a8 01                	test   $0x1,%al
  8010c5:	0f 84 90 00 00 00    	je     80115b <fork+0xf8>
  8010cb:	89 d8                	mov    %ebx,%eax
  8010cd:	c1 e8 0c             	shr    $0xc,%eax
  8010d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d7:	f6 c2 01             	test   $0x1,%dl
  8010da:	74 7f                	je     80115b <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  8010dc:	89 c6                	mov    %eax,%esi
  8010de:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  8010e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e8:	f6 c6 04             	test   $0x4,%dh
  8010eb:	74 33                	je     801120 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  8010ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fc:	50                   	push   %eax
  8010fd:	56                   	push   %esi
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	6a 00                	push   $0x0
  801102:	e8 b4 fc ff ff       	call   800dbb <sys_page_map>
  801107:	83 c4 20             	add    $0x20,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	79 4d                	jns    80115b <fork+0xf8>
		    panic("sys_page_map: %e", r);
  80110e:	50                   	push   %eax
  80110f:	68 94 28 80 00       	push   $0x802894
  801114:	6a 54                	push   $0x54
  801116:	68 4f 28 80 00       	push   $0x80284f
  80111b:	e8 78 f1 ff ff       	call   800298 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  801120:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801127:	a9 02 08 00 00       	test   $0x802,%eax
  80112c:	0f 85 c6 00 00 00    	jne    8011f8 <fork+0x195>
  801132:	e9 e3 00 00 00       	jmp    80121a <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801137:	50                   	push   %eax
  801138:	68 94 28 80 00       	push   $0x802894
  80113d:	6a 5d                	push   $0x5d
  80113f:	68 4f 28 80 00       	push   $0x80284f
  801144:	e8 4f f1 ff ff       	call   800298 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801149:	50                   	push   %eax
  80114a:	68 94 28 80 00       	push   $0x802894
  80114f:	6a 64                	push   $0x64
  801151:	68 4f 28 80 00       	push   $0x80284f
  801156:	e8 3d f1 ff ff       	call   800298 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  80115b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801161:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801167:	0f 85 4a ff ff ff    	jne    8010b7 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	6a 07                	push   $0x7
  801172:	68 00 f0 bf ee       	push   $0xeebff000
  801177:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80117a:	57                   	push   %edi
  80117b:	e8 f8 fb ff ff       	call   800d78 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801180:	83 c4 10             	add    $0x10,%esp
		return ret;
  801183:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801185:	85 c0                	test   %eax,%eax
  801187:	0f 88 b0 00 00 00    	js     80123d <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80118d:	a1 04 40 80 00       	mov    0x804004,%eax
  801192:	8b 40 64             	mov    0x64(%eax),%eax
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	50                   	push   %eax
  801199:	57                   	push   %edi
  80119a:	e8 24 fd ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
  80119f:	83 c4 10             	add    $0x10,%esp
		return ret;
  8011a2:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	0f 88 91 00 00 00    	js     80123d <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	6a 02                	push   $0x2
  8011b1:	57                   	push   %edi
  8011b2:	e8 88 fc ff ff       	call   800e3f <sys_env_set_status>
  8011b7:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	89 fa                	mov    %edi,%edx
  8011be:	0f 48 d0             	cmovs  %eax,%edx
  8011c1:	eb 7a                	jmp    80123d <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  8011c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011c6:	eb 75                	jmp    80123d <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  8011c8:	e8 6d fb ff ff       	call   800d3a <sys_getenvid>
  8011cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011d0:	e8 65 fb ff ff       	call   800d3a <sys_getenvid>
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	68 05 08 00 00       	push   $0x805
  8011dd:	56                   	push   %esi
  8011de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e1:	56                   	push   %esi
  8011e2:	50                   	push   %eax
  8011e3:	e8 d3 fb ff ff       	call   800dbb <sys_page_map>
  8011e8:	83 c4 20             	add    $0x20,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	0f 89 68 ff ff ff    	jns    80115b <fork+0xf8>
  8011f3:	e9 51 ff ff ff       	jmp    801149 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  8011f8:	e8 3d fb ff ff       	call   800d3a <sys_getenvid>
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	68 05 08 00 00       	push   $0x805
  801205:	56                   	push   %esi
  801206:	57                   	push   %edi
  801207:	56                   	push   %esi
  801208:	50                   	push   %eax
  801209:	e8 ad fb ff ff       	call   800dbb <sys_page_map>
  80120e:	83 c4 20             	add    $0x20,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	79 b3                	jns    8011c8 <fork+0x165>
  801215:	e9 1d ff ff ff       	jmp    801137 <fork+0xd4>
  80121a:	e8 1b fb ff ff       	call   800d3a <sys_getenvid>
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	6a 05                	push   $0x5
  801224:	56                   	push   %esi
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	50                   	push   %eax
  801228:	e8 8e fb ff ff       	call   800dbb <sys_page_map>
  80122d:	83 c4 20             	add    $0x20,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	0f 89 23 ff ff ff    	jns    80115b <fork+0xf8>
  801238:	e9 fa fe ff ff       	jmp    801137 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  80123d:	89 d0                	mov    %edx,%eax
  80123f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <sfork>:

// Challenge!
int
sfork(void)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80124d:	68 a5 28 80 00       	push   $0x8028a5
  801252:	68 ac 00 00 00       	push   $0xac
  801257:	68 4f 28 80 00       	push   $0x80284f
  80125c:	e8 37 f0 ff ff       	call   800298 <_panic>

00801261 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801264:	8b 45 08             	mov    0x8(%ebp),%eax
  801267:	05 00 00 00 30       	add    $0x30000000,%eax
  80126c:	c1 e8 0c             	shr    $0xc,%eax
}
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801274:	8b 45 08             	mov    0x8(%ebp),%eax
  801277:	05 00 00 00 30       	add    $0x30000000,%eax
  80127c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801281:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801293:	89 c2                	mov    %eax,%edx
  801295:	c1 ea 16             	shr    $0x16,%edx
  801298:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129f:	f6 c2 01             	test   $0x1,%dl
  8012a2:	74 11                	je     8012b5 <fd_alloc+0x2d>
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	c1 ea 0c             	shr    $0xc,%edx
  8012a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b0:	f6 c2 01             	test   $0x1,%dl
  8012b3:	75 09                	jne    8012be <fd_alloc+0x36>
			*fd_store = fd;
  8012b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bc:	eb 17                	jmp    8012d5 <fd_alloc+0x4d>
  8012be:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012c3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c8:	75 c9                	jne    801293 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ca:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012dd:	83 f8 1f             	cmp    $0x1f,%eax
  8012e0:	77 36                	ja     801318 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e2:	c1 e0 0c             	shl    $0xc,%eax
  8012e5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	c1 ea 16             	shr    $0x16,%edx
  8012ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 24                	je     80131f <fd_lookup+0x48>
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	c1 ea 0c             	shr    $0xc,%edx
  801300:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801307:	f6 c2 01             	test   $0x1,%dl
  80130a:	74 1a                	je     801326 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80130c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130f:	89 02                	mov    %eax,(%edx)
	return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
  801316:	eb 13                	jmp    80132b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801318:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131d:	eb 0c                	jmp    80132b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801324:	eb 05                	jmp    80132b <fd_lookup+0x54>
  801326:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801336:	ba 3c 29 80 00       	mov    $0x80293c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80133b:	eb 13                	jmp    801350 <dev_lookup+0x23>
  80133d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801340:	39 08                	cmp    %ecx,(%eax)
  801342:	75 0c                	jne    801350 <dev_lookup+0x23>
			*dev = devtab[i];
  801344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801347:	89 01                	mov    %eax,(%ecx)
			return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	eb 2e                	jmp    80137e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801350:	8b 02                	mov    (%edx),%eax
  801352:	85 c0                	test   %eax,%eax
  801354:	75 e7                	jne    80133d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801356:	a1 04 40 80 00       	mov    0x804004,%eax
  80135b:	8b 40 48             	mov    0x48(%eax),%eax
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	51                   	push   %ecx
  801362:	50                   	push   %eax
  801363:	68 bc 28 80 00       	push   $0x8028bc
  801368:	e8 04 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  80136d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801370:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 10             	sub    $0x10,%esp
  801388:	8b 75 08             	mov    0x8(%ebp),%esi
  80138b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801398:	c1 e8 0c             	shr    $0xc,%eax
  80139b:	50                   	push   %eax
  80139c:	e8 36 ff ff ff       	call   8012d7 <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 05                	js     8013ad <fd_close+0x2d>
	    || fd != fd2)
  8013a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ab:	74 0c                	je     8013b9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013ad:	84 db                	test   %bl,%bl
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	0f 44 c2             	cmove  %edx,%eax
  8013b7:	eb 41                	jmp    8013fa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 36                	pushl  (%esi)
  8013c2:	e8 66 ff ff ff       	call   80132d <dev_lookup>
  8013c7:	89 c3                	mov    %eax,%ebx
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 1a                	js     8013ea <fd_close+0x6a>
		if (dev->dev_close)
  8013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	74 0b                	je     8013ea <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	56                   	push   %esi
  8013e3:	ff d0                	call   *%eax
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	56                   	push   %esi
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 08 fa ff ff       	call   800dfd <sys_page_unmap>
	return r;
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	89 d8                	mov    %ebx,%eax
}
  8013fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	ff 75 08             	pushl  0x8(%ebp)
  80140e:	e8 c4 fe ff ff       	call   8012d7 <fd_lookup>
  801413:	83 c4 08             	add    $0x8,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 10                	js     80142a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	6a 01                	push   $0x1
  80141f:	ff 75 f4             	pushl  -0xc(%ebp)
  801422:	e8 59 ff ff ff       	call   801380 <fd_close>
  801427:	83 c4 10             	add    $0x10,%esp
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <close_all>:

void
close_all(void)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801433:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	53                   	push   %ebx
  80143c:	e8 c0 ff ff ff       	call   801401 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801441:	83 c3 01             	add    $0x1,%ebx
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	83 fb 20             	cmp    $0x20,%ebx
  80144a:	75 ec                	jne    801438 <close_all+0xc>
		close(i);
}
  80144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	83 ec 2c             	sub    $0x2c,%esp
  80145a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80145d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 6e fe ff ff       	call   8012d7 <fd_lookup>
  801469:	83 c4 08             	add    $0x8,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	0f 88 c1 00 00 00    	js     801535 <dup+0xe4>
		return r;
	close(newfdnum);
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	56                   	push   %esi
  801478:	e8 84 ff ff ff       	call   801401 <close>

	newfd = INDEX2FD(newfdnum);
  80147d:	89 f3                	mov    %esi,%ebx
  80147f:	c1 e3 0c             	shl    $0xc,%ebx
  801482:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801488:	83 c4 04             	add    $0x4,%esp
  80148b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80148e:	e8 de fd ff ff       	call   801271 <fd2data>
  801493:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801495:	89 1c 24             	mov    %ebx,(%esp)
  801498:	e8 d4 fd ff ff       	call   801271 <fd2data>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a3:	89 f8                	mov    %edi,%eax
  8014a5:	c1 e8 16             	shr    $0x16,%eax
  8014a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014af:	a8 01                	test   $0x1,%al
  8014b1:	74 37                	je     8014ea <dup+0x99>
  8014b3:	89 f8                	mov    %edi,%eax
  8014b5:	c1 e8 0c             	shr    $0xc,%eax
  8014b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	74 26                	je     8014ea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cb:	83 ec 0c             	sub    $0xc,%esp
  8014ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d7:	6a 00                	push   $0x0
  8014d9:	57                   	push   %edi
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 da f8 ff ff       	call   800dbb <sys_page_map>
  8014e1:	89 c7                	mov    %eax,%edi
  8014e3:	83 c4 20             	add    $0x20,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 2e                	js     801518 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ed:	89 d0                	mov    %edx,%eax
  8014ef:	c1 e8 0c             	shr    $0xc,%eax
  8014f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801501:	50                   	push   %eax
  801502:	53                   	push   %ebx
  801503:	6a 00                	push   $0x0
  801505:	52                   	push   %edx
  801506:	6a 00                	push   $0x0
  801508:	e8 ae f8 ff ff       	call   800dbb <sys_page_map>
  80150d:	89 c7                	mov    %eax,%edi
  80150f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801512:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801514:	85 ff                	test   %edi,%edi
  801516:	79 1d                	jns    801535 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	53                   	push   %ebx
  80151c:	6a 00                	push   $0x0
  80151e:	e8 da f8 ff ff       	call   800dfd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	ff 75 d4             	pushl  -0x2c(%ebp)
  801529:	6a 00                	push   $0x0
  80152b:	e8 cd f8 ff ff       	call   800dfd <sys_page_unmap>
	return r;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	89 f8                	mov    %edi,%eax
}
  801535:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801538:	5b                   	pop    %ebx
  801539:	5e                   	pop    %esi
  80153a:	5f                   	pop    %edi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 14             	sub    $0x14,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	53                   	push   %ebx
  80154c:	e8 86 fd ff ff       	call   8012d7 <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	89 c2                	mov    %eax,%edx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 6d                	js     8015c7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 c2 fd ff ff       	call   80132d <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 4c                	js     8015be <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801572:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801575:	8b 42 08             	mov    0x8(%edx),%eax
  801578:	83 e0 03             	and    $0x3,%eax
  80157b:	83 f8 01             	cmp    $0x1,%eax
  80157e:	75 21                	jne    8015a1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801580:	a1 04 40 80 00       	mov    0x804004,%eax
  801585:	8b 40 48             	mov    0x48(%eax),%eax
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	53                   	push   %ebx
  80158c:	50                   	push   %eax
  80158d:	68 00 29 80 00       	push   $0x802900
  801592:	e8 da ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159f:	eb 26                	jmp    8015c7 <read+0x8a>
	}
	if (!dev->dev_read)
  8015a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a4:	8b 40 08             	mov    0x8(%eax),%eax
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	74 17                	je     8015c2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	ff 75 10             	pushl  0x10(%ebp)
  8015b1:	ff 75 0c             	pushl  0xc(%ebp)
  8015b4:	52                   	push   %edx
  8015b5:	ff d0                	call   *%eax
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 09                	jmp    8015c7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	eb 05                	jmp    8015c7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e2:	eb 21                	jmp    801605 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	89 f0                	mov    %esi,%eax
  8015e9:	29 d8                	sub    %ebx,%eax
  8015eb:	50                   	push   %eax
  8015ec:	89 d8                	mov    %ebx,%eax
  8015ee:	03 45 0c             	add    0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	57                   	push   %edi
  8015f3:	e8 45 ff ff ff       	call   80153d <read>
		if (m < 0)
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 10                	js     80160f <readn+0x41>
			return m;
		if (m == 0)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	74 0a                	je     80160d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801603:	01 c3                	add    %eax,%ebx
  801605:	39 f3                	cmp    %esi,%ebx
  801607:	72 db                	jb     8015e4 <readn+0x16>
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	eb 02                	jmp    80160f <readn+0x41>
  80160d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 14             	sub    $0x14,%esp
  80161e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801621:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	53                   	push   %ebx
  801626:	e8 ac fc ff ff       	call   8012d7 <fd_lookup>
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	89 c2                	mov    %eax,%edx
  801630:	85 c0                	test   %eax,%eax
  801632:	78 68                	js     80169c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163e:	ff 30                	pushl  (%eax)
  801640:	e8 e8 fc ff ff       	call   80132d <dev_lookup>
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 47                	js     801693 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801653:	75 21                	jne    801676 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801655:	a1 04 40 80 00       	mov    0x804004,%eax
  80165a:	8b 40 48             	mov    0x48(%eax),%eax
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	53                   	push   %ebx
  801661:	50                   	push   %eax
  801662:	68 1c 29 80 00       	push   $0x80291c
  801667:	e8 05 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801674:	eb 26                	jmp    80169c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801676:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801679:	8b 52 0c             	mov    0xc(%edx),%edx
  80167c:	85 d2                	test   %edx,%edx
  80167e:	74 17                	je     801697 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801680:	83 ec 04             	sub    $0x4,%esp
  801683:	ff 75 10             	pushl  0x10(%ebp)
  801686:	ff 75 0c             	pushl  0xc(%ebp)
  801689:	50                   	push   %eax
  80168a:	ff d2                	call   *%edx
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb 09                	jmp    80169c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801693:	89 c2                	mov    %eax,%edx
  801695:	eb 05                	jmp    80169c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801697:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80169c:	89 d0                	mov    %edx,%eax
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 22 fc ff ff       	call   8012d7 <fd_lookup>
  8016b5:	83 c4 08             	add    $0x8,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 0e                	js     8016ca <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 14             	sub    $0x14,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	53                   	push   %ebx
  8016db:	e8 f7 fb ff ff       	call   8012d7 <fd_lookup>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 65                	js     80174e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	ff 30                	pushl  (%eax)
  8016f5:	e8 33 fc ff ff       	call   80132d <dev_lookup>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 44                	js     801745 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801708:	75 21                	jne    80172b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80170a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170f:	8b 40 48             	mov    0x48(%eax),%eax
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	68 dc 28 80 00       	push   $0x8028dc
  80171c:	e8 50 ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801729:	eb 23                	jmp    80174e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80172b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172e:	8b 52 18             	mov    0x18(%edx),%edx
  801731:	85 d2                	test   %edx,%edx
  801733:	74 14                	je     801749 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	50                   	push   %eax
  80173c:	ff d2                	call   *%edx
  80173e:	89 c2                	mov    %eax,%edx
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	eb 09                	jmp    80174e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801745:	89 c2                	mov    %eax,%edx
  801747:	eb 05                	jmp    80174e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801749:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80174e:	89 d0                	mov    %edx,%eax
  801750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 14             	sub    $0x14,%esp
  80175c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801762:	50                   	push   %eax
  801763:	ff 75 08             	pushl  0x8(%ebp)
  801766:	e8 6c fb ff ff       	call   8012d7 <fd_lookup>
  80176b:	83 c4 08             	add    $0x8,%esp
  80176e:	89 c2                	mov    %eax,%edx
  801770:	85 c0                	test   %eax,%eax
  801772:	78 58                	js     8017cc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177e:	ff 30                	pushl  (%eax)
  801780:	e8 a8 fb ff ff       	call   80132d <dev_lookup>
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	78 37                	js     8017c3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80178c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801793:	74 32                	je     8017c7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801795:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801798:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179f:	00 00 00 
	stat->st_isdir = 0;
  8017a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a9:	00 00 00 
	stat->st_dev = dev;
  8017ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	53                   	push   %ebx
  8017b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b9:	ff 50 14             	call   *0x14(%eax)
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	eb 09                	jmp    8017cc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	eb 05                	jmp    8017cc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017cc:	89 d0                	mov    %edx,%eax
  8017ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	6a 00                	push   $0x0
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 e9 01 00 00       	call   8019ce <open>
  8017e5:	89 c3                	mov    %eax,%ebx
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 1b                	js     801809 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	50                   	push   %eax
  8017f5:	e8 5b ff ff ff       	call   801755 <fstat>
  8017fa:	89 c6                	mov    %eax,%esi
	close(fd);
  8017fc:	89 1c 24             	mov    %ebx,(%esp)
  8017ff:	e8 fd fb ff ff       	call   801401 <close>
	return r;
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	89 f0                	mov    %esi,%eax
}
  801809:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180c:	5b                   	pop    %ebx
  80180d:	5e                   	pop    %esi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	89 c6                	mov    %eax,%esi
  801817:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801819:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801820:	75 12                	jne    801834 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	6a 01                	push   $0x1
  801827:	e8 95 08 00 00       	call   8020c1 <ipc_find_env>
  80182c:	a3 00 40 80 00       	mov    %eax,0x804000
  801831:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801834:	6a 07                	push   $0x7
  801836:	68 00 50 80 00       	push   $0x805000
  80183b:	56                   	push   %esi
  80183c:	ff 35 00 40 80 00    	pushl  0x804000
  801842:	e8 26 08 00 00       	call   80206d <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801847:	83 c4 0c             	add    $0xc,%esp
  80184a:	6a 00                	push   $0x0
  80184c:	53                   	push   %ebx
  80184d:	6a 00                	push   $0x0
  80184f:	e8 97 07 00 00       	call   801feb <ipc_recv>
}
  801854:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 40 0c             	mov    0xc(%eax),%eax
  801867:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 02 00 00 00       	mov    $0x2,%eax
  80187e:	e8 8d ff ff ff       	call   801810 <fsipc>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 40 0c             	mov    0xc(%eax),%eax
  801891:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a0:	e8 6b ff ff ff       	call   801810 <fsipc>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c6:	e8 45 ff ff ff       	call   801810 <fsipc>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 2c                	js     8018fb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	68 00 50 80 00       	push   $0x805000
  8018d7:	53                   	push   %ebx
  8018d8:	e8 98 f0 ff ff       	call   800975 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	8b 45 10             	mov    0x10(%ebp),%eax
  801909:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80190e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801913:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801916:	8b 55 08             	mov    0x8(%ebp),%edx
  801919:	8b 52 0c             	mov    0xc(%edx),%edx
  80191c:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801922:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801927:	50                   	push   %eax
  801928:	ff 75 0c             	pushl  0xc(%ebp)
  80192b:	68 08 50 80 00       	push   $0x805008
  801930:	e8 d2 f1 ff ff       	call   800b07 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	b8 04 00 00 00       	mov    $0x4,%eax
  80193f:	e8 cc fe ff ff       	call   801810 <fsipc>
            return r;

    return r;
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	8b 40 0c             	mov    0xc(%eax),%eax
  801954:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801959:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 03 00 00 00       	mov    $0x3,%eax
  801969:	e8 a2 fe ff ff       	call   801810 <fsipc>
  80196e:	89 c3                	mov    %eax,%ebx
  801970:	85 c0                	test   %eax,%eax
  801972:	78 51                	js     8019c5 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801974:	39 c6                	cmp    %eax,%esi
  801976:	73 19                	jae    801991 <devfile_read+0x4b>
  801978:	68 4c 29 80 00       	push   $0x80294c
  80197d:	68 53 29 80 00       	push   $0x802953
  801982:	68 82 00 00 00       	push   $0x82
  801987:	68 68 29 80 00       	push   $0x802968
  80198c:	e8 07 e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801991:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801996:	7e 19                	jle    8019b1 <devfile_read+0x6b>
  801998:	68 73 29 80 00       	push   $0x802973
  80199d:	68 53 29 80 00       	push   $0x802953
  8019a2:	68 83 00 00 00       	push   $0x83
  8019a7:	68 68 29 80 00       	push   $0x802968
  8019ac:	e8 e7 e8 ff ff       	call   800298 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b1:	83 ec 04             	sub    $0x4,%esp
  8019b4:	50                   	push   %eax
  8019b5:	68 00 50 80 00       	push   $0x805000
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	e8 45 f1 ff ff       	call   800b07 <memmove>
	return r;
  8019c2:	83 c4 10             	add    $0x10,%esp
}
  8019c5:	89 d8                	mov    %ebx,%eax
  8019c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 20             	sub    $0x20,%esp
  8019d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019d8:	53                   	push   %ebx
  8019d9:	e8 5e ef ff ff       	call   80093c <strlen>
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e6:	7f 67                	jg     801a4f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ee:	50                   	push   %eax
  8019ef:	e8 94 f8 ff ff       	call   801288 <fd_alloc>
  8019f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	78 57                	js     801a54 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	53                   	push   %ebx
  801a01:	68 00 50 80 00       	push   $0x805000
  801a06:	e8 6a ef ff ff       	call   800975 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a16:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1b:	e8 f0 fd ff ff       	call   801810 <fsipc>
  801a20:	89 c3                	mov    %eax,%ebx
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	79 14                	jns    801a3d <open+0x6f>
		fd_close(fd, 0);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	6a 00                	push   $0x0
  801a2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a31:	e8 4a f9 ff ff       	call   801380 <fd_close>
		return r;
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	89 da                	mov    %ebx,%edx
  801a3b:	eb 17                	jmp    801a54 <open+0x86>
	}

	return fd2num(fd);
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	ff 75 f4             	pushl  -0xc(%ebp)
  801a43:	e8 19 f8 ff ff       	call   801261 <fd2num>
  801a48:	89 c2                	mov    %eax,%edx
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	eb 05                	jmp    801a54 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a4f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a54:	89 d0                	mov    %edx,%eax
  801a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6b:	e8 a0 fd ff ff       	call   801810 <fsipc>
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	ff 75 08             	pushl  0x8(%ebp)
  801a80:	e8 ec f7 ff ff       	call   801271 <fd2data>
  801a85:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a87:	83 c4 08             	add    $0x8,%esp
  801a8a:	68 7f 29 80 00       	push   $0x80297f
  801a8f:	53                   	push   %ebx
  801a90:	e8 e0 ee ff ff       	call   800975 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a95:	8b 46 04             	mov    0x4(%esi),%eax
  801a98:	2b 06                	sub    (%esi),%eax
  801a9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aa0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa7:	00 00 00 
	stat->st_dev = &devpipe;
  801aaa:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ab1:	30 80 00 
	return 0;
}
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aca:	53                   	push   %ebx
  801acb:	6a 00                	push   $0x0
  801acd:	e8 2b f3 ff ff       	call   800dfd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ad2:	89 1c 24             	mov    %ebx,(%esp)
  801ad5:	e8 97 f7 ff ff       	call   801271 <fd2data>
  801ada:	83 c4 08             	add    $0x8,%esp
  801add:	50                   	push   %eax
  801ade:	6a 00                	push   $0x0
  801ae0:	e8 18 f3 ff ff       	call   800dfd <sys_page_unmap>
}
  801ae5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	83 ec 1c             	sub    $0x1c,%esp
  801af3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801af6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af8:	a1 04 40 80 00       	mov    0x804004,%eax
  801afd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	ff 75 e0             	pushl  -0x20(%ebp)
  801b06:	e8 ef 05 00 00       	call   8020fa <pageref>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	89 3c 24             	mov    %edi,(%esp)
  801b10:	e8 e5 05 00 00       	call   8020fa <pageref>
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	39 c3                	cmp    %eax,%ebx
  801b1a:	0f 94 c1             	sete   %cl
  801b1d:	0f b6 c9             	movzbl %cl,%ecx
  801b20:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b23:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b29:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b2c:	39 ce                	cmp    %ecx,%esi
  801b2e:	74 1b                	je     801b4b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b30:	39 c3                	cmp    %eax,%ebx
  801b32:	75 c4                	jne    801af8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b34:	8b 42 58             	mov    0x58(%edx),%eax
  801b37:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3a:	50                   	push   %eax
  801b3b:	56                   	push   %esi
  801b3c:	68 86 29 80 00       	push   $0x802986
  801b41:	e8 2b e8 ff ff       	call   800371 <cprintf>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	eb ad                	jmp    801af8 <_pipeisclosed+0xe>
	}
}
  801b4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 28             	sub    $0x28,%esp
  801b5f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b62:	56                   	push   %esi
  801b63:	e8 09 f7 ff ff       	call   801271 <fd2data>
  801b68:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	bf 00 00 00 00       	mov    $0x0,%edi
  801b72:	eb 4b                	jmp    801bbf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b74:	89 da                	mov    %ebx,%edx
  801b76:	89 f0                	mov    %esi,%eax
  801b78:	e8 6d ff ff ff       	call   801aea <_pipeisclosed>
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	75 48                	jne    801bc9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b81:	e8 d3 f1 ff ff       	call   800d59 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b86:	8b 43 04             	mov    0x4(%ebx),%eax
  801b89:	8b 0b                	mov    (%ebx),%ecx
  801b8b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b8e:	39 d0                	cmp    %edx,%eax
  801b90:	73 e2                	jae    801b74 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b95:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b99:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	c1 fa 1f             	sar    $0x1f,%edx
  801ba1:	89 d1                	mov    %edx,%ecx
  801ba3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba9:	83 e2 1f             	and    $0x1f,%edx
  801bac:	29 ca                	sub    %ecx,%edx
  801bae:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bb2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb6:	83 c0 01             	add    $0x1,%eax
  801bb9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbc:	83 c7 01             	add    $0x1,%edi
  801bbf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc2:	75 c2                	jne    801b86 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc4:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc7:	eb 05                	jmp    801bce <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	57                   	push   %edi
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 18             	sub    $0x18,%esp
  801bdf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801be2:	57                   	push   %edi
  801be3:	e8 89 f6 ff ff       	call   801271 <fd2data>
  801be8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf2:	eb 3d                	jmp    801c31 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf4:	85 db                	test   %ebx,%ebx
  801bf6:	74 04                	je     801bfc <devpipe_read+0x26>
				return i;
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	eb 44                	jmp    801c40 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	89 f8                	mov    %edi,%eax
  801c00:	e8 e5 fe ff ff       	call   801aea <_pipeisclosed>
  801c05:	85 c0                	test   %eax,%eax
  801c07:	75 32                	jne    801c3b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c09:	e8 4b f1 ff ff       	call   800d59 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c0e:	8b 06                	mov    (%esi),%eax
  801c10:	3b 46 04             	cmp    0x4(%esi),%eax
  801c13:	74 df                	je     801bf4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c15:	99                   	cltd   
  801c16:	c1 ea 1b             	shr    $0x1b,%edx
  801c19:	01 d0                	add    %edx,%eax
  801c1b:	83 e0 1f             	and    $0x1f,%eax
  801c1e:	29 d0                	sub    %edx,%eax
  801c20:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c28:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c2b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2e:	83 c3 01             	add    $0x1,%ebx
  801c31:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c34:	75 d8                	jne    801c0e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c36:	8b 45 10             	mov    0x10(%ebp),%eax
  801c39:	eb 05                	jmp    801c40 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	e8 2f f6 ff ff       	call   801288 <fd_alloc>
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	89 c2                	mov    %eax,%edx
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	0f 88 2c 01 00 00    	js     801d92 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c66:	83 ec 04             	sub    $0x4,%esp
  801c69:	68 07 04 00 00       	push   $0x407
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	6a 00                	push   $0x0
  801c73:	e8 00 f1 ff ff       	call   800d78 <sys_page_alloc>
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	89 c2                	mov    %eax,%edx
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	0f 88 0d 01 00 00    	js     801d92 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8b:	50                   	push   %eax
  801c8c:	e8 f7 f5 ff ff       	call   801288 <fd_alloc>
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	85 c0                	test   %eax,%eax
  801c98:	0f 88 e2 00 00 00    	js     801d80 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9e:	83 ec 04             	sub    $0x4,%esp
  801ca1:	68 07 04 00 00       	push   $0x407
  801ca6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 c8 f0 ff ff       	call   800d78 <sys_page_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	0f 88 c3 00 00 00    	js     801d80 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cbd:	83 ec 0c             	sub    $0xc,%esp
  801cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc3:	e8 a9 f5 ff ff       	call   801271 <fd2data>
  801cc8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cca:	83 c4 0c             	add    $0xc,%esp
  801ccd:	68 07 04 00 00       	push   $0x407
  801cd2:	50                   	push   %eax
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 9e f0 ff ff       	call   800d78 <sys_page_alloc>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 89 00 00 00    	js     801d70 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 f0             	pushl  -0x10(%ebp)
  801ced:	e8 7f f5 ff ff       	call   801271 <fd2data>
  801cf2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf9:	50                   	push   %eax
  801cfa:	6a 00                	push   $0x0
  801cfc:	56                   	push   %esi
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 b7 f0 ff ff       	call   800dbb <sys_page_map>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	83 c4 20             	add    $0x20,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 55                	js     801d62 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3d:	e8 1f f5 ff ff       	call   801261 <fd2num>
  801d42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d45:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d47:	83 c4 04             	add    $0x4,%esp
  801d4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4d:	e8 0f f5 ff ff       	call   801261 <fd2num>
  801d52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d55:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d60:	eb 30                	jmp    801d92 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	56                   	push   %esi
  801d66:	6a 00                	push   $0x0
  801d68:	e8 90 f0 ff ff       	call   800dfd <sys_page_unmap>
  801d6d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	ff 75 f0             	pushl  -0x10(%ebp)
  801d76:	6a 00                	push   $0x0
  801d78:	e8 80 f0 ff ff       	call   800dfd <sys_page_unmap>
  801d7d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	ff 75 f4             	pushl  -0xc(%ebp)
  801d86:	6a 00                	push   $0x0
  801d88:	e8 70 f0 ff ff       	call   800dfd <sys_page_unmap>
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d92:	89 d0                	mov    %edx,%eax
  801d94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da4:	50                   	push   %eax
  801da5:	ff 75 08             	pushl  0x8(%ebp)
  801da8:	e8 2a f5 ff ff       	call   8012d7 <fd_lookup>
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	78 18                	js     801dcc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dba:	e8 b2 f4 ff ff       	call   801271 <fd2data>
	return _pipeisclosed(fd, p);
  801dbf:	89 c2                	mov    %eax,%edx
  801dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc4:	e8 21 fd ff ff       	call   801aea <_pipeisclosed>
  801dc9:	83 c4 10             	add    $0x10,%esp
}
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    

00801dd8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dde:	68 99 29 80 00       	push   $0x802999
  801de3:	ff 75 0c             	pushl  0xc(%ebp)
  801de6:	e8 8a eb ff ff       	call   800975 <strcpy>
	return 0;
}
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	57                   	push   %edi
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfe:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e03:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e09:	eb 2d                	jmp    801e38 <devcons_write+0x46>
		m = n - tot;
  801e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e10:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e13:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e18:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	53                   	push   %ebx
  801e1f:	03 45 0c             	add    0xc(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	57                   	push   %edi
  801e24:	e8 de ec ff ff       	call   800b07 <memmove>
		sys_cputs(buf, m);
  801e29:	83 c4 08             	add    $0x8,%esp
  801e2c:	53                   	push   %ebx
  801e2d:	57                   	push   %edi
  801e2e:	e8 89 ee ff ff       	call   800cbc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e33:	01 de                	add    %ebx,%esi
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	89 f0                	mov    %esi,%eax
  801e3a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3d:	72 cc                	jb     801e0b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e42:	5b                   	pop    %ebx
  801e43:	5e                   	pop    %esi
  801e44:	5f                   	pop    %edi
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 08             	sub    $0x8,%esp
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e56:	74 2a                	je     801e82 <devcons_read+0x3b>
  801e58:	eb 05                	jmp    801e5f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e5a:	e8 fa ee ff ff       	call   800d59 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e5f:	e8 76 ee ff ff       	call   800cda <sys_cgetc>
  801e64:	85 c0                	test   %eax,%eax
  801e66:	74 f2                	je     801e5a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 16                	js     801e82 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e6c:	83 f8 04             	cmp    $0x4,%eax
  801e6f:	74 0c                	je     801e7d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e74:	88 02                	mov    %al,(%edx)
	return 1;
  801e76:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7b:	eb 05                	jmp    801e82 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e90:	6a 01                	push   $0x1
  801e92:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	e8 21 ee ff ff       	call   800cbc <sys_cputs>
}
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <getchar>:

int
getchar(void)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ea6:	6a 01                	push   $0x1
  801ea8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	6a 00                	push   $0x0
  801eae:	e8 8a f6 ff ff       	call   80153d <read>
	if (r < 0)
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 0f                	js     801ec9 <getchar+0x29>
		return r;
	if (r < 1)
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	7e 06                	jle    801ec4 <getchar+0x24>
		return -E_EOF;
	return c;
  801ebe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ec2:	eb 05                	jmp    801ec9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ec4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed4:	50                   	push   %eax
  801ed5:	ff 75 08             	pushl  0x8(%ebp)
  801ed8:	e8 fa f3 ff ff       	call   8012d7 <fd_lookup>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 11                	js     801ef5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eed:	39 10                	cmp    %edx,(%eax)
  801eef:	0f 94 c0             	sete   %al
  801ef2:	0f b6 c0             	movzbl %al,%eax
}
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <opencons>:

int
opencons(void)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f00:	50                   	push   %eax
  801f01:	e8 82 f3 ff ff       	call   801288 <fd_alloc>
  801f06:	83 c4 10             	add    $0x10,%esp
		return r;
  801f09:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 3e                	js     801f4d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f0f:	83 ec 04             	sub    $0x4,%esp
  801f12:	68 07 04 00 00       	push   $0x407
  801f17:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1a:	6a 00                	push   $0x0
  801f1c:	e8 57 ee ff ff       	call   800d78 <sys_page_alloc>
  801f21:	83 c4 10             	add    $0x10,%esp
		return r;
  801f24:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 23                	js     801f4d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f2a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f33:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f38:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3f:	83 ec 0c             	sub    $0xc,%esp
  801f42:	50                   	push   %eax
  801f43:	e8 19 f3 ff ff       	call   801261 <fd2num>
  801f48:	89 c2                	mov    %eax,%edx
  801f4a:	83 c4 10             	add    $0x10,%esp
}
  801f4d:	89 d0                	mov    %edx,%eax
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	53                   	push   %ebx
  801f55:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801f58:	e8 dd ed ff ff       	call   800d3a <sys_getenvid>
  801f5d:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801f5f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f66:	75 29                	jne    801f91 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801f68:	83 ec 04             	sub    $0x4,%esp
  801f6b:	6a 07                	push   $0x7
  801f6d:	68 00 f0 bf ee       	push   $0xeebff000
  801f72:	50                   	push   %eax
  801f73:	e8 00 ee ff ff       	call   800d78 <sys_page_alloc>
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	79 12                	jns    801f91 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801f7f:	50                   	push   %eax
  801f80:	68 a5 29 80 00       	push   $0x8029a5
  801f85:	6a 24                	push   $0x24
  801f87:	68 be 29 80 00       	push   $0x8029be
  801f8c:	e8 07 e3 ff ff       	call   800298 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801f91:	8b 45 08             	mov    0x8(%ebp),%eax
  801f94:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801f99:	83 ec 08             	sub    $0x8,%esp
  801f9c:	68 c5 1f 80 00       	push   $0x801fc5
  801fa1:	53                   	push   %ebx
  801fa2:	e8 1c ef ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	85 c0                	test   %eax,%eax
  801fac:	79 12                	jns    801fc0 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801fae:	50                   	push   %eax
  801faf:	68 a5 29 80 00       	push   $0x8029a5
  801fb4:	6a 2e                	push   $0x2e
  801fb6:	68 be 29 80 00       	push   $0x8029be
  801fbb:	e8 d8 e2 ff ff       	call   800298 <_panic>
}
  801fc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fcb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fcd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801fd0:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801fd4:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801fd7:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801fdb:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801fdd:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801fe1:	83 c4 08             	add    $0x8,%esp
	popal
  801fe4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801fe5:	83 c4 04             	add    $0x4,%esp
	popfl
  801fe8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801fe9:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fea:	c3                   	ret    

00801feb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	57                   	push   %edi
  801fef:	56                   	push   %esi
  801ff0:	53                   	push   %ebx
  801ff1:	83 ec 0c             	sub    $0xc,%esp
  801ff4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801ffd:	85 f6                	test   %esi,%esi
  801fff:	74 06                	je     802007 <ipc_recv+0x1c>
		*from_env_store = 0;
  802001:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  802007:	85 db                	test   %ebx,%ebx
  802009:	74 06                	je     802011 <ipc_recv+0x26>
		*perm_store = 0;
  80200b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  802011:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  802013:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802018:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  80201b:	83 ec 0c             	sub    $0xc,%esp
  80201e:	50                   	push   %eax
  80201f:	e8 04 ef ff ff       	call   800f28 <sys_ipc_recv>
  802024:	89 c7                	mov    %eax,%edi
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	85 c0                	test   %eax,%eax
  80202b:	79 14                	jns    802041 <ipc_recv+0x56>
		cprintf("im dead");
  80202d:	83 ec 0c             	sub    $0xc,%esp
  802030:	68 cc 29 80 00       	push   $0x8029cc
  802035:	e8 37 e3 ff ff       	call   800371 <cprintf>
		return r;
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	89 f8                	mov    %edi,%eax
  80203f:	eb 24                	jmp    802065 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  802041:	85 f6                	test   %esi,%esi
  802043:	74 0a                	je     80204f <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  802045:	a1 04 40 80 00       	mov    0x804004,%eax
  80204a:	8b 40 74             	mov    0x74(%eax),%eax
  80204d:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  80204f:	85 db                	test   %ebx,%ebx
  802051:	74 0a                	je     80205d <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  802053:	a1 04 40 80 00       	mov    0x804004,%eax
  802058:	8b 40 78             	mov    0x78(%eax),%eax
  80205b:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  80205d:	a1 04 40 80 00       	mov    0x804004,%eax
  802062:	8b 40 70             	mov    0x70(%eax),%eax
}
  802065:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802068:	5b                   	pop    %ebx
  802069:	5e                   	pop    %esi
  80206a:	5f                   	pop    %edi
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    

0080206d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	57                   	push   %edi
  802071:	56                   	push   %esi
  802072:	53                   	push   %ebx
  802073:	83 ec 0c             	sub    $0xc,%esp
  802076:	8b 7d 08             	mov    0x8(%ebp),%edi
  802079:	8b 75 0c             	mov    0xc(%ebp),%esi
  80207c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  80207f:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  802081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802086:	0f 44 d8             	cmove  %eax,%ebx
  802089:	eb 1c                	jmp    8020a7 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  80208b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80208e:	74 12                	je     8020a2 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  802090:	50                   	push   %eax
  802091:	68 d4 29 80 00       	push   $0x8029d4
  802096:	6a 4e                	push   $0x4e
  802098:	68 e1 29 80 00       	push   $0x8029e1
  80209d:	e8 f6 e1 ff ff       	call   800298 <_panic>
		sys_yield();
  8020a2:	e8 b2 ec ff ff       	call   800d59 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020a7:	ff 75 14             	pushl  0x14(%ebp)
  8020aa:	53                   	push   %ebx
  8020ab:	56                   	push   %esi
  8020ac:	57                   	push   %edi
  8020ad:	e8 53 ee ff ff       	call   800f05 <sys_ipc_try_send>
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	78 d2                	js     80208b <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  8020b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020bc:	5b                   	pop    %ebx
  8020bd:	5e                   	pop    %esi
  8020be:	5f                   	pop    %edi
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    

008020c1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020c7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020cc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020cf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020d5:	8b 52 50             	mov    0x50(%edx),%edx
  8020d8:	39 ca                	cmp    %ecx,%edx
  8020da:	75 0d                	jne    8020e9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020e4:	8b 40 48             	mov    0x48(%eax),%eax
  8020e7:	eb 0f                	jmp    8020f8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e9:	83 c0 01             	add    $0x1,%eax
  8020ec:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020f1:	75 d9                	jne    8020cc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    

008020fa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802100:	89 d0                	mov    %edx,%eax
  802102:	c1 e8 16             	shr    $0x16,%eax
  802105:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80210c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802111:	f6 c1 01             	test   $0x1,%cl
  802114:	74 1d                	je     802133 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802116:	c1 ea 0c             	shr    $0xc,%edx
  802119:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802120:	f6 c2 01             	test   $0x1,%dl
  802123:	74 0e                	je     802133 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802125:	c1 ea 0c             	shr    $0xc,%edx
  802128:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80212f:	ef 
  802130:	0f b7 c0             	movzwl %ax,%eax
}
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	66 90                	xchg   %ax,%ax
  802137:	66 90                	xchg   %ax,%ax
  802139:	66 90                	xchg   %ax,%ax
  80213b:	66 90                	xchg   %ax,%ax
  80213d:	66 90                	xchg   %ax,%ax
  80213f:	90                   	nop

00802140 <__udivdi3>:
  802140:	55                   	push   %ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 1c             	sub    $0x1c,%esp
  802147:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80214b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80214f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802157:	85 f6                	test   %esi,%esi
  802159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80215d:	89 ca                	mov    %ecx,%edx
  80215f:	89 f8                	mov    %edi,%eax
  802161:	75 3d                	jne    8021a0 <__udivdi3+0x60>
  802163:	39 cf                	cmp    %ecx,%edi
  802165:	0f 87 c5 00 00 00    	ja     802230 <__udivdi3+0xf0>
  80216b:	85 ff                	test   %edi,%edi
  80216d:	89 fd                	mov    %edi,%ebp
  80216f:	75 0b                	jne    80217c <__udivdi3+0x3c>
  802171:	b8 01 00 00 00       	mov    $0x1,%eax
  802176:	31 d2                	xor    %edx,%edx
  802178:	f7 f7                	div    %edi
  80217a:	89 c5                	mov    %eax,%ebp
  80217c:	89 c8                	mov    %ecx,%eax
  80217e:	31 d2                	xor    %edx,%edx
  802180:	f7 f5                	div    %ebp
  802182:	89 c1                	mov    %eax,%ecx
  802184:	89 d8                	mov    %ebx,%eax
  802186:	89 cf                	mov    %ecx,%edi
  802188:	f7 f5                	div    %ebp
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	39 ce                	cmp    %ecx,%esi
  8021a2:	77 74                	ja     802218 <__udivdi3+0xd8>
  8021a4:	0f bd fe             	bsr    %esi,%edi
  8021a7:	83 f7 1f             	xor    $0x1f,%edi
  8021aa:	0f 84 98 00 00 00    	je     802248 <__udivdi3+0x108>
  8021b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	89 c5                	mov    %eax,%ebp
  8021b9:	29 fb                	sub    %edi,%ebx
  8021bb:	d3 e6                	shl    %cl,%esi
  8021bd:	89 d9                	mov    %ebx,%ecx
  8021bf:	d3 ed                	shr    %cl,%ebp
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	d3 e0                	shl    %cl,%eax
  8021c5:	09 ee                	or     %ebp,%esi
  8021c7:	89 d9                	mov    %ebx,%ecx
  8021c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021cd:	89 d5                	mov    %edx,%ebp
  8021cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021d3:	d3 ed                	shr    %cl,%ebp
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e2                	shl    %cl,%edx
  8021d9:	89 d9                	mov    %ebx,%ecx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	09 c2                	or     %eax,%edx
  8021df:	89 d0                	mov    %edx,%eax
  8021e1:	89 ea                	mov    %ebp,%edx
  8021e3:	f7 f6                	div    %esi
  8021e5:	89 d5                	mov    %edx,%ebp
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	72 10                	jb     802201 <__udivdi3+0xc1>
  8021f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e6                	shl    %cl,%esi
  8021f9:	39 c6                	cmp    %eax,%esi
  8021fb:	73 07                	jae    802204 <__udivdi3+0xc4>
  8021fd:	39 d5                	cmp    %edx,%ebp
  8021ff:	75 03                	jne    802204 <__udivdi3+0xc4>
  802201:	83 eb 01             	sub    $0x1,%ebx
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 d8                	mov    %ebx,%eax
  802208:	89 fa                	mov    %edi,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	31 ff                	xor    %edi,%edi
  80221a:	31 db                	xor    %ebx,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 d8                	mov    %ebx,%eax
  802232:	f7 f7                	div    %edi
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 c3                	mov    %eax,%ebx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 fa                	mov    %edi,%edx
  80223c:	83 c4 1c             	add    $0x1c,%esp
  80223f:	5b                   	pop    %ebx
  802240:	5e                   	pop    %esi
  802241:	5f                   	pop    %edi
  802242:	5d                   	pop    %ebp
  802243:	c3                   	ret    
  802244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802248:	39 ce                	cmp    %ecx,%esi
  80224a:	72 0c                	jb     802258 <__udivdi3+0x118>
  80224c:	31 db                	xor    %ebx,%ebx
  80224e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802252:	0f 87 34 ff ff ff    	ja     80218c <__udivdi3+0x4c>
  802258:	bb 01 00 00 00       	mov    $0x1,%ebx
  80225d:	e9 2a ff ff ff       	jmp    80218c <__udivdi3+0x4c>
  802262:	66 90                	xchg   %ax,%ax
  802264:	66 90                	xchg   %ax,%ax
  802266:	66 90                	xchg   %ax,%ax
  802268:	66 90                	xchg   %ax,%ax
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	66 90                	xchg   %ax,%ax
  80226e:	66 90                	xchg   %ax,%ax

00802270 <__umoddi3>:
  802270:	55                   	push   %ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	83 ec 1c             	sub    $0x1c,%esp
  802277:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80227b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80227f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802287:	85 d2                	test   %edx,%edx
  802289:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80228d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802291:	89 f3                	mov    %esi,%ebx
  802293:	89 3c 24             	mov    %edi,(%esp)
  802296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80229a:	75 1c                	jne    8022b8 <__umoddi3+0x48>
  80229c:	39 f7                	cmp    %esi,%edi
  80229e:	76 50                	jbe    8022f0 <__umoddi3+0x80>
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	f7 f7                	div    %edi
  8022a6:	89 d0                	mov    %edx,%eax
  8022a8:	31 d2                	xor    %edx,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	39 f2                	cmp    %esi,%edx
  8022ba:	89 d0                	mov    %edx,%eax
  8022bc:	77 52                	ja     802310 <__umoddi3+0xa0>
  8022be:	0f bd ea             	bsr    %edx,%ebp
  8022c1:	83 f5 1f             	xor    $0x1f,%ebp
  8022c4:	75 5a                	jne    802320 <__umoddi3+0xb0>
  8022c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ca:	0f 82 e0 00 00 00    	jb     8023b0 <__umoddi3+0x140>
  8022d0:	39 0c 24             	cmp    %ecx,(%esp)
  8022d3:	0f 86 d7 00 00 00    	jbe    8023b0 <__umoddi3+0x140>
  8022d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022e1:	83 c4 1c             	add    $0x1c,%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	85 ff                	test   %edi,%edi
  8022f2:	89 fd                	mov    %edi,%ebp
  8022f4:	75 0b                	jne    802301 <__umoddi3+0x91>
  8022f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	f7 f7                	div    %edi
  8022ff:	89 c5                	mov    %eax,%ebp
  802301:	89 f0                	mov    %esi,%eax
  802303:	31 d2                	xor    %edx,%edx
  802305:	f7 f5                	div    %ebp
  802307:	89 c8                	mov    %ecx,%eax
  802309:	f7 f5                	div    %ebp
  80230b:	89 d0                	mov    %edx,%eax
  80230d:	eb 99                	jmp    8022a8 <__umoddi3+0x38>
  80230f:	90                   	nop
  802310:	89 c8                	mov    %ecx,%eax
  802312:	89 f2                	mov    %esi,%edx
  802314:	83 c4 1c             	add    $0x1c,%esp
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5f                   	pop    %edi
  80231a:	5d                   	pop    %ebp
  80231b:	c3                   	ret    
  80231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802320:	8b 34 24             	mov    (%esp),%esi
  802323:	bf 20 00 00 00       	mov    $0x20,%edi
  802328:	89 e9                	mov    %ebp,%ecx
  80232a:	29 ef                	sub    %ebp,%edi
  80232c:	d3 e0                	shl    %cl,%eax
  80232e:	89 f9                	mov    %edi,%ecx
  802330:	89 f2                	mov    %esi,%edx
  802332:	d3 ea                	shr    %cl,%edx
  802334:	89 e9                	mov    %ebp,%ecx
  802336:	09 c2                	or     %eax,%edx
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	89 14 24             	mov    %edx,(%esp)
  80233d:	89 f2                	mov    %esi,%edx
  80233f:	d3 e2                	shl    %cl,%edx
  802341:	89 f9                	mov    %edi,%ecx
  802343:	89 54 24 04          	mov    %edx,0x4(%esp)
  802347:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80234b:	d3 e8                	shr    %cl,%eax
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	89 c6                	mov    %eax,%esi
  802351:	d3 e3                	shl    %cl,%ebx
  802353:	89 f9                	mov    %edi,%ecx
  802355:	89 d0                	mov    %edx,%eax
  802357:	d3 e8                	shr    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	09 d8                	or     %ebx,%eax
  80235d:	89 d3                	mov    %edx,%ebx
  80235f:	89 f2                	mov    %esi,%edx
  802361:	f7 34 24             	divl   (%esp)
  802364:	89 d6                	mov    %edx,%esi
  802366:	d3 e3                	shl    %cl,%ebx
  802368:	f7 64 24 04          	mull   0x4(%esp)
  80236c:	39 d6                	cmp    %edx,%esi
  80236e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802372:	89 d1                	mov    %edx,%ecx
  802374:	89 c3                	mov    %eax,%ebx
  802376:	72 08                	jb     802380 <__umoddi3+0x110>
  802378:	75 11                	jne    80238b <__umoddi3+0x11b>
  80237a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80237e:	73 0b                	jae    80238b <__umoddi3+0x11b>
  802380:	2b 44 24 04          	sub    0x4(%esp),%eax
  802384:	1b 14 24             	sbb    (%esp),%edx
  802387:	89 d1                	mov    %edx,%ecx
  802389:	89 c3                	mov    %eax,%ebx
  80238b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80238f:	29 da                	sub    %ebx,%edx
  802391:	19 ce                	sbb    %ecx,%esi
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 f0                	mov    %esi,%eax
  802397:	d3 e0                	shl    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	d3 ea                	shr    %cl,%edx
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	d3 ee                	shr    %cl,%esi
  8023a1:	09 d0                	or     %edx,%eax
  8023a3:	89 f2                	mov    %esi,%edx
  8023a5:	83 c4 1c             	add    $0x1c,%esp
  8023a8:	5b                   	pop    %ebx
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	29 f9                	sub    %edi,%ecx
  8023b2:	19 d6                	sbb    %edx,%esi
  8023b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023bc:	e9 18 ff ff ff       	jmp    8022d9 <__umoddi3+0x69>
