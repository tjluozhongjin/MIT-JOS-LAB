
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 a0 	movl   $0x8024a0,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 74 1c 00 00       	call   801cc2 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 ac 24 80 00       	push   $0x8024ac
  80005d:	6a 0e                	push   $0xe
  80005f:	68 b5 24 80 00       	push   $0x8024b5
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 6f 10 00 00       	call   8010dd <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 c5 24 80 00       	push   $0x8024c5
  80007a:	6a 11                	push   $0x11
  80007c:	68 b5 24 80 00       	push   $0x8024b5
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ce 24 80 00       	push   $0x8024ce
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 c9 13 00 00       	call   80147b <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 eb 24 80 00       	push   $0x8024eb
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 6c 15 00 00       	call   801648 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 08 25 80 00       	push   $0x802508
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 b5 24 80 00       	push   $0x8024b5
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 8b 09 00 00       	call   800a99 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 11 25 80 00       	push   $0x802511
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 2d 25 80 00       	push   $0x80252d
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ce 24 80 00       	push   $0x8024ce
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 11 13 00 00       	call   80147b <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 40 25 80 00       	push   $0x802540
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 25 08 00 00       	call   8009b6 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 ee 14 00 00       	call   801691 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 03 08 00 00       	call   8009b6 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 5d 25 80 00       	push   $0x80255d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 b5 24 80 00       	push   $0x8024b5
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 a4 12 00 00       	call   80147b <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 65 1c 00 00       	call   801e48 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 67 	movl   $0x802567,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 ca 1a 00 00       	call   801cc2 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 ac 24 80 00       	push   $0x8024ac
  800207:	6a 2c                	push   $0x2c
  800209:	68 b5 24 80 00       	push   $0x8024b5
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 c5 0e 00 00       	call   8010dd <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 c5 24 80 00       	push   $0x8024c5
  800224:	6a 2f                	push   $0x2f
  800226:	68 b5 24 80 00       	push   $0x8024b5
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 3c 12 00 00       	call   80147b <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 74 25 80 00       	push   $0x802574
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 76 25 80 00       	push   $0x802576
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 30 14 00 00       	call   801691 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 78 25 80 00       	push   $0x802578
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 f2 11 00 00       	call   80147b <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 e7 11 00 00       	call   80147b <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 ac 1b 00 00       	call   801e48 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 95 25 80 00 	movl   $0x802595,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 f2 0a 00 00       	call   800db4 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 a3 11 00 00       	call   8014a6 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 66 0a 00 00       	call   800d73 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 8f 0a 00 00       	call   800db4 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 f8 25 80 00       	push   $0x8025f8
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 e9 24 80 00 	movl   $0x8024e9,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 ae 09 00 00       	call   800d36 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 1a 01 00 00       	call   8004e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 53 09 00 00       	call   800d36 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 ad 1d 00 00       	call   802200 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 9a 1e 00 00       	call   802330 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 1b 26 80 00 	movsbl 0x80261b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bd:	73 0a                	jae    8004c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c7:	88 02                	mov    %al,(%edx)
}
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d4:	50                   	push   %eax
  8004d5:	ff 75 10             	pushl  0x10(%ebp)
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 05 00 00 00       	call   8004e8 <vprintfmt>
	va_end(ap);
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	57                   	push   %edi
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	83 ec 2c             	sub    $0x2c,%esp
  8004f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fa:	eb 12                	jmp    80050e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	0f 84 42 04 00 00    	je     800946 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	50                   	push   %eax
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050e:	83 c7 01             	add    $0x1,%edi
  800511:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800515:	83 f8 25             	cmp    $0x25,%eax
  800518:	75 e2                	jne    8004fc <vprintfmt+0x14>
  80051a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80051e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800525:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	eb 07                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8d 47 01             	lea    0x1(%edi),%eax
  800544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800547:	0f b6 07             	movzbl (%edi),%eax
  80054a:	0f b6 d0             	movzbl %al,%edx
  80054d:	83 e8 23             	sub    $0x23,%eax
  800550:	3c 55                	cmp    $0x55,%al
  800552:	0f 87 d3 03 00 00    	ja     80092b <vprintfmt+0x443>
  800558:	0f b6 c0             	movzbl %al,%eax
  80055b:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800565:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800569:	eb d6                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800576:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800579:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800580:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800583:	83 f9 09             	cmp    $0x9,%ecx
  800586:	77 3f                	ja     8005c7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800588:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80058b:	eb e9                	jmp    800576 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a1:	eb 2a                	jmp    8005cd <vprintfmt+0xe5>
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	0f 49 d0             	cmovns %eax,%edx
  8005b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	eb 89                	jmp    800541 <vprintfmt+0x59>
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c2:	e9 7a ff ff ff       	jmp    800541 <vprintfmt+0x59>
  8005c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 89 6a ff ff ff    	jns    800541 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e4:	e9 58 ff ff ff       	jmp    800541 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 4d ff ff ff       	jmp    800541 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	ff 30                	pushl  (%eax)
  800600:	ff d6                	call   *%esi
			break;
  800602:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060b:	e9 fe fe ff ff       	jmp    80050e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 0f             	cmp    $0xf,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x145>
  800622:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	75 1b                	jne    800648 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80062d:	50                   	push   %eax
  80062e:	68 33 26 80 00       	push   $0x802633
  800633:	53                   	push   %ebx
  800634:	56                   	push   %esi
  800635:	e8 91 fe ff ff       	call   8004cb <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800643:	e9 c6 fe ff ff       	jmp    80050e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 c5 2a 80 00       	push   $0x802ac5
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 76 fe ff ff       	call   8004cb <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ab fe ff ff       	jmp    80050e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800671:	85 ff                	test   %edi,%edi
  800673:	b8 2c 26 80 00       	mov    $0x80262c,%eax
  800678:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80067b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067f:	0f 8e 94 00 00 00    	jle    800719 <vprintfmt+0x231>
  800685:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800689:	0f 84 98 00 00 00    	je     800727 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 d0             	pushl  -0x30(%ebp)
  800695:	57                   	push   %edi
  800696:	e8 33 03 00 00       	call   8009ce <strnlen>
  80069b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1cc>
  8006c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	0f 49 c1             	cmovns %ecx,%eax
  8006d7:	29 c1                	sub    %eax,%ecx
  8006d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	89 cb                	mov    %ecx,%ebx
  8006e4:	eb 4d                	jmp    800733 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	74 1b                	je     800707 <vprintfmt+0x21f>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 10                	jbe    800707 <vprintfmt+0x21f>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	eb 1a                	jmp    800733 <vprintfmt+0x24b>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	eb 0c                	jmp    800733 <vprintfmt+0x24b>
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	0f be d0             	movsbl %al,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 23                	je     800764 <vprintfmt+0x27c>
  800741:	85 f6                	test   %esi,%esi
  800743:	78 a1                	js     8006e6 <vprintfmt+0x1fe>
  800745:	83 ee 01             	sub    $0x1,%esi
  800748:	79 9c                	jns    8006e6 <vprintfmt+0x1fe>
  80074a:	89 df                	mov    %ebx,%edi
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	eb 18                	jmp    80076c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 20                	push   $0x20
  80075a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 08                	jmp    80076c <vprintfmt+0x284>
  800764:	89 df                	mov    %ebx,%edi
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	85 ff                	test   %edi,%edi
  80076e:	7f e4                	jg     800754 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800770:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 90 fd ff ff       	jmp    80050e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077e:	83 f9 01             	cmp    $0x1,%ecx
  800781:	7e 19                	jle    80079c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
  80079a:	eb 38                	jmp    8007d4 <vprintfmt+0x2ec>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	74 1b                	je     8007bb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c1                	mov    %eax,%ecx
  8007aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b9:	eb 19                	jmp    8007d4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e3:	0f 89 0e 01 00 00    	jns    8008f7 <vprintfmt+0x40f>
				putch('-', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 2d                	push   $0x2d
  8007ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007f7:	f7 da                	neg    %edx
  8007f9:	83 d1 00             	adc    $0x0,%ecx
  8007fc:	f7 d9                	neg    %ecx
  8007fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 ec 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080b:	83 f9 01             	cmp    $0x1,%ecx
  80080e:	7e 18                	jle    800828 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 cf 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 1a                	je     800846 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 b1 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	e9 97 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 58                	push   $0x58
  800866:	ff d6                	call   *%esi
			putch('X', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 58                	push   $0x58
  80086e:	ff d6                	call   *%esi
			putch('X', putdat);
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 58                	push   $0x58
  800876:	ff d6                	call   *%esi
			break;
  800878:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80087e:	e9 8b fc ff ff       	jmp    80050e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 30                	push   $0x30
  800889:	ff d6                	call   *%esi
			putch('x', putdat);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	6a 78                	push   $0x78
  800891:	ff d6                	call   *%esi
			num = (unsigned long long)
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8b 10                	mov    (%eax),%edx
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ab:	eb 4a                	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ad:	83 f9 01             	cmp    $0x1,%ecx
  8008b0:	7e 15                	jle    8008c7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ba:	8d 40 08             	lea    0x8(%eax),%eax
  8008bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c5:	eb 30                	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 17                	je     8008e2 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008db:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e0:	eb 15                	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	8d 40 04             	lea    0x4(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f7:	83 ec 0c             	sub    $0xc,%esp
  8008fa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008fe:	57                   	push   %edi
  8008ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800902:	50                   	push   %eax
  800903:	51                   	push   %ecx
  800904:	52                   	push   %edx
  800905:	89 da                	mov    %ebx,%edx
  800907:	89 f0                	mov    %esi,%eax
  800909:	e8 f1 fa ff ff       	call   8003ff <printnum>
			break;
  80090e:	83 c4 20             	add    $0x20,%esp
  800911:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800914:	e9 f5 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	53                   	push   %ebx
  80091d:	52                   	push   %edx
  80091e:	ff d6                	call   *%esi
			break;
  800920:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800926:	e9 e3 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	6a 25                	push   $0x25
  800931:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	eb 03                	jmp    80093b <vprintfmt+0x453>
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80093f:	75 f7                	jne    800938 <vprintfmt+0x450>
  800941:	e9 c8 fb ff ff       	jmp    80050e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800946:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 18             	sub    $0x18,%esp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800961:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096b:	85 c0                	test   %eax,%eax
  80096d:	74 26                	je     800995 <vsnprintf+0x47>
  80096f:	85 d2                	test   %edx,%edx
  800971:	7e 22                	jle    800995 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800973:	ff 75 14             	pushl  0x14(%ebp)
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097c:	50                   	push   %eax
  80097d:	68 ae 04 80 00       	push   $0x8004ae
  800982:	e8 61 fb ff ff       	call   8004e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800987:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	eb 05                	jmp    80099a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a5:	50                   	push   %eax
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 9a ff ff ff       	call   80094e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 03                	jmp    8009c6 <strlen+0x10>
		n++;
  8009c3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ca:	75 f7                	jne    8009c3 <strlen+0xd>
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	eb 03                	jmp    8009e1 <strnlen+0x13>
		n++;
  8009de:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e1:	39 c2                	cmp    %eax,%edx
  8009e3:	74 08                	je     8009ed <strnlen+0x1f>
  8009e5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e9:	75 f3                	jne    8009de <strnlen+0x10>
  8009eb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a05:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a08:	84 db                	test   %bl,%bl
  800a0a:	75 ef                	jne    8009fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a16:	53                   	push   %ebx
  800a17:	e8 9a ff ff ff       	call   8009b6 <strlen>
  800a1c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	01 d8                	add    %ebx,%eax
  800a24:	50                   	push   %eax
  800a25:	e8 c5 ff ff ff       	call   8009ef <strcpy>
	return dst;
}
  800a2a:	89 d8                	mov    %ebx,%eax
  800a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 75 08             	mov    0x8(%ebp),%esi
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a41:	89 f2                	mov    %esi,%edx
  800a43:	eb 0f                	jmp    800a54 <strncpy+0x23>
		*dst++ = *src;
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	0f b6 01             	movzbl (%ecx),%eax
  800a4b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a51:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	39 da                	cmp    %ebx,%edx
  800a56:	75 ed                	jne    800a45 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a58:	89 f0                	mov    %esi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a69:	8b 55 10             	mov    0x10(%ebp),%edx
  800a6c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	74 21                	je     800a93 <strlcpy+0x35>
  800a72:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a76:	89 f2                	mov    %esi,%edx
  800a78:	eb 09                	jmp    800a83 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a83:	39 c2                	cmp    %eax,%edx
  800a85:	74 09                	je     800a90 <strlcpy+0x32>
  800a87:	0f b6 19             	movzbl (%ecx),%ebx
  800a8a:	84 db                	test   %bl,%bl
  800a8c:	75 ec                	jne    800a7a <strlcpy+0x1c>
  800a8e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a90:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a93:	29 f0                	sub    %esi,%eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa2:	eb 06                	jmp    800aaa <strcmp+0x11>
		p++, q++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaa:	0f b6 01             	movzbl (%ecx),%eax
  800aad:	84 c0                	test   %al,%al
  800aaf:	74 04                	je     800ab5 <strcmp+0x1c>
  800ab1:	3a 02                	cmp    (%edx),%al
  800ab3:	74 ef                	je     800aa4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 12             	movzbl (%edx),%edx
  800abb:	29 d0                	sub    %edx,%eax
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	53                   	push   %ebx
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ace:	eb 06                	jmp    800ad6 <strncmp+0x17>
		n--, p++, q++;
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad6:	39 d8                	cmp    %ebx,%eax
  800ad8:	74 15                	je     800aef <strncmp+0x30>
  800ada:	0f b6 08             	movzbl (%eax),%ecx
  800add:	84 c9                	test   %cl,%cl
  800adf:	74 04                	je     800ae5 <strncmp+0x26>
  800ae1:	3a 0a                	cmp    (%edx),%cl
  800ae3:	74 eb                	je     800ad0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 00             	movzbl (%eax),%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
  800aed:	eb 05                	jmp    800af4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b01:	eb 07                	jmp    800b0a <strchr+0x13>
		if (*s == c)
  800b03:	38 ca                	cmp    %cl,%dl
  800b05:	74 0f                	je     800b16 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	75 f2                	jne    800b03 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b22:	eb 03                	jmp    800b27 <strfind+0xf>
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2a:	38 ca                	cmp    %cl,%dl
  800b2c:	74 04                	je     800b32 <strfind+0x1a>
  800b2e:	84 d2                	test   %dl,%dl
  800b30:	75 f2                	jne    800b24 <strfind+0xc>
			break;
	return (char *) s;
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	74 36                	je     800b7a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4a:	75 28                	jne    800b74 <memset+0x40>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 23                	jne    800b74 <memset+0x40>
		c &= 0xFF;
  800b51:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	c1 e3 08             	shl    $0x8,%ebx
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	c1 e6 18             	shl    $0x18,%esi
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	c1 e0 10             	shl    $0x10,%eax
  800b64:	09 f0                	or     %esi,%eax
  800b66:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b68:	89 d8                	mov    %ebx,%eax
  800b6a:	09 d0                	or     %edx,%eax
  800b6c:	c1 e9 02             	shr    $0x2,%ecx
  800b6f:	fc                   	cld    
  800b70:	f3 ab                	rep stos %eax,%es:(%edi)
  800b72:	eb 06                	jmp    800b7a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	fc                   	cld    
  800b78:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7a:	89 f8                	mov    %edi,%eax
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8f:	39 c6                	cmp    %eax,%esi
  800b91:	73 35                	jae    800bc8 <memmove+0x47>
  800b93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	73 2e                	jae    800bc8 <memmove+0x47>
		s += n;
		d += n;
  800b9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	09 fe                	or     %edi,%esi
  800ba1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba7:	75 13                	jne    800bbc <memmove+0x3b>
  800ba9:	f6 c1 03             	test   $0x3,%cl
  800bac:	75 0e                	jne    800bbc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bae:	83 ef 04             	sub    $0x4,%edi
  800bb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
  800bb7:	fd                   	std    
  800bb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bba:	eb 09                	jmp    800bc5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bbc:	83 ef 01             	sub    $0x1,%edi
  800bbf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bc2:	fd                   	std    
  800bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc5:	fc                   	cld    
  800bc6:	eb 1d                	jmp    800be5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	09 c2                	or     %eax,%edx
  800bcc:	f6 c2 03             	test   $0x3,%dl
  800bcf:	75 0f                	jne    800be0 <memmove+0x5f>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0a                	jne    800be0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bd6:	c1 e9 02             	shr    $0x2,%ecx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 05                	jmp    800be5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be0:	89 c7                	mov    %eax,%edi
  800be2:	fc                   	cld    
  800be3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bec:	ff 75 10             	pushl  0x10(%ebp)
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	ff 75 08             	pushl  0x8(%ebp)
  800bf5:	e8 87 ff ff ff       	call   800b81 <memmove>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0c:	eb 1a                	jmp    800c28 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0e:	0f b6 08             	movzbl (%eax),%ecx
  800c11:	0f b6 1a             	movzbl (%edx),%ebx
  800c14:	38 d9                	cmp    %bl,%cl
  800c16:	74 0a                	je     800c22 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c18:	0f b6 c1             	movzbl %cl,%eax
  800c1b:	0f b6 db             	movzbl %bl,%ebx
  800c1e:	29 d8                	sub    %ebx,%eax
  800c20:	eb 0f                	jmp    800c31 <memcmp+0x35>
		s1++, s2++;
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c28:	39 f0                	cmp    %esi,%eax
  800c2a:	75 e2                	jne    800c0e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3c:	89 c1                	mov    %eax,%ecx
  800c3e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c41:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c45:	eb 0a                	jmp    800c51 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c47:	0f b6 10             	movzbl (%eax),%edx
  800c4a:	39 da                	cmp    %ebx,%edx
  800c4c:	74 07                	je     800c55 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4e:	83 c0 01             	add    $0x1,%eax
  800c51:	39 c8                	cmp    %ecx,%eax
  800c53:	72 f2                	jb     800c47 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c55:	5b                   	pop    %ebx
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c64:	eb 03                	jmp    800c69 <strtol+0x11>
		s++;
  800c66:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	0f b6 01             	movzbl (%ecx),%eax
  800c6c:	3c 20                	cmp    $0x20,%al
  800c6e:	74 f6                	je     800c66 <strtol+0xe>
  800c70:	3c 09                	cmp    $0x9,%al
  800c72:	74 f2                	je     800c66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c74:	3c 2b                	cmp    $0x2b,%al
  800c76:	75 0a                	jne    800c82 <strtol+0x2a>
		s++;
  800c78:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb 11                	jmp    800c93 <strtol+0x3b>
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c87:	3c 2d                	cmp    $0x2d,%al
  800c89:	75 08                	jne    800c93 <strtol+0x3b>
		s++, neg = 1;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c99:	75 15                	jne    800cb0 <strtol+0x58>
  800c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9e:	75 10                	jne    800cb0 <strtol+0x58>
  800ca0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca4:	75 7c                	jne    800d22 <strtol+0xca>
		s += 2, base = 16;
  800ca6:	83 c1 02             	add    $0x2,%ecx
  800ca9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cae:	eb 16                	jmp    800cc6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cb0:	85 db                	test   %ebx,%ebx
  800cb2:	75 12                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cbc:	75 08                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
  800cbe:	83 c1 01             	add    $0x1,%ecx
  800cc1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cce:	0f b6 11             	movzbl (%ecx),%edx
  800cd1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cd4:	89 f3                	mov    %esi,%ebx
  800cd6:	80 fb 09             	cmp    $0x9,%bl
  800cd9:	77 08                	ja     800ce3 <strtol+0x8b>
			dig = *s - '0';
  800cdb:	0f be d2             	movsbl %dl,%edx
  800cde:	83 ea 30             	sub    $0x30,%edx
  800ce1:	eb 22                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ce3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce6:	89 f3                	mov    %esi,%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ced:	0f be d2             	movsbl %dl,%edx
  800cf0:	83 ea 57             	sub    $0x57,%edx
  800cf3:	eb 10                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf8:	89 f3                	mov    %esi,%ebx
  800cfa:	80 fb 19             	cmp    $0x19,%bl
  800cfd:	77 16                	ja     800d15 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cff:	0f be d2             	movsbl %dl,%edx
  800d02:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d08:	7d 0b                	jge    800d15 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d11:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d13:	eb b9                	jmp    800cce <strtol+0x76>

	if (endptr)
  800d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d19:	74 0d                	je     800d28 <strtol+0xd0>
		*endptr = (char *) s;
  800d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1e:	89 0e                	mov    %ecx,(%esi)
  800d20:	eb 06                	jmp    800d28 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d22:	85 db                	test   %ebx,%ebx
  800d24:	74 98                	je     800cbe <strtol+0x66>
  800d26:	eb 9e                	jmp    800cc6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d28:	89 c2                	mov    %eax,%edx
  800d2a:	f7 da                	neg    %edx
  800d2c:	85 ff                	test   %edi,%edi
  800d2e:	0f 45 c2             	cmovne %edx,%eax
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	89 c7                	mov    %eax,%edi
  800d4b:	89 c6                	mov    %eax,%esi
  800d4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 03 00 00 00       	mov    $0x3,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 03                	push   $0x3
  800d9b:	68 1f 29 80 00       	push   $0x80291f
  800da0:	6a 23                	push   $0x23
  800da2:	68 3c 29 80 00       	push   $0x80293c
  800da7:	e8 66 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_yield>:

void
sys_yield(void)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dde:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	89 d3                	mov    %edx,%ebx
  800de7:	89 d7                	mov    %edx,%edi
  800de9:	89 d6                	mov    %edx,%esi
  800deb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	b8 04 00 00 00       	mov    $0x4,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	89 f7                	mov    %esi,%edi
  800e10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 04                	push   $0x4
  800e1c:	68 1f 29 80 00       	push   $0x80291f
  800e21:	6a 23                	push   $0x23
  800e23:	68 3c 29 80 00       	push   $0x80293c
  800e28:	e8 e5 f4 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 17                	jle    800e6f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 05                	push   $0x5
  800e5e:	68 1f 29 80 00       	push   $0x80291f
  800e63:	6a 23                	push   $0x23
  800e65:	68 3c 29 80 00       	push   $0x80293c
  800e6a:	e8 a3 f4 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 df                	mov    %ebx,%edi
  800e92:	89 de                	mov    %ebx,%esi
  800e94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 17                	jle    800eb1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	50                   	push   %eax
  800e9e:	6a 06                	push   $0x6
  800ea0:	68 1f 29 80 00       	push   $0x80291f
  800ea5:	6a 23                	push   $0x23
  800ea7:	68 3c 29 80 00       	push   $0x80293c
  800eac:	e8 61 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec7:	b8 08 00 00 00       	mov    $0x8,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 df                	mov    %ebx,%edi
  800ed4:	89 de                	mov    %ebx,%esi
  800ed6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 17                	jle    800ef3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	50                   	push   %eax
  800ee0:	6a 08                	push   $0x8
  800ee2:	68 1f 29 80 00       	push   $0x80291f
  800ee7:	6a 23                	push   $0x23
  800ee9:	68 3c 29 80 00       	push   $0x80293c
  800eee:	e8 1f f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f09:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 df                	mov    %ebx,%edi
  800f16:	89 de                	mov    %ebx,%esi
  800f18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 17                	jle    800f35 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	50                   	push   %eax
  800f22:	6a 09                	push   $0x9
  800f24:	68 1f 29 80 00       	push   $0x80291f
  800f29:	6a 23                	push   $0x23
  800f2b:	68 3c 29 80 00       	push   $0x80293c
  800f30:	e8 dd f3 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	89 df                	mov    %ebx,%edi
  800f58:	89 de                	mov    %ebx,%esi
  800f5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 17                	jle    800f77 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	50                   	push   %eax
  800f64:	6a 0a                	push   $0xa
  800f66:	68 1f 29 80 00       	push   $0x80291f
  800f6b:	6a 23                	push   $0x23
  800f6d:	68 3c 29 80 00       	push   $0x80293c
  800f72:	e8 9b f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	be 00 00 00 00       	mov    $0x0,%esi
  800f8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 cb                	mov    %ecx,%ebx
  800fba:	89 cf                	mov    %ecx,%edi
  800fbc:	89 ce                	mov    %ecx,%esi
  800fbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	7e 17                	jle    800fdb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	50                   	push   %eax
  800fc8:	6a 0d                	push   $0xd
  800fca:	68 1f 29 80 00       	push   $0x80291f
  800fcf:	6a 23                	push   $0x23
  800fd1:	68 3c 29 80 00       	push   $0x80293c
  800fd6:	e8 37 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800feb:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800fed:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ff1:	74 11                	je     801004 <pgfault+0x21>
  800ff3:	89 d8                	mov    %ebx,%eax
  800ff5:	c1 e8 0c             	shr    $0xc,%eax
  800ff8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fff:	f6 c4 08             	test   $0x8,%ah
  801002:	75 14                	jne    801018 <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	68 4c 29 80 00       	push   $0x80294c
  80100c:	6a 1f                	push   $0x1f
  80100e:	68 af 29 80 00       	push   $0x8029af
  801013:	e8 fa f2 ff ff       	call   800312 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  801018:	e8 97 fd ff ff       	call   800db4 <sys_getenvid>
  80101d:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	6a 07                	push   $0x7
  801024:	68 00 f0 7f 00       	push   $0x7ff000
  801029:	50                   	push   %eax
  80102a:	e8 c3 fd ff ff       	call   800df2 <sys_page_alloc>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	79 12                	jns    801048 <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  801036:	50                   	push   %eax
  801037:	68 8c 29 80 00       	push   $0x80298c
  80103c:	6a 2c                	push   $0x2c
  80103e:	68 af 29 80 00       	push   $0x8029af
  801043:	e8 ca f2 ff ff       	call   800312 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  801048:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	68 00 10 00 00       	push   $0x1000
  801056:	53                   	push   %ebx
  801057:	68 00 f0 7f 00       	push   $0x7ff000
  80105c:	e8 20 fb ff ff       	call   800b81 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	53                   	push   %ebx
  801065:	56                   	push   %esi
  801066:	e8 0c fe ff ff       	call   800e77 <sys_page_unmap>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 12                	jns    801084 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  801072:	50                   	push   %eax
  801073:	68 ba 29 80 00       	push   $0x8029ba
  801078:	6a 32                	push   $0x32
  80107a:	68 af 29 80 00       	push   $0x8029af
  80107f:	e8 8e f2 ff ff       	call   800312 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	6a 07                	push   $0x7
  801089:	53                   	push   %ebx
  80108a:	56                   	push   %esi
  80108b:	68 00 f0 7f 00       	push   $0x7ff000
  801090:	56                   	push   %esi
  801091:	e8 9f fd ff ff       	call   800e35 <sys_page_map>
  801096:	83 c4 20             	add    $0x20,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 12                	jns    8010af <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  80109d:	50                   	push   %eax
  80109e:	68 d8 29 80 00       	push   $0x8029d8
  8010a3:	6a 35                	push   $0x35
  8010a5:	68 af 29 80 00       	push   $0x8029af
  8010aa:	e8 63 f2 ff ff       	call   800312 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	68 00 f0 7f 00       	push   $0x7ff000
  8010b7:	56                   	push   %esi
  8010b8:	e8 ba fd ff ff       	call   800e77 <sys_page_unmap>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	79 12                	jns    8010d6 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  8010c4:	50                   	push   %eax
  8010c5:	68 ba 29 80 00       	push   $0x8029ba
  8010ca:	6a 38                	push   $0x38
  8010cc:	68 af 29 80 00       	push   $0x8029af
  8010d1:	e8 3c f2 ff ff       	call   800312 <_panic>
	//panic("pgfault not implemented");
}
  8010d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  8010e6:	68 e3 0f 80 00       	push   $0x800fe3
  8010eb:	e8 2a 0f 00 00       	call   80201a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010f0:	b8 07 00 00 00       	mov    $0x7,%eax
  8010f5:	cd 30                	int    $0x30
  8010f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 88 38 01 00 00    	js     80123d <fork+0x160>
  801105:	89 c7                	mov    %eax,%edi
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  80110c:	85 c0                	test   %eax,%eax
  80110e:	75 21                	jne    801131 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  801110:	e8 9f fc ff ff       	call   800db4 <sys_getenvid>
  801115:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80111d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801122:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801127:	ba 00 00 00 00       	mov    $0x0,%edx
  80112c:	e9 86 01 00 00       	jmp    8012b7 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801131:	89 d8                	mov    %ebx,%eax
  801133:	c1 e8 16             	shr    $0x16,%eax
  801136:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113d:	a8 01                	test   $0x1,%al
  80113f:	0f 84 90 00 00 00    	je     8011d5 <fork+0xf8>
  801145:	89 d8                	mov    %ebx,%eax
  801147:	c1 e8 0c             	shr    $0xc,%eax
  80114a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801151:	f6 c2 01             	test   $0x1,%dl
  801154:	74 7f                	je     8011d5 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  801156:	89 c6                	mov    %eax,%esi
  801158:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  80115b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801162:	f6 c6 04             	test   $0x4,%dh
  801165:	74 33                	je     80119a <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  801167:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	25 07 0e 00 00       	and    $0xe07,%eax
  801176:	50                   	push   %eax
  801177:	56                   	push   %esi
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	6a 00                	push   $0x0
  80117c:	e8 b4 fc ff ff       	call   800e35 <sys_page_map>
  801181:	83 c4 20             	add    $0x20,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	79 4d                	jns    8011d5 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  801188:	50                   	push   %eax
  801189:	68 f4 29 80 00       	push   $0x8029f4
  80118e:	6a 54                	push   $0x54
  801190:	68 af 29 80 00       	push   $0x8029af
  801195:	e8 78 f1 ff ff       	call   800312 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  80119a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a1:	a9 02 08 00 00       	test   $0x802,%eax
  8011a6:	0f 85 c6 00 00 00    	jne    801272 <fork+0x195>
  8011ac:	e9 e3 00 00 00       	jmp    801294 <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8011b1:	50                   	push   %eax
  8011b2:	68 f4 29 80 00       	push   $0x8029f4
  8011b7:	6a 5d                	push   $0x5d
  8011b9:	68 af 29 80 00       	push   $0x8029af
  8011be:	e8 4f f1 ff ff       	call   800312 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8011c3:	50                   	push   %eax
  8011c4:	68 f4 29 80 00       	push   $0x8029f4
  8011c9:	6a 64                	push   $0x64
  8011cb:	68 af 29 80 00       	push   $0x8029af
  8011d0:	e8 3d f1 ff ff       	call   800312 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  8011d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011db:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011e1:	0f 85 4a ff ff ff    	jne    801131 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	6a 07                	push   $0x7
  8011ec:	68 00 f0 bf ee       	push   $0xeebff000
  8011f1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8011f4:	57                   	push   %edi
  8011f5:	e8 f8 fb ff ff       	call   800df2 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8011fa:	83 c4 10             	add    $0x10,%esp
		return ret;
  8011fd:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8011ff:	85 c0                	test   %eax,%eax
  801201:	0f 88 b0 00 00 00    	js     8012b7 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801207:	a1 04 40 80 00       	mov    0x804004,%eax
  80120c:	8b 40 64             	mov    0x64(%eax),%eax
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	50                   	push   %eax
  801213:	57                   	push   %edi
  801214:	e8 24 fd ff ff       	call   800f3d <sys_env_set_pgfault_upcall>
  801219:	83 c4 10             	add    $0x10,%esp
		return ret;
  80121c:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80121e:	85 c0                	test   %eax,%eax
  801220:	0f 88 91 00 00 00    	js     8012b7 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	6a 02                	push   $0x2
  80122b:	57                   	push   %edi
  80122c:	e8 88 fc ff ff       	call   800eb9 <sys_env_set_status>
  801231:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  801234:	85 c0                	test   %eax,%eax
  801236:	89 fa                	mov    %edi,%edx
  801238:	0f 48 d0             	cmovs  %eax,%edx
  80123b:	eb 7a                	jmp    8012b7 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  80123d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801240:	eb 75                	jmp    8012b7 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801242:	e8 6d fb ff ff       	call   800db4 <sys_getenvid>
  801247:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124a:	e8 65 fb ff ff       	call   800db4 <sys_getenvid>
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	68 05 08 00 00       	push   $0x805
  801257:	56                   	push   %esi
  801258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125b:	56                   	push   %esi
  80125c:	50                   	push   %eax
  80125d:	e8 d3 fb ff ff       	call   800e35 <sys_page_map>
  801262:	83 c4 20             	add    $0x20,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	0f 89 68 ff ff ff    	jns    8011d5 <fork+0xf8>
  80126d:	e9 51 ff ff ff       	jmp    8011c3 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801272:	e8 3d fb ff ff       	call   800db4 <sys_getenvid>
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	68 05 08 00 00       	push   $0x805
  80127f:	56                   	push   %esi
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	50                   	push   %eax
  801283:	e8 ad fb ff ff       	call   800e35 <sys_page_map>
  801288:	83 c4 20             	add    $0x20,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	79 b3                	jns    801242 <fork+0x165>
  80128f:	e9 1d ff ff ff       	jmp    8011b1 <fork+0xd4>
  801294:	e8 1b fb ff ff       	call   800db4 <sys_getenvid>
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	6a 05                	push   $0x5
  80129e:	56                   	push   %esi
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	50                   	push   %eax
  8012a2:	e8 8e fb ff ff       	call   800e35 <sys_page_map>
  8012a7:	83 c4 20             	add    $0x20,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	0f 89 23 ff ff ff    	jns    8011d5 <fork+0xf8>
  8012b2:	e9 fa fe ff ff       	jmp    8011b1 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8012b7:	89 d0                	mov    %edx,%eax
  8012b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5f                   	pop    %edi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012c7:	68 05 2a 80 00       	push   $0x802a05
  8012cc:	68 ac 00 00 00       	push   $0xac
  8012d1:	68 af 29 80 00       	push   $0x8029af
  8012d6:	e8 37 f0 ff ff       	call   800312 <_panic>

008012db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801308:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 16             	shr    $0x16,%edx
  801312:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	74 11                	je     80132f <fd_alloc+0x2d>
  80131e:	89 c2                	mov    %eax,%edx
  801320:	c1 ea 0c             	shr    $0xc,%edx
  801323:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132a:	f6 c2 01             	test   $0x1,%dl
  80132d:	75 09                	jne    801338 <fd_alloc+0x36>
			*fd_store = fd;
  80132f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 17                	jmp    80134f <fd_alloc+0x4d>
  801338:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80133d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801342:	75 c9                	jne    80130d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801344:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80134a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801357:	83 f8 1f             	cmp    $0x1f,%eax
  80135a:	77 36                	ja     801392 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80135c:	c1 e0 0c             	shl    $0xc,%eax
  80135f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801364:	89 c2                	mov    %eax,%edx
  801366:	c1 ea 16             	shr    $0x16,%edx
  801369:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801370:	f6 c2 01             	test   $0x1,%dl
  801373:	74 24                	je     801399 <fd_lookup+0x48>
  801375:	89 c2                	mov    %eax,%edx
  801377:	c1 ea 0c             	shr    $0xc,%edx
  80137a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801381:	f6 c2 01             	test   $0x1,%dl
  801384:	74 1a                	je     8013a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801386:	8b 55 0c             	mov    0xc(%ebp),%edx
  801389:	89 02                	mov    %eax,(%edx)
	return 0;
  80138b:	b8 00 00 00 00       	mov    $0x0,%eax
  801390:	eb 13                	jmp    8013a5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801397:	eb 0c                	jmp    8013a5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801399:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139e:	eb 05                	jmp    8013a5 <fd_lookup+0x54>
  8013a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b0:	ba 9c 2a 80 00       	mov    $0x802a9c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b5:	eb 13                	jmp    8013ca <dev_lookup+0x23>
  8013b7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ba:	39 08                	cmp    %ecx,(%eax)
  8013bc:	75 0c                	jne    8013ca <dev_lookup+0x23>
			*dev = devtab[i];
  8013be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c8:	eb 2e                	jmp    8013f8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ca:	8b 02                	mov    (%edx),%eax
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	75 e7                	jne    8013b7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d5:	8b 40 48             	mov    0x48(%eax),%eax
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	51                   	push   %ecx
  8013dc:	50                   	push   %eax
  8013dd:	68 1c 2a 80 00       	push   $0x802a1c
  8013e2:	e8 04 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  8013e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 10             	sub    $0x10,%esp
  801402:	8b 75 08             	mov    0x8(%ebp),%esi
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
  801415:	50                   	push   %eax
  801416:	e8 36 ff ff ff       	call   801351 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 05                	js     801427 <fd_close+0x2d>
	    || fd != fd2)
  801422:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801425:	74 0c                	je     801433 <fd_close+0x39>
		return (must_exist ? r : 0);
  801427:	84 db                	test   %bl,%bl
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	0f 44 c2             	cmove  %edx,%eax
  801431:	eb 41                	jmp    801474 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 36                	pushl  (%esi)
  80143c:	e8 66 ff ff ff       	call   8013a7 <dev_lookup>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 1a                	js     801464 <fd_close+0x6a>
		if (dev->dev_close)
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801450:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801455:	85 c0                	test   %eax,%eax
  801457:	74 0b                	je     801464 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	56                   	push   %esi
  80145d:	ff d0                	call   *%eax
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	56                   	push   %esi
  801468:	6a 00                	push   $0x0
  80146a:	e8 08 fa ff ff       	call   800e77 <sys_page_unmap>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 d8                	mov    %ebx,%eax
}
  801474:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	ff 75 08             	pushl  0x8(%ebp)
  801488:	e8 c4 fe ff ff       	call   801351 <fd_lookup>
  80148d:	83 c4 08             	add    $0x8,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 10                	js     8014a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	6a 01                	push   $0x1
  801499:	ff 75 f4             	pushl  -0xc(%ebp)
  80149c:	e8 59 ff ff ff       	call   8013fa <fd_close>
  8014a1:	83 c4 10             	add    $0x10,%esp
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <close_all>:

void
close_all(void)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	e8 c0 ff ff ff       	call   80147b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bb:	83 c3 01             	add    $0x1,%ebx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	83 fb 20             	cmp    $0x20,%ebx
  8014c4:	75 ec                	jne    8014b2 <close_all+0xc>
		close(i);
}
  8014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 2c             	sub    $0x2c,%esp
  8014d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	ff 75 08             	pushl  0x8(%ebp)
  8014de:	e8 6e fe ff ff       	call   801351 <fd_lookup>
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	0f 88 c1 00 00 00    	js     8015af <dup+0xe4>
		return r;
	close(newfdnum);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	56                   	push   %esi
  8014f2:	e8 84 ff ff ff       	call   80147b <close>

	newfd = INDEX2FD(newfdnum);
  8014f7:	89 f3                	mov    %esi,%ebx
  8014f9:	c1 e3 0c             	shl    $0xc,%ebx
  8014fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801502:	83 c4 04             	add    $0x4,%esp
  801505:	ff 75 e4             	pushl  -0x1c(%ebp)
  801508:	e8 de fd ff ff       	call   8012eb <fd2data>
  80150d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 d4 fd ff ff       	call   8012eb <fd2data>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80151d:	89 f8                	mov    %edi,%eax
  80151f:	c1 e8 16             	shr    $0x16,%eax
  801522:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801529:	a8 01                	test   $0x1,%al
  80152b:	74 37                	je     801564 <dup+0x99>
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	c1 e8 0c             	shr    $0xc,%eax
  801532:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801539:	f6 c2 01             	test   $0x1,%dl
  80153c:	74 26                	je     801564 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80153e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	25 07 0e 00 00       	and    $0xe07,%eax
  80154d:	50                   	push   %eax
  80154e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801551:	6a 00                	push   $0x0
  801553:	57                   	push   %edi
  801554:	6a 00                	push   $0x0
  801556:	e8 da f8 ff ff       	call   800e35 <sys_page_map>
  80155b:	89 c7                	mov    %eax,%edi
  80155d:	83 c4 20             	add    $0x20,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 2e                	js     801592 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801564:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801567:	89 d0                	mov    %edx,%eax
  801569:	c1 e8 0c             	shr    $0xc,%eax
  80156c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	25 07 0e 00 00       	and    $0xe07,%eax
  80157b:	50                   	push   %eax
  80157c:	53                   	push   %ebx
  80157d:	6a 00                	push   $0x0
  80157f:	52                   	push   %edx
  801580:	6a 00                	push   $0x0
  801582:	e8 ae f8 ff ff       	call   800e35 <sys_page_map>
  801587:	89 c7                	mov    %eax,%edi
  801589:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80158c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158e:	85 ff                	test   %edi,%edi
  801590:	79 1d                	jns    8015af <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	6a 00                	push   $0x0
  801598:	e8 da f8 ff ff       	call   800e77 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a3:	6a 00                	push   $0x0
  8015a5:	e8 cd f8 ff ff       	call   800e77 <sys_page_unmap>
	return r;
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	89 f8                	mov    %edi,%eax
}
  8015af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5f                   	pop    %edi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 14             	sub    $0x14,%esp
  8015be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	53                   	push   %ebx
  8015c6:	e8 86 fd ff ff       	call   801351 <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 6d                	js     801641 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	ff 30                	pushl  (%eax)
  8015e0:	e8 c2 fd ff ff       	call   8013a7 <dev_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 4c                	js     801638 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ef:	8b 42 08             	mov    0x8(%edx),%eax
  8015f2:	83 e0 03             	and    $0x3,%eax
  8015f5:	83 f8 01             	cmp    $0x1,%eax
  8015f8:	75 21                	jne    80161b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ff:	8b 40 48             	mov    0x48(%eax),%eax
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	53                   	push   %ebx
  801606:	50                   	push   %eax
  801607:	68 60 2a 80 00       	push   $0x802a60
  80160c:	e8 da ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801619:	eb 26                	jmp    801641 <read+0x8a>
	}
	if (!dev->dev_read)
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	8b 40 08             	mov    0x8(%eax),%eax
  801621:	85 c0                	test   %eax,%eax
  801623:	74 17                	je     80163c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	ff 75 10             	pushl  0x10(%ebp)
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	52                   	push   %edx
  80162f:	ff d0                	call   *%eax
  801631:	89 c2                	mov    %eax,%edx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 09                	jmp    801641 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801638:	89 c2                	mov    %eax,%edx
  80163a:	eb 05                	jmp    801641 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80163c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801641:	89 d0                	mov    %edx,%eax
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	8b 7d 08             	mov    0x8(%ebp),%edi
  801654:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165c:	eb 21                	jmp    80167f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	89 f0                	mov    %esi,%eax
  801663:	29 d8                	sub    %ebx,%eax
  801665:	50                   	push   %eax
  801666:	89 d8                	mov    %ebx,%eax
  801668:	03 45 0c             	add    0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	57                   	push   %edi
  80166d:	e8 45 ff ff ff       	call   8015b7 <read>
		if (m < 0)
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 10                	js     801689 <readn+0x41>
			return m;
		if (m == 0)
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 0a                	je     801687 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167d:	01 c3                	add    %eax,%ebx
  80167f:	39 f3                	cmp    %esi,%ebx
  801681:	72 db                	jb     80165e <readn+0x16>
  801683:	89 d8                	mov    %ebx,%eax
  801685:	eb 02                	jmp    801689 <readn+0x41>
  801687:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5f                   	pop    %edi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 14             	sub    $0x14,%esp
  801698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	53                   	push   %ebx
  8016a0:	e8 ac fc ff ff       	call   801351 <fd_lookup>
  8016a5:	83 c4 08             	add    $0x8,%esp
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 68                	js     801716 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	ff 30                	pushl  (%eax)
  8016ba:	e8 e8 fc ff ff       	call   8013a7 <dev_lookup>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 47                	js     80170d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cd:	75 21                	jne    8016f0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d4:	8b 40 48             	mov    0x48(%eax),%eax
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	53                   	push   %ebx
  8016db:	50                   	push   %eax
  8016dc:	68 7c 2a 80 00       	push   $0x802a7c
  8016e1:	e8 05 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ee:	eb 26                	jmp    801716 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f6:	85 d2                	test   %edx,%edx
  8016f8:	74 17                	je     801711 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	ff 75 10             	pushl  0x10(%ebp)
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	50                   	push   %eax
  801704:	ff d2                	call   *%edx
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 09                	jmp    801716 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	eb 05                	jmp    801716 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801716:	89 d0                	mov    %edx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <seek>:

int
seek(int fdnum, off_t offset)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801723:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 22 fc ff ff       	call   801351 <fd_lookup>
  80172f:	83 c4 08             	add    $0x8,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 0e                	js     801744 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801736:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801739:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 14             	sub    $0x14,%esp
  80174d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	53                   	push   %ebx
  801755:	e8 f7 fb ff ff       	call   801351 <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 65                	js     8017c8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	ff 30                	pushl  (%eax)
  80176f:	e8 33 fc ff ff       	call   8013a7 <dev_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 44                	js     8017bf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801782:	75 21                	jne    8017a5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801784:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801789:	8b 40 48             	mov    0x48(%eax),%eax
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	53                   	push   %ebx
  801790:	50                   	push   %eax
  801791:	68 3c 2a 80 00       	push   $0x802a3c
  801796:	e8 50 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a3:	eb 23                	jmp    8017c8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a8:	8b 52 18             	mov    0x18(%edx),%edx
  8017ab:	85 d2                	test   %edx,%edx
  8017ad:	74 14                	je     8017c3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	ff 75 0c             	pushl  0xc(%ebp)
  8017b5:	50                   	push   %eax
  8017b6:	ff d2                	call   *%edx
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb 09                	jmp    8017c8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	eb 05                	jmp    8017c8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c8:	89 d0                	mov    %edx,%eax
  8017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 14             	sub    $0x14,%esp
  8017d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 6c fb ff ff       	call   801351 <fd_lookup>
  8017e5:	83 c4 08             	add    $0x8,%esp
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 58                	js     801846 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	ff 30                	pushl  (%eax)
  8017fa:	e8 a8 fb ff ff       	call   8013a7 <dev_lookup>
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	85 c0                	test   %eax,%eax
  801804:	78 37                	js     80183d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801809:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180d:	74 32                	je     801841 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801812:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801819:	00 00 00 
	stat->st_isdir = 0;
  80181c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801823:	00 00 00 
	stat->st_dev = dev;
  801826:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	53                   	push   %ebx
  801830:	ff 75 f0             	pushl  -0x10(%ebp)
  801833:	ff 50 14             	call   *0x14(%eax)
  801836:	89 c2                	mov    %eax,%edx
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	eb 09                	jmp    801846 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	eb 05                	jmp    801846 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801841:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801846:	89 d0                	mov    %edx,%eax
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	6a 00                	push   $0x0
  801857:	ff 75 08             	pushl  0x8(%ebp)
  80185a:	e8 e9 01 00 00       	call   801a48 <open>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	78 1b                	js     801883 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	50                   	push   %eax
  80186f:	e8 5b ff ff ff       	call   8017cf <fstat>
  801874:	89 c6                	mov    %eax,%esi
	close(fd);
  801876:	89 1c 24             	mov    %ebx,(%esp)
  801879:	e8 fd fb ff ff       	call   80147b <close>
	return r;
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	89 f0                	mov    %esi,%eax
}
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	89 c6                	mov    %eax,%esi
  801891:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801893:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80189a:	75 12                	jne    8018ae <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	6a 01                	push   $0x1
  8018a1:	e8 e4 08 00 00       	call   80218a <ipc_find_env>
  8018a6:	a3 00 40 80 00       	mov    %eax,0x804000
  8018ab:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ae:	6a 07                	push   $0x7
  8018b0:	68 00 50 80 00       	push   $0x805000
  8018b5:	56                   	push   %esi
  8018b6:	ff 35 00 40 80 00    	pushl  0x804000
  8018bc:	e8 75 08 00 00       	call   802136 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8018c1:	83 c4 0c             	add    $0xc,%esp
  8018c4:	6a 00                	push   $0x0
  8018c6:	53                   	push   %ebx
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 e6 07 00 00       	call   8020b4 <ipc_recv>
}
  8018ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f8:	e8 8d ff ff ff       	call   80188a <fsipc>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 40 0c             	mov    0xc(%eax),%eax
  80190b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801910:	ba 00 00 00 00       	mov    $0x0,%edx
  801915:	b8 06 00 00 00       	mov    $0x6,%eax
  80191a:	e8 6b ff ff ff       	call   80188a <fsipc>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	8b 40 0c             	mov    0xc(%eax),%eax
  801931:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 05 00 00 00       	mov    $0x5,%eax
  801940:	e8 45 ff ff ff       	call   80188a <fsipc>
  801945:	85 c0                	test   %eax,%eax
  801947:	78 2c                	js     801975 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	68 00 50 80 00       	push   $0x805000
  801951:	53                   	push   %ebx
  801952:	e8 98 f0 ff ff       	call   8009ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801957:	a1 80 50 80 00       	mov    0x805080,%eax
  80195c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801962:	a1 84 50 80 00       	mov    0x805084,%eax
  801967:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	8b 45 10             	mov    0x10(%ebp),%eax
  801983:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801988:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80198d:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801990:	8b 55 08             	mov    0x8(%ebp),%edx
  801993:	8b 52 0c             	mov    0xc(%edx),%edx
  801996:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80199c:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8019a1:	50                   	push   %eax
  8019a2:	ff 75 0c             	pushl  0xc(%ebp)
  8019a5:	68 08 50 80 00       	push   $0x805008
  8019aa:	e8 d2 f1 ff ff       	call   800b81 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b9:	e8 cc fe ff ff       	call   80188a <fsipc>
            return r;

    return r;
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e3:	e8 a2 fe ff ff       	call   80188a <fsipc>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 51                	js     801a3f <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8019ee:	39 c6                	cmp    %eax,%esi
  8019f0:	73 19                	jae    801a0b <devfile_read+0x4b>
  8019f2:	68 ac 2a 80 00       	push   $0x802aac
  8019f7:	68 b3 2a 80 00       	push   $0x802ab3
  8019fc:	68 82 00 00 00       	push   $0x82
  801a01:	68 c8 2a 80 00       	push   $0x802ac8
  801a06:	e8 07 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801a0b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a10:	7e 19                	jle    801a2b <devfile_read+0x6b>
  801a12:	68 d3 2a 80 00       	push   $0x802ad3
  801a17:	68 b3 2a 80 00       	push   $0x802ab3
  801a1c:	68 83 00 00 00       	push   $0x83
  801a21:	68 c8 2a 80 00       	push   $0x802ac8
  801a26:	e8 e7 e8 ff ff       	call   800312 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a2b:	83 ec 04             	sub    $0x4,%esp
  801a2e:	50                   	push   %eax
  801a2f:	68 00 50 80 00       	push   $0x805000
  801a34:	ff 75 0c             	pushl  0xc(%ebp)
  801a37:	e8 45 f1 ff ff       	call   800b81 <memmove>
	return r;
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	89 d8                	mov    %ebx,%eax
  801a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 20             	sub    $0x20,%esp
  801a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a52:	53                   	push   %ebx
  801a53:	e8 5e ef ff ff       	call   8009b6 <strlen>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a60:	7f 67                	jg     801ac9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	e8 94 f8 ff ff       	call   801302 <fd_alloc>
  801a6e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a71:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 57                	js     801ace <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a77:	83 ec 08             	sub    $0x8,%esp
  801a7a:	53                   	push   %ebx
  801a7b:	68 00 50 80 00       	push   $0x805000
  801a80:	e8 6a ef ff ff       	call   8009ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a88:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a90:	b8 01 00 00 00       	mov    $0x1,%eax
  801a95:	e8 f0 fd ff ff       	call   80188a <fsipc>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	79 14                	jns    801ab7 <open+0x6f>
		fd_close(fd, 0);
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	6a 00                	push   $0x0
  801aa8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aab:	e8 4a f9 ff ff       	call   8013fa <fd_close>
		return r;
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	89 da                	mov    %ebx,%edx
  801ab5:	eb 17                	jmp    801ace <open+0x86>
	}

	return fd2num(fd);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	ff 75 f4             	pushl  -0xc(%ebp)
  801abd:	e8 19 f8 ff ff       	call   8012db <fd2num>
  801ac2:	89 c2                	mov    %eax,%edx
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	eb 05                	jmp    801ace <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ace:	89 d0                	mov    %edx,%eax
  801ad0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801adb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ae5:	e8 a0 fd ff ff       	call   80188a <fsipc>
}
  801aea:	c9                   	leave  
  801aeb:	c3                   	ret    

00801aec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	ff 75 08             	pushl  0x8(%ebp)
  801afa:	e8 ec f7 ff ff       	call   8012eb <fd2data>
  801aff:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b01:	83 c4 08             	add    $0x8,%esp
  801b04:	68 df 2a 80 00       	push   $0x802adf
  801b09:	53                   	push   %ebx
  801b0a:	e8 e0 ee ff ff       	call   8009ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b0f:	8b 46 04             	mov    0x4(%esi),%eax
  801b12:	2b 06                	sub    (%esi),%eax
  801b14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b21:	00 00 00 
	stat->st_dev = &devpipe;
  801b24:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b2b:	30 80 00 
	return 0;
}
  801b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b36:	5b                   	pop    %ebx
  801b37:	5e                   	pop    %esi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b44:	53                   	push   %ebx
  801b45:	6a 00                	push   $0x0
  801b47:	e8 2b f3 ff ff       	call   800e77 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b4c:	89 1c 24             	mov    %ebx,(%esp)
  801b4f:	e8 97 f7 ff ff       	call   8012eb <fd2data>
  801b54:	83 c4 08             	add    $0x8,%esp
  801b57:	50                   	push   %eax
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 18 f3 ff ff       	call   800e77 <sys_page_unmap>
}
  801b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	57                   	push   %edi
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 1c             	sub    $0x1c,%esp
  801b6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b70:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b72:	a1 04 40 80 00       	mov    0x804004,%eax
  801b77:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b80:	e8 3e 06 00 00       	call   8021c3 <pageref>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	89 3c 24             	mov    %edi,(%esp)
  801b8a:	e8 34 06 00 00       	call   8021c3 <pageref>
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	39 c3                	cmp    %eax,%ebx
  801b94:	0f 94 c1             	sete   %cl
  801b97:	0f b6 c9             	movzbl %cl,%ecx
  801b9a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b9d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ba3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ba6:	39 ce                	cmp    %ecx,%esi
  801ba8:	74 1b                	je     801bc5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801baa:	39 c3                	cmp    %eax,%ebx
  801bac:	75 c4                	jne    801b72 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bae:	8b 42 58             	mov    0x58(%edx),%eax
  801bb1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb4:	50                   	push   %eax
  801bb5:	56                   	push   %esi
  801bb6:	68 e6 2a 80 00       	push   $0x802ae6
  801bbb:	e8 2b e8 ff ff       	call   8003eb <cprintf>
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	eb ad                	jmp    801b72 <_pipeisclosed+0xe>
	}
}
  801bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 28             	sub    $0x28,%esp
  801bd9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bdc:	56                   	push   %esi
  801bdd:	e8 09 f7 ff ff       	call   8012eb <fd2data>
  801be2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	bf 00 00 00 00       	mov    $0x0,%edi
  801bec:	eb 4b                	jmp    801c39 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bee:	89 da                	mov    %ebx,%edx
  801bf0:	89 f0                	mov    %esi,%eax
  801bf2:	e8 6d ff ff ff       	call   801b64 <_pipeisclosed>
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	75 48                	jne    801c43 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bfb:	e8 d3 f1 ff ff       	call   800dd3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c00:	8b 43 04             	mov    0x4(%ebx),%eax
  801c03:	8b 0b                	mov    (%ebx),%ecx
  801c05:	8d 51 20             	lea    0x20(%ecx),%edx
  801c08:	39 d0                	cmp    %edx,%eax
  801c0a:	73 e2                	jae    801bee <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c13:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c16:	89 c2                	mov    %eax,%edx
  801c18:	c1 fa 1f             	sar    $0x1f,%edx
  801c1b:	89 d1                	mov    %edx,%ecx
  801c1d:	c1 e9 1b             	shr    $0x1b,%ecx
  801c20:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c23:	83 e2 1f             	and    $0x1f,%edx
  801c26:	29 ca                	sub    %ecx,%edx
  801c28:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c30:	83 c0 01             	add    $0x1,%eax
  801c33:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c36:	83 c7 01             	add    $0x1,%edi
  801c39:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3c:	75 c2                	jne    801c00 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c41:	eb 05                	jmp    801c48 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5f                   	pop    %edi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	57                   	push   %edi
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	83 ec 18             	sub    $0x18,%esp
  801c59:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5c:	57                   	push   %edi
  801c5d:	e8 89 f6 ff ff       	call   8012eb <fd2data>
  801c62:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6c:	eb 3d                	jmp    801cab <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c6e:	85 db                	test   %ebx,%ebx
  801c70:	74 04                	je     801c76 <devpipe_read+0x26>
				return i;
  801c72:	89 d8                	mov    %ebx,%eax
  801c74:	eb 44                	jmp    801cba <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c76:	89 f2                	mov    %esi,%edx
  801c78:	89 f8                	mov    %edi,%eax
  801c7a:	e8 e5 fe ff ff       	call   801b64 <_pipeisclosed>
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	75 32                	jne    801cb5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c83:	e8 4b f1 ff ff       	call   800dd3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c88:	8b 06                	mov    (%esi),%eax
  801c8a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c8d:	74 df                	je     801c6e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c8f:	99                   	cltd   
  801c90:	c1 ea 1b             	shr    $0x1b,%edx
  801c93:	01 d0                	add    %edx,%eax
  801c95:	83 e0 1f             	and    $0x1f,%eax
  801c98:	29 d0                	sub    %edx,%eax
  801c9a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca8:	83 c3 01             	add    $0x1,%ebx
  801cab:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cae:	75 d8                	jne    801c88 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb3:	eb 05                	jmp    801cba <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	56                   	push   %esi
  801cc6:	53                   	push   %ebx
  801cc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccd:	50                   	push   %eax
  801cce:	e8 2f f6 ff ff       	call   801302 <fd_alloc>
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	0f 88 2c 01 00 00    	js     801e0c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce0:	83 ec 04             	sub    $0x4,%esp
  801ce3:	68 07 04 00 00       	push   $0x407
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 00 f1 ff ff       	call   800df2 <sys_page_alloc>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	89 c2                	mov    %eax,%edx
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	0f 88 0d 01 00 00    	js     801e0c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cff:	83 ec 0c             	sub    $0xc,%esp
  801d02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d05:	50                   	push   %eax
  801d06:	e8 f7 f5 ff ff       	call   801302 <fd_alloc>
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 e2 00 00 00    	js     801dfa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d18:	83 ec 04             	sub    $0x4,%esp
  801d1b:	68 07 04 00 00       	push   $0x407
  801d20:	ff 75 f0             	pushl  -0x10(%ebp)
  801d23:	6a 00                	push   $0x0
  801d25:	e8 c8 f0 ff ff       	call   800df2 <sys_page_alloc>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	0f 88 c3 00 00 00    	js     801dfa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3d:	e8 a9 f5 ff ff       	call   8012eb <fd2data>
  801d42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d44:	83 c4 0c             	add    $0xc,%esp
  801d47:	68 07 04 00 00       	push   $0x407
  801d4c:	50                   	push   %eax
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 9e f0 ff ff       	call   800df2 <sys_page_alloc>
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	0f 88 89 00 00 00    	js     801dea <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	ff 75 f0             	pushl  -0x10(%ebp)
  801d67:	e8 7f f5 ff ff       	call   8012eb <fd2data>
  801d6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d73:	50                   	push   %eax
  801d74:	6a 00                	push   $0x0
  801d76:	56                   	push   %esi
  801d77:	6a 00                	push   $0x0
  801d79:	e8 b7 f0 ff ff       	call   800e35 <sys_page_map>
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	83 c4 20             	add    $0x20,%esp
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 55                	js     801ddc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d87:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801daa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db1:	83 ec 0c             	sub    $0xc,%esp
  801db4:	ff 75 f4             	pushl  -0xc(%ebp)
  801db7:	e8 1f f5 ff ff       	call   8012db <fd2num>
  801dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc1:	83 c4 04             	add    $0x4,%esp
  801dc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc7:	e8 0f f5 ff ff       	call   8012db <fd2num>
  801dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dcf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	ba 00 00 00 00       	mov    $0x0,%edx
  801dda:	eb 30                	jmp    801e0c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ddc:	83 ec 08             	sub    $0x8,%esp
  801ddf:	56                   	push   %esi
  801de0:	6a 00                	push   $0x0
  801de2:	e8 90 f0 ff ff       	call   800e77 <sys_page_unmap>
  801de7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dea:	83 ec 08             	sub    $0x8,%esp
  801ded:	ff 75 f0             	pushl  -0x10(%ebp)
  801df0:	6a 00                	push   $0x0
  801df2:	e8 80 f0 ff ff       	call   800e77 <sys_page_unmap>
  801df7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801e00:	6a 00                	push   $0x0
  801e02:	e8 70 f0 ff ff       	call   800e77 <sys_page_unmap>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0c:	89 d0                	mov    %edx,%eax
  801e0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	ff 75 08             	pushl  0x8(%ebp)
  801e22:	e8 2a f5 ff ff       	call   801351 <fd_lookup>
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 18                	js     801e46 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	ff 75 f4             	pushl  -0xc(%ebp)
  801e34:	e8 b2 f4 ff ff       	call   8012eb <fd2data>
	return _pipeisclosed(fd, p);
  801e39:	89 c2                	mov    %eax,%edx
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	e8 21 fd ff ff       	call   801b64 <_pipeisclosed>
  801e43:	83 c4 10             	add    $0x10,%esp
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e50:	85 f6                	test   %esi,%esi
  801e52:	75 16                	jne    801e6a <wait+0x22>
  801e54:	68 fe 2a 80 00       	push   $0x802afe
  801e59:	68 b3 2a 80 00       	push   $0x802ab3
  801e5e:	6a 09                	push   $0x9
  801e60:	68 09 2b 80 00       	push   $0x802b09
  801e65:	e8 a8 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e6a:	89 f3                	mov    %esi,%ebx
  801e6c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e72:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e75:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e7b:	eb 05                	jmp    801e82 <wait+0x3a>
		sys_yield();
  801e7d:	e8 51 ef ff ff       	call   800dd3 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e82:	8b 43 48             	mov    0x48(%ebx),%eax
  801e85:	39 c6                	cmp    %eax,%esi
  801e87:	75 07                	jne    801e90 <wait+0x48>
  801e89:	8b 43 54             	mov    0x54(%ebx),%eax
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	75 ed                	jne    801e7d <wait+0x35>
		sys_yield();
}
  801e90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ea7:	68 14 2b 80 00       	push   $0x802b14
  801eac:	ff 75 0c             	pushl  0xc(%ebp)
  801eaf:	e8 3b eb ff ff       	call   8009ef <strcpy>
	return 0;
}
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	57                   	push   %edi
  801ebf:	56                   	push   %esi
  801ec0:	53                   	push   %ebx
  801ec1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed2:	eb 2d                	jmp    801f01 <devcons_write+0x46>
		m = n - tot;
  801ed4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ed7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ed9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801edc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ee1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee4:	83 ec 04             	sub    $0x4,%esp
  801ee7:	53                   	push   %ebx
  801ee8:	03 45 0c             	add    0xc(%ebp),%eax
  801eeb:	50                   	push   %eax
  801eec:	57                   	push   %edi
  801eed:	e8 8f ec ff ff       	call   800b81 <memmove>
		sys_cputs(buf, m);
  801ef2:	83 c4 08             	add    $0x8,%esp
  801ef5:	53                   	push   %ebx
  801ef6:	57                   	push   %edi
  801ef7:	e8 3a ee ff ff       	call   800d36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801efc:	01 de                	add    %ebx,%esi
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	89 f0                	mov    %esi,%eax
  801f03:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f06:	72 cc                	jb     801ed4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0b:	5b                   	pop    %ebx
  801f0c:	5e                   	pop    %esi
  801f0d:	5f                   	pop    %edi
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

00801f10 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	83 ec 08             	sub    $0x8,%esp
  801f16:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f1f:	74 2a                	je     801f4b <devcons_read+0x3b>
  801f21:	eb 05                	jmp    801f28 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f23:	e8 ab ee ff ff       	call   800dd3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f28:	e8 27 ee ff ff       	call   800d54 <sys_cgetc>
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	74 f2                	je     801f23 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 16                	js     801f4b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f35:	83 f8 04             	cmp    $0x4,%eax
  801f38:	74 0c                	je     801f46 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3d:	88 02                	mov    %al,(%edx)
	return 1;
  801f3f:	b8 01 00 00 00       	mov    $0x1,%eax
  801f44:	eb 05                	jmp    801f4b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f53:	8b 45 08             	mov    0x8(%ebp),%eax
  801f56:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f59:	6a 01                	push   $0x1
  801f5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f5e:	50                   	push   %eax
  801f5f:	e8 d2 ed ff ff       	call   800d36 <sys_cputs>
}
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <getchar>:

int
getchar(void)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f6f:	6a 01                	push   $0x1
  801f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f74:	50                   	push   %eax
  801f75:	6a 00                	push   $0x0
  801f77:	e8 3b f6 ff ff       	call   8015b7 <read>
	if (r < 0)
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 0f                	js     801f92 <getchar+0x29>
		return r;
	if (r < 1)
  801f83:	85 c0                	test   %eax,%eax
  801f85:	7e 06                	jle    801f8d <getchar+0x24>
		return -E_EOF;
	return c;
  801f87:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f8b:	eb 05                	jmp    801f92 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f8d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9d:	50                   	push   %eax
  801f9e:	ff 75 08             	pushl  0x8(%ebp)
  801fa1:	e8 ab f3 ff ff       	call   801351 <fd_lookup>
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 11                	js     801fbe <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fb6:	39 10                	cmp    %edx,(%eax)
  801fb8:	0f 94 c0             	sete   %al
  801fbb:	0f b6 c0             	movzbl %al,%eax
}
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <opencons>:

int
opencons(void)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc9:	50                   	push   %eax
  801fca:	e8 33 f3 ff ff       	call   801302 <fd_alloc>
  801fcf:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	78 3e                	js     802016 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd8:	83 ec 04             	sub    $0x4,%esp
  801fdb:	68 07 04 00 00       	push   $0x407
  801fe0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe3:	6a 00                	push   $0x0
  801fe5:	e8 08 ee ff ff       	call   800df2 <sys_page_alloc>
  801fea:	83 c4 10             	add    $0x10,%esp
		return r;
  801fed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 23                	js     802016 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802001:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	50                   	push   %eax
  80200c:	e8 ca f2 ff ff       	call   8012db <fd2num>
  802011:	89 c2                	mov    %eax,%edx
  802013:	83 c4 10             	add    $0x10,%esp
}
  802016:	89 d0                	mov    %edx,%eax
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	53                   	push   %ebx
  80201e:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  802021:	e8 8e ed ff ff       	call   800db4 <sys_getenvid>
  802026:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  802028:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80202f:	75 29                	jne    80205a <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  802031:	83 ec 04             	sub    $0x4,%esp
  802034:	6a 07                	push   $0x7
  802036:	68 00 f0 bf ee       	push   $0xeebff000
  80203b:	50                   	push   %eax
  80203c:	e8 b1 ed ff ff       	call   800df2 <sys_page_alloc>
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	85 c0                	test   %eax,%eax
  802046:	79 12                	jns    80205a <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  802048:	50                   	push   %eax
  802049:	68 20 2b 80 00       	push   $0x802b20
  80204e:	6a 24                	push   $0x24
  802050:	68 39 2b 80 00       	push   $0x802b39
  802055:	e8 b8 e2 ff ff       	call   800312 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  80205a:	8b 45 08             	mov    0x8(%ebp),%eax
  80205d:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  802062:	83 ec 08             	sub    $0x8,%esp
  802065:	68 8e 20 80 00       	push   $0x80208e
  80206a:	53                   	push   %ebx
  80206b:	e8 cd ee ff ff       	call   800f3d <sys_env_set_pgfault_upcall>
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	79 12                	jns    802089 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  802077:	50                   	push   %eax
  802078:	68 20 2b 80 00       	push   $0x802b20
  80207d:	6a 2e                	push   $0x2e
  80207f:	68 39 2b 80 00       	push   $0x802b39
  802084:	e8 89 e2 ff ff       	call   800312 <_panic>
}
  802089:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80208e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80208f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802094:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802096:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  802099:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80209d:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  8020a0:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8020a4:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  8020a6:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8020aa:	83 c4 08             	add    $0x8,%esp
	popal
  8020ad:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8020ae:	83 c4 04             	add    $0x4,%esp
	popfl
  8020b1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  8020b2:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020b3:	c3                   	ret    

008020b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	57                   	push   %edi
  8020b8:	56                   	push   %esi
  8020b9:	53                   	push   %ebx
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  8020c6:	85 f6                	test   %esi,%esi
  8020c8:	74 06                	je     8020d0 <ipc_recv+0x1c>
		*from_env_store = 0;
  8020ca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  8020d0:	85 db                	test   %ebx,%ebx
  8020d2:	74 06                	je     8020da <ipc_recv+0x26>
		*perm_store = 0;
  8020d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  8020da:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  8020dc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8020e1:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  8020e4:	83 ec 0c             	sub    $0xc,%esp
  8020e7:	50                   	push   %eax
  8020e8:	e8 b5 ee ff ff       	call   800fa2 <sys_ipc_recv>
  8020ed:	89 c7                	mov    %eax,%edi
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	79 14                	jns    80210a <ipc_recv+0x56>
		cprintf("im dead");
  8020f6:	83 ec 0c             	sub    $0xc,%esp
  8020f9:	68 47 2b 80 00       	push   $0x802b47
  8020fe:	e8 e8 e2 ff ff       	call   8003eb <cprintf>
		return r;
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	89 f8                	mov    %edi,%eax
  802108:	eb 24                	jmp    80212e <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  80210a:	85 f6                	test   %esi,%esi
  80210c:	74 0a                	je     802118 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  80210e:	a1 04 40 80 00       	mov    0x804004,%eax
  802113:	8b 40 74             	mov    0x74(%eax),%eax
  802116:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  802118:	85 db                	test   %ebx,%ebx
  80211a:	74 0a                	je     802126 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  80211c:	a1 04 40 80 00       	mov    0x804004,%eax
  802121:	8b 40 78             	mov    0x78(%eax),%eax
  802124:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  802126:	a1 04 40 80 00       	mov    0x804004,%eax
  80212b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80212e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    

00802136 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	57                   	push   %edi
  80213a:	56                   	push   %esi
  80213b:	53                   	push   %ebx
  80213c:	83 ec 0c             	sub    $0xc,%esp
  80213f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802142:	8b 75 0c             	mov    0xc(%ebp),%esi
  802145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  802148:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  80214a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80214f:	0f 44 d8             	cmove  %eax,%ebx
  802152:	eb 1c                	jmp    802170 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  802154:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802157:	74 12                	je     80216b <ipc_send+0x35>
			panic("ipc_send: %e", r);
  802159:	50                   	push   %eax
  80215a:	68 4f 2b 80 00       	push   $0x802b4f
  80215f:	6a 4e                	push   $0x4e
  802161:	68 5c 2b 80 00       	push   $0x802b5c
  802166:	e8 a7 e1 ff ff       	call   800312 <_panic>
		sys_yield();
  80216b:	e8 63 ec ff ff       	call   800dd3 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802170:	ff 75 14             	pushl  0x14(%ebp)
  802173:	53                   	push   %ebx
  802174:	56                   	push   %esi
  802175:	57                   	push   %edi
  802176:	e8 04 ee ff ff       	call   800f7f <sys_ipc_try_send>
  80217b:	83 c4 10             	add    $0x10,%esp
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 d2                	js     802154 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  802182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802185:	5b                   	pop    %ebx
  802186:	5e                   	pop    %esi
  802187:	5f                   	pop    %edi
  802188:	5d                   	pop    %ebp
  802189:	c3                   	ret    

0080218a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802190:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802195:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802198:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80219e:	8b 52 50             	mov    0x50(%edx),%edx
  8021a1:	39 ca                	cmp    %ecx,%edx
  8021a3:	75 0d                	jne    8021b2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8021a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ad:	8b 40 48             	mov    0x48(%eax),%eax
  8021b0:	eb 0f                	jmp    8021c1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021b2:	83 c0 01             	add    $0x1,%eax
  8021b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021ba:	75 d9                	jne    802195 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    

008021c3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c9:	89 d0                	mov    %edx,%eax
  8021cb:	c1 e8 16             	shr    $0x16,%eax
  8021ce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021da:	f6 c1 01             	test   $0x1,%cl
  8021dd:	74 1d                	je     8021fc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021df:	c1 ea 0c             	shr    $0xc,%edx
  8021e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021e9:	f6 c2 01             	test   $0x1,%dl
  8021ec:	74 0e                	je     8021fc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ee:	c1 ea 0c             	shr    $0xc,%edx
  8021f1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f8:	ef 
  8021f9:	0f b7 c0             	movzwl %ax,%eax
}
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__udivdi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80220b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80220f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 f6                	test   %esi,%esi
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	89 ca                	mov    %ecx,%edx
  80221f:	89 f8                	mov    %edi,%eax
  802221:	75 3d                	jne    802260 <__udivdi3+0x60>
  802223:	39 cf                	cmp    %ecx,%edi
  802225:	0f 87 c5 00 00 00    	ja     8022f0 <__udivdi3+0xf0>
  80222b:	85 ff                	test   %edi,%edi
  80222d:	89 fd                	mov    %edi,%ebp
  80222f:	75 0b                	jne    80223c <__udivdi3+0x3c>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	31 d2                	xor    %edx,%edx
  802238:	f7 f7                	div    %edi
  80223a:	89 c5                	mov    %eax,%ebp
  80223c:	89 c8                	mov    %ecx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	f7 f5                	div    %ebp
  802242:	89 c1                	mov    %eax,%ecx
  802244:	89 d8                	mov    %ebx,%eax
  802246:	89 cf                	mov    %ecx,%edi
  802248:	f7 f5                	div    %ebp
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	39 ce                	cmp    %ecx,%esi
  802262:	77 74                	ja     8022d8 <__udivdi3+0xd8>
  802264:	0f bd fe             	bsr    %esi,%edi
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	0f 84 98 00 00 00    	je     802308 <__udivdi3+0x108>
  802270:	bb 20 00 00 00       	mov    $0x20,%ebx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	89 c5                	mov    %eax,%ebp
  802279:	29 fb                	sub    %edi,%ebx
  80227b:	d3 e6                	shl    %cl,%esi
  80227d:	89 d9                	mov    %ebx,%ecx
  80227f:	d3 ed                	shr    %cl,%ebp
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	09 ee                	or     %ebp,%esi
  802287:	89 d9                	mov    %ebx,%ecx
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 d5                	mov    %edx,%ebp
  80228f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802293:	d3 ed                	shr    %cl,%ebp
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e2                	shl    %cl,%edx
  802299:	89 d9                	mov    %ebx,%ecx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	09 c2                	or     %eax,%edx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	89 ea                	mov    %ebp,%edx
  8022a3:	f7 f6                	div    %esi
  8022a5:	89 d5                	mov    %edx,%ebp
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	72 10                	jb     8022c1 <__udivdi3+0xc1>
  8022b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e6                	shl    %cl,%esi
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	73 07                	jae    8022c4 <__udivdi3+0xc4>
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	75 03                	jne    8022c4 <__udivdi3+0xc4>
  8022c1:	83 eb 01             	sub    $0x1,%ebx
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 db                	xor    %ebx,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	f7 f7                	div    %edi
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 ce                	cmp    %ecx,%esi
  80230a:	72 0c                	jb     802318 <__udivdi3+0x118>
  80230c:	31 db                	xor    %ebx,%ebx
  80230e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802312:	0f 87 34 ff ff ff    	ja     80224c <__udivdi3+0x4c>
  802318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80231d:	e9 2a ff ff ff       	jmp    80224c <__udivdi3+0x4c>
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__umoddi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80233b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80233f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 d2                	test   %edx,%edx
  802349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f3                	mov    %esi,%ebx
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	75 1c                	jne    802378 <__umoddi3+0x48>
  80235c:	39 f7                	cmp    %esi,%edi
  80235e:	76 50                	jbe    8023b0 <__umoddi3+0x80>
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	f7 f7                	div    %edi
  802366:	89 d0                	mov    %edx,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	77 52                	ja     8023d0 <__umoddi3+0xa0>
  80237e:	0f bd ea             	bsr    %edx,%ebp
  802381:	83 f5 1f             	xor    $0x1f,%ebp
  802384:	75 5a                	jne    8023e0 <__umoddi3+0xb0>
  802386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80238a:	0f 82 e0 00 00 00    	jb     802470 <__umoddi3+0x140>
  802390:	39 0c 24             	cmp    %ecx,(%esp)
  802393:	0f 86 d7 00 00 00    	jbe    802470 <__umoddi3+0x140>
  802399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80239d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a1:	83 c4 1c             	add    $0x1c,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	85 ff                	test   %edi,%edi
  8023b2:	89 fd                	mov    %edi,%ebp
  8023b4:	75 0b                	jne    8023c1 <__umoddi3+0x91>
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f7                	div    %edi
  8023bf:	89 c5                	mov    %eax,%ebp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f5                	div    %ebp
  8023c7:	89 c8                	mov    %ecx,%eax
  8023c9:	f7 f5                	div    %ebp
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	eb 99                	jmp    802368 <__umoddi3+0x38>
  8023cf:	90                   	nop
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 1c             	add    $0x1c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	8b 34 24             	mov    (%esp),%esi
  8023e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	29 ef                	sub    %ebp,%edi
  8023ec:	d3 e0                	shl    %cl,%eax
  8023ee:	89 f9                	mov    %edi,%ecx
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	d3 ea                	shr    %cl,%edx
  8023f4:	89 e9                	mov    %ebp,%ecx
  8023f6:	09 c2                	or     %eax,%edx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 14 24             	mov    %edx,(%esp)
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	d3 e2                	shl    %cl,%edx
  802401:	89 f9                	mov    %edi,%ecx
  802403:	89 54 24 04          	mov    %edx,0x4(%esp)
  802407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	d3 e3                	shl    %cl,%ebx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 d0                	mov    %edx,%eax
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	09 d8                	or     %ebx,%eax
  80241d:	89 d3                	mov    %edx,%ebx
  80241f:	89 f2                	mov    %esi,%edx
  802421:	f7 34 24             	divl   (%esp)
  802424:	89 d6                	mov    %edx,%esi
  802426:	d3 e3                	shl    %cl,%ebx
  802428:	f7 64 24 04          	mull   0x4(%esp)
  80242c:	39 d6                	cmp    %edx,%esi
  80242e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802432:	89 d1                	mov    %edx,%ecx
  802434:	89 c3                	mov    %eax,%ebx
  802436:	72 08                	jb     802440 <__umoddi3+0x110>
  802438:	75 11                	jne    80244b <__umoddi3+0x11b>
  80243a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80243e:	73 0b                	jae    80244b <__umoddi3+0x11b>
  802440:	2b 44 24 04          	sub    0x4(%esp),%eax
  802444:	1b 14 24             	sbb    (%esp),%edx
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80244f:	29 da                	sub    %ebx,%edx
  802451:	19 ce                	sbb    %ecx,%esi
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e0                	shl    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	d3 ea                	shr    %cl,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	09 d0                	or     %edx,%eax
  802463:	89 f2                	mov    %esi,%edx
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	29 f9                	sub    %edi,%ecx
  802472:	19 d6                	sbb    %edx,%esi
  802474:	89 74 24 04          	mov    %esi,0x4(%esp)
  802478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80247c:	e9 18 ff ff ff       	jmp    802399 <__umoddi3+0x69>
