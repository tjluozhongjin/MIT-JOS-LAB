
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 80 23 80 00       	push   $0x802380
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 ee 1c 00 00       	call   801d3e <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 99 23 80 00       	push   $0x802399
  80005d:	6a 0d                	push   $0xd
  80005f:	68 a2 23 80 00       	push   $0x8023a2
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 a1 0f 00 00       	call   80100f <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 b6 23 80 00       	push   $0x8023b6
  80007a:	6a 10                	push   $0x10
  80007c:	68 a2 23 80 00       	push   $0x8023a2
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 27 14 00 00       	call   8014bc <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 e9 1d 00 00       	call   801e91 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 bf 23 80 00       	push   $0x8023bf
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 3c 0c 00 00       	call   800d05 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 31 11 00 00       	call   80120d <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 da 23 80 00       	push   $0x8023da
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 e5 23 80 00       	push   $0x8023e5
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 f2 13 00 00       	call   80150c <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 d7 13 00 00       	call   80150c <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 f0 23 80 00       	push   $0x8023f0
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 39 1d 00 00       	call   801e91 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 4c 24 80 00       	push   $0x80244c
  800167:	6a 3a                	push   $0x3a
  800169:	68 a2 23 80 00       	push   $0x8023a2
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 10 12 00 00       	call   801392 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 06 24 80 00       	push   $0x802406
  80018f:	6a 3c                	push   $0x3c
  800191:	68 a2 23 80 00       	push   $0x8023a2
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 86 11 00 00       	call   80132c <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 7f 19 00 00       	call   801b2d <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 1e 24 80 00       	push   $0x80241e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 34 24 80 00       	push   $0x802434
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 f2 0a 00 00       	call   800ce6 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 b2 12 00 00       	call   8014e7 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 66 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 8f 0a 00 00       	call   800ce6 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 80 24 80 00       	push   $0x802480
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 97 23 80 00 	movl   $0x802397,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 ae 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 1a 01 00 00       	call   80041a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 53 09 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 6b 1d 00 00       	call   8020f0 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 58 1e 00 00       	call   802220 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	88 02                	mov    %al,(%edx)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800403:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 10             	pushl  0x10(%ebp)
  80040a:	ff 75 0c             	pushl  0xc(%ebp)
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 05 00 00 00       	call   80041a <vprintfmt>
	va_end(ap);
}
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 2c             	sub    $0x2c,%esp
  800423:	8b 75 08             	mov    0x8(%ebp),%esi
  800426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800429:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042c:	eb 12                	jmp    800440 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042e:	85 c0                	test   %eax,%eax
  800430:	0f 84 42 04 00 00    	je     800878 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	50                   	push   %eax
  80043b:	ff d6                	call   *%esi
  80043d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800440:	83 c7 01             	add    $0x1,%edi
  800443:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800447:	83 f8 25             	cmp    $0x25,%eax
  80044a:	75 e2                	jne    80042e <vprintfmt+0x14>
  80044c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800450:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	eb 07                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8d 47 01             	lea    0x1(%edi),%eax
  800476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800479:	0f b6 07             	movzbl (%edi),%eax
  80047c:	0f b6 d0             	movzbl %al,%edx
  80047f:	83 e8 23             	sub    $0x23,%eax
  800482:	3c 55                	cmp    $0x55,%al
  800484:	0f 87 d3 03 00 00    	ja     80085d <vprintfmt+0x443>
  80048a:	0f b6 c0             	movzbl %al,%eax
  80048d:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800497:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80049b:	eb d6                	jmp    800473 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b5:	83 f9 09             	cmp    $0x9,%ecx
  8004b8:	77 3f                	ja     8004f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bd:	eb e9                	jmp    8004a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 04             	lea    0x4(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d3:	eb 2a                	jmp    8004ff <vprintfmt+0xe5>
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	0f 49 d0             	cmovns %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e8:	eb 89                	jmp    800473 <vprintfmt+0x59>
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f4:	e9 7a ff ff ff       	jmp    800473 <vprintfmt+0x59>
  8004f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	0f 89 6a ff ff ff    	jns    800473 <vprintfmt+0x59>
				width = precision, precision = -1;
  800509:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800516:	e9 58 ff ff ff       	jmp    800473 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800521:	e9 4d ff ff ff       	jmp    800473 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 78 04             	lea    0x4(%eax),%edi
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	ff 30                	pushl  (%eax)
  800532:	ff d6                	call   *%esi
			break;
  800534:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053d:	e9 fe fe ff ff       	jmp    800440 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 78 04             	lea    0x4(%eax),%edi
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	99                   	cltd   
  80054b:	31 d0                	xor    %edx,%eax
  80054d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 f8 0f             	cmp    $0xf,%eax
  800552:	7f 0b                	jg     80055f <vprintfmt+0x145>
  800554:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80055b:	85 d2                	test   %edx,%edx
  80055d:	75 1b                	jne    80057a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80055f:	50                   	push   %eax
  800560:	68 bb 24 80 00       	push   $0x8024bb
  800565:	53                   	push   %ebx
  800566:	56                   	push   %esi
  800567:	e8 91 fe ff ff       	call   8003fd <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800575:	e9 c6 fe ff ff       	jmp    800440 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057a:	52                   	push   %edx
  80057b:	68 65 29 80 00       	push   $0x802965
  800580:	53                   	push   %ebx
  800581:	56                   	push   %esi
  800582:	e8 76 fe ff ff       	call   8003fd <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 ab fe ff ff       	jmp    800440 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	83 c0 04             	add    $0x4,%eax
  80059b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	b8 b4 24 80 00       	mov    $0x8024b4,%eax
  8005aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	0f 8e 94 00 00 00    	jle    80064b <vprintfmt+0x231>
  8005b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bb:	0f 84 98 00 00 00    	je     800659 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c7:	57                   	push   %edi
  8005c8:	e8 33 03 00 00       	call   800900 <strnlen>
  8005cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d0:	29 c1                	sub    %eax,%ecx
  8005d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	eb 0f                	jmp    8005f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ef 01             	sub    $0x1,%edi
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	85 ff                	test   %edi,%edi
  8005f7:	7f ed                	jg     8005e6 <vprintfmt+0x1cc>
  8005f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	b8 00 00 00 00       	mov    $0x0,%eax
  800606:	0f 49 c1             	cmovns %ecx,%eax
  800609:	29 c1                	sub    %eax,%ecx
  80060b:	89 75 08             	mov    %esi,0x8(%ebp)
  80060e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800611:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800614:	89 cb                	mov    %ecx,%ebx
  800616:	eb 4d                	jmp    800665 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061c:	74 1b                	je     800639 <vprintfmt+0x21f>
  80061e:	0f be c0             	movsbl %al,%eax
  800621:	83 e8 20             	sub    $0x20,%eax
  800624:	83 f8 5e             	cmp    $0x5e,%eax
  800627:	76 10                	jbe    800639 <vprintfmt+0x21f>
					putch('?', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	ff 75 0c             	pushl  0xc(%ebp)
  80062f:	6a 3f                	push   $0x3f
  800631:	ff 55 08             	call   *0x8(%ebp)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	ff 75 0c             	pushl  0xc(%ebp)
  80063f:	52                   	push   %edx
  800640:	ff 55 08             	call   *0x8(%ebp)
  800643:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	eb 1a                	jmp    800665 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	eb 0c                	jmp    800665 <vprintfmt+0x24b>
  800659:	89 75 08             	mov    %esi,0x8(%ebp)
  80065c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800662:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800665:	83 c7 01             	add    $0x1,%edi
  800668:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066c:	0f be d0             	movsbl %al,%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	74 23                	je     800696 <vprintfmt+0x27c>
  800673:	85 f6                	test   %esi,%esi
  800675:	78 a1                	js     800618 <vprintfmt+0x1fe>
  800677:	83 ee 01             	sub    $0x1,%esi
  80067a:	79 9c                	jns    800618 <vprintfmt+0x1fe>
  80067c:	89 df                	mov    %ebx,%edi
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	eb 18                	jmp    80069e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 20                	push   $0x20
  80068c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 08                	jmp    80069e <vprintfmt+0x284>
  800696:	89 df                	mov    %ebx,%edi
  800698:	8b 75 08             	mov    0x8(%ebp),%esi
  80069b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	7f e4                	jg     800686 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 90 fd ff ff       	jmp    800440 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 19                	jle    8006ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb 38                	jmp    800706 <vprintfmt+0x2ec>
	else if (lflag)
  8006ce:	85 c9                	test   %ecx,%ecx
  8006d0:	74 1b                	je     8006ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006eb:	eb 19                	jmp    800706 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 c1                	mov    %eax,%ecx
  8006f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800706:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800709:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800711:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800715:	0f 89 0e 01 00 00    	jns    800829 <vprintfmt+0x40f>
				putch('-', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	6a 2d                	push   $0x2d
  800721:	ff d6                	call   *%esi
				num = -(long long) num;
  800723:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800726:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800729:	f7 da                	neg    %edx
  80072b:	83 d1 00             	adc    $0x0,%ecx
  80072e:	f7 d9                	neg    %ecx
  800730:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
  800738:	e9 ec 00 00 00       	jmp    800829 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073d:	83 f9 01             	cmp    $0x1,%ecx
  800740:	7e 18                	jle    80075a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	8b 48 04             	mov    0x4(%eax),%ecx
  80074a:	8d 40 08             	lea    0x8(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800750:	b8 0a 00 00 00       	mov    $0xa,%eax
  800755:	e9 cf 00 00 00       	jmp    800829 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	74 1a                	je     800778 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 b1 00 00 00       	jmp    800829 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 97 00 00 00       	jmp    800829 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 58                	push   $0x58
  800798:	ff d6                	call   *%esi
			putch('X', putdat);
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 58                	push   $0x58
  8007a0:	ff d6                	call   *%esi
			putch('X', putdat);
  8007a2:	83 c4 08             	add    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 58                	push   $0x58
  8007a8:	ff d6                	call   *%esi
			break;
  8007aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007b0:	e9 8b fc ff ff       	jmp    800440 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	6a 30                	push   $0x30
  8007bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8007bd:	83 c4 08             	add    $0x8,%esp
  8007c0:	53                   	push   %ebx
  8007c1:	6a 78                	push   $0x78
  8007c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cf:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007dd:	eb 4a                	jmp    800829 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007df:	83 f9 01             	cmp    $0x1,%ecx
  8007e2:	7e 15                	jle    8007f9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ec:	8d 40 08             	lea    0x8(%eax),%eax
  8007ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007f2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f7:	eb 30                	jmp    800829 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007f9:	85 c9                	test   %ecx,%ecx
  8007fb:	74 17                	je     800814 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 10                	mov    (%eax),%edx
  800802:	b9 00 00 00 00       	mov    $0x0,%ecx
  800807:	8d 40 04             	lea    0x4(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80080d:	b8 10 00 00 00       	mov    $0x10,%eax
  800812:	eb 15                	jmp    800829 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081e:	8d 40 04             	lea    0x4(%eax),%eax
  800821:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800824:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800829:	83 ec 0c             	sub    $0xc,%esp
  80082c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800830:	57                   	push   %edi
  800831:	ff 75 e0             	pushl  -0x20(%ebp)
  800834:	50                   	push   %eax
  800835:	51                   	push   %ecx
  800836:	52                   	push   %edx
  800837:	89 da                	mov    %ebx,%edx
  800839:	89 f0                	mov    %esi,%eax
  80083b:	e8 f1 fa ff ff       	call   800331 <printnum>
			break;
  800840:	83 c4 20             	add    $0x20,%esp
  800843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800846:	e9 f5 fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	52                   	push   %edx
  800850:	ff d6                	call   *%esi
			break;
  800852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800858:	e9 e3 fb ff ff       	jmp    800440 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 25                	push   $0x25
  800863:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 03                	jmp    80086d <vprintfmt+0x453>
  80086a:	83 ef 01             	sub    $0x1,%edi
  80086d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800871:	75 f7                	jne    80086a <vprintfmt+0x450>
  800873:	e9 c8 fb ff ff       	jmp    800440 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 18             	sub    $0x18,%esp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800893:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 26                	je     8008c7 <vsnprintf+0x47>
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	7e 22                	jle    8008c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a5:	ff 75 14             	pushl  0x14(%ebp)
  8008a8:	ff 75 10             	pushl  0x10(%ebp)
  8008ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ae:	50                   	push   %eax
  8008af:	68 e0 03 80 00       	push   $0x8003e0
  8008b4:	e8 61 fb ff ff       	call   80041a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 05                	jmp    8008cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d7:	50                   	push   %eax
  8008d8:	ff 75 10             	pushl  0x10(%ebp)
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	ff 75 08             	pushl  0x8(%ebp)
  8008e1:	e8 9a ff ff ff       	call   800880 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	eb 03                	jmp    8008f8 <strlen+0x10>
		n++;
  8008f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fc:	75 f7                	jne    8008f5 <strlen+0xd>
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800909:	ba 00 00 00 00       	mov    $0x0,%edx
  80090e:	eb 03                	jmp    800913 <strnlen+0x13>
		n++;
  800910:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	39 c2                	cmp    %eax,%edx
  800915:	74 08                	je     80091f <strnlen+0x1f>
  800917:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80091b:	75 f3                	jne    800910 <strnlen+0x10>
  80091d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800937:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093a:	84 db                	test   %bl,%bl
  80093c:	75 ef                	jne    80092d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800948:	53                   	push   %ebx
  800949:	e8 9a ff ff ff       	call   8008e8 <strlen>
  80094e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800951:	ff 75 0c             	pushl  0xc(%ebp)
  800954:	01 d8                	add    %ebx,%eax
  800956:	50                   	push   %eax
  800957:	e8 c5 ff ff ff       	call   800921 <strcpy>
	return dst;
}
  80095c:	89 d8                	mov    %ebx,%eax
  80095e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	89 f3                	mov    %esi,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800973:	89 f2                	mov    %esi,%edx
  800975:	eb 0f                	jmp    800986 <strncpy+0x23>
		*dst++ = *src;
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800980:	80 39 01             	cmpb   $0x1,(%ecx)
  800983:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800986:	39 da                	cmp    %ebx,%edx
  800988:	75 ed                	jne    800977 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80098a:	89 f0                	mov    %esi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 75 08             	mov    0x8(%ebp),%esi
  800998:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099b:	8b 55 10             	mov    0x10(%ebp),%edx
  80099e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a0:	85 d2                	test   %edx,%edx
  8009a2:	74 21                	je     8009c5 <strlcpy+0x35>
  8009a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	eb 09                	jmp    8009b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b5:	39 c2                	cmp    %eax,%edx
  8009b7:	74 09                	je     8009c2 <strlcpy+0x32>
  8009b9:	0f b6 19             	movzbl (%ecx),%ebx
  8009bc:	84 db                	test   %bl,%bl
  8009be:	75 ec                	jne    8009ac <strlcpy+0x1c>
  8009c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c5:	29 f0                	sub    %esi,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strcmp+0x11>
		p++, q++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	84 c0                	test   %al,%al
  8009e1:	74 04                	je     8009e7 <strcmp+0x1c>
  8009e3:	3a 02                	cmp    (%edx),%al
  8009e5:	74 ef                	je     8009d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e7:	0f b6 c0             	movzbl %al,%eax
  8009ea:	0f b6 12             	movzbl (%edx),%edx
  8009ed:	29 d0                	sub    %edx,%eax
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	89 c3                	mov    %eax,%ebx
  8009fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a00:	eb 06                	jmp    800a08 <strncmp+0x17>
		n--, p++, q++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a08:	39 d8                	cmp    %ebx,%eax
  800a0a:	74 15                	je     800a21 <strncmp+0x30>
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	84 c9                	test   %cl,%cl
  800a11:	74 04                	je     800a17 <strncmp+0x26>
  800a13:	3a 0a                	cmp    (%edx),%cl
  800a15:	74 eb                	je     800a02 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 12             	movzbl (%edx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
  800a1f:	eb 05                	jmp    800a26 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 07                	jmp    800a3c <strchr+0x13>
		if (*s == c)
  800a35:	38 ca                	cmp    %cl,%dl
  800a37:	74 0f                	je     800a48 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f2                	jne    800a35 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 03                	jmp    800a59 <strfind+0xf>
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	74 04                	je     800a64 <strfind+0x1a>
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strfind+0xc>
			break;
	return (char *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	74 36                	je     800aac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7c:	75 28                	jne    800aa6 <memset+0x40>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 23                	jne    800aa6 <memset+0x40>
		c &= 0xFF;
  800a83:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a87:	89 d3                	mov    %edx,%ebx
  800a89:	c1 e3 08             	shl    $0x8,%ebx
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	c1 e6 18             	shl    $0x18,%esi
  800a91:	89 d0                	mov    %edx,%eax
  800a93:	c1 e0 10             	shl    $0x10,%eax
  800a96:	09 f0                	or     %esi,%eax
  800a98:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	09 d0                	or     %edx,%eax
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
  800aa1:	fc                   	cld    
  800aa2:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa4:	eb 06                	jmp    800aac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	fc                   	cld    
  800aaa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac1:	39 c6                	cmp    %eax,%esi
  800ac3:	73 35                	jae    800afa <memmove+0x47>
  800ac5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac8:	39 d0                	cmp    %edx,%eax
  800aca:	73 2e                	jae    800afa <memmove+0x47>
		s += n;
		d += n;
  800acc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	09 fe                	or     %edi,%esi
  800ad3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad9:	75 13                	jne    800aee <memmove+0x3b>
  800adb:	f6 c1 03             	test   $0x3,%cl
  800ade:	75 0e                	jne    800aee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ae0:	83 ef 04             	sub    $0x4,%edi
  800ae3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	fd                   	std    
  800aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aec:	eb 09                	jmp    800af7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aee:	83 ef 01             	sub    $0x1,%edi
  800af1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af4:	fd                   	std    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af7:	fc                   	cld    
  800af8:	eb 1d                	jmp    800b17 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	89 f2                	mov    %esi,%edx
  800afc:	09 c2                	or     %eax,%edx
  800afe:	f6 c2 03             	test   $0x3,%dl
  800b01:	75 0f                	jne    800b12 <memmove+0x5f>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0a                	jne    800b12 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b10:	eb 05                	jmp    800b17 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	fc                   	cld    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 87 ff ff ff       	call   800ab3 <memmove>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3e:	eb 1a                	jmp    800b5a <memcmp+0x2c>
		if (*s1 != *s2)
  800b40:	0f b6 08             	movzbl (%eax),%ecx
  800b43:	0f b6 1a             	movzbl (%edx),%ebx
  800b46:	38 d9                	cmp    %bl,%cl
  800b48:	74 0a                	je     800b54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b4a:	0f b6 c1             	movzbl %cl,%eax
  800b4d:	0f b6 db             	movzbl %bl,%ebx
  800b50:	29 d8                	sub    %ebx,%eax
  800b52:	eb 0f                	jmp    800b63 <memcmp+0x35>
		s1++, s2++;
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	39 f0                	cmp    %esi,%eax
  800b5c:	75 e2                	jne    800b40 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b6e:	89 c1                	mov    %eax,%ecx
  800b70:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b73:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	eb 0a                	jmp    800b83 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b79:	0f b6 10             	movzbl (%eax),%edx
  800b7c:	39 da                	cmp    %ebx,%edx
  800b7e:	74 07                	je     800b87 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b80:	83 c0 01             	add    $0x1,%eax
  800b83:	39 c8                	cmp    %ecx,%eax
  800b85:	72 f2                	jb     800b79 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b96:	eb 03                	jmp    800b9b <strtol+0x11>
		s++;
  800b98:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	3c 20                	cmp    $0x20,%al
  800ba0:	74 f6                	je     800b98 <strtol+0xe>
  800ba2:	3c 09                	cmp    $0x9,%al
  800ba4:	74 f2                	je     800b98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba6:	3c 2b                	cmp    $0x2b,%al
  800ba8:	75 0a                	jne    800bb4 <strtol+0x2a>
		s++;
  800baa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb2:	eb 11                	jmp    800bc5 <strtol+0x3b>
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 08                	jne    800bc5 <strtol+0x3b>
		s++, neg = 1;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcb:	75 15                	jne    800be2 <strtol+0x58>
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	75 10                	jne    800be2 <strtol+0x58>
  800bd2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd6:	75 7c                	jne    800c54 <strtol+0xca>
		s += 2, base = 16;
  800bd8:	83 c1 02             	add    $0x2,%ecx
  800bdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be0:	eb 16                	jmp    800bf8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800be2:	85 db                	test   %ebx,%ebx
  800be4:	75 12                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800beb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bee:	75 08                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c00:	0f b6 11             	movzbl (%ecx),%edx
  800c03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	77 08                	ja     800c15 <strtol+0x8b>
			dig = *s - '0';
  800c0d:	0f be d2             	movsbl %dl,%edx
  800c10:	83 ea 30             	sub    $0x30,%edx
  800c13:	eb 22                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c18:	89 f3                	mov    %esi,%ebx
  800c1a:	80 fb 19             	cmp    $0x19,%bl
  800c1d:	77 08                	ja     800c27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c1f:	0f be d2             	movsbl %dl,%edx
  800c22:	83 ea 57             	sub    $0x57,%edx
  800c25:	eb 10                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c2a:	89 f3                	mov    %esi,%ebx
  800c2c:	80 fb 19             	cmp    $0x19,%bl
  800c2f:	77 16                	ja     800c47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c31:	0f be d2             	movsbl %dl,%edx
  800c34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3a:	7d 0b                	jge    800c47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c45:	eb b9                	jmp    800c00 <strtol+0x76>

	if (endptr)
  800c47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4b:	74 0d                	je     800c5a <strtol+0xd0>
		*endptr = (char *) s;
  800c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c50:	89 0e                	mov    %ecx,(%esi)
  800c52:	eb 06                	jmp    800c5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c54:	85 db                	test   %ebx,%ebx
  800c56:	74 98                	je     800bf0 <strtol+0x66>
  800c58:	eb 9e                	jmp    800bf8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	f7 da                	neg    %edx
  800c5e:	85 ff                	test   %edi,%edi
  800c60:	0f 45 c2             	cmovne %edx,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 cb                	mov    %ecx,%ebx
  800cbd:	89 cf                	mov    %ecx,%edi
  800cbf:	89 ce                	mov    %ecx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 03                	push   $0x3
  800ccd:	68 9f 27 80 00       	push   $0x80279f
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 bc 27 80 00       	push   $0x8027bc
  800cd9:	e8 66 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf6:	89 d1                	mov    %edx,%ecx
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	89 d7                	mov    %edx,%edi
  800cfc:	89 d6                	mov    %edx,%esi
  800cfe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_yield>:

void
sys_yield(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	be 00 00 00 00       	mov    $0x0,%esi
  800d32:	b8 04 00 00 00       	mov    $0x4,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d40:	89 f7                	mov    %esi,%edi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 04                	push   $0x4
  800d4e:	68 9f 27 80 00       	push   $0x80279f
  800d53:	6a 23                	push   $0x23
  800d55:	68 bc 27 80 00       	push   $0x8027bc
  800d5a:	e8 e5 f4 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	b8 05 00 00 00       	mov    $0x5,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 75 18             	mov    0x18(%ebp),%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 05                	push   $0x5
  800d90:	68 9f 27 80 00       	push   $0x80279f
  800d95:	6a 23                	push   $0x23
  800d97:	68 bc 27 80 00       	push   $0x8027bc
  800d9c:	e8 a3 f4 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 06                	push   $0x6
  800dd2:	68 9f 27 80 00       	push   $0x80279f
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 bc 27 80 00       	push   $0x8027bc
  800dde:	e8 61 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	89 df                	mov    %ebx,%edi
  800e06:	89 de                	mov    %ebx,%esi
  800e08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 08                	push   $0x8
  800e14:	68 9f 27 80 00       	push   $0x80279f
  800e19:	6a 23                	push   $0x23
  800e1b:	68 bc 27 80 00       	push   $0x8027bc
  800e20:	e8 1f f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 09                	push   $0x9
  800e56:	68 9f 27 80 00       	push   $0x80279f
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 bc 27 80 00       	push   $0x8027bc
  800e62:	e8 dd f3 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	7e 17                	jle    800ea9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	50                   	push   %eax
  800e96:	6a 0a                	push   $0xa
  800e98:	68 9f 27 80 00       	push   $0x80279f
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 bc 27 80 00       	push   $0x8027bc
  800ea4:	e8 9b f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	be 00 00 00 00       	mov    $0x0,%esi
  800ebc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 cb                	mov    %ecx,%ebx
  800eec:	89 cf                	mov    %ecx,%edi
  800eee:	89 ce                	mov    %ecx,%esi
  800ef0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7e 17                	jle    800f0d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	50                   	push   %eax
  800efa:	6a 0d                	push   $0xd
  800efc:	68 9f 27 80 00       	push   $0x80279f
  800f01:	6a 23                	push   $0x23
  800f03:	68 bc 27 80 00       	push   $0x8027bc
  800f08:	e8 37 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800f1d:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800f1f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f23:	74 11                	je     800f36 <pgfault+0x21>
  800f25:	89 d8                	mov    %ebx,%eax
  800f27:	c1 e8 0c             	shr    $0xc,%eax
  800f2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f31:	f6 c4 08             	test   $0x8,%ah
  800f34:	75 14                	jne    800f4a <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 cc 27 80 00       	push   $0x8027cc
  800f3e:	6a 1f                	push   $0x1f
  800f40:	68 2f 28 80 00       	push   $0x80282f
  800f45:	e8 fa f2 ff ff       	call   800244 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800f4a:	e8 97 fd ff ff       	call   800ce6 <sys_getenvid>
  800f4f:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	6a 07                	push   $0x7
  800f56:	68 00 f0 7f 00       	push   $0x7ff000
  800f5b:	50                   	push   %eax
  800f5c:	e8 c3 fd ff ff       	call   800d24 <sys_page_alloc>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 12                	jns    800f7a <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800f68:	50                   	push   %eax
  800f69:	68 0c 28 80 00       	push   $0x80280c
  800f6e:	6a 2c                	push   $0x2c
  800f70:	68 2f 28 80 00       	push   $0x80282f
  800f75:	e8 ca f2 ff ff       	call   800244 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800f7a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800f80:	83 ec 04             	sub    $0x4,%esp
  800f83:	68 00 10 00 00       	push   $0x1000
  800f88:	53                   	push   %ebx
  800f89:	68 00 f0 7f 00       	push   $0x7ff000
  800f8e:	e8 20 fb ff ff       	call   800ab3 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800f93:	83 c4 08             	add    $0x8,%esp
  800f96:	53                   	push   %ebx
  800f97:	56                   	push   %esi
  800f98:	e8 0c fe ff ff       	call   800da9 <sys_page_unmap>
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	79 12                	jns    800fb6 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800fa4:	50                   	push   %eax
  800fa5:	68 3a 28 80 00       	push   $0x80283a
  800faa:	6a 32                	push   $0x32
  800fac:	68 2f 28 80 00       	push   $0x80282f
  800fb1:	e8 8e f2 ff ff       	call   800244 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	6a 07                	push   $0x7
  800fbb:	53                   	push   %ebx
  800fbc:	56                   	push   %esi
  800fbd:	68 00 f0 7f 00       	push   $0x7ff000
  800fc2:	56                   	push   %esi
  800fc3:	e8 9f fd ff ff       	call   800d67 <sys_page_map>
  800fc8:	83 c4 20             	add    $0x20,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	79 12                	jns    800fe1 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800fcf:	50                   	push   %eax
  800fd0:	68 58 28 80 00       	push   $0x802858
  800fd5:	6a 35                	push   $0x35
  800fd7:	68 2f 28 80 00       	push   $0x80282f
  800fdc:	e8 63 f2 ff ff       	call   800244 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	68 00 f0 7f 00       	push   $0x7ff000
  800fe9:	56                   	push   %esi
  800fea:	e8 ba fd ff ff       	call   800da9 <sys_page_unmap>
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 12                	jns    801008 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800ff6:	50                   	push   %eax
  800ff7:	68 3a 28 80 00       	push   $0x80283a
  800ffc:	6a 38                	push   $0x38
  800ffe:	68 2f 28 80 00       	push   $0x80282f
  801003:	e8 3c f2 ff ff       	call   800244 <_panic>
	//panic("pgfault not implemented");
}
  801008:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	57                   	push   %edi
  801013:	56                   	push   %esi
  801014:	53                   	push   %ebx
  801015:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  801018:	68 15 0f 80 00       	push   $0x800f15
  80101d:	e8 25 10 00 00       	call   802047 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801022:	b8 07 00 00 00       	mov    $0x7,%eax
  801027:	cd 30                	int    $0x30
  801029:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	0f 88 38 01 00 00    	js     80116f <fork+0x160>
  801037:	89 c7                	mov    %eax,%edi
  801039:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  80103e:	85 c0                	test   %eax,%eax
  801040:	75 21                	jne    801063 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  801042:	e8 9f fc ff ff       	call   800ce6 <sys_getenvid>
  801047:	25 ff 03 00 00       	and    $0x3ff,%eax
  80104c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80104f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801054:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801059:	ba 00 00 00 00       	mov    $0x0,%edx
  80105e:	e9 86 01 00 00       	jmp    8011e9 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801063:	89 d8                	mov    %ebx,%eax
  801065:	c1 e8 16             	shr    $0x16,%eax
  801068:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106f:	a8 01                	test   $0x1,%al
  801071:	0f 84 90 00 00 00    	je     801107 <fork+0xf8>
  801077:	89 d8                	mov    %ebx,%eax
  801079:	c1 e8 0c             	shr    $0xc,%eax
  80107c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801083:	f6 c2 01             	test   $0x1,%dl
  801086:	74 7f                	je     801107 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  801088:	89 c6                	mov    %eax,%esi
  80108a:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  80108d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801094:	f6 c6 04             	test   $0x4,%dh
  801097:	74 33                	je     8010cc <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  801099:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a8:	50                   	push   %eax
  8010a9:	56                   	push   %esi
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 b4 fc ff ff       	call   800d67 <sys_page_map>
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 4d                	jns    801107 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  8010ba:	50                   	push   %eax
  8010bb:	68 74 28 80 00       	push   $0x802874
  8010c0:	6a 54                	push   $0x54
  8010c2:	68 2f 28 80 00       	push   $0x80282f
  8010c7:	e8 78 f1 ff ff       	call   800244 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  8010cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d3:	a9 02 08 00 00       	test   $0x802,%eax
  8010d8:	0f 85 c6 00 00 00    	jne    8011a4 <fork+0x195>
  8010de:	e9 e3 00 00 00       	jmp    8011c6 <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8010e3:	50                   	push   %eax
  8010e4:	68 74 28 80 00       	push   $0x802874
  8010e9:	6a 5d                	push   $0x5d
  8010eb:	68 2f 28 80 00       	push   $0x80282f
  8010f0:	e8 4f f1 ff ff       	call   800244 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8010f5:	50                   	push   %eax
  8010f6:	68 74 28 80 00       	push   $0x802874
  8010fb:	6a 64                	push   $0x64
  8010fd:	68 2f 28 80 00       	push   $0x80282f
  801102:	e8 3d f1 ff ff       	call   800244 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  801107:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80110d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801113:	0f 85 4a ff ff ff    	jne    801063 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	6a 07                	push   $0x7
  80111e:	68 00 f0 bf ee       	push   $0xeebff000
  801123:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801126:	57                   	push   %edi
  801127:	e8 f8 fb ff ff       	call   800d24 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  80112c:	83 c4 10             	add    $0x10,%esp
		return ret;
  80112f:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801131:	85 c0                	test   %eax,%eax
  801133:	0f 88 b0 00 00 00    	js     8011e9 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801139:	a1 04 40 80 00       	mov    0x804004,%eax
  80113e:	8b 40 64             	mov    0x64(%eax),%eax
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	50                   	push   %eax
  801145:	57                   	push   %edi
  801146:	e8 24 fd ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
  80114b:	83 c4 10             	add    $0x10,%esp
		return ret;
  80114e:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801150:	85 c0                	test   %eax,%eax
  801152:	0f 88 91 00 00 00    	js     8011e9 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	6a 02                	push   $0x2
  80115d:	57                   	push   %edi
  80115e:	e8 88 fc ff ff       	call   800deb <sys_env_set_status>
  801163:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  801166:	85 c0                	test   %eax,%eax
  801168:	89 fa                	mov    %edi,%edx
  80116a:	0f 48 d0             	cmovs  %eax,%edx
  80116d:	eb 7a                	jmp    8011e9 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  80116f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801172:	eb 75                	jmp    8011e9 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801174:	e8 6d fb ff ff       	call   800ce6 <sys_getenvid>
  801179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80117c:	e8 65 fb ff ff       	call   800ce6 <sys_getenvid>
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	68 05 08 00 00       	push   $0x805
  801189:	56                   	push   %esi
  80118a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118d:	56                   	push   %esi
  80118e:	50                   	push   %eax
  80118f:	e8 d3 fb ff ff       	call   800d67 <sys_page_map>
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	0f 89 68 ff ff ff    	jns    801107 <fork+0xf8>
  80119f:	e9 51 ff ff ff       	jmp    8010f5 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  8011a4:	e8 3d fb ff ff       	call   800ce6 <sys_getenvid>
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	68 05 08 00 00       	push   $0x805
  8011b1:	56                   	push   %esi
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	50                   	push   %eax
  8011b5:	e8 ad fb ff ff       	call   800d67 <sys_page_map>
  8011ba:	83 c4 20             	add    $0x20,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	79 b3                	jns    801174 <fork+0x165>
  8011c1:	e9 1d ff ff ff       	jmp    8010e3 <fork+0xd4>
  8011c6:	e8 1b fb ff ff       	call   800ce6 <sys_getenvid>
  8011cb:	83 ec 0c             	sub    $0xc,%esp
  8011ce:	6a 05                	push   $0x5
  8011d0:	56                   	push   %esi
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	50                   	push   %eax
  8011d4:	e8 8e fb ff ff       	call   800d67 <sys_page_map>
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	0f 89 23 ff ff ff    	jns    801107 <fork+0xf8>
  8011e4:	e9 fa fe ff ff       	jmp    8010e3 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8011e9:	89 d0                	mov    %edx,%eax
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <sfork>:

// Challenge!
int
sfork(void)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011f9:	68 85 28 80 00       	push   $0x802885
  8011fe:	68 ac 00 00 00       	push   $0xac
  801203:	68 2f 28 80 00       	push   $0x80282f
  801208:	e8 37 f0 ff ff       	call   800244 <_panic>

0080120d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8b 75 08             	mov    0x8(%ebp),%esi
  801219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  80121f:	85 f6                	test   %esi,%esi
  801221:	74 06                	je     801229 <ipc_recv+0x1c>
		*from_env_store = 0;
  801223:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801229:	85 db                	test   %ebx,%ebx
  80122b:	74 06                	je     801233 <ipc_recv+0x26>
		*perm_store = 0;
  80122d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801233:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801235:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80123a:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  80123d:	83 ec 0c             	sub    $0xc,%esp
  801240:	50                   	push   %eax
  801241:	e8 8e fc ff ff       	call   800ed4 <sys_ipc_recv>
  801246:	89 c7                	mov    %eax,%edi
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	79 14                	jns    801263 <ipc_recv+0x56>
		cprintf("im dead");
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	68 9b 28 80 00       	push   $0x80289b
  801257:	e8 c1 f0 ff ff       	call   80031d <cprintf>
		return r;
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	89 f8                	mov    %edi,%eax
  801261:	eb 24                	jmp    801287 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801263:	85 f6                	test   %esi,%esi
  801265:	74 0a                	je     801271 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801267:	a1 04 40 80 00       	mov    0x804004,%eax
  80126c:	8b 40 74             	mov    0x74(%eax),%eax
  80126f:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801271:	85 db                	test   %ebx,%ebx
  801273:	74 0a                	je     80127f <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801275:	a1 04 40 80 00       	mov    0x804004,%eax
  80127a:	8b 40 78             	mov    0x78(%eax),%eax
  80127d:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  80127f:	a1 04 40 80 00       	mov    0x804004,%eax
  801284:	8b 40 70             	mov    0x70(%eax),%eax
}
  801287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5f                   	pop    %edi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	57                   	push   %edi
  801293:	56                   	push   %esi
  801294:	53                   	push   %ebx
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	8b 7d 08             	mov    0x8(%ebp),%edi
  80129b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80129e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  8012a1:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  8012a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8012a8:	0f 44 d8             	cmove  %eax,%ebx
  8012ab:	eb 1c                	jmp    8012c9 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8012ad:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012b0:	74 12                	je     8012c4 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  8012b2:	50                   	push   %eax
  8012b3:	68 a3 28 80 00       	push   $0x8028a3
  8012b8:	6a 4e                	push   $0x4e
  8012ba:	68 b0 28 80 00       	push   $0x8028b0
  8012bf:	e8 80 ef ff ff       	call   800244 <_panic>
		sys_yield();
  8012c4:	e8 3c fa ff ff       	call   800d05 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8012c9:	ff 75 14             	pushl  0x14(%ebp)
  8012cc:	53                   	push   %ebx
  8012cd:	56                   	push   %esi
  8012ce:	57                   	push   %edi
  8012cf:	e8 dd fb ff ff       	call   800eb1 <sys_ipc_try_send>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 d2                	js     8012ad <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  8012db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012ee:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012f1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012f7:	8b 52 50             	mov    0x50(%edx),%edx
  8012fa:	39 ca                	cmp    %ecx,%edx
  8012fc:	75 0d                	jne    80130b <ipc_find_env+0x28>
			return envs[i].env_id;
  8012fe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801301:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801306:	8b 40 48             	mov    0x48(%eax),%eax
  801309:	eb 0f                	jmp    80131a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80130b:	83 c0 01             	add    $0x1,%eax
  80130e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801313:	75 d9                	jne    8012ee <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801315:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
  801322:	05 00 00 00 30       	add    $0x30000000,%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
}
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	05 00 00 00 30       	add    $0x30000000,%eax
  801337:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801349:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134e:	89 c2                	mov    %eax,%edx
  801350:	c1 ea 16             	shr    $0x16,%edx
  801353:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135a:	f6 c2 01             	test   $0x1,%dl
  80135d:	74 11                	je     801370 <fd_alloc+0x2d>
  80135f:	89 c2                	mov    %eax,%edx
  801361:	c1 ea 0c             	shr    $0xc,%edx
  801364:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136b:	f6 c2 01             	test   $0x1,%dl
  80136e:	75 09                	jne    801379 <fd_alloc+0x36>
			*fd_store = fd;
  801370:	89 01                	mov    %eax,(%ecx)
			return 0;
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
  801377:	eb 17                	jmp    801390 <fd_alloc+0x4d>
  801379:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80137e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801383:	75 c9                	jne    80134e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801385:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80138b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801398:	83 f8 1f             	cmp    $0x1f,%eax
  80139b:	77 36                	ja     8013d3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139d:	c1 e0 0c             	shl    $0xc,%eax
  8013a0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 16             	shr    $0x16,%edx
  8013aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	74 24                	je     8013da <fd_lookup+0x48>
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 ea 0c             	shr    $0xc,%edx
  8013bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	74 1a                	je     8013e1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8013cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d1:	eb 13                	jmp    8013e6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb 0c                	jmp    8013e6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013df:	eb 05                	jmp    8013e6 <fd_lookup+0x54>
  8013e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f1:	ba 3c 29 80 00       	mov    $0x80293c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f6:	eb 13                	jmp    80140b <dev_lookup+0x23>
  8013f8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013fb:	39 08                	cmp    %ecx,(%eax)
  8013fd:	75 0c                	jne    80140b <dev_lookup+0x23>
			*dev = devtab[i];
  8013ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801402:	89 01                	mov    %eax,(%ecx)
			return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	eb 2e                	jmp    801439 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80140b:	8b 02                	mov    (%edx),%eax
  80140d:	85 c0                	test   %eax,%eax
  80140f:	75 e7                	jne    8013f8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801411:	a1 04 40 80 00       	mov    0x804004,%eax
  801416:	8b 40 48             	mov    0x48(%eax),%eax
  801419:	83 ec 04             	sub    $0x4,%esp
  80141c:	51                   	push   %ecx
  80141d:	50                   	push   %eax
  80141e:	68 bc 28 80 00       	push   $0x8028bc
  801423:	e8 f5 ee ff ff       	call   80031d <cprintf>
	*dev = 0;
  801428:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	83 ec 10             	sub    $0x10,%esp
  801443:	8b 75 08             	mov    0x8(%ebp),%esi
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801453:	c1 e8 0c             	shr    $0xc,%eax
  801456:	50                   	push   %eax
  801457:	e8 36 ff ff ff       	call   801392 <fd_lookup>
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 05                	js     801468 <fd_close+0x2d>
	    || fd != fd2)
  801463:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801466:	74 0c                	je     801474 <fd_close+0x39>
		return (must_exist ? r : 0);
  801468:	84 db                	test   %bl,%bl
  80146a:	ba 00 00 00 00       	mov    $0x0,%edx
  80146f:	0f 44 c2             	cmove  %edx,%eax
  801472:	eb 41                	jmp    8014b5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 36                	pushl  (%esi)
  80147d:	e8 66 ff ff ff       	call   8013e8 <dev_lookup>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 1a                	js     8014a5 <fd_close+0x6a>
		if (dev->dev_close)
  80148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801491:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801496:	85 c0                	test   %eax,%eax
  801498:	74 0b                	je     8014a5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80149a:	83 ec 0c             	sub    $0xc,%esp
  80149d:	56                   	push   %esi
  80149e:	ff d0                	call   *%eax
  8014a0:	89 c3                	mov    %eax,%ebx
  8014a2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	56                   	push   %esi
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 f9 f8 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	89 d8                	mov    %ebx,%eax
}
  8014b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	pushl  0x8(%ebp)
  8014c9:	e8 c4 fe ff ff       	call   801392 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 10                	js     8014e5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	6a 01                	push   $0x1
  8014da:	ff 75 f4             	pushl  -0xc(%ebp)
  8014dd:	e8 59 ff ff ff       	call   80143b <fd_close>
  8014e2:	83 c4 10             	add    $0x10,%esp
}
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <close_all>:

void
close_all(void)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	53                   	push   %ebx
  8014f7:	e8 c0 ff ff ff       	call   8014bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014fc:	83 c3 01             	add    $0x1,%ebx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	83 fb 20             	cmp    $0x20,%ebx
  801505:	75 ec                	jne    8014f3 <close_all+0xc>
		close(i);
}
  801507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	57                   	push   %edi
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	83 ec 2c             	sub    $0x2c,%esp
  801515:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801518:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	ff 75 08             	pushl  0x8(%ebp)
  80151f:	e8 6e fe ff ff       	call   801392 <fd_lookup>
  801524:	83 c4 08             	add    $0x8,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	0f 88 c1 00 00 00    	js     8015f0 <dup+0xe4>
		return r;
	close(newfdnum);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	56                   	push   %esi
  801533:	e8 84 ff ff ff       	call   8014bc <close>

	newfd = INDEX2FD(newfdnum);
  801538:	89 f3                	mov    %esi,%ebx
  80153a:	c1 e3 0c             	shl    $0xc,%ebx
  80153d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801543:	83 c4 04             	add    $0x4,%esp
  801546:	ff 75 e4             	pushl  -0x1c(%ebp)
  801549:	e8 de fd ff ff       	call   80132c <fd2data>
  80154e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801550:	89 1c 24             	mov    %ebx,(%esp)
  801553:	e8 d4 fd ff ff       	call   80132c <fd2data>
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155e:	89 f8                	mov    %edi,%eax
  801560:	c1 e8 16             	shr    $0x16,%eax
  801563:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156a:	a8 01                	test   $0x1,%al
  80156c:	74 37                	je     8015a5 <dup+0x99>
  80156e:	89 f8                	mov    %edi,%eax
  801570:	c1 e8 0c             	shr    $0xc,%eax
  801573:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80157a:	f6 c2 01             	test   $0x1,%dl
  80157d:	74 26                	je     8015a5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	25 07 0e 00 00       	and    $0xe07,%eax
  80158e:	50                   	push   %eax
  80158f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801592:	6a 00                	push   $0x0
  801594:	57                   	push   %edi
  801595:	6a 00                	push   $0x0
  801597:	e8 cb f7 ff ff       	call   800d67 <sys_page_map>
  80159c:	89 c7                	mov    %eax,%edi
  80159e:	83 c4 20             	add    $0x20,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 2e                	js     8015d3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a8:	89 d0                	mov    %edx,%eax
  8015aa:	c1 e8 0c             	shr    $0xc,%eax
  8015ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015bc:	50                   	push   %eax
  8015bd:	53                   	push   %ebx
  8015be:	6a 00                	push   $0x0
  8015c0:	52                   	push   %edx
  8015c1:	6a 00                	push   $0x0
  8015c3:	e8 9f f7 ff ff       	call   800d67 <sys_page_map>
  8015c8:	89 c7                	mov    %eax,%edi
  8015ca:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015cd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cf:	85 ff                	test   %edi,%edi
  8015d1:	79 1d                	jns    8015f0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	53                   	push   %ebx
  8015d7:	6a 00                	push   $0x0
  8015d9:	e8 cb f7 ff ff       	call   800da9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015de:	83 c4 08             	add    $0x8,%esp
  8015e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e4:	6a 00                	push   $0x0
  8015e6:	e8 be f7 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	89 f8                	mov    %edi,%eax
}
  8015f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f3:	5b                   	pop    %ebx
  8015f4:	5e                   	pop    %esi
  8015f5:	5f                   	pop    %edi
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 14             	sub    $0x14,%esp
  8015ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	53                   	push   %ebx
  801607:	e8 86 fd ff ff       	call   801392 <fd_lookup>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	89 c2                	mov    %eax,%edx
  801611:	85 c0                	test   %eax,%eax
  801613:	78 6d                	js     801682 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	ff 30                	pushl  (%eax)
  801621:	e8 c2 fd ff ff       	call   8013e8 <dev_lookup>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 4c                	js     801679 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80162d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801630:	8b 42 08             	mov    0x8(%edx),%eax
  801633:	83 e0 03             	and    $0x3,%eax
  801636:	83 f8 01             	cmp    $0x1,%eax
  801639:	75 21                	jne    80165c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163b:	a1 04 40 80 00       	mov    0x804004,%eax
  801640:	8b 40 48             	mov    0x48(%eax),%eax
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	53                   	push   %ebx
  801647:	50                   	push   %eax
  801648:	68 00 29 80 00       	push   $0x802900
  80164d:	e8 cb ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165a:	eb 26                	jmp    801682 <read+0x8a>
	}
	if (!dev->dev_read)
  80165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165f:	8b 40 08             	mov    0x8(%eax),%eax
  801662:	85 c0                	test   %eax,%eax
  801664:	74 17                	je     80167d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	52                   	push   %edx
  801670:	ff d0                	call   *%eax
  801672:	89 c2                	mov    %eax,%edx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb 09                	jmp    801682 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	89 c2                	mov    %eax,%edx
  80167b:	eb 05                	jmp    801682 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80167d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801682:	89 d0                	mov    %edx,%eax
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	57                   	push   %edi
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	8b 7d 08             	mov    0x8(%ebp),%edi
  801695:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	eb 21                	jmp    8016c0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	89 f0                	mov    %esi,%eax
  8016a4:	29 d8                	sub    %ebx,%eax
  8016a6:	50                   	push   %eax
  8016a7:	89 d8                	mov    %ebx,%eax
  8016a9:	03 45 0c             	add    0xc(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	57                   	push   %edi
  8016ae:	e8 45 ff ff ff       	call   8015f8 <read>
		if (m < 0)
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 10                	js     8016ca <readn+0x41>
			return m;
		if (m == 0)
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	74 0a                	je     8016c8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016be:	01 c3                	add    %eax,%ebx
  8016c0:	39 f3                	cmp    %esi,%ebx
  8016c2:	72 db                	jb     80169f <readn+0x16>
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	eb 02                	jmp    8016ca <readn+0x41>
  8016c8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 14             	sub    $0x14,%esp
  8016d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	53                   	push   %ebx
  8016e1:	e8 ac fc ff ff       	call   801392 <fd_lookup>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 68                	js     801757 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	ff 30                	pushl  (%eax)
  8016fb:	e8 e8 fc ff ff       	call   8013e8 <dev_lookup>
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 47                	js     80174e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170e:	75 21                	jne    801731 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801710:	a1 04 40 80 00       	mov    0x804004,%eax
  801715:	8b 40 48             	mov    0x48(%eax),%eax
  801718:	83 ec 04             	sub    $0x4,%esp
  80171b:	53                   	push   %ebx
  80171c:	50                   	push   %eax
  80171d:	68 1c 29 80 00       	push   $0x80291c
  801722:	e8 f6 eb ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172f:	eb 26                	jmp    801757 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801731:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801734:	8b 52 0c             	mov    0xc(%edx),%edx
  801737:	85 d2                	test   %edx,%edx
  801739:	74 17                	je     801752 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	ff 75 10             	pushl  0x10(%ebp)
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	50                   	push   %eax
  801745:	ff d2                	call   *%edx
  801747:	89 c2                	mov    %eax,%edx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	eb 09                	jmp    801757 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174e:	89 c2                	mov    %eax,%edx
  801750:	eb 05                	jmp    801757 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801752:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801757:	89 d0                	mov    %edx,%eax
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <seek>:

int
seek(int fdnum, off_t offset)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801764:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801767:	50                   	push   %eax
  801768:	ff 75 08             	pushl  0x8(%ebp)
  80176b:	e8 22 fc ff ff       	call   801392 <fd_lookup>
  801770:	83 c4 08             	add    $0x8,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 0e                	js     801785 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801777:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80177a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 14             	sub    $0x14,%esp
  80178e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801791:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	53                   	push   %ebx
  801796:	e8 f7 fb ff ff       	call   801392 <fd_lookup>
  80179b:	83 c4 08             	add    $0x8,%esp
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 65                	js     801809 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ae:	ff 30                	pushl  (%eax)
  8017b0:	e8 33 fc ff ff       	call   8013e8 <dev_lookup>
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 44                	js     801800 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c3:	75 21                	jne    8017e6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ca:	8b 40 48             	mov    0x48(%eax),%eax
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	53                   	push   %ebx
  8017d1:	50                   	push   %eax
  8017d2:	68 dc 28 80 00       	push   $0x8028dc
  8017d7:	e8 41 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e4:	eb 23                	jmp    801809 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e9:	8b 52 18             	mov    0x18(%edx),%edx
  8017ec:	85 d2                	test   %edx,%edx
  8017ee:	74 14                	je     801804 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	ff 75 0c             	pushl  0xc(%ebp)
  8017f6:	50                   	push   %eax
  8017f7:	ff d2                	call   *%edx
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	eb 09                	jmp    801809 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801800:	89 c2                	mov    %eax,%edx
  801802:	eb 05                	jmp    801809 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801804:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801809:	89 d0                	mov    %edx,%eax
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	53                   	push   %ebx
  801814:	83 ec 14             	sub    $0x14,%esp
  801817:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	ff 75 08             	pushl  0x8(%ebp)
  801821:	e8 6c fb ff ff       	call   801392 <fd_lookup>
  801826:	83 c4 08             	add    $0x8,%esp
  801829:	89 c2                	mov    %eax,%edx
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 58                	js     801887 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	ff 30                	pushl  (%eax)
  80183b:	e8 a8 fb ff ff       	call   8013e8 <dev_lookup>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 37                	js     80187e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184e:	74 32                	je     801882 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185a:	00 00 00 
	stat->st_isdir = 0;
  80185d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801864:	00 00 00 
	stat->st_dev = dev;
  801867:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	53                   	push   %ebx
  801871:	ff 75 f0             	pushl  -0x10(%ebp)
  801874:	ff 50 14             	call   *0x14(%eax)
  801877:	89 c2                	mov    %eax,%edx
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	eb 09                	jmp    801887 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187e:	89 c2                	mov    %eax,%edx
  801880:	eb 05                	jmp    801887 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801882:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801887:	89 d0                	mov    %edx,%eax
  801889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	6a 00                	push   $0x0
  801898:	ff 75 08             	pushl  0x8(%ebp)
  80189b:	e8 e9 01 00 00       	call   801a89 <open>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 1b                	js     8018c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	50                   	push   %eax
  8018b0:	e8 5b ff ff ff       	call   801810 <fstat>
  8018b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b7:	89 1c 24             	mov    %ebx,(%esp)
  8018ba:	e8 fd fb ff ff       	call   8014bc <close>
	return r;
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	89 f0                	mov    %esi,%eax
}
  8018c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	89 c6                	mov    %eax,%esi
  8018d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018db:	75 12                	jne    8018ef <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	6a 01                	push   $0x1
  8018e2:	e8 fc f9 ff ff       	call   8012e3 <ipc_find_env>
  8018e7:	a3 00 40 80 00       	mov    %eax,0x804000
  8018ec:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ef:	6a 07                	push   $0x7
  8018f1:	68 00 50 80 00       	push   $0x805000
  8018f6:	56                   	push   %esi
  8018f7:	ff 35 00 40 80 00    	pushl  0x804000
  8018fd:	e8 8d f9 ff ff       	call   80128f <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801902:	83 c4 0c             	add    $0xc,%esp
  801905:	6a 00                	push   $0x0
  801907:	53                   	push   %ebx
  801908:	6a 00                	push   $0x0
  80190a:	e8 fe f8 ff ff       	call   80120d <ipc_recv>
}
  80190f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192f:	ba 00 00 00 00       	mov    $0x0,%edx
  801934:	b8 02 00 00 00       	mov    $0x2,%eax
  801939:	e8 8d ff ff ff       	call   8018cb <fsipc>
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 40 0c             	mov    0xc(%eax),%eax
  80194c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	b8 06 00 00 00       	mov    $0x6,%eax
  80195b:	e8 6b ff ff ff       	call   8018cb <fsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	8b 40 0c             	mov    0xc(%eax),%eax
  801972:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 05 00 00 00       	mov    $0x5,%eax
  801981:	e8 45 ff ff ff       	call   8018cb <fsipc>
  801986:	85 c0                	test   %eax,%eax
  801988:	78 2c                	js     8019b6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	68 00 50 80 00       	push   $0x805000
  801992:	53                   	push   %ebx
  801993:	e8 89 ef ff ff       	call   800921 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801998:	a1 80 50 80 00       	mov    0x805080,%eax
  80199d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a3:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019c9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019ce:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8019d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8019d7:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8019dd:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8019e2:	50                   	push   %eax
  8019e3:	ff 75 0c             	pushl  0xc(%ebp)
  8019e6:	68 08 50 80 00       	push   $0x805008
  8019eb:	e8 c3 f0 ff ff       	call   800ab3 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8019fa:	e8 cc fe ff ff       	call   8018cb <fsipc>
            return r;

    return r;
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a14:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1f:	b8 03 00 00 00       	mov    $0x3,%eax
  801a24:	e8 a2 fe ff ff       	call   8018cb <fsipc>
  801a29:	89 c3                	mov    %eax,%ebx
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 51                	js     801a80 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801a2f:	39 c6                	cmp    %eax,%esi
  801a31:	73 19                	jae    801a4c <devfile_read+0x4b>
  801a33:	68 4c 29 80 00       	push   $0x80294c
  801a38:	68 53 29 80 00       	push   $0x802953
  801a3d:	68 82 00 00 00       	push   $0x82
  801a42:	68 68 29 80 00       	push   $0x802968
  801a47:	e8 f8 e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a4c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a51:	7e 19                	jle    801a6c <devfile_read+0x6b>
  801a53:	68 73 29 80 00       	push   $0x802973
  801a58:	68 53 29 80 00       	push   $0x802953
  801a5d:	68 83 00 00 00       	push   $0x83
  801a62:	68 68 29 80 00       	push   $0x802968
  801a67:	e8 d8 e7 ff ff       	call   800244 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	50                   	push   %eax
  801a70:	68 00 50 80 00       	push   $0x805000
  801a75:	ff 75 0c             	pushl  0xc(%ebp)
  801a78:	e8 36 f0 ff ff       	call   800ab3 <memmove>
	return r;
  801a7d:	83 c4 10             	add    $0x10,%esp
}
  801a80:	89 d8                	mov    %ebx,%eax
  801a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 20             	sub    $0x20,%esp
  801a90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a93:	53                   	push   %ebx
  801a94:	e8 4f ee ff ff       	call   8008e8 <strlen>
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa1:	7f 67                	jg     801b0a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	e8 94 f8 ff ff       	call   801343 <fd_alloc>
  801aaf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 57                	js     801b0f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	53                   	push   %ebx
  801abc:	68 00 50 80 00       	push   $0x805000
  801ac1:	e8 5b ee ff ff       	call   800921 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad6:	e8 f0 fd ff ff       	call   8018cb <fsipc>
  801adb:	89 c3                	mov    %eax,%ebx
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	79 14                	jns    801af8 <open+0x6f>
		fd_close(fd, 0);
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	6a 00                	push   $0x0
  801ae9:	ff 75 f4             	pushl  -0xc(%ebp)
  801aec:	e8 4a f9 ff ff       	call   80143b <fd_close>
		return r;
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	89 da                	mov    %ebx,%edx
  801af6:	eb 17                	jmp    801b0f <open+0x86>
	}

	return fd2num(fd);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 f4             	pushl  -0xc(%ebp)
  801afe:	e8 19 f8 ff ff       	call   80131c <fd2num>
  801b03:	89 c2                	mov    %eax,%edx
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	eb 05                	jmp    801b0f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b0a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b0f:	89 d0                	mov    %edx,%eax
  801b11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b21:	b8 08 00 00 00       	mov    $0x8,%eax
  801b26:	e8 a0 fd ff ff       	call   8018cb <fsipc>
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	c1 e8 16             	shr    $0x16,%eax
  801b38:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b44:	f6 c1 01             	test   $0x1,%cl
  801b47:	74 1d                	je     801b66 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b49:	c1 ea 0c             	shr    $0xc,%edx
  801b4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b53:	f6 c2 01             	test   $0x1,%dl
  801b56:	74 0e                	je     801b66 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b58:	c1 ea 0c             	shr    $0xc,%edx
  801b5b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b62:	ef 
  801b63:	0f b7 c0             	movzwl %ax,%eax
}
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	ff 75 08             	pushl  0x8(%ebp)
  801b76:	e8 b1 f7 ff ff       	call   80132c <fd2data>
  801b7b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b7d:	83 c4 08             	add    $0x8,%esp
  801b80:	68 7f 29 80 00       	push   $0x80297f
  801b85:	53                   	push   %ebx
  801b86:	e8 96 ed ff ff       	call   800921 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b8b:	8b 46 04             	mov    0x4(%esi),%eax
  801b8e:	2b 06                	sub    (%esi),%eax
  801b90:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b96:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b9d:	00 00 00 
	stat->st_dev = &devpipe;
  801ba0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba7:	30 80 00 
	return 0;
}
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
  801baf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb2:	5b                   	pop    %ebx
  801bb3:	5e                   	pop    %esi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    

00801bb6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	53                   	push   %ebx
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bc0:	53                   	push   %ebx
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 e1 f1 ff ff       	call   800da9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc8:	89 1c 24             	mov    %ebx,(%esp)
  801bcb:	e8 5c f7 ff ff       	call   80132c <fd2data>
  801bd0:	83 c4 08             	add    $0x8,%esp
  801bd3:	50                   	push   %eax
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 ce f1 ff ff       	call   800da9 <sys_page_unmap>
}
  801bdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	57                   	push   %edi
  801be4:	56                   	push   %esi
  801be5:	53                   	push   %ebx
  801be6:	83 ec 1c             	sub    $0x1c,%esp
  801be9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bec:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bee:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	ff 75 e0             	pushl  -0x20(%ebp)
  801bfc:	e8 2c ff ff ff       	call   801b2d <pageref>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	89 3c 24             	mov    %edi,(%esp)
  801c06:	e8 22 ff ff ff       	call   801b2d <pageref>
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	39 c3                	cmp    %eax,%ebx
  801c10:	0f 94 c1             	sete   %cl
  801c13:	0f b6 c9             	movzbl %cl,%ecx
  801c16:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c19:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c1f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c22:	39 ce                	cmp    %ecx,%esi
  801c24:	74 1b                	je     801c41 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c26:	39 c3                	cmp    %eax,%ebx
  801c28:	75 c4                	jne    801bee <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c2a:	8b 42 58             	mov    0x58(%edx),%eax
  801c2d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c30:	50                   	push   %eax
  801c31:	56                   	push   %esi
  801c32:	68 86 29 80 00       	push   $0x802986
  801c37:	e8 e1 e6 ff ff       	call   80031d <cprintf>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	eb ad                	jmp    801bee <_pipeisclosed+0xe>
	}
}
  801c41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5f                   	pop    %edi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	83 ec 28             	sub    $0x28,%esp
  801c55:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c58:	56                   	push   %esi
  801c59:	e8 ce f6 ff ff       	call   80132c <fd2data>
  801c5e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	bf 00 00 00 00       	mov    $0x0,%edi
  801c68:	eb 4b                	jmp    801cb5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c6a:	89 da                	mov    %ebx,%edx
  801c6c:	89 f0                	mov    %esi,%eax
  801c6e:	e8 6d ff ff ff       	call   801be0 <_pipeisclosed>
  801c73:	85 c0                	test   %eax,%eax
  801c75:	75 48                	jne    801cbf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c77:	e8 89 f0 ff ff       	call   800d05 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7f:	8b 0b                	mov    (%ebx),%ecx
  801c81:	8d 51 20             	lea    0x20(%ecx),%edx
  801c84:	39 d0                	cmp    %edx,%eax
  801c86:	73 e2                	jae    801c6a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c8f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	c1 fa 1f             	sar    $0x1f,%edx
  801c97:	89 d1                	mov    %edx,%ecx
  801c99:	c1 e9 1b             	shr    $0x1b,%ecx
  801c9c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c9f:	83 e2 1f             	and    $0x1f,%edx
  801ca2:	29 ca                	sub    %ecx,%edx
  801ca4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cac:	83 c0 01             	add    $0x1,%eax
  801caf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb2:	83 c7 01             	add    $0x1,%edi
  801cb5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb8:	75 c2                	jne    801c7c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cba:	8b 45 10             	mov    0x10(%ebp),%eax
  801cbd:	eb 05                	jmp    801cc4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cbf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 18             	sub    $0x18,%esp
  801cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cd8:	57                   	push   %edi
  801cd9:	e8 4e f6 ff ff       	call   80132c <fd2data>
  801cde:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce8:	eb 3d                	jmp    801d27 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cea:	85 db                	test   %ebx,%ebx
  801cec:	74 04                	je     801cf2 <devpipe_read+0x26>
				return i;
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	eb 44                	jmp    801d36 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	89 f8                	mov    %edi,%eax
  801cf6:	e8 e5 fe ff ff       	call   801be0 <_pipeisclosed>
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	75 32                	jne    801d31 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cff:	e8 01 f0 ff ff       	call   800d05 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d04:	8b 06                	mov    (%esi),%eax
  801d06:	3b 46 04             	cmp    0x4(%esi),%eax
  801d09:	74 df                	je     801cea <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d0b:	99                   	cltd   
  801d0c:	c1 ea 1b             	shr    $0x1b,%edx
  801d0f:	01 d0                	add    %edx,%eax
  801d11:	83 e0 1f             	and    $0x1f,%eax
  801d14:	29 d0                	sub    %edx,%eax
  801d16:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d1e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d21:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d24:	83 c3 01             	add    $0x1,%ebx
  801d27:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d2a:	75 d8                	jne    801d04 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2f:	eb 05                	jmp    801d36 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d39:	5b                   	pop    %ebx
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	56                   	push   %esi
  801d42:	53                   	push   %ebx
  801d43:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d49:	50                   	push   %eax
  801d4a:	e8 f4 f5 ff ff       	call   801343 <fd_alloc>
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	85 c0                	test   %eax,%eax
  801d56:	0f 88 2c 01 00 00    	js     801e88 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5c:	83 ec 04             	sub    $0x4,%esp
  801d5f:	68 07 04 00 00       	push   $0x407
  801d64:	ff 75 f4             	pushl  -0xc(%ebp)
  801d67:	6a 00                	push   $0x0
  801d69:	e8 b6 ef ff ff       	call   800d24 <sys_page_alloc>
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	89 c2                	mov    %eax,%edx
  801d73:	85 c0                	test   %eax,%eax
  801d75:	0f 88 0d 01 00 00    	js     801e88 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d7b:	83 ec 0c             	sub    $0xc,%esp
  801d7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d81:	50                   	push   %eax
  801d82:	e8 bc f5 ff ff       	call   801343 <fd_alloc>
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	0f 88 e2 00 00 00    	js     801e76 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	68 07 04 00 00       	push   $0x407
  801d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 7e ef ff ff       	call   800d24 <sys_page_alloc>
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	0f 88 c3 00 00 00    	js     801e76 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff 75 f4             	pushl  -0xc(%ebp)
  801db9:	e8 6e f5 ff ff       	call   80132c <fd2data>
  801dbe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc0:	83 c4 0c             	add    $0xc,%esp
  801dc3:	68 07 04 00 00       	push   $0x407
  801dc8:	50                   	push   %eax
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 54 ef ff ff       	call   800d24 <sys_page_alloc>
  801dd0:	89 c3                	mov    %eax,%ebx
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	0f 88 89 00 00 00    	js     801e66 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	ff 75 f0             	pushl  -0x10(%ebp)
  801de3:	e8 44 f5 ff ff       	call   80132c <fd2data>
  801de8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801def:	50                   	push   %eax
  801df0:	6a 00                	push   $0x0
  801df2:	56                   	push   %esi
  801df3:	6a 00                	push   $0x0
  801df5:	e8 6d ef ff ff       	call   800d67 <sys_page_map>
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	83 c4 20             	add    $0x20,%esp
  801dff:	85 c0                	test   %eax,%eax
  801e01:	78 55                	js     801e58 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	ff 75 f4             	pushl  -0xc(%ebp)
  801e33:	e8 e4 f4 ff ff       	call   80131c <fd2num>
  801e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e3d:	83 c4 04             	add    $0x4,%esp
  801e40:	ff 75 f0             	pushl  -0x10(%ebp)
  801e43:	e8 d4 f4 ff ff       	call   80131c <fd2num>
  801e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	ba 00 00 00 00       	mov    $0x0,%edx
  801e56:	eb 30                	jmp    801e88 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e58:	83 ec 08             	sub    $0x8,%esp
  801e5b:	56                   	push   %esi
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 46 ef ff ff       	call   800da9 <sys_page_unmap>
  801e63:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e66:	83 ec 08             	sub    $0x8,%esp
  801e69:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 36 ef ff ff       	call   800da9 <sys_page_unmap>
  801e73:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e76:	83 ec 08             	sub    $0x8,%esp
  801e79:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 26 ef ff ff       	call   800da9 <sys_page_unmap>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e88:	89 d0                	mov    %edx,%eax
  801e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9a:	50                   	push   %eax
  801e9b:	ff 75 08             	pushl  0x8(%ebp)
  801e9e:	e8 ef f4 ff ff       	call   801392 <fd_lookup>
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	78 18                	js     801ec2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb0:	e8 77 f4 ff ff       	call   80132c <fd2data>
	return _pipeisclosed(fd, p);
  801eb5:	89 c2                	mov    %eax,%edx
  801eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eba:	e8 21 fd ff ff       	call   801be0 <_pipeisclosed>
  801ebf:	83 c4 10             	add    $0x10,%esp
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ed4:	68 9e 29 80 00       	push   $0x80299e
  801ed9:	ff 75 0c             	pushl  0xc(%ebp)
  801edc:	e8 40 ea ff ff       	call   800921 <strcpy>
	return 0;
}
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	57                   	push   %edi
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eff:	eb 2d                	jmp    801f2e <devcons_write+0x46>
		m = n - tot;
  801f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f04:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f06:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f09:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f0e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f11:	83 ec 04             	sub    $0x4,%esp
  801f14:	53                   	push   %ebx
  801f15:	03 45 0c             	add    0xc(%ebp),%eax
  801f18:	50                   	push   %eax
  801f19:	57                   	push   %edi
  801f1a:	e8 94 eb ff ff       	call   800ab3 <memmove>
		sys_cputs(buf, m);
  801f1f:	83 c4 08             	add    $0x8,%esp
  801f22:	53                   	push   %ebx
  801f23:	57                   	push   %edi
  801f24:	e8 3f ed ff ff       	call   800c68 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f29:	01 de                	add    %ebx,%esi
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	89 f0                	mov    %esi,%eax
  801f30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f33:	72 cc                	jb     801f01 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 08             	sub    $0x8,%esp
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f4c:	74 2a                	je     801f78 <devcons_read+0x3b>
  801f4e:	eb 05                	jmp    801f55 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f50:	e8 b0 ed ff ff       	call   800d05 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f55:	e8 2c ed ff ff       	call   800c86 <sys_cgetc>
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	74 f2                	je     801f50 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 16                	js     801f78 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f62:	83 f8 04             	cmp    $0x4,%eax
  801f65:	74 0c                	je     801f73 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6a:	88 02                	mov    %al,(%edx)
	return 1;
  801f6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f71:	eb 05                	jmp    801f78 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f78:	c9                   	leave  
  801f79:	c3                   	ret    

00801f7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f80:	8b 45 08             	mov    0x8(%ebp),%eax
  801f83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f86:	6a 01                	push   $0x1
  801f88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8b:	50                   	push   %eax
  801f8c:	e8 d7 ec ff ff       	call   800c68 <sys_cputs>
}
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <getchar>:

int
getchar(void)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f9c:	6a 01                	push   $0x1
  801f9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa1:	50                   	push   %eax
  801fa2:	6a 00                	push   $0x0
  801fa4:	e8 4f f6 ff ff       	call   8015f8 <read>
	if (r < 0)
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 0f                	js     801fbf <getchar+0x29>
		return r;
	if (r < 1)
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	7e 06                	jle    801fba <getchar+0x24>
		return -E_EOF;
	return c;
  801fb4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fb8:	eb 05                	jmp    801fbf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fca:	50                   	push   %eax
  801fcb:	ff 75 08             	pushl  0x8(%ebp)
  801fce:	e8 bf f3 ff ff       	call   801392 <fd_lookup>
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 11                	js     801feb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe3:	39 10                	cmp    %edx,(%eax)
  801fe5:	0f 94 c0             	sete   %al
  801fe8:	0f b6 c0             	movzbl %al,%eax
}
  801feb:	c9                   	leave  
  801fec:	c3                   	ret    

00801fed <opencons>:

int
opencons(void)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff6:	50                   	push   %eax
  801ff7:	e8 47 f3 ff ff       	call   801343 <fd_alloc>
  801ffc:	83 c4 10             	add    $0x10,%esp
		return r;
  801fff:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802001:	85 c0                	test   %eax,%eax
  802003:	78 3e                	js     802043 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802005:	83 ec 04             	sub    $0x4,%esp
  802008:	68 07 04 00 00       	push   $0x407
  80200d:	ff 75 f4             	pushl  -0xc(%ebp)
  802010:	6a 00                	push   $0x0
  802012:	e8 0d ed ff ff       	call   800d24 <sys_page_alloc>
  802017:	83 c4 10             	add    $0x10,%esp
		return r;
  80201a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80201c:	85 c0                	test   %eax,%eax
  80201e:	78 23                	js     802043 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802026:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802029:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80202b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	50                   	push   %eax
  802039:	e8 de f2 ff ff       	call   80131c <fd2num>
  80203e:	89 c2                	mov    %eax,%edx
  802040:	83 c4 10             	add    $0x10,%esp
}
  802043:	89 d0                	mov    %edx,%eax
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	53                   	push   %ebx
  80204b:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  80204e:	e8 93 ec ff ff       	call   800ce6 <sys_getenvid>
  802053:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  802055:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80205c:	75 29                	jne    802087 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  80205e:	83 ec 04             	sub    $0x4,%esp
  802061:	6a 07                	push   $0x7
  802063:	68 00 f0 bf ee       	push   $0xeebff000
  802068:	50                   	push   %eax
  802069:	e8 b6 ec ff ff       	call   800d24 <sys_page_alloc>
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	79 12                	jns    802087 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  802075:	50                   	push   %eax
  802076:	68 aa 29 80 00       	push   $0x8029aa
  80207b:	6a 24                	push   $0x24
  80207d:	68 c3 29 80 00       	push   $0x8029c3
  802082:	e8 bd e1 ff ff       	call   800244 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  802087:	8b 45 08             	mov    0x8(%ebp),%eax
  80208a:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80208f:	83 ec 08             	sub    $0x8,%esp
  802092:	68 bb 20 80 00       	push   $0x8020bb
  802097:	53                   	push   %ebx
  802098:	e8 d2 ed ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	79 12                	jns    8020b6 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  8020a4:	50                   	push   %eax
  8020a5:	68 aa 29 80 00       	push   $0x8029aa
  8020aa:	6a 2e                	push   $0x2e
  8020ac:	68 c3 29 80 00       	push   $0x8029c3
  8020b1:	e8 8e e1 ff ff       	call   800244 <_panic>
}
  8020b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020bb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020bc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020c1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020c3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  8020c6:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8020ca:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  8020cd:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8020d1:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  8020d3:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8020d7:	83 c4 08             	add    $0x8,%esp
	popal
  8020da:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8020db:	83 c4 04             	add    $0x4,%esp
	popfl
  8020de:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  8020df:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020e0:	c3                   	ret    
  8020e1:	66 90                	xchg   %ax,%ax
  8020e3:	66 90                	xchg   %ax,%ax
  8020e5:	66 90                	xchg   %ax,%ax
  8020e7:	66 90                	xchg   %ax,%ax
  8020e9:	66 90                	xchg   %ax,%ax
  8020eb:	66 90                	xchg   %ax,%ax
  8020ed:	66 90                	xchg   %ax,%ax
  8020ef:	90                   	nop

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
