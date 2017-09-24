
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 3c 0e 00 00       	call   800e80 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 dd 11 00 00       	call   801230 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 00 21 80 00       	push   $0x802100
  800065:	6a 0f                	push   $0xf
  800067:	68 0d 21 80 00       	push   $0x80210d
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 1c 21 80 00       	push   $0x80211c
  80007b:	6a 11                	push   $0x11
  80007d:	68 0d 21 80 00       	push   $0x80210d
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 ed 11 00 00       	call   801280 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 36 21 80 00       	push   $0x802136
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 0d 21 80 00       	push   $0x80210d
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 3e 21 80 00       	push   $0x80213e
  8000b4:	e8 b7 08 00 00       	call   800970 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 4c 21 80 00       	push   $0x80214c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 b4 18 00 00       	call   801984 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 50 21 80 00       	push   $0x802150
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 a0 18 00 00       	call   801984 <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 68 21 80 00       	push   $0x802168
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 96 09 00 00       	call   800a9c <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 ea 0a 00 00       	call   800c2e <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 95 0c 00 00       	call   800de3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 06 0d 00 00       	call   800e80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 82 0c 00 00       	call   800e01 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 2d 0c 00 00       	call   800de3 <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 9e 11 00 00       	call   80136c <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 0e 0f 00 00       	call   801106 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 96 0e 00 00       	call   8010b7 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 63 0c 00 00       	call   800e9f <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 2d 0e 00 00       	call   801090 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 e5 0b 00 00       	call   800e61 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 9e 0f 00 00       	call   80125b <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 59 0b 00 00       	call   800e20 <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 82 0b 00 00       	call   800e61 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 80 21 80 00       	push   $0x802180
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 66 21 80 00 	movl   $0x802166,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 a1 0a 00 00       	call   800de3 <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 1a 01 00 00       	call   8004a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 46 0a 00 00       	call   800de3 <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 53 1a 00 00       	call   801e60 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 40 1b 00 00       	call   801f90 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 a3 21 80 00 	movsbl 0x8021a3(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800472:	8b 10                	mov    (%eax),%edx
  800474:	3b 50 04             	cmp    0x4(%eax),%edx
  800477:	73 0a                	jae    800483 <sprintputch+0x1b>
		*b->buf++ = ch;
  800479:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047c:	89 08                	mov    %ecx,(%eax)
  80047e:	8b 45 08             	mov    0x8(%ebp),%eax
  800481:	88 02                	mov    %al,(%edx)
}
  800483:	5d                   	pop    %ebp
  800484:	c3                   	ret    

00800485 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80048b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048e:	50                   	push   %eax
  80048f:	ff 75 10             	pushl  0x10(%ebp)
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	ff 75 08             	pushl  0x8(%ebp)
  800498:	e8 05 00 00 00       	call   8004a2 <vprintfmt>
	va_end(ap);
}
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    

008004a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	57                   	push   %edi
  8004a6:	56                   	push   %esi
  8004a7:	53                   	push   %ebx
  8004a8:	83 ec 2c             	sub    $0x2c,%esp
  8004ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004b4:	eb 12                	jmp    8004c8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	0f 84 42 04 00 00    	je     800900 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	53                   	push   %ebx
  8004c2:	50                   	push   %eax
  8004c3:	ff d6                	call   *%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c8:	83 c7 01             	add    $0x1,%edi
  8004cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cf:	83 f8 25             	cmp    $0x25,%eax
  8004d2:	75 e2                	jne    8004b6 <vprintfmt+0x14>
  8004d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f2:	eb 07                	jmp    8004fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8d 47 01             	lea    0x1(%edi),%eax
  8004fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800501:	0f b6 07             	movzbl (%edi),%eax
  800504:	0f b6 d0             	movzbl %al,%edx
  800507:	83 e8 23             	sub    $0x23,%eax
  80050a:	3c 55                	cmp    $0x55,%al
  80050c:	0f 87 d3 03 00 00    	ja     8008e5 <vprintfmt+0x443>
  800512:	0f b6 c0             	movzbl %al,%eax
  800515:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80051f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800523:	eb d6                	jmp    8004fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800528:	b8 00 00 00 00       	mov    $0x0,%eax
  80052d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800530:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800533:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800537:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80053a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80053d:	83 f9 09             	cmp    $0x9,%ecx
  800540:	77 3f                	ja     800581 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800542:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800545:	eb e9                	jmp    800530 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 04             	lea    0x4(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055b:	eb 2a                	jmp    800587 <vprintfmt+0xe5>
  80055d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800560:	85 c0                	test   %eax,%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	0f 49 d0             	cmovns %eax,%edx
  80056a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800570:	eb 89                	jmp    8004fb <vprintfmt+0x59>
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800575:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057c:	e9 7a ff ff ff       	jmp    8004fb <vprintfmt+0x59>
  800581:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 6a ff ff ff    	jns    8004fb <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 58 ff ff ff       	jmp    8004fb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 4d ff ff ff       	jmp    8004fb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 78 04             	lea    0x4(%eax),%edi
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	ff 30                	pushl  (%eax)
  8005ba:	ff d6                	call   *%esi
			break;
  8005bc:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005bf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 fe fe ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 78 04             	lea    0x4(%eax),%edi
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	99                   	cltd   
  8005d3:	31 d0                	xor    %edx,%eax
  8005d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d7:	83 f8 0f             	cmp    $0xf,%eax
  8005da:	7f 0b                	jg     8005e7 <vprintfmt+0x145>
  8005dc:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	75 1b                	jne    800602 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8005e7:	50                   	push   %eax
  8005e8:	68 bb 21 80 00       	push   $0x8021bb
  8005ed:	53                   	push   %ebx
  8005ee:	56                   	push   %esi
  8005ef:	e8 91 fe ff ff       	call   800485 <printfmt>
  8005f4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 c6 fe ff ff       	jmp    8004c8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 85 25 80 00       	push   $0x802585
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 76 fe ff ff       	call   800485 <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800618:	e9 ab fe ff ff       	jmp    8004c8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	83 c0 04             	add    $0x4,%eax
  800623:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80062b:	85 ff                	test   %edi,%edi
  80062d:	b8 b4 21 80 00       	mov    $0x8021b4,%eax
  800632:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800635:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800639:	0f 8e 94 00 00 00    	jle    8006d3 <vprintfmt+0x231>
  80063f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800643:	0f 84 98 00 00 00    	je     8006e1 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 d0             	pushl  -0x30(%ebp)
  80064f:	57                   	push   %edi
  800650:	e8 26 04 00 00       	call   800a7b <strnlen>
  800655:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800658:	29 c1                	sub    %eax,%ecx
  80065a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80065d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800660:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800664:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800667:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80066a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066c:	eb 0f                	jmp    80067d <vprintfmt+0x1db>
					putch(padc, putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	ff 75 e0             	pushl  -0x20(%ebp)
  800675:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ef 01             	sub    $0x1,%edi
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	85 ff                	test   %edi,%edi
  80067f:	7f ed                	jg     80066e <vprintfmt+0x1cc>
  800681:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800684:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800687:	85 c9                	test   %ecx,%ecx
  800689:	b8 00 00 00 00       	mov    $0x0,%eax
  80068e:	0f 49 c1             	cmovns %ecx,%eax
  800691:	29 c1                	sub    %eax,%ecx
  800693:	89 75 08             	mov    %esi,0x8(%ebp)
  800696:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800699:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069c:	89 cb                	mov    %ecx,%ebx
  80069e:	eb 4d                	jmp    8006ed <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x21f>
  8006a6:	0f be c0             	movsbl %al,%eax
  8006a9:	83 e8 20             	sub    $0x20,%eax
  8006ac:	83 f8 5e             	cmp    $0x5e,%eax
  8006af:	76 10                	jbe    8006c1 <vprintfmt+0x21f>
					putch('?', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	ff 75 0c             	pushl  0xc(%ebp)
  8006b7:	6a 3f                	push   $0x3f
  8006b9:	ff 55 08             	call   *0x8(%ebp)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 0d                	jmp    8006ce <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	52                   	push   %edx
  8006c8:	ff 55 08             	call   *0x8(%ebp)
  8006cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ce:	83 eb 01             	sub    $0x1,%ebx
  8006d1:	eb 1a                	jmp    8006ed <vprintfmt+0x24b>
  8006d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006df:	eb 0c                	jmp    8006ed <vprintfmt+0x24b>
  8006e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ed:	83 c7 01             	add    $0x1,%edi
  8006f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f4:	0f be d0             	movsbl %al,%edx
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	74 23                	je     80071e <vprintfmt+0x27c>
  8006fb:	85 f6                	test   %esi,%esi
  8006fd:	78 a1                	js     8006a0 <vprintfmt+0x1fe>
  8006ff:	83 ee 01             	sub    $0x1,%esi
  800702:	79 9c                	jns    8006a0 <vprintfmt+0x1fe>
  800704:	89 df                	mov    %ebx,%edi
  800706:	8b 75 08             	mov    0x8(%ebp),%esi
  800709:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070c:	eb 18                	jmp    800726 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 20                	push   $0x20
  800714:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800716:	83 ef 01             	sub    $0x1,%edi
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb 08                	jmp    800726 <vprintfmt+0x284>
  80071e:	89 df                	mov    %ebx,%edi
  800720:	8b 75 08             	mov    0x8(%ebp),%esi
  800723:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800726:	85 ff                	test   %edi,%edi
  800728:	7f e4                	jg     80070e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80072a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800733:	e9 90 fd ff ff       	jmp    8004c8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800738:	83 f9 01             	cmp    $0x1,%ecx
  80073b:	7e 19                	jle    800756 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 50 04             	mov    0x4(%eax),%edx
  800743:	8b 00                	mov    (%eax),%eax
  800745:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800748:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 40 08             	lea    0x8(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
  800754:	eb 38                	jmp    80078e <vprintfmt+0x2ec>
	else if (lflag)
  800756:	85 c9                	test   %ecx,%ecx
  800758:	74 1b                	je     800775 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800762:	89 c1                	mov    %eax,%ecx
  800764:	c1 f9 1f             	sar    $0x1f,%ecx
  800767:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
  800773:	eb 19                	jmp    80078e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077d:	89 c1                	mov    %eax,%ecx
  80077f:	c1 f9 1f             	sar    $0x1f,%ecx
  800782:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 40 04             	lea    0x4(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80078e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800791:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800794:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800799:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079d:	0f 89 0e 01 00 00    	jns    8008b1 <vprintfmt+0x40f>
				putch('-', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 2d                	push   $0x2d
  8007a9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007b1:	f7 da                	neg    %edx
  8007b3:	83 d1 00             	adc    $0x0,%ecx
  8007b6:	f7 d9                	neg    %ecx
  8007b8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c0:	e9 ec 00 00 00       	jmp    8008b1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c5:	83 f9 01             	cmp    $0x1,%ecx
  8007c8:	7e 18                	jle    8007e2 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d2:	8d 40 08             	lea    0x8(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dd:	e9 cf 00 00 00       	jmp    8008b1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007e2:	85 c9                	test   %ecx,%ecx
  8007e4:	74 1a                	je     800800 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f0:	8d 40 04             	lea    0x4(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fb:	e9 b1 00 00 00       	jmp    8008b1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8b 10                	mov    (%eax),%edx
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080a:	8d 40 04             	lea    0x4(%eax),%eax
  80080d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800810:	b8 0a 00 00 00       	mov    $0xa,%eax
  800815:	e9 97 00 00 00       	jmp    8008b1 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	53                   	push   %ebx
  80081e:	6a 58                	push   $0x58
  800820:	ff d6                	call   *%esi
			putch('X', putdat);
  800822:	83 c4 08             	add    $0x8,%esp
  800825:	53                   	push   %ebx
  800826:	6a 58                	push   $0x58
  800828:	ff d6                	call   *%esi
			putch('X', putdat);
  80082a:	83 c4 08             	add    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	6a 58                	push   $0x58
  800830:	ff d6                	call   *%esi
			break;
  800832:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800838:	e9 8b fc ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	53                   	push   %ebx
  800841:	6a 30                	push   $0x30
  800843:	ff d6                	call   *%esi
			putch('x', putdat);
  800845:	83 c4 08             	add    $0x8,%esp
  800848:	53                   	push   %ebx
  800849:	6a 78                	push   $0x78
  80084b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 10                	mov    (%eax),%edx
  800852:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800857:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085a:	8d 40 04             	lea    0x4(%eax),%eax
  80085d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800860:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800865:	eb 4a                	jmp    8008b1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800867:	83 f9 01             	cmp    $0x1,%ecx
  80086a:	7e 15                	jle    800881 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 10                	mov    (%eax),%edx
  800871:	8b 48 04             	mov    0x4(%eax),%ecx
  800874:	8d 40 08             	lea    0x8(%eax),%eax
  800877:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80087a:	b8 10 00 00 00       	mov    $0x10,%eax
  80087f:	eb 30                	jmp    8008b1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 17                	je     80089c <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8b 10                	mov    (%eax),%edx
  80088a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088f:	8d 40 04             	lea    0x4(%eax),%eax
  800892:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800895:	b8 10 00 00 00       	mov    $0x10,%eax
  80089a:	eb 15                	jmp    8008b1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8b 10                	mov    (%eax),%edx
  8008a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a6:	8d 40 04             	lea    0x4(%eax),%eax
  8008a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ac:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b1:	83 ec 0c             	sub    $0xc,%esp
  8008b4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b8:	57                   	push   %edi
  8008b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bc:	50                   	push   %eax
  8008bd:	51                   	push   %ecx
  8008be:	52                   	push   %edx
  8008bf:	89 da                	mov    %ebx,%edx
  8008c1:	89 f0                	mov    %esi,%eax
  8008c3:	e8 f1 fa ff ff       	call   8003b9 <printnum>
			break;
  8008c8:	83 c4 20             	add    $0x20,%esp
  8008cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ce:	e9 f5 fb ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	53                   	push   %ebx
  8008d7:	52                   	push   %edx
  8008d8:	ff d6                	call   *%esi
			break;
  8008da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e0:	e9 e3 fb ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	6a 25                	push   $0x25
  8008eb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb 03                	jmp    8008f5 <vprintfmt+0x453>
  8008f2:	83 ef 01             	sub    $0x1,%edi
  8008f5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f9:	75 f7                	jne    8008f2 <vprintfmt+0x450>
  8008fb:	e9 c8 fb ff ff       	jmp    8004c8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800900:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 18             	sub    $0x18,%esp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800914:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800917:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800925:	85 c0                	test   %eax,%eax
  800927:	74 26                	je     80094f <vsnprintf+0x47>
  800929:	85 d2                	test   %edx,%edx
  80092b:	7e 22                	jle    80094f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092d:	ff 75 14             	pushl  0x14(%ebp)
  800930:	ff 75 10             	pushl  0x10(%ebp)
  800933:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800936:	50                   	push   %eax
  800937:	68 68 04 80 00       	push   $0x800468
  80093c:	e8 61 fb ff ff       	call   8004a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800941:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800944:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 05                	jmp    800954 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095f:	50                   	push   %eax
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 9a ff ff ff       	call   800908 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	83 ec 0c             	sub    $0xc,%esp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80097c:	85 c0                	test   %eax,%eax
  80097e:	74 13                	je     800993 <readline+0x23>
		fprintf(1, "%s", prompt);
  800980:	83 ec 04             	sub    $0x4,%esp
  800983:	50                   	push   %eax
  800984:	68 85 25 80 00       	push   $0x802585
  800989:	6a 01                	push   $0x1
  80098b:	e8 f4 0f 00 00       	call   801984 <fprintf>
  800990:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800993:	83 ec 0c             	sub    $0xc,%esp
  800996:	6a 00                	push   $0x0
  800998:	e8 49 f8 ff ff       	call   8001e6 <iscons>
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009a2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009a7:	e8 0f f8 ff ff       	call   8001bb <getchar>
  8009ac:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	79 29                	jns    8009db <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8009b7:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8009ba:	0f 84 9b 00 00 00    	je     800a5b <readline+0xeb>
				cprintf("read error: %e\n", c);
  8009c0:	83 ec 08             	sub    $0x8,%esp
  8009c3:	53                   	push   %ebx
  8009c4:	68 9f 24 80 00       	push   $0x80249f
  8009c9:	e8 d7 f9 ff ff       	call   8003a5 <cprintf>
  8009ce:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	e9 80 00 00 00       	jmp    800a5b <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009db:	83 f8 08             	cmp    $0x8,%eax
  8009de:	0f 94 c2             	sete   %dl
  8009e1:	83 f8 7f             	cmp    $0x7f,%eax
  8009e4:	0f 94 c0             	sete   %al
  8009e7:	08 c2                	or     %al,%dl
  8009e9:	74 1a                	je     800a05 <readline+0x95>
  8009eb:	85 f6                	test   %esi,%esi
  8009ed:	7e 16                	jle    800a05 <readline+0x95>
			if (echoing)
  8009ef:	85 ff                	test   %edi,%edi
  8009f1:	74 0d                	je     800a00 <readline+0x90>
				cputchar('\b');
  8009f3:	83 ec 0c             	sub    $0xc,%esp
  8009f6:	6a 08                	push   $0x8
  8009f8:	e8 a2 f7 ff ff       	call   80019f <cputchar>
  8009fd:	83 c4 10             	add    $0x10,%esp
			i--;
  800a00:	83 ee 01             	sub    $0x1,%esi
  800a03:	eb a2                	jmp    8009a7 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a05:	83 fb 1f             	cmp    $0x1f,%ebx
  800a08:	7e 26                	jle    800a30 <readline+0xc0>
  800a0a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a10:	7f 1e                	jg     800a30 <readline+0xc0>
			if (echoing)
  800a12:	85 ff                	test   %edi,%edi
  800a14:	74 0c                	je     800a22 <readline+0xb2>
				cputchar(c);
  800a16:	83 ec 0c             	sub    $0xc,%esp
  800a19:	53                   	push   %ebx
  800a1a:	e8 80 f7 ff ff       	call   80019f <cputchar>
  800a1f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800a22:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a28:	8d 76 01             	lea    0x1(%esi),%esi
  800a2b:	e9 77 ff ff ff       	jmp    8009a7 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  800a30:	83 fb 0a             	cmp    $0xa,%ebx
  800a33:	74 09                	je     800a3e <readline+0xce>
  800a35:	83 fb 0d             	cmp    $0xd,%ebx
  800a38:	0f 85 69 ff ff ff    	jne    8009a7 <readline+0x37>
			if (echoing)
  800a3e:	85 ff                	test   %edi,%edi
  800a40:	74 0d                	je     800a4f <readline+0xdf>
				cputchar('\n');
  800a42:	83 ec 0c             	sub    $0xc,%esp
  800a45:	6a 0a                	push   $0xa
  800a47:	e8 53 f7 ff ff       	call   80019f <cputchar>
  800a4c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a4f:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a56:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800a5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	eb 03                	jmp    800a73 <strlen+0x10>
		n++;
  800a70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a77:	75 f7                	jne    800a70 <strlen+0xd>
		n++;
	return n;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	eb 03                	jmp    800a8e <strnlen+0x13>
		n++;
  800a8b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8e:	39 c2                	cmp    %eax,%edx
  800a90:	74 08                	je     800a9a <strnlen+0x1f>
  800a92:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a96:	75 f3                	jne    800a8b <strnlen+0x10>
  800a98:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ab2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ab5:	84 db                	test   %bl,%bl
  800ab7:	75 ef                	jne    800aa8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac3:	53                   	push   %ebx
  800ac4:	e8 9a ff ff ff       	call   800a63 <strlen>
  800ac9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800acc:	ff 75 0c             	pushl  0xc(%ebp)
  800acf:	01 d8                	add    %ebx,%eax
  800ad1:	50                   	push   %eax
  800ad2:	e8 c5 ff ff ff       	call   800a9c <strcpy>
	return dst;
}
  800ad7:	89 d8                	mov    %ebx,%eax
  800ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aee:	89 f2                	mov    %esi,%edx
  800af0:	eb 0f                	jmp    800b01 <strncpy+0x23>
		*dst++ = *src;
  800af2:	83 c2 01             	add    $0x1,%edx
  800af5:	0f b6 01             	movzbl (%ecx),%eax
  800af8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800afb:	80 39 01             	cmpb   $0x1,(%ecx)
  800afe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b01:	39 da                	cmp    %ebx,%edx
  800b03:	75 ed                	jne    800af2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b05:	89 f0                	mov    %esi,%eax
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 75 08             	mov    0x8(%ebp),%esi
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b16:	8b 55 10             	mov    0x10(%ebp),%edx
  800b19:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1b:	85 d2                	test   %edx,%edx
  800b1d:	74 21                	je     800b40 <strlcpy+0x35>
  800b1f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b23:	89 f2                	mov    %esi,%edx
  800b25:	eb 09                	jmp    800b30 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b27:	83 c2 01             	add    $0x1,%edx
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b30:	39 c2                	cmp    %eax,%edx
  800b32:	74 09                	je     800b3d <strlcpy+0x32>
  800b34:	0f b6 19             	movzbl (%ecx),%ebx
  800b37:	84 db                	test   %bl,%bl
  800b39:	75 ec                	jne    800b27 <strlcpy+0x1c>
  800b3b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b3d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b40:	29 f0                	sub    %esi,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b4f:	eb 06                	jmp    800b57 <strcmp+0x11>
		p++, q++;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b57:	0f b6 01             	movzbl (%ecx),%eax
  800b5a:	84 c0                	test   %al,%al
  800b5c:	74 04                	je     800b62 <strcmp+0x1c>
  800b5e:	3a 02                	cmp    (%edx),%al
  800b60:	74 ef                	je     800b51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b62:	0f b6 c0             	movzbl %al,%eax
  800b65:	0f b6 12             	movzbl (%edx),%edx
  800b68:	29 d0                	sub    %edx,%eax
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	53                   	push   %ebx
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b76:	89 c3                	mov    %eax,%ebx
  800b78:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b7b:	eb 06                	jmp    800b83 <strncmp+0x17>
		n--, p++, q++;
  800b7d:	83 c0 01             	add    $0x1,%eax
  800b80:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b83:	39 d8                	cmp    %ebx,%eax
  800b85:	74 15                	je     800b9c <strncmp+0x30>
  800b87:	0f b6 08             	movzbl (%eax),%ecx
  800b8a:	84 c9                	test   %cl,%cl
  800b8c:	74 04                	je     800b92 <strncmp+0x26>
  800b8e:	3a 0a                	cmp    (%edx),%cl
  800b90:	74 eb                	je     800b7d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b92:	0f b6 00             	movzbl (%eax),%eax
  800b95:	0f b6 12             	movzbl (%edx),%edx
  800b98:	29 d0                	sub    %edx,%eax
  800b9a:	eb 05                	jmp    800ba1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bae:	eb 07                	jmp    800bb7 <strchr+0x13>
		if (*s == c)
  800bb0:	38 ca                	cmp    %cl,%dl
  800bb2:	74 0f                	je     800bc3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb4:	83 c0 01             	add    $0x1,%eax
  800bb7:	0f b6 10             	movzbl (%eax),%edx
  800bba:	84 d2                	test   %dl,%dl
  800bbc:	75 f2                	jne    800bb0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcf:	eb 03                	jmp    800bd4 <strfind+0xf>
  800bd1:	83 c0 01             	add    $0x1,%eax
  800bd4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd7:	38 ca                	cmp    %cl,%dl
  800bd9:	74 04                	je     800bdf <strfind+0x1a>
  800bdb:	84 d2                	test   %dl,%dl
  800bdd:	75 f2                	jne    800bd1 <strfind+0xc>
			break;
	return (char *) s;
}
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bed:	85 c9                	test   %ecx,%ecx
  800bef:	74 36                	je     800c27 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf7:	75 28                	jne    800c21 <memset+0x40>
  800bf9:	f6 c1 03             	test   $0x3,%cl
  800bfc:	75 23                	jne    800c21 <memset+0x40>
		c &= 0xFF;
  800bfe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c02:	89 d3                	mov    %edx,%ebx
  800c04:	c1 e3 08             	shl    $0x8,%ebx
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	c1 e6 18             	shl    $0x18,%esi
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	c1 e0 10             	shl    $0x10,%eax
  800c11:	09 f0                	or     %esi,%eax
  800c13:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c15:	89 d8                	mov    %ebx,%eax
  800c17:	09 d0                	or     %edx,%eax
  800c19:	c1 e9 02             	shr    $0x2,%ecx
  800c1c:	fc                   	cld    
  800c1d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1f:	eb 06                	jmp    800c27 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c24:	fc                   	cld    
  800c25:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c27:	89 f8                	mov    %edi,%eax
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3c:	39 c6                	cmp    %eax,%esi
  800c3e:	73 35                	jae    800c75 <memmove+0x47>
  800c40:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c43:	39 d0                	cmp    %edx,%eax
  800c45:	73 2e                	jae    800c75 <memmove+0x47>
		s += n;
		d += n;
  800c47:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	09 fe                	or     %edi,%esi
  800c4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c54:	75 13                	jne    800c69 <memmove+0x3b>
  800c56:	f6 c1 03             	test   $0x3,%cl
  800c59:	75 0e                	jne    800c69 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c5b:	83 ef 04             	sub    $0x4,%edi
  800c5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c61:	c1 e9 02             	shr    $0x2,%ecx
  800c64:	fd                   	std    
  800c65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c67:	eb 09                	jmp    800c72 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c69:	83 ef 01             	sub    $0x1,%edi
  800c6c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c6f:	fd                   	std    
  800c70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c72:	fc                   	cld    
  800c73:	eb 1d                	jmp    800c92 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c75:	89 f2                	mov    %esi,%edx
  800c77:	09 c2                	or     %eax,%edx
  800c79:	f6 c2 03             	test   $0x3,%dl
  800c7c:	75 0f                	jne    800c8d <memmove+0x5f>
  800c7e:	f6 c1 03             	test   $0x3,%cl
  800c81:	75 0a                	jne    800c8d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c83:	c1 e9 02             	shr    $0x2,%ecx
  800c86:	89 c7                	mov    %eax,%edi
  800c88:	fc                   	cld    
  800c89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8b:	eb 05                	jmp    800c92 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8d:	89 c7                	mov    %eax,%edi
  800c8f:	fc                   	cld    
  800c90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c99:	ff 75 10             	pushl  0x10(%ebp)
  800c9c:	ff 75 0c             	pushl  0xc(%ebp)
  800c9f:	ff 75 08             	pushl  0x8(%ebp)
  800ca2:	e8 87 ff ff ff       	call   800c2e <memmove>
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb4:	89 c6                	mov    %eax,%esi
  800cb6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb9:	eb 1a                	jmp    800cd5 <memcmp+0x2c>
		if (*s1 != *s2)
  800cbb:	0f b6 08             	movzbl (%eax),%ecx
  800cbe:	0f b6 1a             	movzbl (%edx),%ebx
  800cc1:	38 d9                	cmp    %bl,%cl
  800cc3:	74 0a                	je     800ccf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cc5:	0f b6 c1             	movzbl %cl,%eax
  800cc8:	0f b6 db             	movzbl %bl,%ebx
  800ccb:	29 d8                	sub    %ebx,%eax
  800ccd:	eb 0f                	jmp    800cde <memcmp+0x35>
		s1++, s2++;
  800ccf:	83 c0 01             	add    $0x1,%eax
  800cd2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd5:	39 f0                	cmp    %esi,%eax
  800cd7:	75 e2                	jne    800cbb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	53                   	push   %ebx
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ce9:	89 c1                	mov    %eax,%ecx
  800ceb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cf2:	eb 0a                	jmp    800cfe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf4:	0f b6 10             	movzbl (%eax),%edx
  800cf7:	39 da                	cmp    %ebx,%edx
  800cf9:	74 07                	je     800d02 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cfb:	83 c0 01             	add    $0x1,%eax
  800cfe:	39 c8                	cmp    %ecx,%eax
  800d00:	72 f2                	jb     800cf4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d02:	5b                   	pop    %ebx
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d11:	eb 03                	jmp    800d16 <strtol+0x11>
		s++;
  800d13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d16:	0f b6 01             	movzbl (%ecx),%eax
  800d19:	3c 20                	cmp    $0x20,%al
  800d1b:	74 f6                	je     800d13 <strtol+0xe>
  800d1d:	3c 09                	cmp    $0x9,%al
  800d1f:	74 f2                	je     800d13 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d21:	3c 2b                	cmp    $0x2b,%al
  800d23:	75 0a                	jne    800d2f <strtol+0x2a>
		s++;
  800d25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d28:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2d:	eb 11                	jmp    800d40 <strtol+0x3b>
  800d2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d34:	3c 2d                	cmp    $0x2d,%al
  800d36:	75 08                	jne    800d40 <strtol+0x3b>
		s++, neg = 1;
  800d38:	83 c1 01             	add    $0x1,%ecx
  800d3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d46:	75 15                	jne    800d5d <strtol+0x58>
  800d48:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4b:	75 10                	jne    800d5d <strtol+0x58>
  800d4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d51:	75 7c                	jne    800dcf <strtol+0xca>
		s += 2, base = 16;
  800d53:	83 c1 02             	add    $0x2,%ecx
  800d56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d5b:	eb 16                	jmp    800d73 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d5d:	85 db                	test   %ebx,%ebx
  800d5f:	75 12                	jne    800d73 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d66:	80 39 30             	cmpb   $0x30,(%ecx)
  800d69:	75 08                	jne    800d73 <strtol+0x6e>
		s++, base = 8;
  800d6b:	83 c1 01             	add    $0x1,%ecx
  800d6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d7b:	0f b6 11             	movzbl (%ecx),%edx
  800d7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d81:	89 f3                	mov    %esi,%ebx
  800d83:	80 fb 09             	cmp    $0x9,%bl
  800d86:	77 08                	ja     800d90 <strtol+0x8b>
			dig = *s - '0';
  800d88:	0f be d2             	movsbl %dl,%edx
  800d8b:	83 ea 30             	sub    $0x30,%edx
  800d8e:	eb 22                	jmp    800db2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d93:	89 f3                	mov    %esi,%ebx
  800d95:	80 fb 19             	cmp    $0x19,%bl
  800d98:	77 08                	ja     800da2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d9a:	0f be d2             	movsbl %dl,%edx
  800d9d:	83 ea 57             	sub    $0x57,%edx
  800da0:	eb 10                	jmp    800db2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800da2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800da5:	89 f3                	mov    %esi,%ebx
  800da7:	80 fb 19             	cmp    $0x19,%bl
  800daa:	77 16                	ja     800dc2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dac:	0f be d2             	movsbl %dl,%edx
  800daf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800db2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800db5:	7d 0b                	jge    800dc2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800db7:	83 c1 01             	add    $0x1,%ecx
  800dba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dbe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800dc0:	eb b9                	jmp    800d7b <strtol+0x76>

	if (endptr)
  800dc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc6:	74 0d                	je     800dd5 <strtol+0xd0>
		*endptr = (char *) s;
  800dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcb:	89 0e                	mov    %ecx,(%esi)
  800dcd:	eb 06                	jmp    800dd5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcf:	85 db                	test   %ebx,%ebx
  800dd1:	74 98                	je     800d6b <strtol+0x66>
  800dd3:	eb 9e                	jmp    800d73 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	f7 da                	neg    %edx
  800dd9:	85 ff                	test   %edi,%edi
  800ddb:	0f 45 c2             	cmovne %edx,%eax
}
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	89 c7                	mov    %eax,%edi
  800df8:	89 c6                	mov    %eax,%esi
  800dfa:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 d7                	mov    %edx,%edi
  800e17:	89 d6                	mov    %edx,%esi
  800e19:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 cb                	mov    %ecx,%ebx
  800e38:	89 cf                	mov    %ecx,%edi
  800e3a:	89 ce                	mov    %ecx,%esi
  800e3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 17                	jle    800e59 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	50                   	push   %eax
  800e46:	6a 03                	push   $0x3
  800e48:	68 af 24 80 00       	push   $0x8024af
  800e4d:	6a 23                	push   $0x23
  800e4f:	68 cc 24 80 00       	push   $0x8024cc
  800e54:	e8 73 f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 d3                	mov    %edx,%ebx
  800e75:	89 d7                	mov    %edx,%edi
  800e77:	89 d6                	mov    %edx,%esi
  800e79:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_yield>:

void
sys_yield(void)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e90:	89 d1                	mov    %edx,%ecx
  800e92:	89 d3                	mov    %edx,%ebx
  800e94:	89 d7                	mov    %edx,%edi
  800e96:	89 d6                	mov    %edx,%esi
  800e98:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	be 00 00 00 00       	mov    $0x0,%esi
  800ead:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebb:	89 f7                	mov    %esi,%edi
  800ebd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 17                	jle    800eda <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	50                   	push   %eax
  800ec7:	6a 04                	push   $0x4
  800ec9:	68 af 24 80 00       	push   $0x8024af
  800ece:	6a 23                	push   $0x23
  800ed0:	68 cc 24 80 00       	push   $0x8024cc
  800ed5:	e8 f2 f3 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800efc:	8b 75 18             	mov    0x18(%ebp),%esi
  800eff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 17                	jle    800f1c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	50                   	push   %eax
  800f09:	6a 05                	push   $0x5
  800f0b:	68 af 24 80 00       	push   $0x8024af
  800f10:	6a 23                	push   $0x23
  800f12:	68 cc 24 80 00       	push   $0x8024cc
  800f17:	e8 b0 f3 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	53                   	push   %ebx
  800f2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f32:	b8 06 00 00 00       	mov    $0x6,%eax
  800f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3d:	89 df                	mov    %ebx,%edi
  800f3f:	89 de                	mov    %ebx,%esi
  800f41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7e 17                	jle    800f5e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	50                   	push   %eax
  800f4b:	6a 06                	push   $0x6
  800f4d:	68 af 24 80 00       	push   $0x8024af
  800f52:	6a 23                	push   $0x23
  800f54:	68 cc 24 80 00       	push   $0x8024cc
  800f59:	e8 6e f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f74:	b8 08 00 00 00       	mov    $0x8,%eax
  800f79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	89 df                	mov    %ebx,%edi
  800f81:	89 de                	mov    %ebx,%esi
  800f83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 17                	jle    800fa0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	50                   	push   %eax
  800f8d:	6a 08                	push   $0x8
  800f8f:	68 af 24 80 00       	push   $0x8024af
  800f94:	6a 23                	push   $0x23
  800f96:	68 cc 24 80 00       	push   $0x8024cc
  800f9b:	e8 2c f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb6:	b8 09 00 00 00       	mov    $0x9,%eax
  800fbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	89 df                	mov    %ebx,%edi
  800fc3:	89 de                	mov    %ebx,%esi
  800fc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7e 17                	jle    800fe2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	50                   	push   %eax
  800fcf:	6a 09                	push   $0x9
  800fd1:	68 af 24 80 00       	push   $0x8024af
  800fd6:	6a 23                	push   $0x23
  800fd8:	68 cc 24 80 00       	push   $0x8024cc
  800fdd:	e8 ea f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	89 df                	mov    %ebx,%edi
  801005:	89 de                	mov    %ebx,%esi
  801007:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7e 17                	jle    801024 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	50                   	push   %eax
  801011:	6a 0a                	push   $0xa
  801013:	68 af 24 80 00       	push   $0x8024af
  801018:	6a 23                	push   $0x23
  80101a:	68 cc 24 80 00       	push   $0x8024cc
  80101f:	e8 a8 f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	be 00 00 00 00       	mov    $0x0,%esi
  801037:	b8 0c 00 00 00       	mov    $0xc,%eax
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801045:	8b 7d 14             	mov    0x14(%ebp),%edi
  801048:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801058:	b9 00 00 00 00       	mov    $0x0,%ecx
  80105d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801062:	8b 55 08             	mov    0x8(%ebp),%edx
  801065:	89 cb                	mov    %ecx,%ebx
  801067:	89 cf                	mov    %ecx,%edi
  801069:	89 ce                	mov    %ecx,%esi
  80106b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 0d                	push   $0xd
  801077:	68 af 24 80 00       	push   $0x8024af
  80107c:	6a 23                	push   $0x23
  80107e:	68 cc 24 80 00       	push   $0x8024cc
  801083:	e8 44 f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	c1 ea 16             	shr    $0x16,%edx
  8010c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ce:	f6 c2 01             	test   $0x1,%dl
  8010d1:	74 11                	je     8010e4 <fd_alloc+0x2d>
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	c1 ea 0c             	shr    $0xc,%edx
  8010d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	75 09                	jne    8010ed <fd_alloc+0x36>
			*fd_store = fd;
  8010e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010eb:	eb 17                	jmp    801104 <fd_alloc+0x4d>
  8010ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f7:	75 c9                	jne    8010c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110c:	83 f8 1f             	cmp    $0x1f,%eax
  80110f:	77 36                	ja     801147 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801111:	c1 e0 0c             	shl    $0xc,%eax
  801114:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801119:	89 c2                	mov    %eax,%edx
  80111b:	c1 ea 16             	shr    $0x16,%edx
  80111e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801125:	f6 c2 01             	test   $0x1,%dl
  801128:	74 24                	je     80114e <fd_lookup+0x48>
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 0c             	shr    $0xc,%edx
  80112f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 1a                	je     801155 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 02                	mov    %eax,(%edx)
	return 0;
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 13                	jmp    80115a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 0c                	jmp    80115a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801153:	eb 05                	jmp    80115a <fd_lookup+0x54>
  801155:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801165:	ba 5c 25 80 00       	mov    $0x80255c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80116a:	eb 13                	jmp    80117f <dev_lookup+0x23>
  80116c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80116f:	39 08                	cmp    %ecx,(%eax)
  801171:	75 0c                	jne    80117f <dev_lookup+0x23>
			*dev = devtab[i];
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	89 01                	mov    %eax,(%ecx)
			return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
  80117d:	eb 2e                	jmp    8011ad <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117f:	8b 02                	mov    (%edx),%eax
  801181:	85 c0                	test   %eax,%eax
  801183:	75 e7                	jne    80116c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801185:	a1 04 44 80 00       	mov    0x804404,%eax
  80118a:	8b 40 48             	mov    0x48(%eax),%eax
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	51                   	push   %ecx
  801191:	50                   	push   %eax
  801192:	68 dc 24 80 00       	push   $0x8024dc
  801197:	e8 09 f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  80119c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ad:	c9                   	leave  
  8011ae:	c3                   	ret    

008011af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	56                   	push   %esi
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 10             	sub    $0x10,%esp
  8011b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
  8011ca:	50                   	push   %eax
  8011cb:	e8 36 ff ff ff       	call   801106 <fd_lookup>
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 05                	js     8011dc <fd_close+0x2d>
	    || fd != fd2)
  8011d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011da:	74 0c                	je     8011e8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011dc:	84 db                	test   %bl,%bl
  8011de:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e3:	0f 44 c2             	cmove  %edx,%eax
  8011e6:	eb 41                	jmp    801229 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ee:	50                   	push   %eax
  8011ef:	ff 36                	pushl  (%esi)
  8011f1:	e8 66 ff ff ff       	call   80115c <dev_lookup>
  8011f6:	89 c3                	mov    %eax,%ebx
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 1a                	js     801219 <fd_close+0x6a>
		if (dev->dev_close)
  8011ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801202:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801205:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80120a:	85 c0                	test   %eax,%eax
  80120c:	74 0b                	je     801219 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	56                   	push   %esi
  801212:	ff d0                	call   *%eax
  801214:	89 c3                	mov    %eax,%ebx
  801216:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	56                   	push   %esi
  80121d:	6a 00                	push   $0x0
  80121f:	e8 00 fd ff ff       	call   800f24 <sys_page_unmap>
	return r;
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	89 d8                	mov    %ebx,%eax
}
  801229:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 c4 fe ff ff       	call   801106 <fd_lookup>
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 10                	js     801259 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	6a 01                	push   $0x1
  80124e:	ff 75 f4             	pushl  -0xc(%ebp)
  801251:	e8 59 ff ff ff       	call   8011af <fd_close>
  801256:	83 c4 10             	add    $0x10,%esp
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <close_all>:

void
close_all(void)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801262:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	53                   	push   %ebx
  80126b:	e8 c0 ff ff ff       	call   801230 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801270:	83 c3 01             	add    $0x1,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	83 fb 20             	cmp    $0x20,%ebx
  801279:	75 ec                	jne    801267 <close_all+0xc>
		close(i);
}
  80127b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
  801289:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80128c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 6e fe ff ff       	call   801106 <fd_lookup>
  801298:	83 c4 08             	add    $0x8,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	0f 88 c1 00 00 00    	js     801364 <dup+0xe4>
		return r;
	close(newfdnum);
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	56                   	push   %esi
  8012a7:	e8 84 ff ff ff       	call   801230 <close>

	newfd = INDEX2FD(newfdnum);
  8012ac:	89 f3                	mov    %esi,%ebx
  8012ae:	c1 e3 0c             	shl    $0xc,%ebx
  8012b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b7:	83 c4 04             	add    $0x4,%esp
  8012ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012bd:	e8 de fd ff ff       	call   8010a0 <fd2data>
  8012c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012c4:	89 1c 24             	mov    %ebx,(%esp)
  8012c7:	e8 d4 fd ff ff       	call   8010a0 <fd2data>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012d2:	89 f8                	mov    %edi,%eax
  8012d4:	c1 e8 16             	shr    $0x16,%eax
  8012d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012de:	a8 01                	test   $0x1,%al
  8012e0:	74 37                	je     801319 <dup+0x99>
  8012e2:	89 f8                	mov    %edi,%eax
  8012e4:	c1 e8 0c             	shr    $0xc,%eax
  8012e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ee:	f6 c2 01             	test   $0x1,%dl
  8012f1:	74 26                	je     801319 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801302:	50                   	push   %eax
  801303:	ff 75 d4             	pushl  -0x2c(%ebp)
  801306:	6a 00                	push   $0x0
  801308:	57                   	push   %edi
  801309:	6a 00                	push   $0x0
  80130b:	e8 d2 fb ff ff       	call   800ee2 <sys_page_map>
  801310:	89 c7                	mov    %eax,%edi
  801312:	83 c4 20             	add    $0x20,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 2e                	js     801347 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801319:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	c1 e8 0c             	shr    $0xc,%eax
  801321:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	25 07 0e 00 00       	and    $0xe07,%eax
  801330:	50                   	push   %eax
  801331:	53                   	push   %ebx
  801332:	6a 00                	push   $0x0
  801334:	52                   	push   %edx
  801335:	6a 00                	push   $0x0
  801337:	e8 a6 fb ff ff       	call   800ee2 <sys_page_map>
  80133c:	89 c7                	mov    %eax,%edi
  80133e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801341:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801343:	85 ff                	test   %edi,%edi
  801345:	79 1d                	jns    801364 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	53                   	push   %ebx
  80134b:	6a 00                	push   $0x0
  80134d:	e8 d2 fb ff ff       	call   800f24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	ff 75 d4             	pushl  -0x2c(%ebp)
  801358:	6a 00                	push   $0x0
  80135a:	e8 c5 fb ff ff       	call   800f24 <sys_page_unmap>
	return r;
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	89 f8                	mov    %edi,%eax
}
  801364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	53                   	push   %ebx
  801370:	83 ec 14             	sub    $0x14,%esp
  801373:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801376:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	53                   	push   %ebx
  80137b:	e8 86 fd ff ff       	call   801106 <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	89 c2                	mov    %eax,%edx
  801385:	85 c0                	test   %eax,%eax
  801387:	78 6d                	js     8013f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	ff 30                	pushl  (%eax)
  801395:	e8 c2 fd ff ff       	call   80115c <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 4c                	js     8013ed <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a4:	8b 42 08             	mov    0x8(%edx),%eax
  8013a7:	83 e0 03             	and    $0x3,%eax
  8013aa:	83 f8 01             	cmp    $0x1,%eax
  8013ad:	75 21                	jne    8013d0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013af:	a1 04 44 80 00       	mov    0x804404,%eax
  8013b4:	8b 40 48             	mov    0x48(%eax),%eax
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	50                   	push   %eax
  8013bc:	68 20 25 80 00       	push   $0x802520
  8013c1:	e8 df ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ce:	eb 26                	jmp    8013f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d3:	8b 40 08             	mov    0x8(%eax),%eax
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	74 17                	je     8013f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013da:	83 ec 04             	sub    $0x4,%esp
  8013dd:	ff 75 10             	pushl  0x10(%ebp)
  8013e0:	ff 75 0c             	pushl  0xc(%ebp)
  8013e3:	52                   	push   %edx
  8013e4:	ff d0                	call   *%eax
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	eb 09                	jmp    8013f6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	eb 05                	jmp    8013f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013f6:	89 d0                	mov    %edx,%eax
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	57                   	push   %edi
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	8b 7d 08             	mov    0x8(%ebp),%edi
  801409:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801411:	eb 21                	jmp    801434 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801413:	83 ec 04             	sub    $0x4,%esp
  801416:	89 f0                	mov    %esi,%eax
  801418:	29 d8                	sub    %ebx,%eax
  80141a:	50                   	push   %eax
  80141b:	89 d8                	mov    %ebx,%eax
  80141d:	03 45 0c             	add    0xc(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	57                   	push   %edi
  801422:	e8 45 ff ff ff       	call   80136c <read>
		if (m < 0)
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 10                	js     80143e <readn+0x41>
			return m;
		if (m == 0)
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 0a                	je     80143c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801432:	01 c3                	add    %eax,%ebx
  801434:	39 f3                	cmp    %esi,%ebx
  801436:	72 db                	jb     801413 <readn+0x16>
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	eb 02                	jmp    80143e <readn+0x41>
  80143c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80143e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 14             	sub    $0x14,%esp
  80144d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801450:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	53                   	push   %ebx
  801455:	e8 ac fc ff ff       	call   801106 <fd_lookup>
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	89 c2                	mov    %eax,%edx
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 68                	js     8014cb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	ff 30                	pushl  (%eax)
  80146f:	e8 e8 fc ff ff       	call   80115c <dev_lookup>
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 47                	js     8014c2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801482:	75 21                	jne    8014a5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801484:	a1 04 44 80 00       	mov    0x804404,%eax
  801489:	8b 40 48             	mov    0x48(%eax),%eax
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	53                   	push   %ebx
  801490:	50                   	push   %eax
  801491:	68 3c 25 80 00       	push   $0x80253c
  801496:	e8 0a ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a3:	eb 26                	jmp    8014cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 17                	je     8014c6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	ff 75 10             	pushl  0x10(%ebp)
  8014b5:	ff 75 0c             	pushl  0xc(%ebp)
  8014b8:	50                   	push   %eax
  8014b9:	ff d2                	call   *%edx
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	eb 09                	jmp    8014cb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	eb 05                	jmp    8014cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	ff 75 08             	pushl  0x8(%ebp)
  8014df:	e8 22 fc ff ff       	call   801106 <fd_lookup>
  8014e4:	83 c4 08             	add    $0x8,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 0e                	js     8014f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 14             	sub    $0x14,%esp
  801502:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801505:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	53                   	push   %ebx
  80150a:	e8 f7 fb ff ff       	call   801106 <fd_lookup>
  80150f:	83 c4 08             	add    $0x8,%esp
  801512:	89 c2                	mov    %eax,%edx
  801514:	85 c0                	test   %eax,%eax
  801516:	78 65                	js     80157d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801522:	ff 30                	pushl  (%eax)
  801524:	e8 33 fc ff ff       	call   80115c <dev_lookup>
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 44                	js     801574 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801533:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801537:	75 21                	jne    80155a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801539:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153e:	8b 40 48             	mov    0x48(%eax),%eax
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	53                   	push   %ebx
  801545:	50                   	push   %eax
  801546:	68 fc 24 80 00       	push   $0x8024fc
  80154b:	e8 55 ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801558:	eb 23                	jmp    80157d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80155a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155d:	8b 52 18             	mov    0x18(%edx),%edx
  801560:	85 d2                	test   %edx,%edx
  801562:	74 14                	je     801578 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	50                   	push   %eax
  80156b:	ff d2                	call   *%edx
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb 09                	jmp    80157d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	89 c2                	mov    %eax,%edx
  801576:	eb 05                	jmp    80157d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801578:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80157d:	89 d0                	mov    %edx,%eax
  80157f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 14             	sub    $0x14,%esp
  80158b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 6c fb ff ff       	call   801106 <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 58                	js     8015fb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	ff 30                	pushl  (%eax)
  8015af:	e8 a8 fb ff ff       	call   80115c <dev_lookup>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 37                	js     8015f2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c2:	74 32                	je     8015f6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ce:	00 00 00 
	stat->st_isdir = 0;
  8015d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d8:	00 00 00 
	stat->st_dev = dev;
  8015db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e8:	ff 50 14             	call   *0x14(%eax)
  8015eb:	89 c2                	mov    %eax,%edx
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	eb 09                	jmp    8015fb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	eb 05                	jmp    8015fb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015fb:	89 d0                	mov    %edx,%eax
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	6a 00                	push   $0x0
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 e9 01 00 00       	call   8017fd <open>
  801614:	89 c3                	mov    %eax,%ebx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 1b                	js     801638 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	50                   	push   %eax
  801624:	e8 5b ff ff ff       	call   801584 <fstat>
  801629:	89 c6                	mov    %eax,%esi
	close(fd);
  80162b:	89 1c 24             	mov    %ebx,(%esp)
  80162e:	e8 fd fb ff ff       	call   801230 <close>
	return r;
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	89 f0                	mov    %esi,%eax
}
  801638:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	89 c6                	mov    %eax,%esi
  801646:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801648:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80164f:	75 12                	jne    801663 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	6a 01                	push   $0x1
  801656:	e8 88 07 00 00       	call   801de3 <ipc_find_env>
  80165b:	a3 00 44 80 00       	mov    %eax,0x804400
  801660:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801663:	6a 07                	push   $0x7
  801665:	68 00 50 80 00       	push   $0x805000
  80166a:	56                   	push   %esi
  80166b:	ff 35 00 44 80 00    	pushl  0x804400
  801671:	e8 19 07 00 00       	call   801d8f <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801676:	83 c4 0c             	add    $0xc,%esp
  801679:	6a 00                	push   $0x0
  80167b:	53                   	push   %ebx
  80167c:	6a 00                	push   $0x0
  80167e:	e8 8a 06 00 00       	call   801d0d <ipc_recv>
}
  801683:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	8b 40 0c             	mov    0xc(%eax),%eax
  801696:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80169b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ad:	e8 8d ff ff ff       	call   80163f <fsipc>
}
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8016cf:	e8 6b ff ff ff       	call   80163f <fsipc>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f5:	e8 45 ff ff ff       	call   80163f <fsipc>
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 2c                	js     80172a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	68 00 50 80 00       	push   $0x805000
  801706:	53                   	push   %ebx
  801707:	e8 90 f3 ff ff       	call   800a9c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170c:	a1 80 50 80 00       	mov    0x805080,%eax
  801711:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801717:	a1 84 50 80 00       	mov    0x805084,%eax
  80171c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	8b 45 10             	mov    0x10(%ebp),%eax
  801738:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80173d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801742:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801745:	8b 55 08             	mov    0x8(%ebp),%edx
  801748:	8b 52 0c             	mov    0xc(%edx),%edx
  80174b:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801751:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801756:	50                   	push   %eax
  801757:	ff 75 0c             	pushl  0xc(%ebp)
  80175a:	68 08 50 80 00       	push   $0x805008
  80175f:	e8 ca f4 ff ff       	call   800c2e <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 04 00 00 00       	mov    $0x4,%eax
  80176e:	e8 cc fe ff ff       	call   80163f <fsipc>
            return r;

    return r;
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801788:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178e:	ba 00 00 00 00       	mov    $0x0,%edx
  801793:	b8 03 00 00 00       	mov    $0x3,%eax
  801798:	e8 a2 fe ff ff       	call   80163f <fsipc>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 51                	js     8017f4 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8017a3:	39 c6                	cmp    %eax,%esi
  8017a5:	73 19                	jae    8017c0 <devfile_read+0x4b>
  8017a7:	68 6c 25 80 00       	push   $0x80256c
  8017ac:	68 73 25 80 00       	push   $0x802573
  8017b1:	68 82 00 00 00       	push   $0x82
  8017b6:	68 88 25 80 00       	push   $0x802588
  8017bb:	e8 0c eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  8017c0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c5:	7e 19                	jle    8017e0 <devfile_read+0x6b>
  8017c7:	68 93 25 80 00       	push   $0x802593
  8017cc:	68 73 25 80 00       	push   $0x802573
  8017d1:	68 83 00 00 00       	push   $0x83
  8017d6:	68 88 25 80 00       	push   $0x802588
  8017db:	e8 ec ea ff ff       	call   8002cc <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	50                   	push   %eax
  8017e4:	68 00 50 80 00       	push   $0x805000
  8017e9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ec:	e8 3d f4 ff ff       	call   800c2e <memmove>
	return r;
  8017f1:	83 c4 10             	add    $0x10,%esp
}
  8017f4:	89 d8                	mov    %ebx,%eax
  8017f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	53                   	push   %ebx
  801801:	83 ec 20             	sub    $0x20,%esp
  801804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801807:	53                   	push   %ebx
  801808:	e8 56 f2 ff ff       	call   800a63 <strlen>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801815:	7f 67                	jg     80187e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801817:	83 ec 0c             	sub    $0xc,%esp
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	e8 94 f8 ff ff       	call   8010b7 <fd_alloc>
  801823:	83 c4 10             	add    $0x10,%esp
		return r;
  801826:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 57                	js     801883 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	53                   	push   %ebx
  801830:	68 00 50 80 00       	push   $0x805000
  801835:	e8 62 f2 ff ff       	call   800a9c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801842:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801845:	b8 01 00 00 00       	mov    $0x1,%eax
  80184a:	e8 f0 fd ff ff       	call   80163f <fsipc>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	79 14                	jns    80186c <open+0x6f>
		fd_close(fd, 0);
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	6a 00                	push   $0x0
  80185d:	ff 75 f4             	pushl  -0xc(%ebp)
  801860:	e8 4a f9 ff ff       	call   8011af <fd_close>
		return r;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	89 da                	mov    %ebx,%edx
  80186a:	eb 17                	jmp    801883 <open+0x86>
	}

	return fd2num(fd);
  80186c:	83 ec 0c             	sub    $0xc,%esp
  80186f:	ff 75 f4             	pushl  -0xc(%ebp)
  801872:	e8 19 f8 ff ff       	call   801090 <fd2num>
  801877:	89 c2                	mov    %eax,%edx
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	eb 05                	jmp    801883 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80187e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801883:	89 d0                	mov    %edx,%eax
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801890:	ba 00 00 00 00       	mov    $0x0,%edx
  801895:	b8 08 00 00 00       	mov    $0x8,%eax
  80189a:	e8 a0 fd ff ff       	call   80163f <fsipc>
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018a1:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018a5:	7e 37                	jle    8018de <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018b0:	ff 70 04             	pushl  0x4(%eax)
  8018b3:	8d 40 10             	lea    0x10(%eax),%eax
  8018b6:	50                   	push   %eax
  8018b7:	ff 33                	pushl  (%ebx)
  8018b9:	e8 88 fb ff ff       	call   801446 <write>
		if (result > 0)
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	7e 03                	jle    8018c8 <writebuf+0x27>
			b->result += result;
  8018c5:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018c8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018cb:	74 0d                	je     8018da <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	0f 4f c2             	cmovg  %edx,%eax
  8018d7:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018dd:	c9                   	leave  
  8018de:	f3 c3                	repz ret 

008018e0 <putch>:

static void
putch(int ch, void *thunk)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018ea:	8b 53 04             	mov    0x4(%ebx),%edx
  8018ed:	8d 42 01             	lea    0x1(%edx),%eax
  8018f0:	89 43 04             	mov    %eax,0x4(%ebx)
  8018f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f6:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018fa:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018ff:	75 0e                	jne    80190f <putch+0x2f>
		writebuf(b);
  801901:	89 d8                	mov    %ebx,%eax
  801903:	e8 99 ff ff ff       	call   8018a1 <writebuf>
		b->idx = 0;
  801908:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80190f:	83 c4 04             	add    $0x4,%esp
  801912:	5b                   	pop    %ebx
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801927:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80192e:	00 00 00 
	b.result = 0;
  801931:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801938:	00 00 00 
	b.error = 1;
  80193b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801942:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801945:	ff 75 10             	pushl  0x10(%ebp)
  801948:	ff 75 0c             	pushl  0xc(%ebp)
  80194b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	68 e0 18 80 00       	push   $0x8018e0
  801957:	e8 46 eb ff ff       	call   8004a2 <vprintfmt>
	if (b.idx > 0)
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801966:	7e 0b                	jle    801973 <vfprintf+0x5e>
		writebuf(&b);
  801968:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80196e:	e8 2e ff ff ff       	call   8018a1 <writebuf>

	return (b.result ? b.result : b.error);
  801973:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801979:	85 c0                	test   %eax,%eax
  80197b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80198a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80198d:	50                   	push   %eax
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	ff 75 08             	pushl  0x8(%ebp)
  801994:	e8 7c ff ff ff       	call   801915 <vfprintf>
	va_end(ap);

	return cnt;
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <printf>:

int
printf(const char *fmt, ...)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019a4:	50                   	push   %eax
  8019a5:	ff 75 08             	pushl  0x8(%ebp)
  8019a8:	6a 01                	push   $0x1
  8019aa:	e8 66 ff ff ff       	call   801915 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	ff 75 08             	pushl  0x8(%ebp)
  8019bf:	e8 dc f6 ff ff       	call   8010a0 <fd2data>
  8019c4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019c6:	83 c4 08             	add    $0x8,%esp
  8019c9:	68 9f 25 80 00       	push   $0x80259f
  8019ce:	53                   	push   %ebx
  8019cf:	e8 c8 f0 ff ff       	call   800a9c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019d4:	8b 46 04             	mov    0x4(%esi),%eax
  8019d7:	2b 06                	sub    (%esi),%eax
  8019d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019df:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e6:	00 00 00 
	stat->st_dev = &devpipe;
  8019e9:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019f0:	30 80 00 
	return 0;
}
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	53                   	push   %ebx
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a09:	53                   	push   %ebx
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 13 f5 ff ff       	call   800f24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a11:	89 1c 24             	mov    %ebx,(%esp)
  801a14:	e8 87 f6 ff ff       	call   8010a0 <fd2data>
  801a19:	83 c4 08             	add    $0x8,%esp
  801a1c:	50                   	push   %eax
  801a1d:	6a 00                	push   $0x0
  801a1f:	e8 00 f5 ff ff       	call   800f24 <sys_page_unmap>
}
  801a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	57                   	push   %edi
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 1c             	sub    $0x1c,%esp
  801a32:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a35:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a37:	a1 04 44 80 00       	mov    0x804404,%eax
  801a3c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	ff 75 e0             	pushl  -0x20(%ebp)
  801a45:	e8 d2 03 00 00       	call   801e1c <pageref>
  801a4a:	89 c3                	mov    %eax,%ebx
  801a4c:	89 3c 24             	mov    %edi,(%esp)
  801a4f:	e8 c8 03 00 00       	call   801e1c <pageref>
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	39 c3                	cmp    %eax,%ebx
  801a59:	0f 94 c1             	sete   %cl
  801a5c:	0f b6 c9             	movzbl %cl,%ecx
  801a5f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a62:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a68:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a6b:	39 ce                	cmp    %ecx,%esi
  801a6d:	74 1b                	je     801a8a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a6f:	39 c3                	cmp    %eax,%ebx
  801a71:	75 c4                	jne    801a37 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a73:	8b 42 58             	mov    0x58(%edx),%eax
  801a76:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a79:	50                   	push   %eax
  801a7a:	56                   	push   %esi
  801a7b:	68 a6 25 80 00       	push   $0x8025a6
  801a80:	e8 20 e9 ff ff       	call   8003a5 <cprintf>
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb ad                	jmp    801a37 <_pipeisclosed+0xe>
	}
}
  801a8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5f                   	pop    %edi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	57                   	push   %edi
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 28             	sub    $0x28,%esp
  801a9e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa1:	56                   	push   %esi
  801aa2:	e8 f9 f5 ff ff       	call   8010a0 <fd2data>
  801aa7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab1:	eb 4b                	jmp    801afe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab3:	89 da                	mov    %ebx,%edx
  801ab5:	89 f0                	mov    %esi,%eax
  801ab7:	e8 6d ff ff ff       	call   801a29 <_pipeisclosed>
  801abc:	85 c0                	test   %eax,%eax
  801abe:	75 48                	jne    801b08 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac0:	e8 bb f3 ff ff       	call   800e80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac8:	8b 0b                	mov    (%ebx),%ecx
  801aca:	8d 51 20             	lea    0x20(%ecx),%edx
  801acd:	39 d0                	cmp    %edx,%eax
  801acf:	73 e2                	jae    801ab3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ad8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801adb:	89 c2                	mov    %eax,%edx
  801add:	c1 fa 1f             	sar    $0x1f,%edx
  801ae0:	89 d1                	mov    %edx,%ecx
  801ae2:	c1 e9 1b             	shr    $0x1b,%ecx
  801ae5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ae8:	83 e2 1f             	and    $0x1f,%edx
  801aeb:	29 ca                	sub    %ecx,%edx
  801aed:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801af1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801af5:	83 c0 01             	add    $0x1,%eax
  801af8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afb:	83 c7 01             	add    $0x1,%edi
  801afe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b01:	75 c2                	jne    801ac5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b03:	8b 45 10             	mov    0x10(%ebp),%eax
  801b06:	eb 05                	jmp    801b0d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5f                   	pop    %edi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	57                   	push   %edi
  801b19:	56                   	push   %esi
  801b1a:	53                   	push   %ebx
  801b1b:	83 ec 18             	sub    $0x18,%esp
  801b1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b21:	57                   	push   %edi
  801b22:	e8 79 f5 ff ff       	call   8010a0 <fd2data>
  801b27:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b31:	eb 3d                	jmp    801b70 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b33:	85 db                	test   %ebx,%ebx
  801b35:	74 04                	je     801b3b <devpipe_read+0x26>
				return i;
  801b37:	89 d8                	mov    %ebx,%eax
  801b39:	eb 44                	jmp    801b7f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b3b:	89 f2                	mov    %esi,%edx
  801b3d:	89 f8                	mov    %edi,%eax
  801b3f:	e8 e5 fe ff ff       	call   801a29 <_pipeisclosed>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	75 32                	jne    801b7a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b48:	e8 33 f3 ff ff       	call   800e80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b4d:	8b 06                	mov    (%esi),%eax
  801b4f:	3b 46 04             	cmp    0x4(%esi),%eax
  801b52:	74 df                	je     801b33 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b54:	99                   	cltd   
  801b55:	c1 ea 1b             	shr    $0x1b,%edx
  801b58:	01 d0                	add    %edx,%eax
  801b5a:	83 e0 1f             	and    $0x1f,%eax
  801b5d:	29 d0                	sub    %edx,%eax
  801b5f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b67:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b6a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6d:	83 c3 01             	add    $0x1,%ebx
  801b70:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b73:	75 d8                	jne    801b4d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b75:	8b 45 10             	mov    0x10(%ebp),%eax
  801b78:	eb 05                	jmp    801b7f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b92:	50                   	push   %eax
  801b93:	e8 1f f5 ff ff       	call   8010b7 <fd_alloc>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	89 c2                	mov    %eax,%edx
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	0f 88 2c 01 00 00    	js     801cd1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba5:	83 ec 04             	sub    $0x4,%esp
  801ba8:	68 07 04 00 00       	push   $0x407
  801bad:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb0:	6a 00                	push   $0x0
  801bb2:	e8 e8 f2 ff ff       	call   800e9f <sys_page_alloc>
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	89 c2                	mov    %eax,%edx
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	0f 88 0d 01 00 00    	js     801cd1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bca:	50                   	push   %eax
  801bcb:	e8 e7 f4 ff ff       	call   8010b7 <fd_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 e2 00 00 00    	js     801cbf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdd:	83 ec 04             	sub    $0x4,%esp
  801be0:	68 07 04 00 00       	push   $0x407
  801be5:	ff 75 f0             	pushl  -0x10(%ebp)
  801be8:	6a 00                	push   $0x0
  801bea:	e8 b0 f2 ff ff       	call   800e9f <sys_page_alloc>
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	0f 88 c3 00 00 00    	js     801cbf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bfc:	83 ec 0c             	sub    $0xc,%esp
  801bff:	ff 75 f4             	pushl  -0xc(%ebp)
  801c02:	e8 99 f4 ff ff       	call   8010a0 <fd2data>
  801c07:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c09:	83 c4 0c             	add    $0xc,%esp
  801c0c:	68 07 04 00 00       	push   $0x407
  801c11:	50                   	push   %eax
  801c12:	6a 00                	push   $0x0
  801c14:	e8 86 f2 ff ff       	call   800e9f <sys_page_alloc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 89 00 00 00    	js     801caf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2c:	e8 6f f4 ff ff       	call   8010a0 <fd2data>
  801c31:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c38:	50                   	push   %eax
  801c39:	6a 00                	push   $0x0
  801c3b:	56                   	push   %esi
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 9f f2 ff ff       	call   800ee2 <sys_page_map>
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	83 c4 20             	add    $0x20,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 55                	js     801ca1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c4c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7c:	e8 0f f4 ff ff       	call   801090 <fd2num>
  801c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c84:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c86:	83 c4 04             	add    $0x4,%esp
  801c89:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8c:	e8 ff f3 ff ff       	call   801090 <fd2num>
  801c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c94:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9f:	eb 30                	jmp    801cd1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	56                   	push   %esi
  801ca5:	6a 00                	push   $0x0
  801ca7:	e8 78 f2 ff ff       	call   800f24 <sys_page_unmap>
  801cac:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb5:	6a 00                	push   $0x0
  801cb7:	e8 68 f2 ff ff       	call   800f24 <sys_page_unmap>
  801cbc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 58 f2 ff ff       	call   800f24 <sys_page_unmap>
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cd1:	89 d0                	mov    %edx,%eax
  801cd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd6:	5b                   	pop    %ebx
  801cd7:	5e                   	pop    %esi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	ff 75 08             	pushl  0x8(%ebp)
  801ce7:	e8 1a f4 ff ff       	call   801106 <fd_lookup>
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	78 18                	js     801d0b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf9:	e8 a2 f3 ff ff       	call   8010a0 <fd2data>
	return _pipeisclosed(fd, p);
  801cfe:	89 c2                	mov    %eax,%edx
  801d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d03:	e8 21 fd ff ff       	call   801a29 <_pipeisclosed>
  801d08:	83 c4 10             	add    $0x10,%esp
}
  801d0b:	c9                   	leave  
  801d0c:	c3                   	ret    

00801d0d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	57                   	push   %edi
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	8b 75 08             	mov    0x8(%ebp),%esi
  801d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801d1f:	85 f6                	test   %esi,%esi
  801d21:	74 06                	je     801d29 <ipc_recv+0x1c>
		*from_env_store = 0;
  801d23:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801d29:	85 db                	test   %ebx,%ebx
  801d2b:	74 06                	je     801d33 <ipc_recv+0x26>
		*perm_store = 0;
  801d2d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801d33:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801d35:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d3a:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801d3d:	83 ec 0c             	sub    $0xc,%esp
  801d40:	50                   	push   %eax
  801d41:	e8 09 f3 ff ff       	call   80104f <sys_ipc_recv>
  801d46:	89 c7                	mov    %eax,%edi
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	79 14                	jns    801d63 <ipc_recv+0x56>
		cprintf("im dead");
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	68 be 25 80 00       	push   $0x8025be
  801d57:	e8 49 e6 ff ff       	call   8003a5 <cprintf>
		return r;
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	89 f8                	mov    %edi,%eax
  801d61:	eb 24                	jmp    801d87 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801d63:	85 f6                	test   %esi,%esi
  801d65:	74 0a                	je     801d71 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801d67:	a1 04 44 80 00       	mov    0x804404,%eax
  801d6c:	8b 40 74             	mov    0x74(%eax),%eax
  801d6f:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801d71:	85 db                	test   %ebx,%ebx
  801d73:	74 0a                	je     801d7f <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801d75:	a1 04 44 80 00       	mov    0x804404,%eax
  801d7a:	8b 40 78             	mov    0x78(%eax),%eax
  801d7d:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801d7f:	a1 04 44 80 00       	mov    0x804404,%eax
  801d84:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	57                   	push   %edi
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801da1:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801da3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801da8:	0f 44 d8             	cmove  %eax,%ebx
  801dab:	eb 1c                	jmp    801dc9 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801dad:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801db0:	74 12                	je     801dc4 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801db2:	50                   	push   %eax
  801db3:	68 c6 25 80 00       	push   $0x8025c6
  801db8:	6a 4e                	push   $0x4e
  801dba:	68 d3 25 80 00       	push   $0x8025d3
  801dbf:	e8 08 e5 ff ff       	call   8002cc <_panic>
		sys_yield();
  801dc4:	e8 b7 f0 ff ff       	call   800e80 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801dc9:	ff 75 14             	pushl  0x14(%ebp)
  801dcc:	53                   	push   %ebx
  801dcd:	56                   	push   %esi
  801dce:	57                   	push   %edi
  801dcf:	e8 58 f2 ff ff       	call   80102c <sys_ipc_try_send>
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 d2                	js     801dad <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dee:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801df1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801df7:	8b 52 50             	mov    0x50(%edx),%edx
  801dfa:	39 ca                	cmp    %ecx,%edx
  801dfc:	75 0d                	jne    801e0b <ipc_find_env+0x28>
			return envs[i].env_id;
  801dfe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e01:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e06:	8b 40 48             	mov    0x48(%eax),%eax
  801e09:	eb 0f                	jmp    801e1a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e0b:	83 c0 01             	add    $0x1,%eax
  801e0e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e13:	75 d9                	jne    801dee <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    

00801e1c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e22:	89 d0                	mov    %edx,%eax
  801e24:	c1 e8 16             	shr    $0x16,%eax
  801e27:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e33:	f6 c1 01             	test   $0x1,%cl
  801e36:	74 1d                	je     801e55 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e38:	c1 ea 0c             	shr    $0xc,%edx
  801e3b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e42:	f6 c2 01             	test   $0x1,%dl
  801e45:	74 0e                	je     801e55 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e47:	c1 ea 0c             	shr    $0xc,%edx
  801e4a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e51:	ef 
  801e52:	0f b7 c0             	movzwl %ax,%eax
}
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    
  801e57:	66 90                	xchg   %ax,%ax
  801e59:	66 90                	xchg   %ax,%ax
  801e5b:	66 90                	xchg   %ax,%ax
  801e5d:	66 90                	xchg   %ax,%ax
  801e5f:	90                   	nop

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
  801e67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e77:	85 f6                	test   %esi,%esi
  801e79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7d:	89 ca                	mov    %ecx,%edx
  801e7f:	89 f8                	mov    %edi,%eax
  801e81:	75 3d                	jne    801ec0 <__udivdi3+0x60>
  801e83:	39 cf                	cmp    %ecx,%edi
  801e85:	0f 87 c5 00 00 00    	ja     801f50 <__udivdi3+0xf0>
  801e8b:	85 ff                	test   %edi,%edi
  801e8d:	89 fd                	mov    %edi,%ebp
  801e8f:	75 0b                	jne    801e9c <__udivdi3+0x3c>
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	31 d2                	xor    %edx,%edx
  801e98:	f7 f7                	div    %edi
  801e9a:	89 c5                	mov    %eax,%ebp
  801e9c:	89 c8                	mov    %ecx,%eax
  801e9e:	31 d2                	xor    %edx,%edx
  801ea0:	f7 f5                	div    %ebp
  801ea2:	89 c1                	mov    %eax,%ecx
  801ea4:	89 d8                	mov    %ebx,%eax
  801ea6:	89 cf                	mov    %ecx,%edi
  801ea8:	f7 f5                	div    %ebp
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	89 fa                	mov    %edi,%edx
  801eb0:	83 c4 1c             	add    $0x1c,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	39 ce                	cmp    %ecx,%esi
  801ec2:	77 74                	ja     801f38 <__udivdi3+0xd8>
  801ec4:	0f bd fe             	bsr    %esi,%edi
  801ec7:	83 f7 1f             	xor    $0x1f,%edi
  801eca:	0f 84 98 00 00 00    	je     801f68 <__udivdi3+0x108>
  801ed0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	89 c5                	mov    %eax,%ebp
  801ed9:	29 fb                	sub    %edi,%ebx
  801edb:	d3 e6                	shl    %cl,%esi
  801edd:	89 d9                	mov    %ebx,%ecx
  801edf:	d3 ed                	shr    %cl,%ebp
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e0                	shl    %cl,%eax
  801ee5:	09 ee                	or     %ebp,%esi
  801ee7:	89 d9                	mov    %ebx,%ecx
  801ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eed:	89 d5                	mov    %edx,%ebp
  801eef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ef3:	d3 ed                	shr    %cl,%ebp
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	d3 e2                	shl    %cl,%edx
  801ef9:	89 d9                	mov    %ebx,%ecx
  801efb:	d3 e8                	shr    %cl,%eax
  801efd:	09 c2                	or     %eax,%edx
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	89 ea                	mov    %ebp,%edx
  801f03:	f7 f6                	div    %esi
  801f05:	89 d5                	mov    %edx,%ebp
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	f7 64 24 0c          	mull   0xc(%esp)
  801f0d:	39 d5                	cmp    %edx,%ebp
  801f0f:	72 10                	jb     801f21 <__udivdi3+0xc1>
  801f11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e6                	shl    %cl,%esi
  801f19:	39 c6                	cmp    %eax,%esi
  801f1b:	73 07                	jae    801f24 <__udivdi3+0xc4>
  801f1d:	39 d5                	cmp    %edx,%ebp
  801f1f:	75 03                	jne    801f24 <__udivdi3+0xc4>
  801f21:	83 eb 01             	sub    $0x1,%ebx
  801f24:	31 ff                	xor    %edi,%edi
  801f26:	89 d8                	mov    %ebx,%eax
  801f28:	89 fa                	mov    %edi,%edx
  801f2a:	83 c4 1c             	add    $0x1c,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    
  801f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f38:	31 ff                	xor    %edi,%edi
  801f3a:	31 db                	xor    %ebx,%ebx
  801f3c:	89 d8                	mov    %ebx,%eax
  801f3e:	89 fa                	mov    %edi,%edx
  801f40:	83 c4 1c             	add    $0x1c,%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    
  801f48:	90                   	nop
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 d8                	mov    %ebx,%eax
  801f52:	f7 f7                	div    %edi
  801f54:	31 ff                	xor    %edi,%edi
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	89 d8                	mov    %ebx,%eax
  801f5a:	89 fa                	mov    %edi,%edx
  801f5c:	83 c4 1c             	add    $0x1c,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	39 ce                	cmp    %ecx,%esi
  801f6a:	72 0c                	jb     801f78 <__udivdi3+0x118>
  801f6c:	31 db                	xor    %ebx,%ebx
  801f6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f72:	0f 87 34 ff ff ff    	ja     801eac <__udivdi3+0x4c>
  801f78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f7d:	e9 2a ff ff ff       	jmp    801eac <__udivdi3+0x4c>
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 d2                	test   %edx,%edx
  801fa9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb1:	89 f3                	mov    %esi,%ebx
  801fb3:	89 3c 24             	mov    %edi,(%esp)
  801fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fba:	75 1c                	jne    801fd8 <__umoddi3+0x48>
  801fbc:	39 f7                	cmp    %esi,%edi
  801fbe:	76 50                	jbe    802010 <__umoddi3+0x80>
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 f2                	mov    %esi,%edx
  801fc4:	f7 f7                	div    %edi
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	31 d2                	xor    %edx,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	39 f2                	cmp    %esi,%edx
  801fda:	89 d0                	mov    %edx,%eax
  801fdc:	77 52                	ja     802030 <__umoddi3+0xa0>
  801fde:	0f bd ea             	bsr    %edx,%ebp
  801fe1:	83 f5 1f             	xor    $0x1f,%ebp
  801fe4:	75 5a                	jne    802040 <__umoddi3+0xb0>
  801fe6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fea:	0f 82 e0 00 00 00    	jb     8020d0 <__umoddi3+0x140>
  801ff0:	39 0c 24             	cmp    %ecx,(%esp)
  801ff3:	0f 86 d7 00 00 00    	jbe    8020d0 <__umoddi3+0x140>
  801ff9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ffd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802001:	83 c4 1c             	add    $0x1c,%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	85 ff                	test   %edi,%edi
  802012:	89 fd                	mov    %edi,%ebp
  802014:	75 0b                	jne    802021 <__umoddi3+0x91>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f7                	div    %edi
  80201f:	89 c5                	mov    %eax,%ebp
  802021:	89 f0                	mov    %esi,%eax
  802023:	31 d2                	xor    %edx,%edx
  802025:	f7 f5                	div    %ebp
  802027:	89 c8                	mov    %ecx,%eax
  802029:	f7 f5                	div    %ebp
  80202b:	89 d0                	mov    %edx,%eax
  80202d:	eb 99                	jmp    801fc8 <__umoddi3+0x38>
  80202f:	90                   	nop
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	8b 34 24             	mov    (%esp),%esi
  802043:	bf 20 00 00 00       	mov    $0x20,%edi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	29 ef                	sub    %ebp,%edi
  80204c:	d3 e0                	shl    %cl,%eax
  80204e:	89 f9                	mov    %edi,%ecx
  802050:	89 f2                	mov    %esi,%edx
  802052:	d3 ea                	shr    %cl,%edx
  802054:	89 e9                	mov    %ebp,%ecx
  802056:	09 c2                	or     %eax,%edx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 14 24             	mov    %edx,(%esp)
  80205d:	89 f2                	mov    %esi,%edx
  80205f:	d3 e2                	shl    %cl,%edx
  802061:	89 f9                	mov    %edi,%ecx
  802063:	89 54 24 04          	mov    %edx,0x4(%esp)
  802067:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	89 e9                	mov    %ebp,%ecx
  80206f:	89 c6                	mov    %eax,%esi
  802071:	d3 e3                	shl    %cl,%ebx
  802073:	89 f9                	mov    %edi,%ecx
  802075:	89 d0                	mov    %edx,%eax
  802077:	d3 e8                	shr    %cl,%eax
  802079:	89 e9                	mov    %ebp,%ecx
  80207b:	09 d8                	or     %ebx,%eax
  80207d:	89 d3                	mov    %edx,%ebx
  80207f:	89 f2                	mov    %esi,%edx
  802081:	f7 34 24             	divl   (%esp)
  802084:	89 d6                	mov    %edx,%esi
  802086:	d3 e3                	shl    %cl,%ebx
  802088:	f7 64 24 04          	mull   0x4(%esp)
  80208c:	39 d6                	cmp    %edx,%esi
  80208e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802092:	89 d1                	mov    %edx,%ecx
  802094:	89 c3                	mov    %eax,%ebx
  802096:	72 08                	jb     8020a0 <__umoddi3+0x110>
  802098:	75 11                	jne    8020ab <__umoddi3+0x11b>
  80209a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80209e:	73 0b                	jae    8020ab <__umoddi3+0x11b>
  8020a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020a4:	1b 14 24             	sbb    (%esp),%edx
  8020a7:	89 d1                	mov    %edx,%ecx
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020af:	29 da                	sub    %ebx,%edx
  8020b1:	19 ce                	sbb    %ecx,%esi
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	89 f0                	mov    %esi,%eax
  8020b7:	d3 e0                	shl    %cl,%eax
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	d3 ea                	shr    %cl,%edx
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	d3 ee                	shr    %cl,%esi
  8020c1:	09 d0                	or     %edx,%eax
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	83 c4 1c             	add    $0x1c,%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5e                   	pop    %esi
  8020ca:	5f                   	pop    %edi
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    
  8020cd:	8d 76 00             	lea    0x0(%esi),%esi
  8020d0:	29 f9                	sub    %edi,%ecx
  8020d2:	19 d6                	sbb    %edx,%esi
  8020d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020dc:	e9 18 ff ff ff       	jmp    801ff9 <__umoddi3+0x69>
