
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 a0 18 00 00       	call   8018ef <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 96 18 00 00       	call   8018ef <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 85 0e 00 00       	call   800f08 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 f7 16 00 00       	call   801789 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 3a 2b 80 00       	push   $0x802b3a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 50 0e 00 00       	call   800f08 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 c2 16 00 00       	call   801789 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 35 2b 80 00       	push   $0x802b35
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 52 15 00 00       	call   80164d <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 46 15 00 00       	call   80164d <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 48 2b 80 00       	push   $0x802b48
  80011b:	e8 fa 1a 00 00       	call   801c1a <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 55 2b 80 00       	push   $0x802b55
  80012f:	6a 13                	push   $0x13
  800131:	68 6b 2b 80 00       	push   $0x802b6b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 2b 23 00 00       	call   802472 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 7c 2b 80 00       	push   $0x802b7c
  800154:	6a 15                	push   $0x15
  800156:	68 6b 2b 80 00       	push   $0x802b6b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 e4 2a 80 00       	push   $0x802ae4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 3a 11 00 00       	call   8012af <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 85 2b 80 00       	push   $0x802b85
  800182:	6a 1a                	push   $0x1a
  800184:	68 6b 2b 80 00       	push   $0x802b6b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 00 15 00 00       	call   80169d <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 f5 14 00 00       	call   80169d <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 9d 14 00 00       	call   80164d <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 95 14 00 00       	call   80164d <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 8e 2b 80 00       	push   $0x802b8e
  8001bf:	68 52 2b 80 00       	push   $0x802b52
  8001c4:	68 91 2b 80 00       	push   $0x802b91
  8001c9:	e8 5b 20 00 00       	call   802229 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 95 2b 80 00       	push   $0x802b95
  8001dd:	6a 21                	push   $0x21
  8001df:	68 6b 2b 80 00       	push   $0x802b6b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 5a 14 00 00       	call   80164d <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 4e 14 00 00       	call   80164d <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 f1 23 00 00       	call   8025f8 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 35 14 00 00       	call   80164d <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 2d 14 00 00       	call   80164d <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 9f 2b 80 00       	push   $0x802b9f
  800230:	e8 e5 19 00 00       	call   801c1a <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 08 2b 80 00       	push   $0x802b08
  800245:	6a 2c                	push   $0x2c
  800247:	68 6b 2b 80 00       	push   $0x802b6b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 1d 15 00 00       	call   801789 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 0a 15 00 00       	call   801789 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 ad 2b 80 00       	push   $0x802bad
  80028c:	6a 33                	push   $0x33
  80028e:	68 6b 2b 80 00       	push   $0x802b6b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 c7 2b 80 00       	push   $0x802bc7
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 6b 2b 80 00       	push   $0x802b6b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 e1 2b 80 00       	push   $0x802be1
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 f6 2b 80 00       	push   $0x802bf6
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 a3 08 00 00       	call   800bc1 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 f7 09 00 00       	call   800d53 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 a2 0b 00 00       	call   800f08 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 13 0c 00 00       	call   800fa5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 8f 0b 00 00       	call   800f26 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 3a 0b 00 00       	call   800f08 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 a3 13 00 00       	call   801789 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 13 11 00 00       	call   801523 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 9b 10 00 00       	call   8014d4 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 70 0b 00 00       	call   800fc4 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 32 10 00 00       	call   8014ad <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 f2 0a 00 00       	call   800f86 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 a3 11 00 00       	call   801678 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 66 0a 00 00       	call   800f45 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 8f 0a 00 00       	call   800f86 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 0c 2c 80 00       	push   $0x802c0c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 38 2b 80 00 	movl   $0x802b38,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 ae 09 00 00       	call   800f08 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 1a 01 00 00       	call   8006ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 53 09 00 00       	call   800f08 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 0b 22 00 00       	call   802830 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 f8 22 00 00       	call   802960 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 2f 2c 80 00 	movsbl 0x802c2f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800686:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	3b 50 04             	cmp    0x4(%eax),%edx
  80068f:	73 0a                	jae    80069b <sprintputch+0x1b>
		*b->buf++ = ch;
  800691:	8d 4a 01             	lea    0x1(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	88 02                	mov    %al,(%edx)
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	ff 75 08             	pushl  0x8(%ebp)
  8006b0:	e8 05 00 00 00       	call   8006ba <vprintfmt>
	va_end(ap);
}
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	83 ec 2c             	sub    $0x2c,%esp
  8006c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006cc:	eb 12                	jmp    8006e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	0f 84 42 04 00 00    	je     800b18 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	50                   	push   %eax
  8006db:	ff d6                	call   *%esi
  8006dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	83 c7 01             	add    $0x1,%edi
  8006e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e7:	83 f8 25             	cmp    $0x25,%eax
  8006ea:	75 e2                	jne    8006ce <vprintfmt+0x14>
  8006ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	eb 07                	jmp    800713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80070f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800713:	8d 47 01             	lea    0x1(%edi),%eax
  800716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800719:	0f b6 07             	movzbl (%edi),%eax
  80071c:	0f b6 d0             	movzbl %al,%edx
  80071f:	83 e8 23             	sub    $0x23,%eax
  800722:	3c 55                	cmp    $0x55,%al
  800724:	0f 87 d3 03 00 00    	ja     800afd <vprintfmt+0x443>
  80072a:	0f b6 c0             	movzbl %al,%eax
  80072d:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800737:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80073b:	eb d6                	jmp    800713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800748:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80074f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800752:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800755:	83 f9 09             	cmp    $0x9,%ecx
  800758:	77 3f                	ja     800799 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075d:	eb e9                	jmp    800748 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 00                	mov    (%eax),%eax
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 40 04             	lea    0x4(%eax),%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800773:	eb 2a                	jmp    80079f <vprintfmt+0xe5>
  800775:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800778:	85 c0                	test   %eax,%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	0f 49 d0             	cmovns %eax,%edx
  800782:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	eb 89                	jmp    800713 <vprintfmt+0x59>
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800794:	e9 7a ff ff ff       	jmp    800713 <vprintfmt+0x59>
  800799:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80079c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80079f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a3:	0f 89 6a ff ff ff    	jns    800713 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007b6:	e9 58 ff ff ff       	jmp    800713 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007bb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007c1:	e9 4d ff ff ff       	jmp    800713 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 78 04             	lea    0x4(%eax),%edi
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	ff 30                	pushl  (%eax)
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007dd:	e9 fe fe ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 78 04             	lea    0x4(%eax),%edi
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	99                   	cltd   
  8007eb:	31 d0                	xor    %edx,%eax
  8007ed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ef:	83 f8 0f             	cmp    $0xf,%eax
  8007f2:	7f 0b                	jg     8007ff <vprintfmt+0x145>
  8007f4:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	75 1b                	jne    80081a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8007ff:	50                   	push   %eax
  800800:	68 47 2c 80 00       	push   $0x802c47
  800805:	53                   	push   %ebx
  800806:	56                   	push   %esi
  800807:	e8 91 fe ff ff       	call   80069d <printfmt>
  80080c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800815:	e9 c6 fe ff ff       	jmp    8006e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80081a:	52                   	push   %edx
  80081b:	68 e1 30 80 00       	push   $0x8030e1
  800820:	53                   	push   %ebx
  800821:	56                   	push   %esi
  800822:	e8 76 fe ff ff       	call   80069d <printfmt>
  800827:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80082a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800830:	e9 ab fe ff ff       	jmp    8006e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	83 c0 04             	add    $0x4,%eax
  80083b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800843:	85 ff                	test   %edi,%edi
  800845:	b8 40 2c 80 00       	mov    $0x802c40,%eax
  80084a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80084d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800851:	0f 8e 94 00 00 00    	jle    8008eb <vprintfmt+0x231>
  800857:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80085b:	0f 84 98 00 00 00    	je     8008f9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	ff 75 d0             	pushl  -0x30(%ebp)
  800867:	57                   	push   %edi
  800868:	e8 33 03 00 00       	call   800ba0 <strnlen>
  80086d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800870:	29 c1                	sub    %eax,%ecx
  800872:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800875:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800878:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80087c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80087f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800882:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800884:	eb 0f                	jmp    800895 <vprintfmt+0x1db>
					putch(padc, putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	ff 75 e0             	pushl  -0x20(%ebp)
  80088d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ef 01             	sub    $0x1,%edi
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 ff                	test   %edi,%edi
  800897:	7f ed                	jg     800886 <vprintfmt+0x1cc>
  800899:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80089c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	0f 49 c1             	cmovns %ecx,%eax
  8008a9:	29 c1                	sub    %eax,%ecx
  8008ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008b4:	89 cb                	mov    %ecx,%ebx
  8008b6:	eb 4d                	jmp    800905 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008bc:	74 1b                	je     8008d9 <vprintfmt+0x21f>
  8008be:	0f be c0             	movsbl %al,%eax
  8008c1:	83 e8 20             	sub    $0x20,%eax
  8008c4:	83 f8 5e             	cmp    $0x5e,%eax
  8008c7:	76 10                	jbe    8008d9 <vprintfmt+0x21f>
					putch('?', putdat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	6a 3f                	push   $0x3f
  8008d1:	ff 55 08             	call   *0x8(%ebp)
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 0d                	jmp    8008e6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	ff 75 0c             	pushl  0xc(%ebp)
  8008df:	52                   	push   %edx
  8008e0:	ff 55 08             	call   *0x8(%ebp)
  8008e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e6:	83 eb 01             	sub    $0x1,%ebx
  8008e9:	eb 1a                	jmp    800905 <vprintfmt+0x24b>
  8008eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008f7:	eb 0c                	jmp    800905 <vprintfmt+0x24b>
  8008f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800905:	83 c7 01             	add    $0x1,%edi
  800908:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090c:	0f be d0             	movsbl %al,%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 23                	je     800936 <vprintfmt+0x27c>
  800913:	85 f6                	test   %esi,%esi
  800915:	78 a1                	js     8008b8 <vprintfmt+0x1fe>
  800917:	83 ee 01             	sub    $0x1,%esi
  80091a:	79 9c                	jns    8008b8 <vprintfmt+0x1fe>
  80091c:	89 df                	mov    %ebx,%edi
  80091e:	8b 75 08             	mov    0x8(%ebp),%esi
  800921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800924:	eb 18                	jmp    80093e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	53                   	push   %ebx
  80092a:	6a 20                	push   $0x20
  80092c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	83 ef 01             	sub    $0x1,%edi
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb 08                	jmp    80093e <vprintfmt+0x284>
  800936:	89 df                	mov    %ebx,%edi
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093e:	85 ff                	test   %edi,%edi
  800940:	7f e4                	jg     800926 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800942:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800945:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094b:	e9 90 fd ff ff       	jmp    8006e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800950:	83 f9 01             	cmp    $0x1,%ecx
  800953:	7e 19                	jle    80096e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8b 50 04             	mov    0x4(%eax),%edx
  80095b:	8b 00                	mov    (%eax),%eax
  80095d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8d 40 08             	lea    0x8(%eax),%eax
  800969:	89 45 14             	mov    %eax,0x14(%ebp)
  80096c:	eb 38                	jmp    8009a6 <vprintfmt+0x2ec>
	else if (lflag)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	74 1b                	je     80098d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8b 00                	mov    (%eax),%eax
  800977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	c1 f9 1f             	sar    $0x1f,%ecx
  80097f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 40 04             	lea    0x4(%eax),%eax
  800988:	89 45 14             	mov    %eax,0x14(%ebp)
  80098b:	eb 19                	jmp    8009a6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	8b 00                	mov    (%eax),%eax
  800992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800995:	89 c1                	mov    %eax,%ecx
  800997:	c1 f9 1f             	sar    $0x1f,%ecx
  80099a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 40 04             	lea    0x4(%eax),%eax
  8009a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b5:	0f 89 0e 01 00 00    	jns    800ac9 <vprintfmt+0x40f>
				putch('-', putdat);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	53                   	push   %ebx
  8009bf:	6a 2d                	push   $0x2d
  8009c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8009c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009c9:	f7 da                	neg    %edx
  8009cb:	83 d1 00             	adc    $0x0,%ecx
  8009ce:	f7 d9                	neg    %ecx
  8009d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d8:	e9 ec 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009dd:	83 f9 01             	cmp    $0x1,%ecx
  8009e0:	7e 18                	jle    8009fa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 10                	mov    (%eax),%edx
  8009e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ea:	8d 40 08             	lea    0x8(%eax),%eax
  8009ed:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f5:	e9 cf 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009fa:	85 c9                	test   %ecx,%ecx
  8009fc:	74 1a                	je     800a18 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8009fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a08:	8d 40 04             	lea    0x4(%eax),%eax
  800a0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a13:	e9 b1 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	8b 10                	mov    (%eax),%edx
  800a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a22:	8d 40 04             	lea    0x4(%eax),%eax
  800a25:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a2d:	e9 97 00 00 00       	jmp    800ac9 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a32:	83 ec 08             	sub    $0x8,%esp
  800a35:	53                   	push   %ebx
  800a36:	6a 58                	push   $0x58
  800a38:	ff d6                	call   *%esi
			putch('X', putdat);
  800a3a:	83 c4 08             	add    $0x8,%esp
  800a3d:	53                   	push   %ebx
  800a3e:	6a 58                	push   $0x58
  800a40:	ff d6                	call   *%esi
			putch('X', putdat);
  800a42:	83 c4 08             	add    $0x8,%esp
  800a45:	53                   	push   %ebx
  800a46:	6a 58                	push   $0x58
  800a48:	ff d6                	call   *%esi
			break;
  800a4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a50:	e9 8b fc ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a55:	83 ec 08             	sub    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 30                	push   $0x30
  800a5b:	ff d6                	call   *%esi
			putch('x', putdat);
  800a5d:	83 c4 08             	add    $0x8,%esp
  800a60:	53                   	push   %ebx
  800a61:	6a 78                	push   $0x78
  800a63:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a65:	8b 45 14             	mov    0x14(%ebp),%eax
  800a68:	8b 10                	mov    (%eax),%edx
  800a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a6f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a72:	8d 40 04             	lea    0x4(%eax),%eax
  800a75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a78:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a7d:	eb 4a                	jmp    800ac9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a7f:	83 f9 01             	cmp    $0x1,%ecx
  800a82:	7e 15                	jle    800a99 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8b 10                	mov    (%eax),%edx
  800a89:	8b 48 04             	mov    0x4(%eax),%ecx
  800a8c:	8d 40 08             	lea    0x8(%eax),%eax
  800a8f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a92:	b8 10 00 00 00       	mov    $0x10,%eax
  800a97:	eb 30                	jmp    800ac9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800a99:	85 c9                	test   %ecx,%ecx
  800a9b:	74 17                	je     800ab4 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa0:	8b 10                	mov    (%eax),%edx
  800aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa7:	8d 40 04             	lea    0x4(%eax),%eax
  800aaa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aad:	b8 10 00 00 00       	mov    $0x10,%eax
  800ab2:	eb 15                	jmp    800ac9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab7:	8b 10                	mov    (%eax),%edx
  800ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abe:	8d 40 04             	lea    0x4(%eax),%eax
  800ac1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ac4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800ad0:	57                   	push   %edi
  800ad1:	ff 75 e0             	pushl  -0x20(%ebp)
  800ad4:	50                   	push   %eax
  800ad5:	51                   	push   %ecx
  800ad6:	52                   	push   %edx
  800ad7:	89 da                	mov    %ebx,%edx
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	e8 f1 fa ff ff       	call   8005d1 <printnum>
			break;
  800ae0:	83 c4 20             	add    $0x20,%esp
  800ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae6:	e9 f5 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	53                   	push   %ebx
  800aef:	52                   	push   %edx
  800af0:	ff d6                	call   *%esi
			break;
  800af2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800af8:	e9 e3 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800afd:	83 ec 08             	sub    $0x8,%esp
  800b00:	53                   	push   %ebx
  800b01:	6a 25                	push   $0x25
  800b03:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	eb 03                	jmp    800b0d <vprintfmt+0x453>
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b11:	75 f7                	jne    800b0a <vprintfmt+0x450>
  800b13:	e9 c8 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 18             	sub    $0x18,%esp
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b33:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	74 26                	je     800b67 <vsnprintf+0x47>
  800b41:	85 d2                	test   %edx,%edx
  800b43:	7e 22                	jle    800b67 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b45:	ff 75 14             	pushl  0x14(%ebp)
  800b48:	ff 75 10             	pushl  0x10(%ebp)
  800b4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b4e:	50                   	push   %eax
  800b4f:	68 80 06 80 00       	push   $0x800680
  800b54:	e8 61 fb ff ff       	call   8006ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	eb 05                	jmp    800b6c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b74:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b77:	50                   	push   %eax
  800b78:	ff 75 10             	pushl  0x10(%ebp)
  800b7b:	ff 75 0c             	pushl  0xc(%ebp)
  800b7e:	ff 75 08             	pushl  0x8(%ebp)
  800b81:	e8 9a ff ff ff       	call   800b20 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	eb 03                	jmp    800b98 <strlen+0x10>
		n++;
  800b95:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b98:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b9c:	75 f7                	jne    800b95 <strlen+0xd>
		n++;
	return n;
}
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	eb 03                	jmp    800bb3 <strnlen+0x13>
		n++;
  800bb0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bb3:	39 c2                	cmp    %eax,%edx
  800bb5:	74 08                	je     800bbf <strnlen+0x1f>
  800bb7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bbb:	75 f3                	jne    800bb0 <strnlen+0x10>
  800bbd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bd7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bda:	84 db                	test   %bl,%bl
  800bdc:	75 ef                	jne    800bcd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	53                   	push   %ebx
  800be5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be8:	53                   	push   %ebx
  800be9:	e8 9a ff ff ff       	call   800b88 <strlen>
  800bee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bf1:	ff 75 0c             	pushl  0xc(%ebp)
  800bf4:	01 d8                	add    %ebx,%eax
  800bf6:	50                   	push   %eax
  800bf7:	e8 c5 ff ff ff       	call   800bc1 <strcpy>
	return dst;
}
  800bfc:	89 d8                	mov    %ebx,%eax
  800bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 75 08             	mov    0x8(%ebp),%esi
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c13:	89 f2                	mov    %esi,%edx
  800c15:	eb 0f                	jmp    800c26 <strncpy+0x23>
		*dst++ = *src;
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	0f b6 01             	movzbl (%ecx),%eax
  800c1d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c20:	80 39 01             	cmpb   $0x1,(%ecx)
  800c23:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c26:	39 da                	cmp    %ebx,%edx
  800c28:	75 ed                	jne    800c17 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	8b 75 08             	mov    0x8(%ebp),%esi
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 10             	mov    0x10(%ebp),%edx
  800c3e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c40:	85 d2                	test   %edx,%edx
  800c42:	74 21                	je     800c65 <strlcpy+0x35>
  800c44:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c48:	89 f2                	mov    %esi,%edx
  800c4a:	eb 09                	jmp    800c55 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c4c:	83 c2 01             	add    $0x1,%edx
  800c4f:	83 c1 01             	add    $0x1,%ecx
  800c52:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c55:	39 c2                	cmp    %eax,%edx
  800c57:	74 09                	je     800c62 <strlcpy+0x32>
  800c59:	0f b6 19             	movzbl (%ecx),%ebx
  800c5c:	84 db                	test   %bl,%bl
  800c5e:	75 ec                	jne    800c4c <strlcpy+0x1c>
  800c60:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c65:	29 f0                	sub    %esi,%eax
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c74:	eb 06                	jmp    800c7c <strcmp+0x11>
		p++, q++;
  800c76:	83 c1 01             	add    $0x1,%ecx
  800c79:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7c:	0f b6 01             	movzbl (%ecx),%eax
  800c7f:	84 c0                	test   %al,%al
  800c81:	74 04                	je     800c87 <strcmp+0x1c>
  800c83:	3a 02                	cmp    (%edx),%al
  800c85:	74 ef                	je     800c76 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c87:	0f b6 c0             	movzbl %al,%eax
  800c8a:	0f b6 12             	movzbl (%edx),%edx
  800c8d:	29 d0                	sub    %edx,%eax
}
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	53                   	push   %ebx
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9b:	89 c3                	mov    %eax,%ebx
  800c9d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ca0:	eb 06                	jmp    800ca8 <strncmp+0x17>
		n--, p++, q++;
  800ca2:	83 c0 01             	add    $0x1,%eax
  800ca5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca8:	39 d8                	cmp    %ebx,%eax
  800caa:	74 15                	je     800cc1 <strncmp+0x30>
  800cac:	0f b6 08             	movzbl (%eax),%ecx
  800caf:	84 c9                	test   %cl,%cl
  800cb1:	74 04                	je     800cb7 <strncmp+0x26>
  800cb3:	3a 0a                	cmp    (%edx),%cl
  800cb5:	74 eb                	je     800ca2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb7:	0f b6 00             	movzbl (%eax),%eax
  800cba:	0f b6 12             	movzbl (%edx),%edx
  800cbd:	29 d0                	sub    %edx,%eax
  800cbf:	eb 05                	jmp    800cc6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd3:	eb 07                	jmp    800cdc <strchr+0x13>
		if (*s == c)
  800cd5:	38 ca                	cmp    %cl,%dl
  800cd7:	74 0f                	je     800ce8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cd9:	83 c0 01             	add    $0x1,%eax
  800cdc:	0f b6 10             	movzbl (%eax),%edx
  800cdf:	84 d2                	test   %dl,%dl
  800ce1:	75 f2                	jne    800cd5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf4:	eb 03                	jmp    800cf9 <strfind+0xf>
  800cf6:	83 c0 01             	add    $0x1,%eax
  800cf9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	74 04                	je     800d04 <strfind+0x1a>
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 f2                	jne    800cf6 <strfind+0xc>
			break;
	return (char *) s;
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d12:	85 c9                	test   %ecx,%ecx
  800d14:	74 36                	je     800d4c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1c:	75 28                	jne    800d46 <memset+0x40>
  800d1e:	f6 c1 03             	test   $0x3,%cl
  800d21:	75 23                	jne    800d46 <memset+0x40>
		c &= 0xFF;
  800d23:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	c1 e3 08             	shl    $0x8,%ebx
  800d2c:	89 d6                	mov    %edx,%esi
  800d2e:	c1 e6 18             	shl    $0x18,%esi
  800d31:	89 d0                	mov    %edx,%eax
  800d33:	c1 e0 10             	shl    $0x10,%eax
  800d36:	09 f0                	or     %esi,%eax
  800d38:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d3a:	89 d8                	mov    %ebx,%eax
  800d3c:	09 d0                	or     %edx,%eax
  800d3e:	c1 e9 02             	shr    $0x2,%ecx
  800d41:	fc                   	cld    
  800d42:	f3 ab                	rep stos %eax,%es:(%edi)
  800d44:	eb 06                	jmp    800d4c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d49:	fc                   	cld    
  800d4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4c:	89 f8                	mov    %edi,%eax
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d61:	39 c6                	cmp    %eax,%esi
  800d63:	73 35                	jae    800d9a <memmove+0x47>
  800d65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d68:	39 d0                	cmp    %edx,%eax
  800d6a:	73 2e                	jae    800d9a <memmove+0x47>
		s += n;
		d += n;
  800d6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	09 fe                	or     %edi,%esi
  800d73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d79:	75 13                	jne    800d8e <memmove+0x3b>
  800d7b:	f6 c1 03             	test   $0x3,%cl
  800d7e:	75 0e                	jne    800d8e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d80:	83 ef 04             	sub    $0x4,%edi
  800d83:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d86:	c1 e9 02             	shr    $0x2,%ecx
  800d89:	fd                   	std    
  800d8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d8c:	eb 09                	jmp    800d97 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8e:	83 ef 01             	sub    $0x1,%edi
  800d91:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d94:	fd                   	std    
  800d95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d97:	fc                   	cld    
  800d98:	eb 1d                	jmp    800db7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9a:	89 f2                	mov    %esi,%edx
  800d9c:	09 c2                	or     %eax,%edx
  800d9e:	f6 c2 03             	test   $0x3,%dl
  800da1:	75 0f                	jne    800db2 <memmove+0x5f>
  800da3:	f6 c1 03             	test   $0x3,%cl
  800da6:	75 0a                	jne    800db2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800da8:	c1 e9 02             	shr    $0x2,%ecx
  800dab:	89 c7                	mov    %eax,%edi
  800dad:	fc                   	cld    
  800dae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db0:	eb 05                	jmp    800db7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800db2:	89 c7                	mov    %eax,%edi
  800db4:	fc                   	cld    
  800db5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800dbe:	ff 75 10             	pushl  0x10(%ebp)
  800dc1:	ff 75 0c             	pushl  0xc(%ebp)
  800dc4:	ff 75 08             	pushl  0x8(%ebp)
  800dc7:	e8 87 ff ff ff       	call   800d53 <memmove>
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd9:	89 c6                	mov    %eax,%esi
  800ddb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dde:	eb 1a                	jmp    800dfa <memcmp+0x2c>
		if (*s1 != *s2)
  800de0:	0f b6 08             	movzbl (%eax),%ecx
  800de3:	0f b6 1a             	movzbl (%edx),%ebx
  800de6:	38 d9                	cmp    %bl,%cl
  800de8:	74 0a                	je     800df4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dea:	0f b6 c1             	movzbl %cl,%eax
  800ded:	0f b6 db             	movzbl %bl,%ebx
  800df0:	29 d8                	sub    %ebx,%eax
  800df2:	eb 0f                	jmp    800e03 <memcmp+0x35>
		s1++, s2++;
  800df4:	83 c0 01             	add    $0x1,%eax
  800df7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dfa:	39 f0                	cmp    %esi,%eax
  800dfc:	75 e2                	jne    800de0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	53                   	push   %ebx
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e0e:	89 c1                	mov    %eax,%ecx
  800e10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e17:	eb 0a                	jmp    800e23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e19:	0f b6 10             	movzbl (%eax),%edx
  800e1c:	39 da                	cmp    %ebx,%edx
  800e1e:	74 07                	je     800e27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e20:	83 c0 01             	add    $0x1,%eax
  800e23:	39 c8                	cmp    %ecx,%eax
  800e25:	72 f2                	jb     800e19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e36:	eb 03                	jmp    800e3b <strtol+0x11>
		s++;
  800e38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3b:	0f b6 01             	movzbl (%ecx),%eax
  800e3e:	3c 20                	cmp    $0x20,%al
  800e40:	74 f6                	je     800e38 <strtol+0xe>
  800e42:	3c 09                	cmp    $0x9,%al
  800e44:	74 f2                	je     800e38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e46:	3c 2b                	cmp    $0x2b,%al
  800e48:	75 0a                	jne    800e54 <strtol+0x2a>
		s++;
  800e4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800e52:	eb 11                	jmp    800e65 <strtol+0x3b>
  800e54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e59:	3c 2d                	cmp    $0x2d,%al
  800e5b:	75 08                	jne    800e65 <strtol+0x3b>
		s++, neg = 1;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e6b:	75 15                	jne    800e82 <strtol+0x58>
  800e6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800e70:	75 10                	jne    800e82 <strtol+0x58>
  800e72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e76:	75 7c                	jne    800ef4 <strtol+0xca>
		s += 2, base = 16;
  800e78:	83 c1 02             	add    $0x2,%ecx
  800e7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e80:	eb 16                	jmp    800e98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e82:	85 db                	test   %ebx,%ebx
  800e84:	75 12                	jne    800e98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800e8e:	75 08                	jne    800e98 <strtol+0x6e>
		s++, base = 8;
  800e90:	83 c1 01             	add    $0x1,%ecx
  800e93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e98:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ea0:	0f b6 11             	movzbl (%ecx),%edx
  800ea3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ea6:	89 f3                	mov    %esi,%ebx
  800ea8:	80 fb 09             	cmp    $0x9,%bl
  800eab:	77 08                	ja     800eb5 <strtol+0x8b>
			dig = *s - '0';
  800ead:	0f be d2             	movsbl %dl,%edx
  800eb0:	83 ea 30             	sub    $0x30,%edx
  800eb3:	eb 22                	jmp    800ed7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800eb5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eb8:	89 f3                	mov    %esi,%ebx
  800eba:	80 fb 19             	cmp    $0x19,%bl
  800ebd:	77 08                	ja     800ec7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ebf:	0f be d2             	movsbl %dl,%edx
  800ec2:	83 ea 57             	sub    $0x57,%edx
  800ec5:	eb 10                	jmp    800ed7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ec7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eca:	89 f3                	mov    %esi,%ebx
  800ecc:	80 fb 19             	cmp    $0x19,%bl
  800ecf:	77 16                	ja     800ee7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ed1:	0f be d2             	movsbl %dl,%edx
  800ed4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ed7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eda:	7d 0b                	jge    800ee7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800edc:	83 c1 01             	add    $0x1,%ecx
  800edf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ee3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ee5:	eb b9                	jmp    800ea0 <strtol+0x76>

	if (endptr)
  800ee7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eeb:	74 0d                	je     800efa <strtol+0xd0>
		*endptr = (char *) s;
  800eed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ef0:	89 0e                	mov    %ecx,(%esi)
  800ef2:	eb 06                	jmp    800efa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ef4:	85 db                	test   %ebx,%ebx
  800ef6:	74 98                	je     800e90 <strtol+0x66>
  800ef8:	eb 9e                	jmp    800e98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	f7 da                	neg    %edx
  800efe:	85 ff                	test   %edi,%edi
  800f00:	0f 45 c2             	cmovne %edx,%eax
}
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	89 c6                	mov    %eax,%esi
  800f1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 01 00 00 00       	mov    $0x1,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	b8 03 00 00 00       	mov    $0x3,%eax
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	89 cb                	mov    %ecx,%ebx
  800f5d:	89 cf                	mov    %ecx,%edi
  800f5f:	89 ce                	mov    %ecx,%esi
  800f61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f63:	85 c0                	test   %eax,%eax
  800f65:	7e 17                	jle    800f7e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	50                   	push   %eax
  800f6b:	6a 03                	push   $0x3
  800f6d:	68 3f 2f 80 00       	push   $0x802f3f
  800f72:	6a 23                	push   $0x23
  800f74:	68 5c 2f 80 00       	push   $0x802f5c
  800f79:	e8 66 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f91:	b8 02 00 00 00       	mov    $0x2,%eax
  800f96:	89 d1                	mov    %edx,%ecx
  800f98:	89 d3                	mov    %edx,%ebx
  800f9a:	89 d7                	mov    %edx,%edi
  800f9c:	89 d6                	mov    %edx,%esi
  800f9e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <sys_yield>:

void
sys_yield(void)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 d3                	mov    %edx,%ebx
  800fb9:	89 d7                	mov    %edx,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcd:	be 00 00 00 00       	mov    $0x0,%esi
  800fd2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fda:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe0:	89 f7                	mov    %esi,%edi
  800fe2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	7e 17                	jle    800fff <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	50                   	push   %eax
  800fec:	6a 04                	push   $0x4
  800fee:	68 3f 2f 80 00       	push   $0x802f3f
  800ff3:	6a 23                	push   $0x23
  800ff5:	68 5c 2f 80 00       	push   $0x802f5c
  800ffa:	e8 e5 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801010:	b8 05 00 00 00       	mov    $0x5,%eax
  801015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801021:	8b 75 18             	mov    0x18(%ebp),%esi
  801024:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801026:	85 c0                	test   %eax,%eax
  801028:	7e 17                	jle    801041 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	50                   	push   %eax
  80102e:	6a 05                	push   $0x5
  801030:	68 3f 2f 80 00       	push   $0x802f3f
  801035:	6a 23                	push   $0x23
  801037:	68 5c 2f 80 00       	push   $0x802f5c
  80103c:	e8 a3 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801052:	bb 00 00 00 00       	mov    $0x0,%ebx
  801057:	b8 06 00 00 00       	mov    $0x6,%eax
  80105c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105f:	8b 55 08             	mov    0x8(%ebp),%edx
  801062:	89 df                	mov    %ebx,%edi
  801064:	89 de                	mov    %ebx,%esi
  801066:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801068:	85 c0                	test   %eax,%eax
  80106a:	7e 17                	jle    801083 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	50                   	push   %eax
  801070:	6a 06                	push   $0x6
  801072:	68 3f 2f 80 00       	push   $0x802f3f
  801077:	6a 23                	push   $0x23
  801079:	68 5c 2f 80 00       	push   $0x802f5c
  80107e:	e8 61 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801094:	bb 00 00 00 00       	mov    $0x0,%ebx
  801099:	b8 08 00 00 00       	mov    $0x8,%eax
  80109e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a4:	89 df                	mov    %ebx,%edi
  8010a6:	89 de                	mov    %ebx,%esi
  8010a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	7e 17                	jle    8010c5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	50                   	push   %eax
  8010b2:	6a 08                	push   $0x8
  8010b4:	68 3f 2f 80 00       	push   $0x802f3f
  8010b9:	6a 23                	push   $0x23
  8010bb:	68 5c 2f 80 00       	push   $0x802f5c
  8010c0:	e8 1f f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010db:	b8 09 00 00 00       	mov    $0x9,%eax
  8010e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e6:	89 df                	mov    %ebx,%edi
  8010e8:	89 de                	mov    %ebx,%esi
  8010ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	7e 17                	jle    801107 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	50                   	push   %eax
  8010f4:	6a 09                	push   $0x9
  8010f6:	68 3f 2f 80 00       	push   $0x802f3f
  8010fb:	6a 23                	push   $0x23
  8010fd:	68 5c 2f 80 00       	push   $0x802f5c
  801102:	e8 dd f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801118:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801122:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801125:	8b 55 08             	mov    0x8(%ebp),%edx
  801128:	89 df                	mov    %ebx,%edi
  80112a:	89 de                	mov    %ebx,%esi
  80112c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80112e:	85 c0                	test   %eax,%eax
  801130:	7e 17                	jle    801149 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	50                   	push   %eax
  801136:	6a 0a                	push   $0xa
  801138:	68 3f 2f 80 00       	push   $0x802f3f
  80113d:	6a 23                	push   $0x23
  80113f:	68 5c 2f 80 00       	push   $0x802f5c
  801144:	e8 9b f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801157:	be 00 00 00 00       	mov    $0x0,%esi
  80115c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801164:	8b 55 08             	mov    0x8(%ebp),%edx
  801167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801182:	b8 0d 00 00 00       	mov    $0xd,%eax
  801187:	8b 55 08             	mov    0x8(%ebp),%edx
  80118a:	89 cb                	mov    %ecx,%ebx
  80118c:	89 cf                	mov    %ecx,%edi
  80118e:	89 ce                	mov    %ecx,%esi
  801190:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	7e 17                	jle    8011ad <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	50                   	push   %eax
  80119a:	6a 0d                	push   $0xd
  80119c:	68 3f 2f 80 00       	push   $0x802f3f
  8011a1:	6a 23                	push   $0x23
  8011a3:	68 5c 2f 80 00       	push   $0x802f5c
  8011a8:	e8 37 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  8011bd:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  8011bf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011c3:	74 11                	je     8011d6 <pgfault+0x21>
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
  8011ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d1:	f6 c4 08             	test   $0x8,%ah
  8011d4:	75 14                	jne    8011ea <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	68 6c 2f 80 00       	push   $0x802f6c
  8011de:	6a 1f                	push   $0x1f
  8011e0:	68 cf 2f 80 00       	push   $0x802fcf
  8011e5:	e8 fa f2 ff ff       	call   8004e4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  8011ea:	e8 97 fd ff ff       	call   800f86 <sys_getenvid>
  8011ef:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	6a 07                	push   $0x7
  8011f6:	68 00 f0 7f 00       	push   $0x7ff000
  8011fb:	50                   	push   %eax
  8011fc:	e8 c3 fd ff ff       	call   800fc4 <sys_page_alloc>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	79 12                	jns    80121a <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  801208:	50                   	push   %eax
  801209:	68 ac 2f 80 00       	push   $0x802fac
  80120e:	6a 2c                	push   $0x2c
  801210:	68 cf 2f 80 00       	push   $0x802fcf
  801215:	e8 ca f2 ff ff       	call   8004e4 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  80121a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	68 00 10 00 00       	push   $0x1000
  801228:	53                   	push   %ebx
  801229:	68 00 f0 7f 00       	push   $0x7ff000
  80122e:	e8 20 fb ff ff       	call   800d53 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  801233:	83 c4 08             	add    $0x8,%esp
  801236:	53                   	push   %ebx
  801237:	56                   	push   %esi
  801238:	e8 0c fe ff ff       	call   801049 <sys_page_unmap>
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	79 12                	jns    801256 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  801244:	50                   	push   %eax
  801245:	68 da 2f 80 00       	push   $0x802fda
  80124a:	6a 32                	push   $0x32
  80124c:	68 cf 2f 80 00       	push   $0x802fcf
  801251:	e8 8e f2 ff ff       	call   8004e4 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	6a 07                	push   $0x7
  80125b:	53                   	push   %ebx
  80125c:	56                   	push   %esi
  80125d:	68 00 f0 7f 00       	push   $0x7ff000
  801262:	56                   	push   %esi
  801263:	e8 9f fd ff ff       	call   801007 <sys_page_map>
  801268:	83 c4 20             	add    $0x20,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	79 12                	jns    801281 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  80126f:	50                   	push   %eax
  801270:	68 f8 2f 80 00       	push   $0x802ff8
  801275:	6a 35                	push   $0x35
  801277:	68 cf 2f 80 00       	push   $0x802fcf
  80127c:	e8 63 f2 ff ff       	call   8004e4 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	68 00 f0 7f 00       	push   $0x7ff000
  801289:	56                   	push   %esi
  80128a:	e8 ba fd ff ff       	call   801049 <sys_page_unmap>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	79 12                	jns    8012a8 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  801296:	50                   	push   %eax
  801297:	68 da 2f 80 00       	push   $0x802fda
  80129c:	6a 38                	push   $0x38
  80129e:	68 cf 2f 80 00       	push   $0x802fcf
  8012a3:	e8 3c f2 ff ff       	call   8004e4 <_panic>
	//panic("pgfault not implemented");
}
  8012a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  8012b8:	68 b5 11 80 00       	push   $0x8011b5
  8012bd:	e8 85 13 00 00       	call   802647 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012c2:	b8 07 00 00 00       	mov    $0x7,%eax
  8012c7:	cd 30                	int    $0x30
  8012c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 38 01 00 00    	js     80140f <fork+0x160>
  8012d7:	89 c7                	mov    %eax,%edi
  8012d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	75 21                	jne    801303 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  8012e2:	e8 9f fc ff ff       	call   800f86 <sys_getenvid>
  8012e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012f4:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  8012f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fe:	e9 86 01 00 00       	jmp    801489 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801303:	89 d8                	mov    %ebx,%eax
  801305:	c1 e8 16             	shr    $0x16,%eax
  801308:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130f:	a8 01                	test   $0x1,%al
  801311:	0f 84 90 00 00 00    	je     8013a7 <fork+0xf8>
  801317:	89 d8                	mov    %ebx,%eax
  801319:	c1 e8 0c             	shr    $0xc,%eax
  80131c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801323:	f6 c2 01             	test   $0x1,%dl
  801326:	74 7f                	je     8013a7 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  801328:	89 c6                	mov    %eax,%esi
  80132a:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  80132d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801334:	f6 c6 04             	test   $0x4,%dh
  801337:	74 33                	je     80136c <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  801339:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	25 07 0e 00 00       	and    $0xe07,%eax
  801348:	50                   	push   %eax
  801349:	56                   	push   %esi
  80134a:	57                   	push   %edi
  80134b:	56                   	push   %esi
  80134c:	6a 00                	push   $0x0
  80134e:	e8 b4 fc ff ff       	call   801007 <sys_page_map>
  801353:	83 c4 20             	add    $0x20,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	79 4d                	jns    8013a7 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  80135a:	50                   	push   %eax
  80135b:	68 14 30 80 00       	push   $0x803014
  801360:	6a 54                	push   $0x54
  801362:	68 cf 2f 80 00       	push   $0x802fcf
  801367:	e8 78 f1 ff ff       	call   8004e4 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  80136c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801373:	a9 02 08 00 00       	test   $0x802,%eax
  801378:	0f 85 c6 00 00 00    	jne    801444 <fork+0x195>
  80137e:	e9 e3 00 00 00       	jmp    801466 <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801383:	50                   	push   %eax
  801384:	68 14 30 80 00       	push   $0x803014
  801389:	6a 5d                	push   $0x5d
  80138b:	68 cf 2f 80 00       	push   $0x802fcf
  801390:	e8 4f f1 ff ff       	call   8004e4 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801395:	50                   	push   %eax
  801396:	68 14 30 80 00       	push   $0x803014
  80139b:	6a 64                	push   $0x64
  80139d:	68 cf 2f 80 00       	push   $0x802fcf
  8013a2:	e8 3d f1 ff ff       	call   8004e4 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  8013a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013ad:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013b3:	0f 85 4a ff ff ff    	jne    801303 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  8013b9:	83 ec 04             	sub    $0x4,%esp
  8013bc:	6a 07                	push   $0x7
  8013be:	68 00 f0 bf ee       	push   $0xeebff000
  8013c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8013c6:	57                   	push   %edi
  8013c7:	e8 f8 fb ff ff       	call   800fc4 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8013cc:	83 c4 10             	add    $0x10,%esp
		return ret;
  8013cf:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	0f 88 b0 00 00 00    	js     801489 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8013d9:	a1 04 50 80 00       	mov    0x805004,%eax
  8013de:	8b 40 64             	mov    0x64(%eax),%eax
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	50                   	push   %eax
  8013e5:	57                   	push   %edi
  8013e6:	e8 24 fd ff ff       	call   80110f <sys_env_set_pgfault_upcall>
  8013eb:	83 c4 10             	add    $0x10,%esp
		return ret;
  8013ee:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	0f 88 91 00 00 00    	js     801489 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	6a 02                	push   $0x2
  8013fd:	57                   	push   %edi
  8013fe:	e8 88 fc ff ff       	call   80108b <sys_env_set_status>
  801403:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  801406:	85 c0                	test   %eax,%eax
  801408:	89 fa                	mov    %edi,%edx
  80140a:	0f 48 d0             	cmovs  %eax,%edx
  80140d:	eb 7a                	jmp    801489 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  80140f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801412:	eb 75                	jmp    801489 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801414:	e8 6d fb ff ff       	call   800f86 <sys_getenvid>
  801419:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80141c:	e8 65 fb ff ff       	call   800f86 <sys_getenvid>
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	68 05 08 00 00       	push   $0x805
  801429:	56                   	push   %esi
  80142a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142d:	56                   	push   %esi
  80142e:	50                   	push   %eax
  80142f:	e8 d3 fb ff ff       	call   801007 <sys_page_map>
  801434:	83 c4 20             	add    $0x20,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	0f 89 68 ff ff ff    	jns    8013a7 <fork+0xf8>
  80143f:	e9 51 ff ff ff       	jmp    801395 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801444:	e8 3d fb ff ff       	call   800f86 <sys_getenvid>
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	68 05 08 00 00       	push   $0x805
  801451:	56                   	push   %esi
  801452:	57                   	push   %edi
  801453:	56                   	push   %esi
  801454:	50                   	push   %eax
  801455:	e8 ad fb ff ff       	call   801007 <sys_page_map>
  80145a:	83 c4 20             	add    $0x20,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	79 b3                	jns    801414 <fork+0x165>
  801461:	e9 1d ff ff ff       	jmp    801383 <fork+0xd4>
  801466:	e8 1b fb ff ff       	call   800f86 <sys_getenvid>
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	6a 05                	push   $0x5
  801470:	56                   	push   %esi
  801471:	57                   	push   %edi
  801472:	56                   	push   %esi
  801473:	50                   	push   %eax
  801474:	e8 8e fb ff ff       	call   801007 <sys_page_map>
  801479:	83 c4 20             	add    $0x20,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	0f 89 23 ff ff ff    	jns    8013a7 <fork+0xf8>
  801484:	e9 fa fe ff ff       	jmp    801383 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  801489:	89 d0                	mov    %edx,%eax
  80148b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <sfork>:

// Challenge!
int
sfork(void)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801499:	68 25 30 80 00       	push   $0x803025
  80149e:	68 ac 00 00 00       	push   $0xac
  8014a3:	68 cf 2f 80 00       	push   $0x802fcf
  8014a8:	e8 37 f0 ff ff       	call   8004e4 <_panic>

008014ad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8014b8:	c1 e8 0c             	shr    $0xc,%eax
}
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8014c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014cd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014da:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	c1 ea 16             	shr    $0x16,%edx
  8014e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014eb:	f6 c2 01             	test   $0x1,%dl
  8014ee:	74 11                	je     801501 <fd_alloc+0x2d>
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	c1 ea 0c             	shr    $0xc,%edx
  8014f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fc:	f6 c2 01             	test   $0x1,%dl
  8014ff:	75 09                	jne    80150a <fd_alloc+0x36>
			*fd_store = fd;
  801501:	89 01                	mov    %eax,(%ecx)
			return 0;
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
  801508:	eb 17                	jmp    801521 <fd_alloc+0x4d>
  80150a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80150f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801514:	75 c9                	jne    8014df <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801516:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80151c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801529:	83 f8 1f             	cmp    $0x1f,%eax
  80152c:	77 36                	ja     801564 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80152e:	c1 e0 0c             	shl    $0xc,%eax
  801531:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801536:	89 c2                	mov    %eax,%edx
  801538:	c1 ea 16             	shr    $0x16,%edx
  80153b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801542:	f6 c2 01             	test   $0x1,%dl
  801545:	74 24                	je     80156b <fd_lookup+0x48>
  801547:	89 c2                	mov    %eax,%edx
  801549:	c1 ea 0c             	shr    $0xc,%edx
  80154c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801553:	f6 c2 01             	test   $0x1,%dl
  801556:	74 1a                	je     801572 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801558:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155b:	89 02                	mov    %eax,(%edx)
	return 0;
  80155d:	b8 00 00 00 00       	mov    $0x0,%eax
  801562:	eb 13                	jmp    801577 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801569:	eb 0c                	jmp    801577 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80156b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801570:	eb 05                	jmp    801577 <fd_lookup+0x54>
  801572:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801582:	ba b8 30 80 00       	mov    $0x8030b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801587:	eb 13                	jmp    80159c <dev_lookup+0x23>
  801589:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80158c:	39 08                	cmp    %ecx,(%eax)
  80158e:	75 0c                	jne    80159c <dev_lookup+0x23>
			*dev = devtab[i];
  801590:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801593:	89 01                	mov    %eax,(%ecx)
			return 0;
  801595:	b8 00 00 00 00       	mov    $0x0,%eax
  80159a:	eb 2e                	jmp    8015ca <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80159c:	8b 02                	mov    (%edx),%eax
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	75 e7                	jne    801589 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a2:	a1 04 50 80 00       	mov    0x805004,%eax
  8015a7:	8b 40 48             	mov    0x48(%eax),%eax
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	51                   	push   %ecx
  8015ae:	50                   	push   %eax
  8015af:	68 3c 30 80 00       	push   $0x80303c
  8015b4:	e8 04 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  8015b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 10             	sub    $0x10,%esp
  8015d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015e4:	c1 e8 0c             	shr    $0xc,%eax
  8015e7:	50                   	push   %eax
  8015e8:	e8 36 ff ff ff       	call   801523 <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 05                	js     8015f9 <fd_close+0x2d>
	    || fd != fd2)
  8015f4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015f7:	74 0c                	je     801605 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015f9:	84 db                	test   %bl,%bl
  8015fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801600:	0f 44 c2             	cmove  %edx,%eax
  801603:	eb 41                	jmp    801646 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	ff 36                	pushl  (%esi)
  80160e:	e8 66 ff ff ff       	call   801579 <dev_lookup>
  801613:	89 c3                	mov    %eax,%ebx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 1a                	js     801636 <fd_close+0x6a>
		if (dev->dev_close)
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801622:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801627:	85 c0                	test   %eax,%eax
  801629:	74 0b                	je     801636 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	56                   	push   %esi
  80162f:	ff d0                	call   *%eax
  801631:	89 c3                	mov    %eax,%ebx
  801633:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	56                   	push   %esi
  80163a:	6a 00                	push   $0x0
  80163c:	e8 08 fa ff ff       	call   801049 <sys_page_unmap>
	return r;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	89 d8                	mov    %ebx,%eax
}
  801646:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801649:	5b                   	pop    %ebx
  80164a:	5e                   	pop    %esi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    

0080164d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	ff 75 08             	pushl  0x8(%ebp)
  80165a:	e8 c4 fe ff ff       	call   801523 <fd_lookup>
  80165f:	83 c4 08             	add    $0x8,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 10                	js     801676 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	6a 01                	push   $0x1
  80166b:	ff 75 f4             	pushl  -0xc(%ebp)
  80166e:	e8 59 ff ff ff       	call   8015cc <fd_close>
  801673:	83 c4 10             	add    $0x10,%esp
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <close_all>:

void
close_all(void)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	53                   	push   %ebx
  80167c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80167f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	53                   	push   %ebx
  801688:	e8 c0 ff ff ff       	call   80164d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80168d:	83 c3 01             	add    $0x1,%ebx
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	83 fb 20             	cmp    $0x20,%ebx
  801696:	75 ec                	jne    801684 <close_all+0xc>
		close(i);
}
  801698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	57                   	push   %edi
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 2c             	sub    $0x2c,%esp
  8016a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 6e fe ff ff       	call   801523 <fd_lookup>
  8016b5:	83 c4 08             	add    $0x8,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	0f 88 c1 00 00 00    	js     801781 <dup+0xe4>
		return r;
	close(newfdnum);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	56                   	push   %esi
  8016c4:	e8 84 ff ff ff       	call   80164d <close>

	newfd = INDEX2FD(newfdnum);
  8016c9:	89 f3                	mov    %esi,%ebx
  8016cb:	c1 e3 0c             	shl    $0xc,%ebx
  8016ce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016d4:	83 c4 04             	add    $0x4,%esp
  8016d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016da:	e8 de fd ff ff       	call   8014bd <fd2data>
  8016df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016e1:	89 1c 24             	mov    %ebx,(%esp)
  8016e4:	e8 d4 fd ff ff       	call   8014bd <fd2data>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ef:	89 f8                	mov    %edi,%eax
  8016f1:	c1 e8 16             	shr    $0x16,%eax
  8016f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016fb:	a8 01                	test   $0x1,%al
  8016fd:	74 37                	je     801736 <dup+0x99>
  8016ff:	89 f8                	mov    %edi,%eax
  801701:	c1 e8 0c             	shr    $0xc,%eax
  801704:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80170b:	f6 c2 01             	test   $0x1,%dl
  80170e:	74 26                	je     801736 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801710:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801717:	83 ec 0c             	sub    $0xc,%esp
  80171a:	25 07 0e 00 00       	and    $0xe07,%eax
  80171f:	50                   	push   %eax
  801720:	ff 75 d4             	pushl  -0x2c(%ebp)
  801723:	6a 00                	push   $0x0
  801725:	57                   	push   %edi
  801726:	6a 00                	push   $0x0
  801728:	e8 da f8 ff ff       	call   801007 <sys_page_map>
  80172d:	89 c7                	mov    %eax,%edi
  80172f:	83 c4 20             	add    $0x20,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 2e                	js     801764 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801736:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801739:	89 d0                	mov    %edx,%eax
  80173b:	c1 e8 0c             	shr    $0xc,%eax
  80173e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801745:	83 ec 0c             	sub    $0xc,%esp
  801748:	25 07 0e 00 00       	and    $0xe07,%eax
  80174d:	50                   	push   %eax
  80174e:	53                   	push   %ebx
  80174f:	6a 00                	push   $0x0
  801751:	52                   	push   %edx
  801752:	6a 00                	push   $0x0
  801754:	e8 ae f8 ff ff       	call   801007 <sys_page_map>
  801759:	89 c7                	mov    %eax,%edi
  80175b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80175e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801760:	85 ff                	test   %edi,%edi
  801762:	79 1d                	jns    801781 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	53                   	push   %ebx
  801768:	6a 00                	push   $0x0
  80176a:	e8 da f8 ff ff       	call   801049 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80176f:	83 c4 08             	add    $0x8,%esp
  801772:	ff 75 d4             	pushl  -0x2c(%ebp)
  801775:	6a 00                	push   $0x0
  801777:	e8 cd f8 ff ff       	call   801049 <sys_page_unmap>
	return r;
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	89 f8                	mov    %edi,%eax
}
  801781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5f                   	pop    %edi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	53                   	push   %ebx
  80178d:	83 ec 14             	sub    $0x14,%esp
  801790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801793:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801796:	50                   	push   %eax
  801797:	53                   	push   %ebx
  801798:	e8 86 fd ff ff       	call   801523 <fd_lookup>
  80179d:	83 c4 08             	add    $0x8,%esp
  8017a0:	89 c2                	mov    %eax,%edx
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 6d                	js     801813 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ac:	50                   	push   %eax
  8017ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b0:	ff 30                	pushl  (%eax)
  8017b2:	e8 c2 fd ff ff       	call   801579 <dev_lookup>
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 4c                	js     80180a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c1:	8b 42 08             	mov    0x8(%edx),%eax
  8017c4:	83 e0 03             	and    $0x3,%eax
  8017c7:	83 f8 01             	cmp    $0x1,%eax
  8017ca:	75 21                	jne    8017ed <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017cc:	a1 04 50 80 00       	mov    0x805004,%eax
  8017d1:	8b 40 48             	mov    0x48(%eax),%eax
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	53                   	push   %ebx
  8017d8:	50                   	push   %eax
  8017d9:	68 7d 30 80 00       	push   $0x80307d
  8017de:	e8 da ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017eb:	eb 26                	jmp    801813 <read+0x8a>
	}
	if (!dev->dev_read)
  8017ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f0:	8b 40 08             	mov    0x8(%eax),%eax
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	74 17                	je     80180e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f7:	83 ec 04             	sub    $0x4,%esp
  8017fa:	ff 75 10             	pushl  0x10(%ebp)
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	52                   	push   %edx
  801801:	ff d0                	call   *%eax
  801803:	89 c2                	mov    %eax,%edx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb 09                	jmp    801813 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	eb 05                	jmp    801813 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80180e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801813:	89 d0                	mov    %edx,%eax
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	57                   	push   %edi
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	8b 7d 08             	mov    0x8(%ebp),%edi
  801826:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801829:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182e:	eb 21                	jmp    801851 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	89 f0                	mov    %esi,%eax
  801835:	29 d8                	sub    %ebx,%eax
  801837:	50                   	push   %eax
  801838:	89 d8                	mov    %ebx,%eax
  80183a:	03 45 0c             	add    0xc(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	57                   	push   %edi
  80183f:	e8 45 ff ff ff       	call   801789 <read>
		if (m < 0)
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	78 10                	js     80185b <readn+0x41>
			return m;
		if (m == 0)
  80184b:	85 c0                	test   %eax,%eax
  80184d:	74 0a                	je     801859 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80184f:	01 c3                	add    %eax,%ebx
  801851:	39 f3                	cmp    %esi,%ebx
  801853:	72 db                	jb     801830 <readn+0x16>
  801855:	89 d8                	mov    %ebx,%eax
  801857:	eb 02                	jmp    80185b <readn+0x41>
  801859:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80185b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5f                   	pop    %edi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 14             	sub    $0x14,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801870:	50                   	push   %eax
  801871:	53                   	push   %ebx
  801872:	e8 ac fc ff ff       	call   801523 <fd_lookup>
  801877:	83 c4 08             	add    $0x8,%esp
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 68                	js     8018e8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188a:	ff 30                	pushl  (%eax)
  80188c:	e8 e8 fc ff ff       	call   801579 <dev_lookup>
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	78 47                	js     8018df <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189f:	75 21                	jne    8018c2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a1:	a1 04 50 80 00       	mov    0x805004,%eax
  8018a6:	8b 40 48             	mov    0x48(%eax),%eax
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	53                   	push   %ebx
  8018ad:	50                   	push   %eax
  8018ae:	68 99 30 80 00       	push   $0x803099
  8018b3:	e8 05 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c0:	eb 26                	jmp    8018e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c8:	85 d2                	test   %edx,%edx
  8018ca:	74 17                	je     8018e3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	ff 75 10             	pushl  0x10(%ebp)
  8018d2:	ff 75 0c             	pushl  0xc(%ebp)
  8018d5:	50                   	push   %eax
  8018d6:	ff d2                	call   *%edx
  8018d8:	89 c2                	mov    %eax,%edx
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	eb 09                	jmp    8018e8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	eb 05                	jmp    8018e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018e8:	89 d0                	mov    %edx,%eax
  8018ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	ff 75 08             	pushl  0x8(%ebp)
  8018fc:	e8 22 fc ff ff       	call   801523 <fd_lookup>
  801901:	83 c4 08             	add    $0x8,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 0e                	js     801916 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801908:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80190b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	53                   	push   %ebx
  80191c:	83 ec 14             	sub    $0x14,%esp
  80191f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801922:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801925:	50                   	push   %eax
  801926:	53                   	push   %ebx
  801927:	e8 f7 fb ff ff       	call   801523 <fd_lookup>
  80192c:	83 c4 08             	add    $0x8,%esp
  80192f:	89 c2                	mov    %eax,%edx
  801931:	85 c0                	test   %eax,%eax
  801933:	78 65                	js     80199a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193f:	ff 30                	pushl  (%eax)
  801941:	e8 33 fc ff ff       	call   801579 <dev_lookup>
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 44                	js     801991 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80194d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801950:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801954:	75 21                	jne    801977 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801956:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80195b:	8b 40 48             	mov    0x48(%eax),%eax
  80195e:	83 ec 04             	sub    $0x4,%esp
  801961:	53                   	push   %ebx
  801962:	50                   	push   %eax
  801963:	68 5c 30 80 00       	push   $0x80305c
  801968:	e8 50 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801975:	eb 23                	jmp    80199a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801977:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197a:	8b 52 18             	mov    0x18(%edx),%edx
  80197d:	85 d2                	test   %edx,%edx
  80197f:	74 14                	je     801995 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	ff 75 0c             	pushl  0xc(%ebp)
  801987:	50                   	push   %eax
  801988:	ff d2                	call   *%edx
  80198a:	89 c2                	mov    %eax,%edx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	eb 09                	jmp    80199a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801991:	89 c2                	mov    %eax,%edx
  801993:	eb 05                	jmp    80199a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801995:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80199a:	89 d0                	mov    %edx,%eax
  80199c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 14             	sub    $0x14,%esp
  8019a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ae:	50                   	push   %eax
  8019af:	ff 75 08             	pushl  0x8(%ebp)
  8019b2:	e8 6c fb ff ff       	call   801523 <fd_lookup>
  8019b7:	83 c4 08             	add    $0x8,%esp
  8019ba:	89 c2                	mov    %eax,%edx
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 58                	js     801a18 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c0:	83 ec 08             	sub    $0x8,%esp
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	50                   	push   %eax
  8019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ca:	ff 30                	pushl  (%eax)
  8019cc:	e8 a8 fb ff ff       	call   801579 <dev_lookup>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 37                	js     801a0f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019db:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019df:	74 32                	je     801a13 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019eb:	00 00 00 
	stat->st_isdir = 0;
  8019ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f5:	00 00 00 
	stat->st_dev = dev;
  8019f8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	53                   	push   %ebx
  801a02:	ff 75 f0             	pushl  -0x10(%ebp)
  801a05:	ff 50 14             	call   *0x14(%eax)
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	eb 09                	jmp    801a18 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	eb 05                	jmp    801a18 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a13:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a18:	89 d0                	mov    %edx,%eax
  801a1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	6a 00                	push   $0x0
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	e8 e9 01 00 00       	call   801c1a <open>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 1b                	js     801a55 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	ff 75 0c             	pushl  0xc(%ebp)
  801a40:	50                   	push   %eax
  801a41:	e8 5b ff ff ff       	call   8019a1 <fstat>
  801a46:	89 c6                	mov    %eax,%esi
	close(fd);
  801a48:	89 1c 24             	mov    %ebx,(%esp)
  801a4b:	e8 fd fb ff ff       	call   80164d <close>
	return r;
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	89 f0                	mov    %esi,%eax
}
  801a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	89 c6                	mov    %eax,%esi
  801a63:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a65:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a6c:	75 12                	jne    801a80 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	6a 01                	push   $0x1
  801a73:	e8 3f 0d 00 00       	call   8027b7 <ipc_find_env>
  801a78:	a3 00 50 80 00       	mov    %eax,0x805000
  801a7d:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a80:	6a 07                	push   $0x7
  801a82:	68 00 60 80 00       	push   $0x806000
  801a87:	56                   	push   %esi
  801a88:	ff 35 00 50 80 00    	pushl  0x805000
  801a8e:	e8 d0 0c 00 00       	call   802763 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801a93:	83 c4 0c             	add    $0xc,%esp
  801a96:	6a 00                	push   $0x0
  801a98:	53                   	push   %ebx
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 41 0c 00 00       	call   8026e1 <ipc_recv>
}
  801aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abb:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac5:	b8 02 00 00 00       	mov    $0x2,%eax
  801aca:	e8 8d ff ff ff       	call   801a5c <fsipc>
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	8b 40 0c             	mov    0xc(%eax),%eax
  801add:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae7:	b8 06 00 00 00       	mov    $0x6,%eax
  801aec:	e8 6b ff ff ff       	call   801a5c <fsipc>
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	53                   	push   %ebx
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	8b 40 0c             	mov    0xc(%eax),%eax
  801b03:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b08:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b12:	e8 45 ff ff ff       	call   801a5c <fsipc>
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 2c                	js     801b47 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	68 00 60 80 00       	push   $0x806000
  801b23:	53                   	push   %ebx
  801b24:	e8 98 f0 ff ff       	call   800bc1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b29:	a1 80 60 80 00       	mov    0x806080,%eax
  801b2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b34:	a1 84 60 80 00       	mov    0x806084,%eax
  801b39:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	8b 45 10             	mov    0x10(%ebp),%eax
  801b55:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b5a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b5f:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b62:	8b 55 08             	mov    0x8(%ebp),%edx
  801b65:	8b 52 0c             	mov    0xc(%edx),%edx
  801b68:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = n;
  801b6e:	a3 04 60 80 00       	mov    %eax,0x806004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801b73:	50                   	push   %eax
  801b74:	ff 75 0c             	pushl  0xc(%ebp)
  801b77:	68 08 60 80 00       	push   $0x806008
  801b7c:	e8 d2 f1 ff ff       	call   800d53 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b81:	ba 00 00 00 00       	mov    $0x0,%edx
  801b86:	b8 04 00 00 00       	mov    $0x4,%eax
  801b8b:	e8 cc fe ff ff       	call   801a5c <fsipc>
            return r;

    return r;
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ba5:	89 35 04 60 80 00    	mov    %esi,0x806004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb5:	e8 a2 fe ff ff       	call   801a5c <fsipc>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 51                	js     801c11 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801bc0:	39 c6                	cmp    %eax,%esi
  801bc2:	73 19                	jae    801bdd <devfile_read+0x4b>
  801bc4:	68 c8 30 80 00       	push   $0x8030c8
  801bc9:	68 cf 30 80 00       	push   $0x8030cf
  801bce:	68 82 00 00 00       	push   $0x82
  801bd3:	68 e4 30 80 00       	push   $0x8030e4
  801bd8:	e8 07 e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801bdd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be2:	7e 19                	jle    801bfd <devfile_read+0x6b>
  801be4:	68 ef 30 80 00       	push   $0x8030ef
  801be9:	68 cf 30 80 00       	push   $0x8030cf
  801bee:	68 83 00 00 00       	push   $0x83
  801bf3:	68 e4 30 80 00       	push   $0x8030e4
  801bf8:	e8 e7 e8 ff ff       	call   8004e4 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	50                   	push   %eax
  801c01:	68 00 60 80 00       	push   $0x806000
  801c06:	ff 75 0c             	pushl  0xc(%ebp)
  801c09:	e8 45 f1 ff ff       	call   800d53 <memmove>
	return r;
  801c0e:	83 c4 10             	add    $0x10,%esp
}
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 20             	sub    $0x20,%esp
  801c21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c24:	53                   	push   %ebx
  801c25:	e8 5e ef ff ff       	call   800b88 <strlen>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c32:	7f 67                	jg     801c9b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c34:	83 ec 0c             	sub    $0xc,%esp
  801c37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3a:	50                   	push   %eax
  801c3b:	e8 94 f8 ff ff       	call   8014d4 <fd_alloc>
  801c40:	83 c4 10             	add    $0x10,%esp
		return r;
  801c43:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 57                	js     801ca0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	53                   	push   %ebx
  801c4d:	68 00 60 80 00       	push   $0x806000
  801c52:	e8 6a ef ff ff       	call   800bc1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5a:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	e8 f0 fd ff ff       	call   801a5c <fsipc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	79 14                	jns    801c89 <open+0x6f>
		fd_close(fd, 0);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	6a 00                	push   $0x0
  801c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7d:	e8 4a f9 ff ff       	call   8015cc <fd_close>
		return r;
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	89 da                	mov    %ebx,%edx
  801c87:	eb 17                	jmp    801ca0 <open+0x86>
	}

	return fd2num(fd);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	e8 19 f8 ff ff       	call   8014ad <fd2num>
  801c94:	89 c2                	mov    %eax,%edx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	eb 05                	jmp    801ca0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c9b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca0:	89 d0                	mov    %edx,%eax
  801ca2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cad:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb2:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb7:	e8 a0 fd ff ff       	call   801a5c <fsipc>
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().
	
	// 打开文件
	if ((r = open(prog, O_RDONLY)) < 0)
  801cca:	6a 00                	push   $0x0
  801ccc:	ff 75 08             	pushl  0x8(%ebp)
  801ccf:	e8 46 ff ff ff       	call   801c1a <open>
  801cd4:	89 c7                	mov    %eax,%edi
  801cd6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 95 04 00 00    	js     80217c <spawn+0x4be>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	68 00 02 00 00       	push   $0x200
  801cef:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cf5:	50                   	push   %eax
  801cf6:	57                   	push   %edi
  801cf7:	e8 1e fb ff ff       	call   80181a <readn>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d04:	75 0c                	jne    801d12 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801d06:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d0d:	45 4c 46 
  801d10:	74 33                	je     801d45 <spawn+0x87>
		close(fd);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d1b:	e8 2d f9 ff ff       	call   80164d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d20:	83 c4 0c             	add    $0xc,%esp
  801d23:	68 7f 45 4c 46       	push   $0x464c457f
  801d28:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d2e:	68 fb 30 80 00       	push   $0x8030fb
  801d33:	e8 85 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d40:	e9 da 04 00 00       	jmp    80221f <spawn+0x561>
  801d45:	b8 07 00 00 00       	mov    $0x7,%eax
  801d4a:	cd 30                	int    $0x30
  801d4c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d52:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 27 04 00 00    	js     802187 <spawn+0x4c9>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	// 设置寄存器信息
	child_tf = envs[ENVX(child)].env_tf;
  801d60:	89 c6                	mov    %eax,%esi
  801d62:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d68:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d6b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d71:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d77:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d7e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d84:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d8f:	be 00 00 00 00       	mov    $0x0,%esi
  801d94:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d97:	eb 13                	jmp    801dac <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	50                   	push   %eax
  801d9d:	e8 e6 ed ff ff       	call   800b88 <strlen>
  801da2:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801da6:	83 c3 01             	add    $0x1,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801db3:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801db6:	85 c0                	test   %eax,%eax
  801db8:	75 df                	jne    801d99 <spawn+0xdb>
  801dba:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801dc0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dc6:	bf 00 10 40 00       	mov    $0x401000,%edi
  801dcb:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dcd:	89 fa                	mov    %edi,%edx
  801dcf:	83 e2 fc             	and    $0xfffffffc,%edx
  801dd2:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801dd9:	29 c2                	sub    %eax,%edx
  801ddb:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801de1:	8d 42 f8             	lea    -0x8(%edx),%eax
  801de4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801de9:	0f 86 ae 03 00 00    	jbe    80219d <spawn+0x4df>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	6a 07                	push   $0x7
  801df4:	68 00 00 40 00       	push   $0x400000
  801df9:	6a 00                	push   $0x0
  801dfb:	e8 c4 f1 ff ff       	call   800fc4 <sys_page_alloc>
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	85 c0                	test   %eax,%eax
  801e05:	0f 88 99 03 00 00    	js     8021a4 <spawn+0x4e6>
  801e0b:	be 00 00 00 00       	mov    $0x0,%esi
  801e10:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e19:	eb 30                	jmp    801e4b <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801e1b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e21:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e27:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e2a:	83 ec 08             	sub    $0x8,%esp
  801e2d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e30:	57                   	push   %edi
  801e31:	e8 8b ed ff ff       	call   800bc1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e36:	83 c4 04             	add    $0x4,%esp
  801e39:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e3c:	e8 47 ed ff ff       	call   800b88 <strlen>
  801e41:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e45:	83 c6 01             	add    $0x1,%esi
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e51:	7f c8                	jg     801e1b <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e53:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e59:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801e5f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e66:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e6c:	74 19                	je     801e87 <spawn+0x1c9>
  801e6e:	68 88 31 80 00       	push   $0x803188
  801e73:	68 cf 30 80 00       	push   $0x8030cf
  801e78:	68 f8 00 00 00       	push   $0xf8
  801e7d:	68 15 31 80 00       	push   $0x803115
  801e82:	e8 5d e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e87:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e8d:	89 f8                	mov    %edi,%eax
  801e8f:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e94:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e97:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e9d:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ea0:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ea6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	6a 07                	push   $0x7
  801eb1:	68 00 d0 bf ee       	push   $0xeebfd000
  801eb6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ebc:	68 00 00 40 00       	push   $0x400000
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 3f f1 ff ff       	call   801007 <sys_page_map>
  801ec8:	89 c3                	mov    %eax,%ebx
  801eca:	83 c4 20             	add    $0x20,%esp
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	0f 88 38 03 00 00    	js     80220d <spawn+0x54f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	68 00 00 40 00       	push   $0x400000
  801edd:	6a 00                	push   $0x0
  801edf:	e8 65 f1 ff ff       	call   801049 <sys_page_unmap>
  801ee4:	89 c3                	mov    %eax,%ebx
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 88 1c 03 00 00    	js     80220d <spawn+0x54f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// 加载程序到进程空间
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ef1:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ef7:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801efe:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f04:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801f0b:	00 00 00 
  801f0e:	e9 88 01 00 00       	jmp    80209b <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801f13:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f19:	83 38 01             	cmpl   $0x1,(%eax)
  801f1c:	0f 85 6b 01 00 00    	jne    80208d <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f22:	89 c7                	mov    %eax,%edi
  801f24:	8b 40 18             	mov    0x18(%eax),%eax
  801f27:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f2d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f30:	83 f8 01             	cmp    $0x1,%eax
  801f33:	19 c0                	sbb    %eax,%eax
  801f35:	83 e0 fe             	and    $0xfffffffe,%eax
  801f38:	83 c0 07             	add    $0x7,%eax
  801f3b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f41:	89 f8                	mov    %edi,%eax
  801f43:	8b 7f 04             	mov    0x4(%edi),%edi
  801f46:	89 fa                	mov    %edi,%edx
  801f48:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801f4e:	8b 78 10             	mov    0x10(%eax),%edi
  801f51:	8b 48 14             	mov    0x14(%eax),%ecx
  801f54:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801f5a:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f5d:	89 f0                	mov    %esi,%eax
  801f5f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f64:	74 14                	je     801f7a <spawn+0x2bc>
		va -= i;
  801f66:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f68:	01 c1                	add    %eax,%ecx
  801f6a:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801f70:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f72:	29 c2                	sub    %eax,%edx
  801f74:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7f:	e9 f7 00 00 00       	jmp    80207b <spawn+0x3bd>
		if (i >= filesz) {
  801f84:	39 fb                	cmp    %edi,%ebx
  801f86:	72 27                	jb     801faf <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f91:	56                   	push   %esi
  801f92:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f98:	e8 27 f0 ff ff       	call   800fc4 <sys_page_alloc>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	0f 89 c7 00 00 00    	jns    80206f <spawn+0x3b1>
  801fa8:	89 c3                	mov    %eax,%ebx
  801faa:	e9 03 02 00 00       	jmp    8021b2 <spawn+0x4f4>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	6a 07                	push   $0x7
  801fb4:	68 00 00 40 00       	push   $0x400000
  801fb9:	6a 00                	push   $0x0
  801fbb:	e8 04 f0 ff ff       	call   800fc4 <sys_page_alloc>
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	0f 88 dd 01 00 00    	js     8021a8 <spawn+0x4ea>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fcb:	83 ec 08             	sub    $0x8,%esp
  801fce:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801fd4:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801fda:	50                   	push   %eax
  801fdb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fe1:	e8 09 f9 ff ff       	call   8018ef <seek>
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	0f 88 bb 01 00 00    	js     8021ac <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ff1:	83 ec 04             	sub    $0x4,%esp
  801ff4:	89 f8                	mov    %edi,%eax
  801ff6:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ffc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802001:	ba 00 10 00 00       	mov    $0x1000,%edx
  802006:	0f 47 c2             	cmova  %edx,%eax
  802009:	50                   	push   %eax
  80200a:	68 00 00 40 00       	push   $0x400000
  80200f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802015:	e8 00 f8 ff ff       	call   80181a <readn>
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	85 c0                	test   %eax,%eax
  80201f:	0f 88 8b 01 00 00    	js     8021b0 <spawn+0x4f2>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802025:	83 ec 0c             	sub    $0xc,%esp
  802028:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80202e:	56                   	push   %esi
  80202f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802035:	68 00 00 40 00       	push   $0x400000
  80203a:	6a 00                	push   $0x0
  80203c:	e8 c6 ef ff ff       	call   801007 <sys_page_map>
  802041:	83 c4 20             	add    $0x20,%esp
  802044:	85 c0                	test   %eax,%eax
  802046:	79 15                	jns    80205d <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802048:	50                   	push   %eax
  802049:	68 21 31 80 00       	push   $0x803121
  80204e:	68 2b 01 00 00       	push   $0x12b
  802053:	68 15 31 80 00       	push   $0x803115
  802058:	e8 87 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  80205d:	83 ec 08             	sub    $0x8,%esp
  802060:	68 00 00 40 00       	push   $0x400000
  802065:	6a 00                	push   $0x0
  802067:	e8 dd ef ff ff       	call   801049 <sys_page_unmap>
  80206c:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80206f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802075:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80207b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802081:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802087:	0f 82 f7 fe ff ff    	jb     801f84 <spawn+0x2c6>
		return r;

	// 加载程序到进程空间
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80208d:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802094:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80209b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020a2:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8020a8:	0f 8c 65 fe ff ff    	jl     801f13 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020b7:	e8 91 f5 ff ff       	call   80164d <close>
  8020bc:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	void *addr;

	for (addr = 0; addr < (void *) USTACKTOP; addr += PGSIZE) {
  8020bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8020ca:	89 d8                	mov    %ebx,%eax
  8020cc:	c1 e8 16             	shr    $0x16,%eax
  8020cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020d6:	a8 01                	test   $0x1,%al
  8020d8:	74 4e                	je     802128 <spawn+0x46a>
  8020da:	89 d8                	mov    %ebx,%eax
  8020dc:	c1 e8 0c             	shr    $0xc,%eax
  8020df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020e6:	f6 c2 01             	test   $0x1,%dl
  8020e9:	74 3d                	je     802128 <spawn+0x46a>
			&& (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  8020eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020f2:	f6 c2 04             	test   $0x4,%dl
  8020f5:	74 31                	je     802128 <spawn+0x46a>
  8020f7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020fe:	f6 c6 04             	test   $0x4,%dh
  802101:	74 25                	je     802128 <spawn+0x46a>
			if ((r = sys_page_map(0, addr, child, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0) 
  802103:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80210a:	83 ec 0c             	sub    $0xc,%esp
  80210d:	25 07 0e 00 00       	and    $0xe07,%eax
  802112:	50                   	push   %eax
  802113:	53                   	push   %ebx
  802114:	56                   	push   %esi
  802115:	53                   	push   %ebx
  802116:	6a 00                	push   $0x0
  802118:	e8 ea ee ff ff       	call   801007 <sys_page_map>
  80211d:	83 c4 20             	add    $0x20,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	0f 88 ab 00 00 00    	js     8021d3 <spawn+0x515>
{
	// LAB 5: Your code here.
	int r;
	void *addr;

	for (addr = 0; addr < (void *) USTACKTOP; addr += PGSIZE) {
  802128:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80212e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802134:	75 94                	jne    8020ca <spawn+0x40c>
  802136:	e9 ad 00 00 00       	jmp    8021e8 <spawn+0x52a>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	// 初始化新建进程的寄存器信息
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80213b:	50                   	push   %eax
  80213c:	68 3e 31 80 00       	push   $0x80313e
  802141:	68 8b 00 00 00       	push   $0x8b
  802146:	68 15 31 80 00       	push   $0x803115
  80214b:	e8 94 e3 ff ff       	call   8004e4 <_panic>

	// 设置进程状态
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802150:	83 ec 08             	sub    $0x8,%esp
  802153:	6a 02                	push   $0x2
  802155:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80215b:	e8 2b ef ff ff       	call   80108b <sys_env_set_status>
  802160:	83 c4 10             	add    $0x10,%esp
  802163:	85 c0                	test   %eax,%eax
  802165:	79 2b                	jns    802192 <spawn+0x4d4>
		panic("sys_env_set_status: %e", r);
  802167:	50                   	push   %eax
  802168:	68 58 31 80 00       	push   $0x803158
  80216d:	68 8f 00 00 00       	push   $0x8f
  802172:	68 15 31 80 00       	push   $0x803115
  802177:	e8 68 e3 ff ff       	call   8004e4 <_panic>
	//
	//   - Start the child process running with sys_env_set_status().
	
	// 打开文件
	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80217c:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802182:	e9 98 00 00 00       	jmp    80221f <spawn+0x561>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802187:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80218d:	e9 8d 00 00 00       	jmp    80221f <spawn+0x561>

	// 设置进程状态
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802192:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802198:	e9 82 00 00 00       	jmp    80221f <spawn+0x561>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80219d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8021a2:	eb 7b                	jmp    80221f <spawn+0x561>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	eb 77                	jmp    80221f <spawn+0x561>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8021a8:	89 c3                	mov    %eax,%ebx
  8021aa:	eb 06                	jmp    8021b2 <spawn+0x4f4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8021ac:	89 c3                	mov    %eax,%ebx
  8021ae:	eb 02                	jmp    8021b2 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8021b0:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8021b2:	83 ec 0c             	sub    $0xc,%esp
  8021b5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021bb:	e8 85 ed ff ff       	call   800f45 <sys_env_destroy>
	close(fd);
  8021c0:	83 c4 04             	add    $0x4,%esp
  8021c3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021c9:	e8 7f f4 ff ff       	call   80164d <close>
	return r;
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	eb 4c                	jmp    80221f <spawn+0x561>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8021d3:	50                   	push   %eax
  8021d4:	68 6f 31 80 00       	push   $0x80316f
  8021d9:	68 87 00 00 00       	push   $0x87
  8021de:	68 15 31 80 00       	push   $0x803115
  8021e3:	e8 fc e2 ff ff       	call   8004e4 <_panic>

	// 初始化新建进程的寄存器信息
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021e8:	83 ec 08             	sub    $0x8,%esp
  8021eb:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021f1:	50                   	push   %eax
  8021f2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021f8:	e8 d0 ee ff ff       	call   8010cd <sys_env_set_trapframe>
  8021fd:	83 c4 10             	add    $0x10,%esp
  802200:	85 c0                	test   %eax,%eax
  802202:	0f 89 48 ff ff ff    	jns    802150 <spawn+0x492>
  802208:	e9 2e ff ff ff       	jmp    80213b <spawn+0x47d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80220d:	83 ec 08             	sub    $0x8,%esp
  802210:	68 00 00 40 00       	push   $0x400000
  802215:	6a 00                	push   $0x0
  802217:	e8 2d ee ff ff       	call   801049 <sys_page_unmap>
  80221c:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80221f:	89 d8                	mov    %ebx,%eax
  802221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    

00802229 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	56                   	push   %esi
  80222d:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80222e:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802236:	eb 03                	jmp    80223b <spawnl+0x12>
		argc++;
  802238:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80223b:	83 c2 04             	add    $0x4,%edx
  80223e:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802242:	75 f4                	jne    802238 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802244:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  80224b:	83 e2 f0             	and    $0xfffffff0,%edx
  80224e:	29 d4                	sub    %edx,%esp
  802250:	8d 54 24 03          	lea    0x3(%esp),%edx
  802254:	c1 ea 02             	shr    $0x2,%edx
  802257:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80225e:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802263:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80226a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802271:	00 
  802272:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802274:	b8 00 00 00 00       	mov    $0x0,%eax
  802279:	eb 0a                	jmp    802285 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80227b:	83 c0 01             	add    $0x1,%eax
  80227e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802282:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802285:	39 d0                	cmp    %edx,%eax
  802287:	75 f2                	jne    80227b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802289:	83 ec 08             	sub    $0x8,%esp
  80228c:	56                   	push   %esi
  80228d:	ff 75 08             	pushl  0x8(%ebp)
  802290:	e8 29 fa ff ff       	call   801cbe <spawn>
}
  802295:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    

0080229c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022a4:	83 ec 0c             	sub    $0xc,%esp
  8022a7:	ff 75 08             	pushl  0x8(%ebp)
  8022aa:	e8 0e f2 ff ff       	call   8014bd <fd2data>
  8022af:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022b1:	83 c4 08             	add    $0x8,%esp
  8022b4:	68 b0 31 80 00       	push   $0x8031b0
  8022b9:	53                   	push   %ebx
  8022ba:	e8 02 e9 ff ff       	call   800bc1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022bf:	8b 46 04             	mov    0x4(%esi),%eax
  8022c2:	2b 06                	sub    (%esi),%eax
  8022c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022d1:	00 00 00 
	stat->st_dev = &devpipe;
  8022d4:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8022db:	40 80 00 
	return 0;
}
  8022de:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e6:	5b                   	pop    %ebx
  8022e7:	5e                   	pop    %esi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	53                   	push   %ebx
  8022ee:	83 ec 0c             	sub    $0xc,%esp
  8022f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022f4:	53                   	push   %ebx
  8022f5:	6a 00                	push   $0x0
  8022f7:	e8 4d ed ff ff       	call   801049 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022fc:	89 1c 24             	mov    %ebx,(%esp)
  8022ff:	e8 b9 f1 ff ff       	call   8014bd <fd2data>
  802304:	83 c4 08             	add    $0x8,%esp
  802307:	50                   	push   %eax
  802308:	6a 00                	push   $0x0
  80230a:	e8 3a ed ff ff       	call   801049 <sys_page_unmap>
}
  80230f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802312:	c9                   	leave  
  802313:	c3                   	ret    

00802314 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	57                   	push   %edi
  802318:	56                   	push   %esi
  802319:	53                   	push   %ebx
  80231a:	83 ec 1c             	sub    $0x1c,%esp
  80231d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802320:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802322:	a1 04 50 80 00       	mov    0x805004,%eax
  802327:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80232a:	83 ec 0c             	sub    $0xc,%esp
  80232d:	ff 75 e0             	pushl  -0x20(%ebp)
  802330:	e8 bb 04 00 00       	call   8027f0 <pageref>
  802335:	89 c3                	mov    %eax,%ebx
  802337:	89 3c 24             	mov    %edi,(%esp)
  80233a:	e8 b1 04 00 00       	call   8027f0 <pageref>
  80233f:	83 c4 10             	add    $0x10,%esp
  802342:	39 c3                	cmp    %eax,%ebx
  802344:	0f 94 c1             	sete   %cl
  802347:	0f b6 c9             	movzbl %cl,%ecx
  80234a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80234d:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802353:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802356:	39 ce                	cmp    %ecx,%esi
  802358:	74 1b                	je     802375 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80235a:	39 c3                	cmp    %eax,%ebx
  80235c:	75 c4                	jne    802322 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80235e:	8b 42 58             	mov    0x58(%edx),%eax
  802361:	ff 75 e4             	pushl  -0x1c(%ebp)
  802364:	50                   	push   %eax
  802365:	56                   	push   %esi
  802366:	68 b7 31 80 00       	push   $0x8031b7
  80236b:	e8 4d e2 ff ff       	call   8005bd <cprintf>
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	eb ad                	jmp    802322 <_pipeisclosed+0xe>
	}
}
  802375:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80237b:	5b                   	pop    %ebx
  80237c:	5e                   	pop    %esi
  80237d:	5f                   	pop    %edi
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 28             	sub    $0x28,%esp
  802389:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80238c:	56                   	push   %esi
  80238d:	e8 2b f1 ff ff       	call   8014bd <fd2data>
  802392:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	bf 00 00 00 00       	mov    $0x0,%edi
  80239c:	eb 4b                	jmp    8023e9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80239e:	89 da                	mov    %ebx,%edx
  8023a0:	89 f0                	mov    %esi,%eax
  8023a2:	e8 6d ff ff ff       	call   802314 <_pipeisclosed>
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	75 48                	jne    8023f3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023ab:	e8 f5 eb ff ff       	call   800fa5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023b0:	8b 43 04             	mov    0x4(%ebx),%eax
  8023b3:	8b 0b                	mov    (%ebx),%ecx
  8023b5:	8d 51 20             	lea    0x20(%ecx),%edx
  8023b8:	39 d0                	cmp    %edx,%eax
  8023ba:	73 e2                	jae    80239e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023bf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023c3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023c6:	89 c2                	mov    %eax,%edx
  8023c8:	c1 fa 1f             	sar    $0x1f,%edx
  8023cb:	89 d1                	mov    %edx,%ecx
  8023cd:	c1 e9 1b             	shr    $0x1b,%ecx
  8023d0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023d3:	83 e2 1f             	and    $0x1f,%edx
  8023d6:	29 ca                	sub    %ecx,%edx
  8023d8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8023dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023e0:	83 c0 01             	add    $0x1,%eax
  8023e3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023e6:	83 c7 01             	add    $0x1,%edi
  8023e9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023ec:	75 c2                	jne    8023b0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f1:	eb 05                	jmp    8023f8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023fb:	5b                   	pop    %ebx
  8023fc:	5e                   	pop    %esi
  8023fd:	5f                   	pop    %edi
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	57                   	push   %edi
  802404:	56                   	push   %esi
  802405:	53                   	push   %ebx
  802406:	83 ec 18             	sub    $0x18,%esp
  802409:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80240c:	57                   	push   %edi
  80240d:	e8 ab f0 ff ff       	call   8014bd <fd2data>
  802412:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802414:	83 c4 10             	add    $0x10,%esp
  802417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80241c:	eb 3d                	jmp    80245b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80241e:	85 db                	test   %ebx,%ebx
  802420:	74 04                	je     802426 <devpipe_read+0x26>
				return i;
  802422:	89 d8                	mov    %ebx,%eax
  802424:	eb 44                	jmp    80246a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802426:	89 f2                	mov    %esi,%edx
  802428:	89 f8                	mov    %edi,%eax
  80242a:	e8 e5 fe ff ff       	call   802314 <_pipeisclosed>
  80242f:	85 c0                	test   %eax,%eax
  802431:	75 32                	jne    802465 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802433:	e8 6d eb ff ff       	call   800fa5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802438:	8b 06                	mov    (%esi),%eax
  80243a:	3b 46 04             	cmp    0x4(%esi),%eax
  80243d:	74 df                	je     80241e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80243f:	99                   	cltd   
  802440:	c1 ea 1b             	shr    $0x1b,%edx
  802443:	01 d0                	add    %edx,%eax
  802445:	83 e0 1f             	and    $0x1f,%eax
  802448:	29 d0                	sub    %edx,%eax
  80244a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80244f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802452:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802455:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802458:	83 c3 01             	add    $0x1,%ebx
  80245b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80245e:	75 d8                	jne    802438 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802460:	8b 45 10             	mov    0x10(%ebp),%eax
  802463:	eb 05                	jmp    80246a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802465:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80246a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    

00802472 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	56                   	push   %esi
  802476:	53                   	push   %ebx
  802477:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80247a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80247d:	50                   	push   %eax
  80247e:	e8 51 f0 ff ff       	call   8014d4 <fd_alloc>
  802483:	83 c4 10             	add    $0x10,%esp
  802486:	89 c2                	mov    %eax,%edx
  802488:	85 c0                	test   %eax,%eax
  80248a:	0f 88 2c 01 00 00    	js     8025bc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802490:	83 ec 04             	sub    $0x4,%esp
  802493:	68 07 04 00 00       	push   $0x407
  802498:	ff 75 f4             	pushl  -0xc(%ebp)
  80249b:	6a 00                	push   $0x0
  80249d:	e8 22 eb ff ff       	call   800fc4 <sys_page_alloc>
  8024a2:	83 c4 10             	add    $0x10,%esp
  8024a5:	89 c2                	mov    %eax,%edx
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	0f 88 0d 01 00 00    	js     8025bc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024af:	83 ec 0c             	sub    $0xc,%esp
  8024b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024b5:	50                   	push   %eax
  8024b6:	e8 19 f0 ff ff       	call   8014d4 <fd_alloc>
  8024bb:	89 c3                	mov    %eax,%ebx
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	0f 88 e2 00 00 00    	js     8025aa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024c8:	83 ec 04             	sub    $0x4,%esp
  8024cb:	68 07 04 00 00       	push   $0x407
  8024d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8024d3:	6a 00                	push   $0x0
  8024d5:	e8 ea ea ff ff       	call   800fc4 <sys_page_alloc>
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	0f 88 c3 00 00 00    	js     8025aa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024e7:	83 ec 0c             	sub    $0xc,%esp
  8024ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ed:	e8 cb ef ff ff       	call   8014bd <fd2data>
  8024f2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024f4:	83 c4 0c             	add    $0xc,%esp
  8024f7:	68 07 04 00 00       	push   $0x407
  8024fc:	50                   	push   %eax
  8024fd:	6a 00                	push   $0x0
  8024ff:	e8 c0 ea ff ff       	call   800fc4 <sys_page_alloc>
  802504:	89 c3                	mov    %eax,%ebx
  802506:	83 c4 10             	add    $0x10,%esp
  802509:	85 c0                	test   %eax,%eax
  80250b:	0f 88 89 00 00 00    	js     80259a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802511:	83 ec 0c             	sub    $0xc,%esp
  802514:	ff 75 f0             	pushl  -0x10(%ebp)
  802517:	e8 a1 ef ff ff       	call   8014bd <fd2data>
  80251c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802523:	50                   	push   %eax
  802524:	6a 00                	push   $0x0
  802526:	56                   	push   %esi
  802527:	6a 00                	push   $0x0
  802529:	e8 d9 ea ff ff       	call   801007 <sys_page_map>
  80252e:	89 c3                	mov    %eax,%ebx
  802530:	83 c4 20             	add    $0x20,%esp
  802533:	85 c0                	test   %eax,%eax
  802535:	78 55                	js     80258c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802537:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80253d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802540:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802545:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80254c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802555:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80255a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802561:	83 ec 0c             	sub    $0xc,%esp
  802564:	ff 75 f4             	pushl  -0xc(%ebp)
  802567:	e8 41 ef ff ff       	call   8014ad <fd2num>
  80256c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80256f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802571:	83 c4 04             	add    $0x4,%esp
  802574:	ff 75 f0             	pushl  -0x10(%ebp)
  802577:	e8 31 ef ff ff       	call   8014ad <fd2num>
  80257c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80257f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802582:	83 c4 10             	add    $0x10,%esp
  802585:	ba 00 00 00 00       	mov    $0x0,%edx
  80258a:	eb 30                	jmp    8025bc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80258c:	83 ec 08             	sub    $0x8,%esp
  80258f:	56                   	push   %esi
  802590:	6a 00                	push   $0x0
  802592:	e8 b2 ea ff ff       	call   801049 <sys_page_unmap>
  802597:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80259a:	83 ec 08             	sub    $0x8,%esp
  80259d:	ff 75 f0             	pushl  -0x10(%ebp)
  8025a0:	6a 00                	push   $0x0
  8025a2:	e8 a2 ea ff ff       	call   801049 <sys_page_unmap>
  8025a7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8025aa:	83 ec 08             	sub    $0x8,%esp
  8025ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b0:	6a 00                	push   $0x0
  8025b2:	e8 92 ea ff ff       	call   801049 <sys_page_unmap>
  8025b7:	83 c4 10             	add    $0x10,%esp
  8025ba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8025bc:	89 d0                	mov    %edx,%eax
  8025be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025c1:	5b                   	pop    %ebx
  8025c2:	5e                   	pop    %esi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    

008025c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ce:	50                   	push   %eax
  8025cf:	ff 75 08             	pushl  0x8(%ebp)
  8025d2:	e8 4c ef ff ff       	call   801523 <fd_lookup>
  8025d7:	83 c4 10             	add    $0x10,%esp
  8025da:	85 c0                	test   %eax,%eax
  8025dc:	78 18                	js     8025f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025de:	83 ec 0c             	sub    $0xc,%esp
  8025e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8025e4:	e8 d4 ee ff ff       	call   8014bd <fd2data>
	return _pipeisclosed(fd, p);
  8025e9:	89 c2                	mov    %eax,%edx
  8025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ee:	e8 21 fd ff ff       	call   802314 <_pipeisclosed>
  8025f3:	83 c4 10             	add    $0x10,%esp
}
  8025f6:	c9                   	leave  
  8025f7:	c3                   	ret    

008025f8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	56                   	push   %esi
  8025fc:	53                   	push   %ebx
  8025fd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802600:	85 f6                	test   %esi,%esi
  802602:	75 16                	jne    80261a <wait+0x22>
  802604:	68 cf 31 80 00       	push   $0x8031cf
  802609:	68 cf 30 80 00       	push   $0x8030cf
  80260e:	6a 09                	push   $0x9
  802610:	68 da 31 80 00       	push   $0x8031da
  802615:	e8 ca de ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  80261a:	89 f3                	mov    %esi,%ebx
  80261c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802622:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802625:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80262b:	eb 05                	jmp    802632 <wait+0x3a>
		sys_yield();
  80262d:	e8 73 e9 ff ff       	call   800fa5 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802632:	8b 43 48             	mov    0x48(%ebx),%eax
  802635:	39 c6                	cmp    %eax,%esi
  802637:	75 07                	jne    802640 <wait+0x48>
  802639:	8b 43 54             	mov    0x54(%ebx),%eax
  80263c:	85 c0                	test   %eax,%eax
  80263e:	75 ed                	jne    80262d <wait+0x35>
		sys_yield();
}
  802640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802643:	5b                   	pop    %ebx
  802644:	5e                   	pop    %esi
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    

00802647 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802647:	55                   	push   %ebp
  802648:	89 e5                	mov    %esp,%ebp
  80264a:	53                   	push   %ebx
  80264b:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  80264e:	e8 33 e9 ff ff       	call   800f86 <sys_getenvid>
  802653:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  802655:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80265c:	75 29                	jne    802687 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  80265e:	83 ec 04             	sub    $0x4,%esp
  802661:	6a 07                	push   $0x7
  802663:	68 00 f0 bf ee       	push   $0xeebff000
  802668:	50                   	push   %eax
  802669:	e8 56 e9 ff ff       	call   800fc4 <sys_page_alloc>
  80266e:	83 c4 10             	add    $0x10,%esp
  802671:	85 c0                	test   %eax,%eax
  802673:	79 12                	jns    802687 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  802675:	50                   	push   %eax
  802676:	68 e5 31 80 00       	push   $0x8031e5
  80267b:	6a 24                	push   $0x24
  80267d:	68 fe 31 80 00       	push   $0x8031fe
  802682:	e8 5d de ff ff       	call   8004e4 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  802687:	8b 45 08             	mov    0x8(%ebp),%eax
  80268a:	a3 00 70 80 00       	mov    %eax,0x807000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80268f:	83 ec 08             	sub    $0x8,%esp
  802692:	68 bb 26 80 00       	push   $0x8026bb
  802697:	53                   	push   %ebx
  802698:	e8 72 ea ff ff       	call   80110f <sys_env_set_pgfault_upcall>
  80269d:	83 c4 10             	add    $0x10,%esp
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	79 12                	jns    8026b6 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  8026a4:	50                   	push   %eax
  8026a5:	68 e5 31 80 00       	push   $0x8031e5
  8026aa:	6a 2e                	push   $0x2e
  8026ac:	68 fe 31 80 00       	push   $0x8031fe
  8026b1:	e8 2e de ff ff       	call   8004e4 <_panic>
}
  8026b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026b9:	c9                   	leave  
  8026ba:	c3                   	ret    

008026bb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026bb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026bc:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026c1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026c3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  8026c6:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8026ca:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  8026cd:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8026d1:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  8026d3:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8026d7:	83 c4 08             	add    $0x8,%esp
	popal
  8026da:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8026db:	83 c4 04             	add    $0x4,%esp
	popfl
  8026de:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  8026df:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026e0:	c3                   	ret    

008026e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026e1:	55                   	push   %ebp
  8026e2:	89 e5                	mov    %esp,%ebp
  8026e4:	57                   	push   %edi
  8026e5:	56                   	push   %esi
  8026e6:	53                   	push   %ebx
  8026e7:	83 ec 0c             	sub    $0xc,%esp
  8026ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8026ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  8026f3:	85 f6                	test   %esi,%esi
  8026f5:	74 06                	je     8026fd <ipc_recv+0x1c>
		*from_env_store = 0;
  8026f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  8026fd:	85 db                	test   %ebx,%ebx
  8026ff:	74 06                	je     802707 <ipc_recv+0x26>
		*perm_store = 0;
  802701:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  802707:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  802709:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80270e:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  802711:	83 ec 0c             	sub    $0xc,%esp
  802714:	50                   	push   %eax
  802715:	e8 5a ea ff ff       	call   801174 <sys_ipc_recv>
  80271a:	89 c7                	mov    %eax,%edi
  80271c:	83 c4 10             	add    $0x10,%esp
  80271f:	85 c0                	test   %eax,%eax
  802721:	79 14                	jns    802737 <ipc_recv+0x56>
		cprintf("im dead");
  802723:	83 ec 0c             	sub    $0xc,%esp
  802726:	68 0c 32 80 00       	push   $0x80320c
  80272b:	e8 8d de ff ff       	call   8005bd <cprintf>
		return r;
  802730:	83 c4 10             	add    $0x10,%esp
  802733:	89 f8                	mov    %edi,%eax
  802735:	eb 24                	jmp    80275b <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  802737:	85 f6                	test   %esi,%esi
  802739:	74 0a                	je     802745 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  80273b:	a1 04 50 80 00       	mov    0x805004,%eax
  802740:	8b 40 74             	mov    0x74(%eax),%eax
  802743:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  802745:	85 db                	test   %ebx,%ebx
  802747:	74 0a                	je     802753 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  802749:	a1 04 50 80 00       	mov    0x805004,%eax
  80274e:	8b 40 78             	mov    0x78(%eax),%eax
  802751:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  802753:	a1 04 50 80 00       	mov    0x805004,%eax
  802758:	8b 40 70             	mov    0x70(%eax),%eax
}
  80275b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80275e:	5b                   	pop    %ebx
  80275f:	5e                   	pop    %esi
  802760:	5f                   	pop    %edi
  802761:	5d                   	pop    %ebp
  802762:	c3                   	ret    

00802763 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802763:	55                   	push   %ebp
  802764:	89 e5                	mov    %esp,%ebp
  802766:	57                   	push   %edi
  802767:	56                   	push   %esi
  802768:	53                   	push   %ebx
  802769:	83 ec 0c             	sub    $0xc,%esp
  80276c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80276f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802772:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  802775:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  802777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80277c:	0f 44 d8             	cmove  %eax,%ebx
  80277f:	eb 1c                	jmp    80279d <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  802781:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802784:	74 12                	je     802798 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  802786:	50                   	push   %eax
  802787:	68 14 32 80 00       	push   $0x803214
  80278c:	6a 4e                	push   $0x4e
  80278e:	68 21 32 80 00       	push   $0x803221
  802793:	e8 4c dd ff ff       	call   8004e4 <_panic>
		sys_yield();
  802798:	e8 08 e8 ff ff       	call   800fa5 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80279d:	ff 75 14             	pushl  0x14(%ebp)
  8027a0:	53                   	push   %ebx
  8027a1:	56                   	push   %esi
  8027a2:	57                   	push   %edi
  8027a3:	e8 a9 e9 ff ff       	call   801151 <sys_ipc_try_send>
  8027a8:	83 c4 10             	add    $0x10,%esp
  8027ab:	85 c0                	test   %eax,%eax
  8027ad:	78 d2                	js     802781 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  8027af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b2:	5b                   	pop    %ebx
  8027b3:	5e                   	pop    %esi
  8027b4:	5f                   	pop    %edi
  8027b5:	5d                   	pop    %ebp
  8027b6:	c3                   	ret    

008027b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027b7:	55                   	push   %ebp
  8027b8:	89 e5                	mov    %esp,%ebp
  8027ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027c5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027cb:	8b 52 50             	mov    0x50(%edx),%edx
  8027ce:	39 ca                	cmp    %ecx,%edx
  8027d0:	75 0d                	jne    8027df <ipc_find_env+0x28>
			return envs[i].env_id;
  8027d2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027da:	8b 40 48             	mov    0x48(%eax),%eax
  8027dd:	eb 0f                	jmp    8027ee <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027df:	83 c0 01             	add    $0x1,%eax
  8027e2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027e7:	75 d9                	jne    8027c2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027ee:	5d                   	pop    %ebp
  8027ef:	c3                   	ret    

008027f0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027f0:	55                   	push   %ebp
  8027f1:	89 e5                	mov    %esp,%ebp
  8027f3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027f6:	89 d0                	mov    %edx,%eax
  8027f8:	c1 e8 16             	shr    $0x16,%eax
  8027fb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802802:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802807:	f6 c1 01             	test   $0x1,%cl
  80280a:	74 1d                	je     802829 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80280c:	c1 ea 0c             	shr    $0xc,%edx
  80280f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802816:	f6 c2 01             	test   $0x1,%dl
  802819:	74 0e                	je     802829 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80281b:	c1 ea 0c             	shr    $0xc,%edx
  80281e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802825:	ef 
  802826:	0f b7 c0             	movzwl %ax,%eax
}
  802829:	5d                   	pop    %ebp
  80282a:	c3                   	ret    
  80282b:	66 90                	xchg   %ax,%ax
  80282d:	66 90                	xchg   %ax,%ax
  80282f:	90                   	nop

00802830 <__udivdi3>:
  802830:	55                   	push   %ebp
  802831:	57                   	push   %edi
  802832:	56                   	push   %esi
  802833:	53                   	push   %ebx
  802834:	83 ec 1c             	sub    $0x1c,%esp
  802837:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80283b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80283f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802843:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802847:	85 f6                	test   %esi,%esi
  802849:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80284d:	89 ca                	mov    %ecx,%edx
  80284f:	89 f8                	mov    %edi,%eax
  802851:	75 3d                	jne    802890 <__udivdi3+0x60>
  802853:	39 cf                	cmp    %ecx,%edi
  802855:	0f 87 c5 00 00 00    	ja     802920 <__udivdi3+0xf0>
  80285b:	85 ff                	test   %edi,%edi
  80285d:	89 fd                	mov    %edi,%ebp
  80285f:	75 0b                	jne    80286c <__udivdi3+0x3c>
  802861:	b8 01 00 00 00       	mov    $0x1,%eax
  802866:	31 d2                	xor    %edx,%edx
  802868:	f7 f7                	div    %edi
  80286a:	89 c5                	mov    %eax,%ebp
  80286c:	89 c8                	mov    %ecx,%eax
  80286e:	31 d2                	xor    %edx,%edx
  802870:	f7 f5                	div    %ebp
  802872:	89 c1                	mov    %eax,%ecx
  802874:	89 d8                	mov    %ebx,%eax
  802876:	89 cf                	mov    %ecx,%edi
  802878:	f7 f5                	div    %ebp
  80287a:	89 c3                	mov    %eax,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	39 ce                	cmp    %ecx,%esi
  802892:	77 74                	ja     802908 <__udivdi3+0xd8>
  802894:	0f bd fe             	bsr    %esi,%edi
  802897:	83 f7 1f             	xor    $0x1f,%edi
  80289a:	0f 84 98 00 00 00    	je     802938 <__udivdi3+0x108>
  8028a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8028a5:	89 f9                	mov    %edi,%ecx
  8028a7:	89 c5                	mov    %eax,%ebp
  8028a9:	29 fb                	sub    %edi,%ebx
  8028ab:	d3 e6                	shl    %cl,%esi
  8028ad:	89 d9                	mov    %ebx,%ecx
  8028af:	d3 ed                	shr    %cl,%ebp
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	d3 e0                	shl    %cl,%eax
  8028b5:	09 ee                	or     %ebp,%esi
  8028b7:	89 d9                	mov    %ebx,%ecx
  8028b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028bd:	89 d5                	mov    %edx,%ebp
  8028bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028c3:	d3 ed                	shr    %cl,%ebp
  8028c5:	89 f9                	mov    %edi,%ecx
  8028c7:	d3 e2                	shl    %cl,%edx
  8028c9:	89 d9                	mov    %ebx,%ecx
  8028cb:	d3 e8                	shr    %cl,%eax
  8028cd:	09 c2                	or     %eax,%edx
  8028cf:	89 d0                	mov    %edx,%eax
  8028d1:	89 ea                	mov    %ebp,%edx
  8028d3:	f7 f6                	div    %esi
  8028d5:	89 d5                	mov    %edx,%ebp
  8028d7:	89 c3                	mov    %eax,%ebx
  8028d9:	f7 64 24 0c          	mull   0xc(%esp)
  8028dd:	39 d5                	cmp    %edx,%ebp
  8028df:	72 10                	jb     8028f1 <__udivdi3+0xc1>
  8028e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028e5:	89 f9                	mov    %edi,%ecx
  8028e7:	d3 e6                	shl    %cl,%esi
  8028e9:	39 c6                	cmp    %eax,%esi
  8028eb:	73 07                	jae    8028f4 <__udivdi3+0xc4>
  8028ed:	39 d5                	cmp    %edx,%ebp
  8028ef:	75 03                	jne    8028f4 <__udivdi3+0xc4>
  8028f1:	83 eb 01             	sub    $0x1,%ebx
  8028f4:	31 ff                	xor    %edi,%edi
  8028f6:	89 d8                	mov    %ebx,%eax
  8028f8:	89 fa                	mov    %edi,%edx
  8028fa:	83 c4 1c             	add    $0x1c,%esp
  8028fd:	5b                   	pop    %ebx
  8028fe:	5e                   	pop    %esi
  8028ff:	5f                   	pop    %edi
  802900:	5d                   	pop    %ebp
  802901:	c3                   	ret    
  802902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802908:	31 ff                	xor    %edi,%edi
  80290a:	31 db                	xor    %ebx,%ebx
  80290c:	89 d8                	mov    %ebx,%eax
  80290e:	89 fa                	mov    %edi,%edx
  802910:	83 c4 1c             	add    $0x1c,%esp
  802913:	5b                   	pop    %ebx
  802914:	5e                   	pop    %esi
  802915:	5f                   	pop    %edi
  802916:	5d                   	pop    %ebp
  802917:	c3                   	ret    
  802918:	90                   	nop
  802919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802920:	89 d8                	mov    %ebx,%eax
  802922:	f7 f7                	div    %edi
  802924:	31 ff                	xor    %edi,%edi
  802926:	89 c3                	mov    %eax,%ebx
  802928:	89 d8                	mov    %ebx,%eax
  80292a:	89 fa                	mov    %edi,%edx
  80292c:	83 c4 1c             	add    $0x1c,%esp
  80292f:	5b                   	pop    %ebx
  802930:	5e                   	pop    %esi
  802931:	5f                   	pop    %edi
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    
  802934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802938:	39 ce                	cmp    %ecx,%esi
  80293a:	72 0c                	jb     802948 <__udivdi3+0x118>
  80293c:	31 db                	xor    %ebx,%ebx
  80293e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802942:	0f 87 34 ff ff ff    	ja     80287c <__udivdi3+0x4c>
  802948:	bb 01 00 00 00       	mov    $0x1,%ebx
  80294d:	e9 2a ff ff ff       	jmp    80287c <__udivdi3+0x4c>
  802952:	66 90                	xchg   %ax,%ax
  802954:	66 90                	xchg   %ax,%ax
  802956:	66 90                	xchg   %ax,%ax
  802958:	66 90                	xchg   %ax,%ax
  80295a:	66 90                	xchg   %ax,%ax
  80295c:	66 90                	xchg   %ax,%ax
  80295e:	66 90                	xchg   %ax,%ax

00802960 <__umoddi3>:
  802960:	55                   	push   %ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	53                   	push   %ebx
  802964:	83 ec 1c             	sub    $0x1c,%esp
  802967:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80296b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80296f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802973:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802977:	85 d2                	test   %edx,%edx
  802979:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80297d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802981:	89 f3                	mov    %esi,%ebx
  802983:	89 3c 24             	mov    %edi,(%esp)
  802986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80298a:	75 1c                	jne    8029a8 <__umoddi3+0x48>
  80298c:	39 f7                	cmp    %esi,%edi
  80298e:	76 50                	jbe    8029e0 <__umoddi3+0x80>
  802990:	89 c8                	mov    %ecx,%eax
  802992:	89 f2                	mov    %esi,%edx
  802994:	f7 f7                	div    %edi
  802996:	89 d0                	mov    %edx,%eax
  802998:	31 d2                	xor    %edx,%edx
  80299a:	83 c4 1c             	add    $0x1c,%esp
  80299d:	5b                   	pop    %ebx
  80299e:	5e                   	pop    %esi
  80299f:	5f                   	pop    %edi
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    
  8029a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a8:	39 f2                	cmp    %esi,%edx
  8029aa:	89 d0                	mov    %edx,%eax
  8029ac:	77 52                	ja     802a00 <__umoddi3+0xa0>
  8029ae:	0f bd ea             	bsr    %edx,%ebp
  8029b1:	83 f5 1f             	xor    $0x1f,%ebp
  8029b4:	75 5a                	jne    802a10 <__umoddi3+0xb0>
  8029b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8029ba:	0f 82 e0 00 00 00    	jb     802aa0 <__umoddi3+0x140>
  8029c0:	39 0c 24             	cmp    %ecx,(%esp)
  8029c3:	0f 86 d7 00 00 00    	jbe    802aa0 <__umoddi3+0x140>
  8029c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029d1:	83 c4 1c             	add    $0x1c,%esp
  8029d4:	5b                   	pop    %ebx
  8029d5:	5e                   	pop    %esi
  8029d6:	5f                   	pop    %edi
  8029d7:	5d                   	pop    %ebp
  8029d8:	c3                   	ret    
  8029d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029e0:	85 ff                	test   %edi,%edi
  8029e2:	89 fd                	mov    %edi,%ebp
  8029e4:	75 0b                	jne    8029f1 <__umoddi3+0x91>
  8029e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029eb:	31 d2                	xor    %edx,%edx
  8029ed:	f7 f7                	div    %edi
  8029ef:	89 c5                	mov    %eax,%ebp
  8029f1:	89 f0                	mov    %esi,%eax
  8029f3:	31 d2                	xor    %edx,%edx
  8029f5:	f7 f5                	div    %ebp
  8029f7:	89 c8                	mov    %ecx,%eax
  8029f9:	f7 f5                	div    %ebp
  8029fb:	89 d0                	mov    %edx,%eax
  8029fd:	eb 99                	jmp    802998 <__umoddi3+0x38>
  8029ff:	90                   	nop
  802a00:	89 c8                	mov    %ecx,%eax
  802a02:	89 f2                	mov    %esi,%edx
  802a04:	83 c4 1c             	add    $0x1c,%esp
  802a07:	5b                   	pop    %ebx
  802a08:	5e                   	pop    %esi
  802a09:	5f                   	pop    %edi
  802a0a:	5d                   	pop    %ebp
  802a0b:	c3                   	ret    
  802a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a10:	8b 34 24             	mov    (%esp),%esi
  802a13:	bf 20 00 00 00       	mov    $0x20,%edi
  802a18:	89 e9                	mov    %ebp,%ecx
  802a1a:	29 ef                	sub    %ebp,%edi
  802a1c:	d3 e0                	shl    %cl,%eax
  802a1e:	89 f9                	mov    %edi,%ecx
  802a20:	89 f2                	mov    %esi,%edx
  802a22:	d3 ea                	shr    %cl,%edx
  802a24:	89 e9                	mov    %ebp,%ecx
  802a26:	09 c2                	or     %eax,%edx
  802a28:	89 d8                	mov    %ebx,%eax
  802a2a:	89 14 24             	mov    %edx,(%esp)
  802a2d:	89 f2                	mov    %esi,%edx
  802a2f:	d3 e2                	shl    %cl,%edx
  802a31:	89 f9                	mov    %edi,%ecx
  802a33:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a3b:	d3 e8                	shr    %cl,%eax
  802a3d:	89 e9                	mov    %ebp,%ecx
  802a3f:	89 c6                	mov    %eax,%esi
  802a41:	d3 e3                	shl    %cl,%ebx
  802a43:	89 f9                	mov    %edi,%ecx
  802a45:	89 d0                	mov    %edx,%eax
  802a47:	d3 e8                	shr    %cl,%eax
  802a49:	89 e9                	mov    %ebp,%ecx
  802a4b:	09 d8                	or     %ebx,%eax
  802a4d:	89 d3                	mov    %edx,%ebx
  802a4f:	89 f2                	mov    %esi,%edx
  802a51:	f7 34 24             	divl   (%esp)
  802a54:	89 d6                	mov    %edx,%esi
  802a56:	d3 e3                	shl    %cl,%ebx
  802a58:	f7 64 24 04          	mull   0x4(%esp)
  802a5c:	39 d6                	cmp    %edx,%esi
  802a5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a62:	89 d1                	mov    %edx,%ecx
  802a64:	89 c3                	mov    %eax,%ebx
  802a66:	72 08                	jb     802a70 <__umoddi3+0x110>
  802a68:	75 11                	jne    802a7b <__umoddi3+0x11b>
  802a6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a6e:	73 0b                	jae    802a7b <__umoddi3+0x11b>
  802a70:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a74:	1b 14 24             	sbb    (%esp),%edx
  802a77:	89 d1                	mov    %edx,%ecx
  802a79:	89 c3                	mov    %eax,%ebx
  802a7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a7f:	29 da                	sub    %ebx,%edx
  802a81:	19 ce                	sbb    %ecx,%esi
  802a83:	89 f9                	mov    %edi,%ecx
  802a85:	89 f0                	mov    %esi,%eax
  802a87:	d3 e0                	shl    %cl,%eax
  802a89:	89 e9                	mov    %ebp,%ecx
  802a8b:	d3 ea                	shr    %cl,%edx
  802a8d:	89 e9                	mov    %ebp,%ecx
  802a8f:	d3 ee                	shr    %cl,%esi
  802a91:	09 d0                	or     %edx,%eax
  802a93:	89 f2                	mov    %esi,%edx
  802a95:	83 c4 1c             	add    $0x1c,%esp
  802a98:	5b                   	pop    %ebx
  802a99:	5e                   	pop    %esi
  802a9a:	5f                   	pop    %edi
  802a9b:	5d                   	pop    %ebp
  802a9c:	c3                   	ret    
  802a9d:	8d 76 00             	lea    0x0(%esi),%esi
  802aa0:	29 f9                	sub    %edi,%ecx
  802aa2:	19 d6                	sbb    %edx,%esi
  802aa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802aa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802aac:	e9 18 ff ff ff       	jmp    8029c9 <__umoddi3+0x69>
