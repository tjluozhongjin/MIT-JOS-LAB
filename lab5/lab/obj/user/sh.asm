
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 60 33 80 00       	push   $0x803360
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 6f 33 80 00       	push   $0x80336f
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 7d 33 80 00       	push   $0x80337d
  8000b0:	e8 38 12 00 00       	call   8012ed <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 82 33 80 00       	push   $0x803382
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 93 33 80 00       	push   $0x803393
  8000fb:	e8 ed 11 00 00       	call   8012ed <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 87 33 80 00       	push   $0x803387
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 8f 33 80 00       	push   $0x80338f
  800151:	e8 97 11 00 00       	call   8012ed <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 9b 33 80 00       	push   $0x80339b
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 a5 33 80 00       	push   $0x8033a5
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 f8 34 80 00       	push   $0x8034f8
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			// panic("< redirection not implemented");
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 cc 20 00 00       	call   802392 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 b9 33 80 00       	push   $0x8033b9
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
				exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}
			if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 18 1b 00 00       	call   801e15 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 c0 1a 00 00       	call   801dc5 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 20 35 80 00       	push   $0x803520
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 4d 20 00 00       	call   802392 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ce 33 80 00       	push   $0x8033ce
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 9a 1a 00 00       	call   801e15 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 42 1a 00 00       	call   801dc5 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 60 29 00 00       	call   802cfa <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 e4 33 80 00       	push   $0x8033e4
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 ed 33 80 00       	push   $0x8033ed
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 f2 14 00 00       	call   8018d3 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 fa 33 80 00       	push   $0x8033fa
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 ff 19 00 00       	call   801e15 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 a1 19 00 00       	call   801dc5 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 90 19 00 00       	call   801dc5 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 c2 19 00 00       	call   801e15 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 64 19 00 00       	call   801dc5 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 53 19 00 00       	call   801dc5 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 03 34 80 00       	push   $0x803403
  80047d:	6a 78                	push   $0x78
  80047f:	68 1f 34 80 00       	push   $0x80341f
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 29 34 80 00       	push   $0x803429
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 0c 0d 00 00       	call   8011e5 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 38 34 80 00       	push   $0x803438
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 c0 34 80 00       	push   $0x8034c0
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 80 33 80 00       	push   $0x803380
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 fe 1f 00 00       	call   802546 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 46 34 80 00       	push   $0x803446
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 85 18 00 00       	call   801df0 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 54 34 80 00       	push   $0x803454
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 ed 28 00 00       	call   802e80 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 69 34 80 00       	push   $0x803469
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 7f 34 80 00       	push   $0x80347f
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 94 28 00 00       	call   802e80 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 69 34 80 00       	push   $0x803469
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 d3 17 00 00       	call   801df0 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 48 35 80 00       	push   $0x803548
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 60 14 00 00       	call   801ad1 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 44 14 00 00       	call   801b01 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 e6 16 00 00       	call   801dc5 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 a6 1c 00 00       	call   802392 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 9c 34 80 00       	push   $0x80349c
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 1f 34 80 00       	push   $0x80341f
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 a8 34 80 00       	push   $0x8034a8
  800717:	68 af 34 80 00       	push   $0x8034af
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 1f 34 80 00       	push   $0x80341f
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf c4 34 80 00       	mov    $0x8034c4,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 62 09 00 00       	call   8010b9 <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 c7 34 80 00       	push   $0x8034c7
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 d0 34 80 00       	push   $0x8034d0
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 da 34 80 00       	push   $0x8034da
  8007ac:	e8 7f 1d 00 00       	call   802530 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 e0 34 80 00       	push   $0x8034e0
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 01 11 00 00       	call   8018d3 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 fa 33 80 00       	push   $0x8033fa
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 1f 34 80 00       	push   $0x80341f
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 ed 34 80 00       	push   $0x8034ed
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 56 26 00 00       	call   802e80 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 69 35 80 00       	push   $0x803569
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 96 09 00 00       	call   8011e5 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 ea 0a 00 00       	call   801377 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 95 0c 00 00       	call   80152c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 06 0d 00 00       	call   8015c9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 82 0c 00 00       	call   80154a <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 2d 0c 00 00       	call   80152c <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 ea 15 00 00       	call   801f01 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 5a 13 00 00       	call   801c9b <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 e2 12 00 00       	call   801c4c <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 63 0c 00 00       	call   8015e8 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 79 12 00 00       	call   801c25 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 e5 0b 00 00       	call   8015aa <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 ea 13 00 00       	call   801df0 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 59 0b 00 00       	call   801569 <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 82 0b 00 00       	call   8015aa <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 80 35 80 00       	push   $0x803580
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 80 33 80 00 	movl   $0x803380,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 a1 0a 00 00       	call   80152c <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 1a 01 00 00       	call   800beb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 46 0a 00 00       	call   80152c <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 6a 25 00 00       	call   8030c0 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 57 26 00 00       	call   8031f0 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 a3 35 80 00 	movsbl 0x8035a3(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bb7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bbb:	8b 10                	mov    (%eax),%edx
  800bbd:	3b 50 04             	cmp    0x4(%eax),%edx
  800bc0:	73 0a                	jae    800bcc <sprintputch+0x1b>
		*b->buf++ = ch;
  800bc2:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bc5:	89 08                	mov    %ecx,(%eax)
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	88 02                	mov    %al,(%edx)
}
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800bd4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bd7:	50                   	push   %eax
  800bd8:	ff 75 10             	pushl  0x10(%ebp)
  800bdb:	ff 75 0c             	pushl  0xc(%ebp)
  800bde:	ff 75 08             	pushl  0x8(%ebp)
  800be1:	e8 05 00 00 00       	call   800beb <vprintfmt>
	va_end(ap);
}
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 2c             	sub    $0x2c,%esp
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfa:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bfd:	eb 12                	jmp    800c11 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bff:	85 c0                	test   %eax,%eax
  800c01:	0f 84 42 04 00 00    	je     801049 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800c07:	83 ec 08             	sub    $0x8,%esp
  800c0a:	53                   	push   %ebx
  800c0b:	50                   	push   %eax
  800c0c:	ff d6                	call   *%esi
  800c0e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c11:	83 c7 01             	add    $0x1,%edi
  800c14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c18:	83 f8 25             	cmp    $0x25,%eax
  800c1b:	75 e2                	jne    800bff <vprintfmt+0x14>
  800c1d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c2f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	eb 07                	jmp    800c44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c40:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c44:	8d 47 01             	lea    0x1(%edi),%eax
  800c47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4a:	0f b6 07             	movzbl (%edi),%eax
  800c4d:	0f b6 d0             	movzbl %al,%edx
  800c50:	83 e8 23             	sub    $0x23,%eax
  800c53:	3c 55                	cmp    $0x55,%al
  800c55:	0f 87 d3 03 00 00    	ja     80102e <vprintfmt+0x443>
  800c5b:	0f b6 c0             	movzbl %al,%eax
  800c5e:	ff 24 85 e0 36 80 00 	jmp    *0x8036e0(,%eax,4)
  800c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c68:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c6c:	eb d6                	jmp    800c44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c79:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c7c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800c80:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800c83:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c86:	83 f9 09             	cmp    $0x9,%ecx
  800c89:	77 3f                	ja     800cca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c8b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c8e:	eb e9                	jmp    800c79 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c90:	8b 45 14             	mov    0x14(%ebp),%eax
  800c93:	8b 00                	mov    (%eax),%eax
  800c95:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c98:	8b 45 14             	mov    0x14(%ebp),%eax
  800c9b:	8d 40 04             	lea    0x4(%eax),%eax
  800c9e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800ca4:	eb 2a                	jmp    800cd0 <vprintfmt+0xe5>
  800ca6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	0f 49 d0             	cmovns %eax,%edx
  800cb3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb9:	eb 89                	jmp    800c44 <vprintfmt+0x59>
  800cbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cbe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cc5:	e9 7a ff ff ff       	jmp    800c44 <vprintfmt+0x59>
  800cca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800ccd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800cd0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cd4:	0f 89 6a ff ff ff    	jns    800c44 <vprintfmt+0x59>
				width = precision, precision = -1;
  800cda:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ce0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ce7:	e9 58 ff ff ff       	jmp    800c44 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800cec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800cf2:	e9 4d ff ff ff       	jmp    800c44 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cf7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cfa:	8d 78 04             	lea    0x4(%eax),%edi
  800cfd:	83 ec 08             	sub    $0x8,%esp
  800d00:	53                   	push   %ebx
  800d01:	ff 30                	pushl  (%eax)
  800d03:	ff d6                	call   *%esi
			break;
  800d05:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d08:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d0e:	e9 fe fe ff ff       	jmp    800c11 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d13:	8b 45 14             	mov    0x14(%ebp),%eax
  800d16:	8d 78 04             	lea    0x4(%eax),%edi
  800d19:	8b 00                	mov    (%eax),%eax
  800d1b:	99                   	cltd   
  800d1c:	31 d0                	xor    %edx,%eax
  800d1e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d20:	83 f8 0f             	cmp    $0xf,%eax
  800d23:	7f 0b                	jg     800d30 <vprintfmt+0x145>
  800d25:	8b 14 85 40 38 80 00 	mov    0x803840(,%eax,4),%edx
  800d2c:	85 d2                	test   %edx,%edx
  800d2e:	75 1b                	jne    800d4b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800d30:	50                   	push   %eax
  800d31:	68 bb 35 80 00       	push   $0x8035bb
  800d36:	53                   	push   %ebx
  800d37:	56                   	push   %esi
  800d38:	e8 91 fe ff ff       	call   800bce <printfmt>
  800d3d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d40:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d46:	e9 c6 fe ff ff       	jmp    800c11 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d4b:	52                   	push   %edx
  800d4c:	68 c1 34 80 00       	push   $0x8034c1
  800d51:	53                   	push   %ebx
  800d52:	56                   	push   %esi
  800d53:	e8 76 fe ff ff       	call   800bce <printfmt>
  800d58:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d5b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d61:	e9 ab fe ff ff       	jmp    800c11 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d66:	8b 45 14             	mov    0x14(%ebp),%eax
  800d69:	83 c0 04             	add    $0x4,%eax
  800d6c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d72:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d74:	85 ff                	test   %edi,%edi
  800d76:	b8 b4 35 80 00       	mov    $0x8035b4,%eax
  800d7b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d7e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d82:	0f 8e 94 00 00 00    	jle    800e1c <vprintfmt+0x231>
  800d88:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d8c:	0f 84 98 00 00 00    	je     800e2a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d92:	83 ec 08             	sub    $0x8,%esp
  800d95:	ff 75 d0             	pushl  -0x30(%ebp)
  800d98:	57                   	push   %edi
  800d99:	e8 26 04 00 00       	call   8011c4 <strnlen>
  800d9e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800da1:	29 c1                	sub    %eax,%ecx
  800da3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800da6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800da9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800dad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800db0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800db3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800db5:	eb 0f                	jmp    800dc6 <vprintfmt+0x1db>
					putch(padc, putdat);
  800db7:	83 ec 08             	sub    $0x8,%esp
  800dba:	53                   	push   %ebx
  800dbb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dbe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc0:	83 ef 01             	sub    $0x1,%edi
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 ff                	test   %edi,%edi
  800dc8:	7f ed                	jg     800db7 <vprintfmt+0x1cc>
  800dca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dcd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800dd0:	85 c9                	test   %ecx,%ecx
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd7:	0f 49 c1             	cmovns %ecx,%eax
  800dda:	29 c1                	sub    %eax,%ecx
  800ddc:	89 75 08             	mov    %esi,0x8(%ebp)
  800ddf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800de2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800de5:	89 cb                	mov    %ecx,%ebx
  800de7:	eb 4d                	jmp    800e36 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800de9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ded:	74 1b                	je     800e0a <vprintfmt+0x21f>
  800def:	0f be c0             	movsbl %al,%eax
  800df2:	83 e8 20             	sub    $0x20,%eax
  800df5:	83 f8 5e             	cmp    $0x5e,%eax
  800df8:	76 10                	jbe    800e0a <vprintfmt+0x21f>
					putch('?', putdat);
  800dfa:	83 ec 08             	sub    $0x8,%esp
  800dfd:	ff 75 0c             	pushl  0xc(%ebp)
  800e00:	6a 3f                	push   $0x3f
  800e02:	ff 55 08             	call   *0x8(%ebp)
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	eb 0d                	jmp    800e17 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800e0a:	83 ec 08             	sub    $0x8,%esp
  800e0d:	ff 75 0c             	pushl  0xc(%ebp)
  800e10:	52                   	push   %edx
  800e11:	ff 55 08             	call   *0x8(%ebp)
  800e14:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e17:	83 eb 01             	sub    $0x1,%ebx
  800e1a:	eb 1a                	jmp    800e36 <vprintfmt+0x24b>
  800e1c:	89 75 08             	mov    %esi,0x8(%ebp)
  800e1f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e22:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e25:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e28:	eb 0c                	jmp    800e36 <vprintfmt+0x24b>
  800e2a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e2d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e30:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e33:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e36:	83 c7 01             	add    $0x1,%edi
  800e39:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e3d:	0f be d0             	movsbl %al,%edx
  800e40:	85 d2                	test   %edx,%edx
  800e42:	74 23                	je     800e67 <vprintfmt+0x27c>
  800e44:	85 f6                	test   %esi,%esi
  800e46:	78 a1                	js     800de9 <vprintfmt+0x1fe>
  800e48:	83 ee 01             	sub    $0x1,%esi
  800e4b:	79 9c                	jns    800de9 <vprintfmt+0x1fe>
  800e4d:	89 df                	mov    %ebx,%edi
  800e4f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e55:	eb 18                	jmp    800e6f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	53                   	push   %ebx
  800e5b:	6a 20                	push   $0x20
  800e5d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e5f:	83 ef 01             	sub    $0x1,%edi
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	eb 08                	jmp    800e6f <vprintfmt+0x284>
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e6f:	85 ff                	test   %edi,%edi
  800e71:	7f e4                	jg     800e57 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e73:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e76:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e7c:	e9 90 fd ff ff       	jmp    800c11 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e81:	83 f9 01             	cmp    $0x1,%ecx
  800e84:	7e 19                	jle    800e9f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800e86:	8b 45 14             	mov    0x14(%ebp),%eax
  800e89:	8b 50 04             	mov    0x4(%eax),%edx
  800e8c:	8b 00                	mov    (%eax),%eax
  800e8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e91:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800e94:	8b 45 14             	mov    0x14(%ebp),%eax
  800e97:	8d 40 08             	lea    0x8(%eax),%eax
  800e9a:	89 45 14             	mov    %eax,0x14(%ebp)
  800e9d:	eb 38                	jmp    800ed7 <vprintfmt+0x2ec>
	else if (lflag)
  800e9f:	85 c9                	test   %ecx,%ecx
  800ea1:	74 1b                	je     800ebe <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8b 00                	mov    (%eax),%eax
  800ea8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eab:	89 c1                	mov    %eax,%ecx
  800ead:	c1 f9 1f             	sar    $0x1f,%ecx
  800eb0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800eb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb6:	8d 40 04             	lea    0x4(%eax),%eax
  800eb9:	89 45 14             	mov    %eax,0x14(%ebp)
  800ebc:	eb 19                	jmp    800ed7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800ebe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec1:	8b 00                	mov    (%eax),%eax
  800ec3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec6:	89 c1                	mov    %eax,%ecx
  800ec8:	c1 f9 1f             	sar    $0x1f,%ecx
  800ecb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ece:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed1:	8d 40 04             	lea    0x4(%eax),%eax
  800ed4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ed7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800eda:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800edd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ee2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ee6:	0f 89 0e 01 00 00    	jns    800ffa <vprintfmt+0x40f>
				putch('-', putdat);
  800eec:	83 ec 08             	sub    $0x8,%esp
  800eef:	53                   	push   %ebx
  800ef0:	6a 2d                	push   $0x2d
  800ef2:	ff d6                	call   *%esi
				num = -(long long) num;
  800ef4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ef7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800efa:	f7 da                	neg    %edx
  800efc:	83 d1 00             	adc    $0x0,%ecx
  800eff:	f7 d9                	neg    %ecx
  800f01:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f09:	e9 ec 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f0e:	83 f9 01             	cmp    $0x1,%ecx
  800f11:	7e 18                	jle    800f2b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800f13:	8b 45 14             	mov    0x14(%ebp),%eax
  800f16:	8b 10                	mov    (%eax),%edx
  800f18:	8b 48 04             	mov    0x4(%eax),%ecx
  800f1b:	8d 40 08             	lea    0x8(%eax),%eax
  800f1e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f26:	e9 cf 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800f2b:	85 c9                	test   %ecx,%ecx
  800f2d:	74 1a                	je     800f49 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800f2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f32:	8b 10                	mov    (%eax),%edx
  800f34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f39:	8d 40 04             	lea    0x4(%eax),%eax
  800f3c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f44:	e9 b1 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800f49:	8b 45 14             	mov    0x14(%ebp),%eax
  800f4c:	8b 10                	mov    (%eax),%edx
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	8d 40 04             	lea    0x4(%eax),%eax
  800f56:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800f59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5e:	e9 97 00 00 00       	jmp    800ffa <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	53                   	push   %ebx
  800f67:	6a 58                	push   $0x58
  800f69:	ff d6                	call   *%esi
			putch('X', putdat);
  800f6b:	83 c4 08             	add    $0x8,%esp
  800f6e:	53                   	push   %ebx
  800f6f:	6a 58                	push   $0x58
  800f71:	ff d6                	call   *%esi
			putch('X', putdat);
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	53                   	push   %ebx
  800f77:	6a 58                	push   $0x58
  800f79:	ff d6                	call   *%esi
			break;
  800f7b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800f81:	e9 8b fc ff ff       	jmp    800c11 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	53                   	push   %ebx
  800f8a:	6a 30                	push   $0x30
  800f8c:	ff d6                	call   *%esi
			putch('x', putdat);
  800f8e:	83 c4 08             	add    $0x8,%esp
  800f91:	53                   	push   %ebx
  800f92:	6a 78                	push   $0x78
  800f94:	ff d6                	call   *%esi
			num = (unsigned long long)
  800f96:	8b 45 14             	mov    0x14(%ebp),%eax
  800f99:	8b 10                	mov    (%eax),%edx
  800f9b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800fa0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800fa3:	8d 40 04             	lea    0x4(%eax),%eax
  800fa6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800fa9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fae:	eb 4a                	jmp    800ffa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800fb0:	83 f9 01             	cmp    $0x1,%ecx
  800fb3:	7e 15                	jle    800fca <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800fb5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb8:	8b 10                	mov    (%eax),%edx
  800fba:	8b 48 04             	mov    0x4(%eax),%ecx
  800fbd:	8d 40 08             	lea    0x8(%eax),%eax
  800fc0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fc3:	b8 10 00 00 00       	mov    $0x10,%eax
  800fc8:	eb 30                	jmp    800ffa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800fca:	85 c9                	test   %ecx,%ecx
  800fcc:	74 17                	je     800fe5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800fce:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd1:	8b 10                	mov    (%eax),%edx
  800fd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd8:	8d 40 04             	lea    0x4(%eax),%eax
  800fdb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800fde:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe3:	eb 15                	jmp    800ffa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800fe5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe8:	8b 10                	mov    (%eax),%edx
  800fea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fef:	8d 40 04             	lea    0x4(%eax),%eax
  800ff2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ff5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801001:	57                   	push   %edi
  801002:	ff 75 e0             	pushl  -0x20(%ebp)
  801005:	50                   	push   %eax
  801006:	51                   	push   %ecx
  801007:	52                   	push   %edx
  801008:	89 da                	mov    %ebx,%edx
  80100a:	89 f0                	mov    %esi,%eax
  80100c:	e8 f1 fa ff ff       	call   800b02 <printnum>
			break;
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801017:	e9 f5 fb ff ff       	jmp    800c11 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	53                   	push   %ebx
  801020:	52                   	push   %edx
  801021:	ff d6                	call   *%esi
			break;
  801023:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801026:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801029:	e9 e3 fb ff ff       	jmp    800c11 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	53                   	push   %ebx
  801032:	6a 25                	push   $0x25
  801034:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	eb 03                	jmp    80103e <vprintfmt+0x453>
  80103b:	83 ef 01             	sub    $0x1,%edi
  80103e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801042:	75 f7                	jne    80103b <vprintfmt+0x450>
  801044:	e9 c8 fb ff ff       	jmp    800c11 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 18             	sub    $0x18,%esp
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80105d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801060:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801064:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801067:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80106e:	85 c0                	test   %eax,%eax
  801070:	74 26                	je     801098 <vsnprintf+0x47>
  801072:	85 d2                	test   %edx,%edx
  801074:	7e 22                	jle    801098 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801076:	ff 75 14             	pushl  0x14(%ebp)
  801079:	ff 75 10             	pushl  0x10(%ebp)
  80107c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80107f:	50                   	push   %eax
  801080:	68 b1 0b 80 00       	push   $0x800bb1
  801085:	e8 61 fb ff ff       	call   800beb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80108a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80108d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	eb 05                	jmp    80109d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801098:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010a8:	50                   	push   %eax
  8010a9:	ff 75 10             	pushl  0x10(%ebp)
  8010ac:	ff 75 0c             	pushl  0xc(%ebp)
  8010af:	ff 75 08             	pushl  0x8(%ebp)
  8010b2:	e8 9a ff ff ff       	call   801051 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	74 13                	je     8010dc <readline+0x23>
		fprintf(1, "%s", prompt);
  8010c9:	83 ec 04             	sub    $0x4,%esp
  8010cc:	50                   	push   %eax
  8010cd:	68 c1 34 80 00       	push   $0x8034c1
  8010d2:	6a 01                	push   $0x1
  8010d4:	e8 40 14 00 00       	call   802519 <fprintf>
  8010d9:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 49 f8 ff ff       	call   80092f <iscons>
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010eb:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010f0:	e8 0f f8 ff ff       	call   800904 <getchar>
  8010f5:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	79 29                	jns    801124 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801100:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801103:	0f 84 9b 00 00 00    	je     8011a4 <readline+0xeb>
				cprintf("read error: %e\n", c);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	53                   	push   %ebx
  80110d:	68 9f 38 80 00       	push   $0x80389f
  801112:	e8 d7 f9 ff ff       	call   800aee <cprintf>
  801117:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	e9 80 00 00 00       	jmp    8011a4 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801124:	83 f8 08             	cmp    $0x8,%eax
  801127:	0f 94 c2             	sete   %dl
  80112a:	83 f8 7f             	cmp    $0x7f,%eax
  80112d:	0f 94 c0             	sete   %al
  801130:	08 c2                	or     %al,%dl
  801132:	74 1a                	je     80114e <readline+0x95>
  801134:	85 f6                	test   %esi,%esi
  801136:	7e 16                	jle    80114e <readline+0x95>
			if (echoing)
  801138:	85 ff                	test   %edi,%edi
  80113a:	74 0d                	je     801149 <readline+0x90>
				cputchar('\b');
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	6a 08                	push   $0x8
  801141:	e8 a2 f7 ff ff       	call   8008e8 <cputchar>
  801146:	83 c4 10             	add    $0x10,%esp
			i--;
  801149:	83 ee 01             	sub    $0x1,%esi
  80114c:	eb a2                	jmp    8010f0 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80114e:	83 fb 1f             	cmp    $0x1f,%ebx
  801151:	7e 26                	jle    801179 <readline+0xc0>
  801153:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801159:	7f 1e                	jg     801179 <readline+0xc0>
			if (echoing)
  80115b:	85 ff                	test   %edi,%edi
  80115d:	74 0c                	je     80116b <readline+0xb2>
				cputchar(c);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	53                   	push   %ebx
  801163:	e8 80 f7 ff ff       	call   8008e8 <cputchar>
  801168:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80116b:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801171:	8d 76 01             	lea    0x1(%esi),%esi
  801174:	e9 77 ff ff ff       	jmp    8010f0 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801179:	83 fb 0a             	cmp    $0xa,%ebx
  80117c:	74 09                	je     801187 <readline+0xce>
  80117e:	83 fb 0d             	cmp    $0xd,%ebx
  801181:	0f 85 69 ff ff ff    	jne    8010f0 <readline+0x37>
			if (echoing)
  801187:	85 ff                	test   %edi,%edi
  801189:	74 0d                	je     801198 <readline+0xdf>
				cputchar('\n');
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	6a 0a                	push   $0xa
  801190:	e8 53 f7 ff ff       	call   8008e8 <cputchar>
  801195:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801198:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80119f:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 03                	jmp    8011bc <strlen+0x10>
		n++;
  8011b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011c0:	75 f7                	jne    8011b9 <strlen+0xd>
		n++;
	return n;
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d2:	eb 03                	jmp    8011d7 <strnlen+0x13>
		n++;
  8011d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011d7:	39 c2                	cmp    %eax,%edx
  8011d9:	74 08                	je     8011e3 <strnlen+0x1f>
  8011db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8011df:	75 f3                	jne    8011d4 <strnlen+0x10>
  8011e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	53                   	push   %ebx
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	83 c2 01             	add    $0x1,%edx
  8011f4:	83 c1 01             	add    $0x1,%ecx
  8011f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8011fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8011fe:	84 db                	test   %bl,%bl
  801200:	75 ef                	jne    8011f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801202:	5b                   	pop    %ebx
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	53                   	push   %ebx
  801209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80120c:	53                   	push   %ebx
  80120d:	e8 9a ff ff ff       	call   8011ac <strlen>
  801212:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	01 d8                	add    %ebx,%eax
  80121a:	50                   	push   %eax
  80121b:	e8 c5 ff ff ff       	call   8011e5 <strcpy>
	return dst;
}
  801220:	89 d8                	mov    %ebx,%eax
  801222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	56                   	push   %esi
  80122b:	53                   	push   %ebx
  80122c:	8b 75 08             	mov    0x8(%ebp),%esi
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	89 f3                	mov    %esi,%ebx
  801234:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801237:	89 f2                	mov    %esi,%edx
  801239:	eb 0f                	jmp    80124a <strncpy+0x23>
		*dst++ = *src;
  80123b:	83 c2 01             	add    $0x1,%edx
  80123e:	0f b6 01             	movzbl (%ecx),%eax
  801241:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801244:	80 39 01             	cmpb   $0x1,(%ecx)
  801247:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80124a:	39 da                	cmp    %ebx,%edx
  80124c:	75 ed                	jne    80123b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80124e:	89 f0                	mov    %esi,%eax
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
  80125c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125f:	8b 55 10             	mov    0x10(%ebp),%edx
  801262:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801264:	85 d2                	test   %edx,%edx
  801266:	74 21                	je     801289 <strlcpy+0x35>
  801268:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80126c:	89 f2                	mov    %esi,%edx
  80126e:	eb 09                	jmp    801279 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801270:	83 c2 01             	add    $0x1,%edx
  801273:	83 c1 01             	add    $0x1,%ecx
  801276:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801279:	39 c2                	cmp    %eax,%edx
  80127b:	74 09                	je     801286 <strlcpy+0x32>
  80127d:	0f b6 19             	movzbl (%ecx),%ebx
  801280:	84 db                	test   %bl,%bl
  801282:	75 ec                	jne    801270 <strlcpy+0x1c>
  801284:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801286:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801289:	29 f0                	sub    %esi,%eax
}
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801295:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801298:	eb 06                	jmp    8012a0 <strcmp+0x11>
		p++, q++;
  80129a:	83 c1 01             	add    $0x1,%ecx
  80129d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012a0:	0f b6 01             	movzbl (%ecx),%eax
  8012a3:	84 c0                	test   %al,%al
  8012a5:	74 04                	je     8012ab <strcmp+0x1c>
  8012a7:	3a 02                	cmp    (%edx),%al
  8012a9:	74 ef                	je     80129a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012ab:	0f b6 c0             	movzbl %al,%eax
  8012ae:	0f b6 12             	movzbl (%edx),%edx
  8012b1:	29 d0                	sub    %edx,%eax
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bf:	89 c3                	mov    %eax,%ebx
  8012c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012c4:	eb 06                	jmp    8012cc <strncmp+0x17>
		n--, p++, q++;
  8012c6:	83 c0 01             	add    $0x1,%eax
  8012c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012cc:	39 d8                	cmp    %ebx,%eax
  8012ce:	74 15                	je     8012e5 <strncmp+0x30>
  8012d0:	0f b6 08             	movzbl (%eax),%ecx
  8012d3:	84 c9                	test   %cl,%cl
  8012d5:	74 04                	je     8012db <strncmp+0x26>
  8012d7:	3a 0a                	cmp    (%edx),%cl
  8012d9:	74 eb                	je     8012c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012db:	0f b6 00             	movzbl (%eax),%eax
  8012de:	0f b6 12             	movzbl (%edx),%edx
  8012e1:	29 d0                	sub    %edx,%eax
  8012e3:	eb 05                	jmp    8012ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012ea:	5b                   	pop    %ebx
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012f7:	eb 07                	jmp    801300 <strchr+0x13>
		if (*s == c)
  8012f9:	38 ca                	cmp    %cl,%dl
  8012fb:	74 0f                	je     80130c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012fd:	83 c0 01             	add    $0x1,%eax
  801300:	0f b6 10             	movzbl (%eax),%edx
  801303:	84 d2                	test   %dl,%dl
  801305:	75 f2                	jne    8012f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801318:	eb 03                	jmp    80131d <strfind+0xf>
  80131a:	83 c0 01             	add    $0x1,%eax
  80131d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801320:	38 ca                	cmp    %cl,%dl
  801322:	74 04                	je     801328 <strfind+0x1a>
  801324:	84 d2                	test   %dl,%dl
  801326:	75 f2                	jne    80131a <strfind+0xc>
			break;
	return (char *) s;
}
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	57                   	push   %edi
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	8b 7d 08             	mov    0x8(%ebp),%edi
  801333:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801336:	85 c9                	test   %ecx,%ecx
  801338:	74 36                	je     801370 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80133a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801340:	75 28                	jne    80136a <memset+0x40>
  801342:	f6 c1 03             	test   $0x3,%cl
  801345:	75 23                	jne    80136a <memset+0x40>
		c &= 0xFF;
  801347:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80134b:	89 d3                	mov    %edx,%ebx
  80134d:	c1 e3 08             	shl    $0x8,%ebx
  801350:	89 d6                	mov    %edx,%esi
  801352:	c1 e6 18             	shl    $0x18,%esi
  801355:	89 d0                	mov    %edx,%eax
  801357:	c1 e0 10             	shl    $0x10,%eax
  80135a:	09 f0                	or     %esi,%eax
  80135c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80135e:	89 d8                	mov    %ebx,%eax
  801360:	09 d0                	or     %edx,%eax
  801362:	c1 e9 02             	shr    $0x2,%ecx
  801365:	fc                   	cld    
  801366:	f3 ab                	rep stos %eax,%es:(%edi)
  801368:	eb 06                	jmp    801370 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80136a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136d:	fc                   	cld    
  80136e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801370:	89 f8                	mov    %edi,%eax
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
  80137f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801382:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801385:	39 c6                	cmp    %eax,%esi
  801387:	73 35                	jae    8013be <memmove+0x47>
  801389:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80138c:	39 d0                	cmp    %edx,%eax
  80138e:	73 2e                	jae    8013be <memmove+0x47>
		s += n;
		d += n;
  801390:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801393:	89 d6                	mov    %edx,%esi
  801395:	09 fe                	or     %edi,%esi
  801397:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80139d:	75 13                	jne    8013b2 <memmove+0x3b>
  80139f:	f6 c1 03             	test   $0x3,%cl
  8013a2:	75 0e                	jne    8013b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8013a4:	83 ef 04             	sub    $0x4,%edi
  8013a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013aa:	c1 e9 02             	shr    $0x2,%ecx
  8013ad:	fd                   	std    
  8013ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013b0:	eb 09                	jmp    8013bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013b2:	83 ef 01             	sub    $0x1,%edi
  8013b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8013b8:	fd                   	std    
  8013b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013bb:	fc                   	cld    
  8013bc:	eb 1d                	jmp    8013db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013be:	89 f2                	mov    %esi,%edx
  8013c0:	09 c2                	or     %eax,%edx
  8013c2:	f6 c2 03             	test   $0x3,%dl
  8013c5:	75 0f                	jne    8013d6 <memmove+0x5f>
  8013c7:	f6 c1 03             	test   $0x3,%cl
  8013ca:	75 0a                	jne    8013d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8013cc:	c1 e9 02             	shr    $0x2,%ecx
  8013cf:	89 c7                	mov    %eax,%edi
  8013d1:	fc                   	cld    
  8013d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013d4:	eb 05                	jmp    8013db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8013d6:	89 c7                	mov    %eax,%edi
  8013d8:	fc                   	cld    
  8013d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8013e2:	ff 75 10             	pushl  0x10(%ebp)
  8013e5:	ff 75 0c             	pushl  0xc(%ebp)
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	e8 87 ff ff ff       	call   801377 <memmove>
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fd:	89 c6                	mov    %eax,%esi
  8013ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801402:	eb 1a                	jmp    80141e <memcmp+0x2c>
		if (*s1 != *s2)
  801404:	0f b6 08             	movzbl (%eax),%ecx
  801407:	0f b6 1a             	movzbl (%edx),%ebx
  80140a:	38 d9                	cmp    %bl,%cl
  80140c:	74 0a                	je     801418 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80140e:	0f b6 c1             	movzbl %cl,%eax
  801411:	0f b6 db             	movzbl %bl,%ebx
  801414:	29 d8                	sub    %ebx,%eax
  801416:	eb 0f                	jmp    801427 <memcmp+0x35>
		s1++, s2++;
  801418:	83 c0 01             	add    $0x1,%eax
  80141b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80141e:	39 f0                	cmp    %esi,%eax
  801420:	75 e2                	jne    801404 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801432:	89 c1                	mov    %eax,%ecx
  801434:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801437:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80143b:	eb 0a                	jmp    801447 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80143d:	0f b6 10             	movzbl (%eax),%edx
  801440:	39 da                	cmp    %ebx,%edx
  801442:	74 07                	je     80144b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801444:	83 c0 01             	add    $0x1,%eax
  801447:	39 c8                	cmp    %ecx,%eax
  801449:	72 f2                	jb     80143d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80144b:	5b                   	pop    %ebx
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	53                   	push   %ebx
  801454:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801457:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80145a:	eb 03                	jmp    80145f <strtol+0x11>
		s++;
  80145c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80145f:	0f b6 01             	movzbl (%ecx),%eax
  801462:	3c 20                	cmp    $0x20,%al
  801464:	74 f6                	je     80145c <strtol+0xe>
  801466:	3c 09                	cmp    $0x9,%al
  801468:	74 f2                	je     80145c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80146a:	3c 2b                	cmp    $0x2b,%al
  80146c:	75 0a                	jne    801478 <strtol+0x2a>
		s++;
  80146e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801471:	bf 00 00 00 00       	mov    $0x0,%edi
  801476:	eb 11                	jmp    801489 <strtol+0x3b>
  801478:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80147d:	3c 2d                	cmp    $0x2d,%al
  80147f:	75 08                	jne    801489 <strtol+0x3b>
		s++, neg = 1;
  801481:	83 c1 01             	add    $0x1,%ecx
  801484:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801489:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80148f:	75 15                	jne    8014a6 <strtol+0x58>
  801491:	80 39 30             	cmpb   $0x30,(%ecx)
  801494:	75 10                	jne    8014a6 <strtol+0x58>
  801496:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80149a:	75 7c                	jne    801518 <strtol+0xca>
		s += 2, base = 16;
  80149c:	83 c1 02             	add    $0x2,%ecx
  80149f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014a4:	eb 16                	jmp    8014bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8014a6:	85 db                	test   %ebx,%ebx
  8014a8:	75 12                	jne    8014bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014af:	80 39 30             	cmpb   $0x30,(%ecx)
  8014b2:	75 08                	jne    8014bc <strtol+0x6e>
		s++, base = 8;
  8014b4:	83 c1 01             	add    $0x1,%ecx
  8014b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014c4:	0f b6 11             	movzbl (%ecx),%edx
  8014c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014ca:	89 f3                	mov    %esi,%ebx
  8014cc:	80 fb 09             	cmp    $0x9,%bl
  8014cf:	77 08                	ja     8014d9 <strtol+0x8b>
			dig = *s - '0';
  8014d1:	0f be d2             	movsbl %dl,%edx
  8014d4:	83 ea 30             	sub    $0x30,%edx
  8014d7:	eb 22                	jmp    8014fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8014d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8014dc:	89 f3                	mov    %esi,%ebx
  8014de:	80 fb 19             	cmp    $0x19,%bl
  8014e1:	77 08                	ja     8014eb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8014e3:	0f be d2             	movsbl %dl,%edx
  8014e6:	83 ea 57             	sub    $0x57,%edx
  8014e9:	eb 10                	jmp    8014fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8014eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8014ee:	89 f3                	mov    %esi,%ebx
  8014f0:	80 fb 19             	cmp    $0x19,%bl
  8014f3:	77 16                	ja     80150b <strtol+0xbd>
			dig = *s - 'A' + 10;
  8014f5:	0f be d2             	movsbl %dl,%edx
  8014f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8014fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014fe:	7d 0b                	jge    80150b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801500:	83 c1 01             	add    $0x1,%ecx
  801503:	0f af 45 10          	imul   0x10(%ebp),%eax
  801507:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801509:	eb b9                	jmp    8014c4 <strtol+0x76>

	if (endptr)
  80150b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80150f:	74 0d                	je     80151e <strtol+0xd0>
		*endptr = (char *) s;
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
  801514:	89 0e                	mov    %ecx,(%esi)
  801516:	eb 06                	jmp    80151e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801518:	85 db                	test   %ebx,%ebx
  80151a:	74 98                	je     8014b4 <strtol+0x66>
  80151c:	eb 9e                	jmp    8014bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80151e:	89 c2                	mov    %eax,%edx
  801520:	f7 da                	neg    %edx
  801522:	85 ff                	test   %edi,%edi
  801524:	0f 45 c2             	cmovne %edx,%eax
}
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	57                   	push   %edi
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
  801537:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153a:	8b 55 08             	mov    0x8(%ebp),%edx
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	89 c7                	mov    %eax,%edi
  801541:	89 c6                	mov    %eax,%esi
  801543:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sys_cgetc>:

int
sys_cgetc(void)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 01 00 00 00       	mov    $0x1,%eax
  80155a:	89 d1                	mov    %edx,%ecx
  80155c:	89 d3                	mov    %edx,%ebx
  80155e:	89 d7                	mov    %edx,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	57                   	push   %edi
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801572:	b9 00 00 00 00       	mov    $0x0,%ecx
  801577:	b8 03 00 00 00       	mov    $0x3,%eax
  80157c:	8b 55 08             	mov    0x8(%ebp),%edx
  80157f:	89 cb                	mov    %ecx,%ebx
  801581:	89 cf                	mov    %ecx,%edi
  801583:	89 ce                	mov    %ecx,%esi
  801585:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801587:	85 c0                	test   %eax,%eax
  801589:	7e 17                	jle    8015a2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	50                   	push   %eax
  80158f:	6a 03                	push   $0x3
  801591:	68 af 38 80 00       	push   $0x8038af
  801596:	6a 23                	push   $0x23
  801598:	68 cc 38 80 00       	push   $0x8038cc
  80159d:	e8 73 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	57                   	push   %edi
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ba:	89 d1                	mov    %edx,%ecx
  8015bc:	89 d3                	mov    %edx,%ebx
  8015be:	89 d7                	mov    %edx,%edi
  8015c0:	89 d6                	mov    %edx,%esi
  8015c2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <sys_yield>:

void
sys_yield(void)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015d9:	89 d1                	mov    %edx,%ecx
  8015db:	89 d3                	mov    %edx,%ebx
  8015dd:	89 d7                	mov    %edx,%edi
  8015df:	89 d6                	mov    %edx,%esi
  8015e1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5f                   	pop    %edi
  8015e6:	5d                   	pop    %ebp
  8015e7:	c3                   	ret    

008015e8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f1:	be 00 00 00 00       	mov    $0x0,%esi
  8015f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801601:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801604:	89 f7                	mov    %esi,%edi
  801606:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801608:	85 c0                	test   %eax,%eax
  80160a:	7e 17                	jle    801623 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	50                   	push   %eax
  801610:	6a 04                	push   $0x4
  801612:	68 af 38 80 00       	push   $0x8038af
  801617:	6a 23                	push   $0x23
  801619:	68 cc 38 80 00       	push   $0x8038cc
  80161e:	e8 f2 f3 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5f                   	pop    %edi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	57                   	push   %edi
  80162f:	56                   	push   %esi
  801630:	53                   	push   %ebx
  801631:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801634:	b8 05 00 00 00       	mov    $0x5,%eax
  801639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163c:	8b 55 08             	mov    0x8(%ebp),%edx
  80163f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801642:	8b 7d 14             	mov    0x14(%ebp),%edi
  801645:	8b 75 18             	mov    0x18(%ebp),%esi
  801648:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80164a:	85 c0                	test   %eax,%eax
  80164c:	7e 17                	jle    801665 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	50                   	push   %eax
  801652:	6a 05                	push   $0x5
  801654:	68 af 38 80 00       	push   $0x8038af
  801659:	6a 23                	push   $0x23
  80165b:	68 cc 38 80 00       	push   $0x8038cc
  801660:	e8 b0 f3 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	57                   	push   %edi
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801676:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167b:	b8 06 00 00 00       	mov    $0x6,%eax
  801680:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801683:	8b 55 08             	mov    0x8(%ebp),%edx
  801686:	89 df                	mov    %ebx,%edi
  801688:	89 de                	mov    %ebx,%esi
  80168a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80168c:	85 c0                	test   %eax,%eax
  80168e:	7e 17                	jle    8016a7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	50                   	push   %eax
  801694:	6a 06                	push   $0x6
  801696:	68 af 38 80 00       	push   $0x8038af
  80169b:	6a 23                	push   $0x23
  80169d:	68 cc 38 80 00       	push   $0x8038cc
  8016a2:	e8 6e f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	57                   	push   %edi
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c8:	89 df                	mov    %ebx,%edi
  8016ca:	89 de                	mov    %ebx,%esi
  8016cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	7e 17                	jle    8016e9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	50                   	push   %eax
  8016d6:	6a 08                	push   $0x8
  8016d8:	68 af 38 80 00       	push   $0x8038af
  8016dd:	6a 23                	push   $0x23
  8016df:	68 cc 38 80 00       	push   $0x8038cc
  8016e4:	e8 2c f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5f                   	pop    %edi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    

008016f1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	57                   	push   %edi
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ff:	b8 09 00 00 00       	mov    $0x9,%eax
  801704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801707:	8b 55 08             	mov    0x8(%ebp),%edx
  80170a:	89 df                	mov    %ebx,%edi
  80170c:	89 de                	mov    %ebx,%esi
  80170e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801710:	85 c0                	test   %eax,%eax
  801712:	7e 17                	jle    80172b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	50                   	push   %eax
  801718:	6a 09                	push   $0x9
  80171a:	68 af 38 80 00       	push   $0x8038af
  80171f:	6a 23                	push   $0x23
  801721:	68 cc 38 80 00       	push   $0x8038cc
  801726:	e8 ea f2 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80172b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	57                   	push   %edi
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80173c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801741:	b8 0a 00 00 00       	mov    $0xa,%eax
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	8b 55 08             	mov    0x8(%ebp),%edx
  80174c:	89 df                	mov    %ebx,%edi
  80174e:	89 de                	mov    %ebx,%esi
  801750:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801752:	85 c0                	test   %eax,%eax
  801754:	7e 17                	jle    80176d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	50                   	push   %eax
  80175a:	6a 0a                	push   $0xa
  80175c:	68 af 38 80 00       	push   $0x8038af
  801761:	6a 23                	push   $0x23
  801763:	68 cc 38 80 00       	push   $0x8038cc
  801768:	e8 a8 f2 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80176d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5f                   	pop    %edi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	57                   	push   %edi
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80177b:	be 00 00 00 00       	mov    $0x0,%esi
  801780:	b8 0c 00 00 00       	mov    $0xc,%eax
  801785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801788:	8b 55 08             	mov    0x8(%ebp),%edx
  80178b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80178e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801791:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5f                   	pop    %edi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	57                   	push   %edi
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ae:	89 cb                	mov    %ecx,%ebx
  8017b0:	89 cf                	mov    %ecx,%edi
  8017b2:	89 ce                	mov    %ecx,%esi
  8017b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	7e 17                	jle    8017d1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017ba:	83 ec 0c             	sub    $0xc,%esp
  8017bd:	50                   	push   %eax
  8017be:	6a 0d                	push   $0xd
  8017c0:	68 af 38 80 00       	push   $0x8038af
  8017c5:	6a 23                	push   $0x23
  8017c7:	68 cc 38 80 00       	push   $0x8038cc
  8017cc:	e8 44 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5f                   	pop    %edi
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	56                   	push   %esi
  8017dd:	53                   	push   %ebx
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  8017e1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  8017e3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017e7:	74 11                	je     8017fa <pgfault+0x21>
  8017e9:	89 d8                	mov    %ebx,%eax
  8017eb:	c1 e8 0c             	shr    $0xc,%eax
  8017ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017f5:	f6 c4 08             	test   $0x8,%ah
  8017f8:	75 14                	jne    80180e <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	68 dc 38 80 00       	push   $0x8038dc
  801802:	6a 1f                	push   $0x1f
  801804:	68 3f 39 80 00       	push   $0x80393f
  801809:	e8 07 f2 ff ff       	call   800a15 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  80180e:	e8 97 fd ff ff       	call   8015aa <sys_getenvid>
  801813:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  801815:	83 ec 04             	sub    $0x4,%esp
  801818:	6a 07                	push   $0x7
  80181a:	68 00 f0 7f 00       	push   $0x7ff000
  80181f:	50                   	push   %eax
  801820:	e8 c3 fd ff ff       	call   8015e8 <sys_page_alloc>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	79 12                	jns    80183e <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  80182c:	50                   	push   %eax
  80182d:	68 1c 39 80 00       	push   $0x80391c
  801832:	6a 2c                	push   $0x2c
  801834:	68 3f 39 80 00       	push   $0x80393f
  801839:	e8 d7 f1 ff ff       	call   800a15 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  80183e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	68 00 10 00 00       	push   $0x1000
  80184c:	53                   	push   %ebx
  80184d:	68 00 f0 7f 00       	push   $0x7ff000
  801852:	e8 20 fb ff ff       	call   801377 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  801857:	83 c4 08             	add    $0x8,%esp
  80185a:	53                   	push   %ebx
  80185b:	56                   	push   %esi
  80185c:	e8 0c fe ff ff       	call   80166d <sys_page_unmap>
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	79 12                	jns    80187a <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  801868:	50                   	push   %eax
  801869:	68 4a 39 80 00       	push   $0x80394a
  80186e:	6a 32                	push   $0x32
  801870:	68 3f 39 80 00       	push   $0x80393f
  801875:	e8 9b f1 ff ff       	call   800a15 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	6a 07                	push   $0x7
  80187f:	53                   	push   %ebx
  801880:	56                   	push   %esi
  801881:	68 00 f0 7f 00       	push   $0x7ff000
  801886:	56                   	push   %esi
  801887:	e8 9f fd ff ff       	call   80162b <sys_page_map>
  80188c:	83 c4 20             	add    $0x20,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 12                	jns    8018a5 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  801893:	50                   	push   %eax
  801894:	68 68 39 80 00       	push   $0x803968
  801899:	6a 35                	push   $0x35
  80189b:	68 3f 39 80 00       	push   $0x80393f
  8018a0:	e8 70 f1 ff ff       	call   800a15 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	68 00 f0 7f 00       	push   $0x7ff000
  8018ad:	56                   	push   %esi
  8018ae:	e8 ba fd ff ff       	call   80166d <sys_page_unmap>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	79 12                	jns    8018cc <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  8018ba:	50                   	push   %eax
  8018bb:	68 4a 39 80 00       	push   $0x80394a
  8018c0:	6a 38                	push   $0x38
  8018c2:	68 3f 39 80 00       	push   $0x80393f
  8018c7:	e8 49 f1 ff ff       	call   800a15 <_panic>
	//panic("pgfault not implemented");
}
  8018cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5e                   	pop    %esi
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	57                   	push   %edi
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  8018dc:	68 d9 17 80 00       	push   $0x8017d9
  8018e1:	e8 e9 15 00 00       	call   802ecf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8018e6:	b8 07 00 00 00       	mov    $0x7,%eax
  8018eb:	cd 30                	int    $0x30
  8018ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	0f 88 38 01 00 00    	js     801a33 <fork+0x160>
  8018fb:	89 c7                	mov    %eax,%edi
  8018fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  801902:	85 c0                	test   %eax,%eax
  801904:	75 21                	jne    801927 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  801906:	e8 9f fc ff ff       	call   8015aa <sys_getenvid>
  80190b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801910:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801913:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801918:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	e9 86 01 00 00       	jmp    801aad <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801927:	89 d8                	mov    %ebx,%eax
  801929:	c1 e8 16             	shr    $0x16,%eax
  80192c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801933:	a8 01                	test   $0x1,%al
  801935:	0f 84 90 00 00 00    	je     8019cb <fork+0xf8>
  80193b:	89 d8                	mov    %ebx,%eax
  80193d:	c1 e8 0c             	shr    $0xc,%eax
  801940:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801947:	f6 c2 01             	test   $0x1,%dl
  80194a:	74 7f                	je     8019cb <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  80194c:	89 c6                	mov    %eax,%esi
  80194e:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  801951:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801958:	f6 c6 04             	test   $0x4,%dh
  80195b:	74 33                	je     801990 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  80195d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	25 07 0e 00 00       	and    $0xe07,%eax
  80196c:	50                   	push   %eax
  80196d:	56                   	push   %esi
  80196e:	57                   	push   %edi
  80196f:	56                   	push   %esi
  801970:	6a 00                	push   $0x0
  801972:	e8 b4 fc ff ff       	call   80162b <sys_page_map>
  801977:	83 c4 20             	add    $0x20,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	79 4d                	jns    8019cb <fork+0xf8>
		    panic("sys_page_map: %e", r);
  80197e:	50                   	push   %eax
  80197f:	68 84 39 80 00       	push   $0x803984
  801984:	6a 54                	push   $0x54
  801986:	68 3f 39 80 00       	push   $0x80393f
  80198b:	e8 85 f0 ff ff       	call   800a15 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  801990:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801997:	a9 02 08 00 00       	test   $0x802,%eax
  80199c:	0f 85 c6 00 00 00    	jne    801a68 <fork+0x195>
  8019a2:	e9 e3 00 00 00       	jmp    801a8a <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8019a7:	50                   	push   %eax
  8019a8:	68 84 39 80 00       	push   $0x803984
  8019ad:	6a 5d                	push   $0x5d
  8019af:	68 3f 39 80 00       	push   $0x80393f
  8019b4:	e8 5c f0 ff ff       	call   800a15 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8019b9:	50                   	push   %eax
  8019ba:	68 84 39 80 00       	push   $0x803984
  8019bf:	6a 64                	push   $0x64
  8019c1:	68 3f 39 80 00       	push   $0x80393f
  8019c6:	e8 4a f0 ff ff       	call   800a15 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  8019cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019d1:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8019d7:	0f 85 4a ff ff ff    	jne    801927 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  8019dd:	83 ec 04             	sub    $0x4,%esp
  8019e0:	6a 07                	push   $0x7
  8019e2:	68 00 f0 bf ee       	push   $0xeebff000
  8019e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8019ea:	57                   	push   %edi
  8019eb:	e8 f8 fb ff ff       	call   8015e8 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8019f0:	83 c4 10             	add    $0x10,%esp
		return ret;
  8019f3:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 88 b0 00 00 00    	js     801aad <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8019fd:	a1 24 54 80 00       	mov    0x805424,%eax
  801a02:	8b 40 64             	mov    0x64(%eax),%eax
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	50                   	push   %eax
  801a09:	57                   	push   %edi
  801a0a:	e8 24 fd ff ff       	call   801733 <sys_env_set_pgfault_upcall>
  801a0f:	83 c4 10             	add    $0x10,%esp
		return ret;
  801a12:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 91 00 00 00    	js     801aad <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	6a 02                	push   $0x2
  801a21:	57                   	push   %edi
  801a22:	e8 88 fc ff ff       	call   8016af <sys_env_set_status>
  801a27:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	89 fa                	mov    %edi,%edx
  801a2e:	0f 48 d0             	cmovs  %eax,%edx
  801a31:	eb 7a                	jmp    801aad <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801a33:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801a36:	eb 75                	jmp    801aad <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801a38:	e8 6d fb ff ff       	call   8015aa <sys_getenvid>
  801a3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a40:	e8 65 fb ff ff       	call   8015aa <sys_getenvid>
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	68 05 08 00 00       	push   $0x805
  801a4d:	56                   	push   %esi
  801a4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a51:	56                   	push   %esi
  801a52:	50                   	push   %eax
  801a53:	e8 d3 fb ff ff       	call   80162b <sys_page_map>
  801a58:	83 c4 20             	add    $0x20,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	0f 89 68 ff ff ff    	jns    8019cb <fork+0xf8>
  801a63:	e9 51 ff ff ff       	jmp    8019b9 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801a68:	e8 3d fb ff ff       	call   8015aa <sys_getenvid>
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	68 05 08 00 00       	push   $0x805
  801a75:	56                   	push   %esi
  801a76:	57                   	push   %edi
  801a77:	56                   	push   %esi
  801a78:	50                   	push   %eax
  801a79:	e8 ad fb ff ff       	call   80162b <sys_page_map>
  801a7e:	83 c4 20             	add    $0x20,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	79 b3                	jns    801a38 <fork+0x165>
  801a85:	e9 1d ff ff ff       	jmp    8019a7 <fork+0xd4>
  801a8a:	e8 1b fb ff ff       	call   8015aa <sys_getenvid>
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	6a 05                	push   $0x5
  801a94:	56                   	push   %esi
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	50                   	push   %eax
  801a98:	e8 8e fb ff ff       	call   80162b <sys_page_map>
  801a9d:	83 c4 20             	add    $0x20,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 89 23 ff ff ff    	jns    8019cb <fork+0xf8>
  801aa8:	e9 fa fe ff ff       	jmp    8019a7 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  801aad:	89 d0                	mov    %edx,%eax
  801aaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5f                   	pop    %edi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <sfork>:

// Challenge!
int
sfork(void)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801abd:	68 95 39 80 00       	push   $0x803995
  801ac2:	68 ac 00 00 00       	push   $0xac
  801ac7:	68 3f 39 80 00       	push   $0x80393f
  801acc:	e8 44 ef ff ff       	call   800a15 <_panic>

00801ad1 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ada:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801add:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801adf:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ae2:	83 3a 01             	cmpl   $0x1,(%edx)
  801ae5:	7e 09                	jle    801af0 <argstart+0x1f>
  801ae7:	ba 81 33 80 00       	mov    $0x803381,%edx
  801aec:	85 c9                	test   %ecx,%ecx
  801aee:	75 05                	jne    801af5 <argstart+0x24>
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801af8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <argnext>:

int
argnext(struct Argstate *args)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	53                   	push   %ebx
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b0b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b12:	8b 43 08             	mov    0x8(%ebx),%eax
  801b15:	85 c0                	test   %eax,%eax
  801b17:	74 6f                	je     801b88 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b19:	80 38 00             	cmpb   $0x0,(%eax)
  801b1c:	75 4e                	jne    801b6c <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b1e:	8b 0b                	mov    (%ebx),%ecx
  801b20:	83 39 01             	cmpl   $0x1,(%ecx)
  801b23:	74 55                	je     801b7a <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b25:	8b 53 04             	mov    0x4(%ebx),%edx
  801b28:	8b 42 04             	mov    0x4(%edx),%eax
  801b2b:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b2e:	75 4a                	jne    801b7a <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b30:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b34:	74 44                	je     801b7a <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b36:	83 c0 01             	add    $0x1,%eax
  801b39:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	8b 01                	mov    (%ecx),%eax
  801b41:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b48:	50                   	push   %eax
  801b49:	8d 42 08             	lea    0x8(%edx),%eax
  801b4c:	50                   	push   %eax
  801b4d:	83 c2 04             	add    $0x4,%edx
  801b50:	52                   	push   %edx
  801b51:	e8 21 f8 ff ff       	call   801377 <memmove>
		(*args->argc)--;
  801b56:	8b 03                	mov    (%ebx),%eax
  801b58:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b5b:	8b 43 08             	mov    0x8(%ebx),%eax
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b64:	75 06                	jne    801b6c <argnext+0x6b>
  801b66:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b6a:	74 0e                	je     801b7a <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b6c:	8b 53 08             	mov    0x8(%ebx),%edx
  801b6f:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b72:	83 c2 01             	add    $0x1,%edx
  801b75:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b78:	eb 13                	jmp    801b8d <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b7a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b86:	eb 05                	jmp    801b8d <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	53                   	push   %ebx
  801b96:	83 ec 04             	sub    $0x4,%esp
  801b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b9c:	8b 43 08             	mov    0x8(%ebx),%eax
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	74 58                	je     801bfb <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801ba3:	80 38 00             	cmpb   $0x0,(%eax)
  801ba6:	74 0c                	je     801bb4 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801ba8:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bab:	c7 43 08 81 33 80 00 	movl   $0x803381,0x8(%ebx)
  801bb2:	eb 42                	jmp    801bf6 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801bb4:	8b 13                	mov    (%ebx),%edx
  801bb6:	83 3a 01             	cmpl   $0x1,(%edx)
  801bb9:	7e 2d                	jle    801be8 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bbb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bbe:	8b 48 04             	mov    0x4(%eax),%ecx
  801bc1:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	8b 12                	mov    (%edx),%edx
  801bc9:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bd0:	52                   	push   %edx
  801bd1:	8d 50 08             	lea    0x8(%eax),%edx
  801bd4:	52                   	push   %edx
  801bd5:	83 c0 04             	add    $0x4,%eax
  801bd8:	50                   	push   %eax
  801bd9:	e8 99 f7 ff ff       	call   801377 <memmove>
		(*args->argc)--;
  801bde:	8b 03                	mov    (%ebx),%eax
  801be0:	83 28 01             	subl   $0x1,(%eax)
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	eb 0e                	jmp    801bf6 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801be8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bef:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bf6:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bf9:	eb 05                	jmp    801c00 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c0e:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c11:	89 d0                	mov    %edx,%eax
  801c13:	85 d2                	test   %edx,%edx
  801c15:	75 0c                	jne    801c23 <argvalue+0x1e>
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	51                   	push   %ecx
  801c1b:	e8 72 ff ff ff       	call   801b92 <argnextvalue>
  801c20:	83 c4 10             	add    $0x10,%esp
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	05 00 00 00 30       	add    $0x30000000,%eax
  801c30:	c1 e8 0c             	shr    $0xc,%eax
}
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	05 00 00 00 30       	add    $0x30000000,%eax
  801c40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c45:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c52:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	c1 ea 16             	shr    $0x16,%edx
  801c5c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c63:	f6 c2 01             	test   $0x1,%dl
  801c66:	74 11                	je     801c79 <fd_alloc+0x2d>
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	c1 ea 0c             	shr    $0xc,%edx
  801c6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c74:	f6 c2 01             	test   $0x1,%dl
  801c77:	75 09                	jne    801c82 <fd_alloc+0x36>
			*fd_store = fd;
  801c79:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c80:	eb 17                	jmp    801c99 <fd_alloc+0x4d>
  801c82:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c87:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c8c:	75 c9                	jne    801c57 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c8e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c94:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ca1:	83 f8 1f             	cmp    $0x1f,%eax
  801ca4:	77 36                	ja     801cdc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ca6:	c1 e0 0c             	shl    $0xc,%eax
  801ca9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	c1 ea 16             	shr    $0x16,%edx
  801cb3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cba:	f6 c2 01             	test   $0x1,%dl
  801cbd:	74 24                	je     801ce3 <fd_lookup+0x48>
  801cbf:	89 c2                	mov    %eax,%edx
  801cc1:	c1 ea 0c             	shr    $0xc,%edx
  801cc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ccb:	f6 c2 01             	test   $0x1,%dl
  801cce:	74 1a                	je     801cea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd3:	89 02                	mov    %eax,(%edx)
	return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cda:	eb 13                	jmp    801cef <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce1:	eb 0c                	jmp    801cef <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ce3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ce8:	eb 05                	jmp    801cef <fd_lookup+0x54>
  801cea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 08             	sub    $0x8,%esp
  801cf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfa:	ba 28 3a 80 00       	mov    $0x803a28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cff:	eb 13                	jmp    801d14 <dev_lookup+0x23>
  801d01:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801d04:	39 08                	cmp    %ecx,(%eax)
  801d06:	75 0c                	jne    801d14 <dev_lookup+0x23>
			*dev = devtab[i];
  801d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0b:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d12:	eb 2e                	jmp    801d42 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d14:	8b 02                	mov    (%edx),%eax
  801d16:	85 c0                	test   %eax,%eax
  801d18:	75 e7                	jne    801d01 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d1a:	a1 24 54 80 00       	mov    0x805424,%eax
  801d1f:	8b 40 48             	mov    0x48(%eax),%eax
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	51                   	push   %ecx
  801d26:	50                   	push   %eax
  801d27:	68 ac 39 80 00       	push   $0x8039ac
  801d2c:	e8 bd ed ff ff       	call   800aee <cprintf>
	*dev = 0;
  801d31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	56                   	push   %esi
  801d48:	53                   	push   %ebx
  801d49:	83 ec 10             	sub    $0x10,%esp
  801d4c:	8b 75 08             	mov    0x8(%ebp),%esi
  801d4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d5c:	c1 e8 0c             	shr    $0xc,%eax
  801d5f:	50                   	push   %eax
  801d60:	e8 36 ff ff ff       	call   801c9b <fd_lookup>
  801d65:	83 c4 08             	add    $0x8,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 05                	js     801d71 <fd_close+0x2d>
	    || fd != fd2)
  801d6c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d6f:	74 0c                	je     801d7d <fd_close+0x39>
		return (must_exist ? r : 0);
  801d71:	84 db                	test   %bl,%bl
  801d73:	ba 00 00 00 00       	mov    $0x0,%edx
  801d78:	0f 44 c2             	cmove  %edx,%eax
  801d7b:	eb 41                	jmp    801dbe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	ff 36                	pushl  (%esi)
  801d86:	e8 66 ff ff ff       	call   801cf1 <dev_lookup>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 1a                	js     801dae <fd_close+0x6a>
		if (dev->dev_close)
  801d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d97:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	74 0b                	je     801dae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801da3:	83 ec 0c             	sub    $0xc,%esp
  801da6:	56                   	push   %esi
  801da7:	ff d0                	call   *%eax
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dae:	83 ec 08             	sub    $0x8,%esp
  801db1:	56                   	push   %esi
  801db2:	6a 00                	push   $0x0
  801db4:	e8 b4 f8 ff ff       	call   80166d <sys_page_unmap>
	return r;
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	89 d8                	mov    %ebx,%eax
}
  801dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	ff 75 08             	pushl  0x8(%ebp)
  801dd2:	e8 c4 fe ff ff       	call   801c9b <fd_lookup>
  801dd7:	83 c4 08             	add    $0x8,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 10                	js     801dee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	6a 01                	push   $0x1
  801de3:	ff 75 f4             	pushl  -0xc(%ebp)
  801de6:	e8 59 ff ff ff       	call   801d44 <fd_close>
  801deb:	83 c4 10             	add    $0x10,%esp
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <close_all>:

void
close_all(void)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	53                   	push   %ebx
  801df4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801df7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	53                   	push   %ebx
  801e00:	e8 c0 ff ff ff       	call   801dc5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e05:	83 c3 01             	add    $0x1,%ebx
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	83 fb 20             	cmp    $0x20,%ebx
  801e0e:	75 ec                	jne    801dfc <close_all+0xc>
		close(i);
}
  801e10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	57                   	push   %edi
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	83 ec 2c             	sub    $0x2c,%esp
  801e1e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e24:	50                   	push   %eax
  801e25:	ff 75 08             	pushl  0x8(%ebp)
  801e28:	e8 6e fe ff ff       	call   801c9b <fd_lookup>
  801e2d:	83 c4 08             	add    $0x8,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	0f 88 c1 00 00 00    	js     801ef9 <dup+0xe4>
		return r;
	close(newfdnum);
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	56                   	push   %esi
  801e3c:	e8 84 ff ff ff       	call   801dc5 <close>

	newfd = INDEX2FD(newfdnum);
  801e41:	89 f3                	mov    %esi,%ebx
  801e43:	c1 e3 0c             	shl    $0xc,%ebx
  801e46:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e4c:	83 c4 04             	add    $0x4,%esp
  801e4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e52:	e8 de fd ff ff       	call   801c35 <fd2data>
  801e57:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e59:	89 1c 24             	mov    %ebx,(%esp)
  801e5c:	e8 d4 fd ff ff       	call   801c35 <fd2data>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e67:	89 f8                	mov    %edi,%eax
  801e69:	c1 e8 16             	shr    $0x16,%eax
  801e6c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e73:	a8 01                	test   $0x1,%al
  801e75:	74 37                	je     801eae <dup+0x99>
  801e77:	89 f8                	mov    %edi,%eax
  801e79:	c1 e8 0c             	shr    $0xc,%eax
  801e7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e83:	f6 c2 01             	test   $0x1,%dl
  801e86:	74 26                	je     801eae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	25 07 0e 00 00       	and    $0xe07,%eax
  801e97:	50                   	push   %eax
  801e98:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e9b:	6a 00                	push   $0x0
  801e9d:	57                   	push   %edi
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 86 f7 ff ff       	call   80162b <sys_page_map>
  801ea5:	89 c7                	mov    %eax,%edi
  801ea7:	83 c4 20             	add    $0x20,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 2e                	js     801edc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801eae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801eb1:	89 d0                	mov    %edx,%eax
  801eb3:	c1 e8 0c             	shr    $0xc,%eax
  801eb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	25 07 0e 00 00       	and    $0xe07,%eax
  801ec5:	50                   	push   %eax
  801ec6:	53                   	push   %ebx
  801ec7:	6a 00                	push   $0x0
  801ec9:	52                   	push   %edx
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 5a f7 ff ff       	call   80162b <sys_page_map>
  801ed1:	89 c7                	mov    %eax,%edi
  801ed3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801ed6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ed8:	85 ff                	test   %edi,%edi
  801eda:	79 1d                	jns    801ef9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	53                   	push   %ebx
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 86 f7 ff ff       	call   80166d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ee7:	83 c4 08             	add    $0x8,%esp
  801eea:	ff 75 d4             	pushl  -0x2c(%ebp)
  801eed:	6a 00                	push   $0x0
  801eef:	e8 79 f7 ff ff       	call   80166d <sys_page_unmap>
	return r;
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	89 f8                	mov    %edi,%eax
}
  801ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5f                   	pop    %edi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    

00801f01 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	53                   	push   %ebx
  801f05:	83 ec 14             	sub    $0x14,%esp
  801f08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	53                   	push   %ebx
  801f10:	e8 86 fd ff ff       	call   801c9b <fd_lookup>
  801f15:	83 c4 08             	add    $0x8,%esp
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 6d                	js     801f8b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f1e:	83 ec 08             	sub    $0x8,%esp
  801f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f28:	ff 30                	pushl  (%eax)
  801f2a:	e8 c2 fd ff ff       	call   801cf1 <dev_lookup>
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 4c                	js     801f82 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f39:	8b 42 08             	mov    0x8(%edx),%eax
  801f3c:	83 e0 03             	and    $0x3,%eax
  801f3f:	83 f8 01             	cmp    $0x1,%eax
  801f42:	75 21                	jne    801f65 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f44:	a1 24 54 80 00       	mov    0x805424,%eax
  801f49:	8b 40 48             	mov    0x48(%eax),%eax
  801f4c:	83 ec 04             	sub    $0x4,%esp
  801f4f:	53                   	push   %ebx
  801f50:	50                   	push   %eax
  801f51:	68 ed 39 80 00       	push   $0x8039ed
  801f56:	e8 93 eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f63:	eb 26                	jmp    801f8b <read+0x8a>
	}
	if (!dev->dev_read)
  801f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f68:	8b 40 08             	mov    0x8(%eax),%eax
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	74 17                	je     801f86 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f6f:	83 ec 04             	sub    $0x4,%esp
  801f72:	ff 75 10             	pushl  0x10(%ebp)
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	52                   	push   %edx
  801f79:	ff d0                	call   *%eax
  801f7b:	89 c2                	mov    %eax,%edx
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	eb 09                	jmp    801f8b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	eb 05                	jmp    801f8b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f86:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	57                   	push   %edi
  801f96:	56                   	push   %esi
  801f97:	53                   	push   %ebx
  801f98:	83 ec 0c             	sub    $0xc,%esp
  801f9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fa1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa6:	eb 21                	jmp    801fc9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fa8:	83 ec 04             	sub    $0x4,%esp
  801fab:	89 f0                	mov    %esi,%eax
  801fad:	29 d8                	sub    %ebx,%eax
  801faf:	50                   	push   %eax
  801fb0:	89 d8                	mov    %ebx,%eax
  801fb2:	03 45 0c             	add    0xc(%ebp),%eax
  801fb5:	50                   	push   %eax
  801fb6:	57                   	push   %edi
  801fb7:	e8 45 ff ff ff       	call   801f01 <read>
		if (m < 0)
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	78 10                	js     801fd3 <readn+0x41>
			return m;
		if (m == 0)
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	74 0a                	je     801fd1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fc7:	01 c3                	add    %eax,%ebx
  801fc9:	39 f3                	cmp    %esi,%ebx
  801fcb:	72 db                	jb     801fa8 <readn+0x16>
  801fcd:	89 d8                	mov    %ebx,%eax
  801fcf:	eb 02                	jmp    801fd3 <readn+0x41>
  801fd1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd6:	5b                   	pop    %ebx
  801fd7:	5e                   	pop    %esi
  801fd8:	5f                   	pop    %edi
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 14             	sub    $0x14,%esp
  801fe2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fe5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe8:	50                   	push   %eax
  801fe9:	53                   	push   %ebx
  801fea:	e8 ac fc ff ff       	call   801c9b <fd_lookup>
  801fef:	83 c4 08             	add    $0x8,%esp
  801ff2:	89 c2                	mov    %eax,%edx
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 68                	js     802060 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ff8:	83 ec 08             	sub    $0x8,%esp
  801ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802002:	ff 30                	pushl  (%eax)
  802004:	e8 e8 fc ff ff       	call   801cf1 <dev_lookup>
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 47                	js     802057 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802010:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802013:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802017:	75 21                	jne    80203a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802019:	a1 24 54 80 00       	mov    0x805424,%eax
  80201e:	8b 40 48             	mov    0x48(%eax),%eax
  802021:	83 ec 04             	sub    $0x4,%esp
  802024:	53                   	push   %ebx
  802025:	50                   	push   %eax
  802026:	68 09 3a 80 00       	push   $0x803a09
  80202b:	e8 be ea ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802038:	eb 26                	jmp    802060 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80203a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80203d:	8b 52 0c             	mov    0xc(%edx),%edx
  802040:	85 d2                	test   %edx,%edx
  802042:	74 17                	je     80205b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802044:	83 ec 04             	sub    $0x4,%esp
  802047:	ff 75 10             	pushl  0x10(%ebp)
  80204a:	ff 75 0c             	pushl  0xc(%ebp)
  80204d:	50                   	push   %eax
  80204e:	ff d2                	call   *%edx
  802050:	89 c2                	mov    %eax,%edx
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	eb 09                	jmp    802060 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802057:	89 c2                	mov    %eax,%edx
  802059:	eb 05                	jmp    802060 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80205b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802060:	89 d0                	mov    %edx,%eax
  802062:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802065:	c9                   	leave  
  802066:	c3                   	ret    

00802067 <seek>:

int
seek(int fdnum, off_t offset)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80206d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802070:	50                   	push   %eax
  802071:	ff 75 08             	pushl  0x8(%ebp)
  802074:	e8 22 fc ff ff       	call   801c9b <fd_lookup>
  802079:	83 c4 08             	add    $0x8,%esp
  80207c:	85 c0                	test   %eax,%eax
  80207e:	78 0e                	js     80208e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802080:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802083:	8b 55 0c             	mov    0xc(%ebp),%edx
  802086:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802089:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80208e:	c9                   	leave  
  80208f:	c3                   	ret    

00802090 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	53                   	push   %ebx
  802094:	83 ec 14             	sub    $0x14,%esp
  802097:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80209a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80209d:	50                   	push   %eax
  80209e:	53                   	push   %ebx
  80209f:	e8 f7 fb ff ff       	call   801c9b <fd_lookup>
  8020a4:	83 c4 08             	add    $0x8,%esp
  8020a7:	89 c2                	mov    %eax,%edx
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 65                	js     802112 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020ad:	83 ec 08             	sub    $0x8,%esp
  8020b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b3:	50                   	push   %eax
  8020b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b7:	ff 30                	pushl  (%eax)
  8020b9:	e8 33 fc ff ff       	call   801cf1 <dev_lookup>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	78 44                	js     802109 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020cc:	75 21                	jne    8020ef <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020ce:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020d3:	8b 40 48             	mov    0x48(%eax),%eax
  8020d6:	83 ec 04             	sub    $0x4,%esp
  8020d9:	53                   	push   %ebx
  8020da:	50                   	push   %eax
  8020db:	68 cc 39 80 00       	push   $0x8039cc
  8020e0:	e8 09 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020e5:	83 c4 10             	add    $0x10,%esp
  8020e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020ed:	eb 23                	jmp    802112 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f2:	8b 52 18             	mov    0x18(%edx),%edx
  8020f5:	85 d2                	test   %edx,%edx
  8020f7:	74 14                	je     80210d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020f9:	83 ec 08             	sub    $0x8,%esp
  8020fc:	ff 75 0c             	pushl  0xc(%ebp)
  8020ff:	50                   	push   %eax
  802100:	ff d2                	call   *%edx
  802102:	89 c2                	mov    %eax,%edx
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	eb 09                	jmp    802112 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802109:	89 c2                	mov    %eax,%edx
  80210b:	eb 05                	jmp    802112 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80210d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802112:	89 d0                	mov    %edx,%eax
  802114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802117:	c9                   	leave  
  802118:	c3                   	ret    

00802119 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	53                   	push   %ebx
  80211d:	83 ec 14             	sub    $0x14,%esp
  802120:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802123:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802126:	50                   	push   %eax
  802127:	ff 75 08             	pushl  0x8(%ebp)
  80212a:	e8 6c fb ff ff       	call   801c9b <fd_lookup>
  80212f:	83 c4 08             	add    $0x8,%esp
  802132:	89 c2                	mov    %eax,%edx
  802134:	85 c0                	test   %eax,%eax
  802136:	78 58                	js     802190 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802138:	83 ec 08             	sub    $0x8,%esp
  80213b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213e:	50                   	push   %eax
  80213f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802142:	ff 30                	pushl  (%eax)
  802144:	e8 a8 fb ff ff       	call   801cf1 <dev_lookup>
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 37                	js     802187 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802150:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802153:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802157:	74 32                	je     80218b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802159:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80215c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802163:	00 00 00 
	stat->st_isdir = 0;
  802166:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80216d:	00 00 00 
	stat->st_dev = dev;
  802170:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802176:	83 ec 08             	sub    $0x8,%esp
  802179:	53                   	push   %ebx
  80217a:	ff 75 f0             	pushl  -0x10(%ebp)
  80217d:	ff 50 14             	call   *0x14(%eax)
  802180:	89 c2                	mov    %eax,%edx
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	eb 09                	jmp    802190 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802187:	89 c2                	mov    %eax,%edx
  802189:	eb 05                	jmp    802190 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80218b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802190:	89 d0                	mov    %edx,%eax
  802192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802195:	c9                   	leave  
  802196:	c3                   	ret    

00802197 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	56                   	push   %esi
  80219b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80219c:	83 ec 08             	sub    $0x8,%esp
  80219f:	6a 00                	push   $0x0
  8021a1:	ff 75 08             	pushl  0x8(%ebp)
  8021a4:	e8 e9 01 00 00       	call   802392 <open>
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	83 c4 10             	add    $0x10,%esp
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	78 1b                	js     8021cd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021b2:	83 ec 08             	sub    $0x8,%esp
  8021b5:	ff 75 0c             	pushl  0xc(%ebp)
  8021b8:	50                   	push   %eax
  8021b9:	e8 5b ff ff ff       	call   802119 <fstat>
  8021be:	89 c6                	mov    %eax,%esi
	close(fd);
  8021c0:	89 1c 24             	mov    %ebx,(%esp)
  8021c3:	e8 fd fb ff ff       	call   801dc5 <close>
	return r;
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	89 f0                	mov    %esi,%eax
}
  8021cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    

008021d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	56                   	push   %esi
  8021d8:	53                   	push   %ebx
  8021d9:	89 c6                	mov    %eax,%esi
  8021db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021dd:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021e4:	75 12                	jne    8021f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021e6:	83 ec 0c             	sub    $0xc,%esp
  8021e9:	6a 01                	push   $0x1
  8021eb:	e8 4f 0e 00 00       	call   80303f <ipc_find_env>
  8021f0:	a3 20 54 80 00       	mov    %eax,0x805420
  8021f5:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021f8:	6a 07                	push   $0x7
  8021fa:	68 00 60 80 00       	push   $0x806000
  8021ff:	56                   	push   %esi
  802200:	ff 35 20 54 80 00    	pushl  0x805420
  802206:	e8 e0 0d 00 00       	call   802feb <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80220b:	83 c4 0c             	add    $0xc,%esp
  80220e:	6a 00                	push   $0x0
  802210:	53                   	push   %ebx
  802211:	6a 00                	push   $0x0
  802213:	e8 51 0d 00 00       	call   802f69 <ipc_recv>
}
  802218:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    

0080221f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802225:	8b 45 08             	mov    0x8(%ebp),%eax
  802228:	8b 40 0c             	mov    0xc(%eax),%eax
  80222b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802230:	8b 45 0c             	mov    0xc(%ebp),%eax
  802233:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802238:	ba 00 00 00 00       	mov    $0x0,%edx
  80223d:	b8 02 00 00 00       	mov    $0x2,%eax
  802242:	e8 8d ff ff ff       	call   8021d4 <fsipc>
}
  802247:	c9                   	leave  
  802248:	c3                   	ret    

00802249 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80224f:	8b 45 08             	mov    0x8(%ebp),%eax
  802252:	8b 40 0c             	mov    0xc(%eax),%eax
  802255:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80225a:	ba 00 00 00 00       	mov    $0x0,%edx
  80225f:	b8 06 00 00 00       	mov    $0x6,%eax
  802264:	e8 6b ff ff ff       	call   8021d4 <fsipc>
}
  802269:	c9                   	leave  
  80226a:	c3                   	ret    

0080226b <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	53                   	push   %ebx
  80226f:	83 ec 04             	sub    $0x4,%esp
  802272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802275:	8b 45 08             	mov    0x8(%ebp),%eax
  802278:	8b 40 0c             	mov    0xc(%eax),%eax
  80227b:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802280:	ba 00 00 00 00       	mov    $0x0,%edx
  802285:	b8 05 00 00 00       	mov    $0x5,%eax
  80228a:	e8 45 ff ff ff       	call   8021d4 <fsipc>
  80228f:	85 c0                	test   %eax,%eax
  802291:	78 2c                	js     8022bf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802293:	83 ec 08             	sub    $0x8,%esp
  802296:	68 00 60 80 00       	push   $0x806000
  80229b:	53                   	push   %ebx
  80229c:	e8 44 ef ff ff       	call   8011e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022a1:	a1 80 60 80 00       	mov    0x806080,%eax
  8022a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022ac:	a1 84 60 80 00       	mov    0x806084,%eax
  8022b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    

008022c4 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	83 ec 0c             	sub    $0xc,%esp
  8022ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8022cd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8022d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8022d7:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022da:	8b 55 08             	mov    0x8(%ebp),%edx
  8022dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8022e0:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = n;
  8022e6:	a3 04 60 80 00       	mov    %eax,0x806004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8022eb:	50                   	push   %eax
  8022ec:	ff 75 0c             	pushl  0xc(%ebp)
  8022ef:	68 08 60 80 00       	push   $0x806008
  8022f4:	e8 7e f0 ff ff       	call   801377 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8022f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022fe:	b8 04 00 00 00       	mov    $0x4,%eax
  802303:	e8 cc fe ff ff       	call   8021d4 <fsipc>
            return r;

    return r;
}
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	56                   	push   %esi
  80230e:	53                   	push   %ebx
  80230f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802312:	8b 45 08             	mov    0x8(%ebp),%eax
  802315:	8b 40 0c             	mov    0xc(%eax),%eax
  802318:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80231d:	89 35 04 60 80 00    	mov    %esi,0x806004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802323:	ba 00 00 00 00       	mov    $0x0,%edx
  802328:	b8 03 00 00 00       	mov    $0x3,%eax
  80232d:	e8 a2 fe ff ff       	call   8021d4 <fsipc>
  802332:	89 c3                	mov    %eax,%ebx
  802334:	85 c0                	test   %eax,%eax
  802336:	78 51                	js     802389 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  802338:	39 c6                	cmp    %eax,%esi
  80233a:	73 19                	jae    802355 <devfile_read+0x4b>
  80233c:	68 38 3a 80 00       	push   $0x803a38
  802341:	68 af 34 80 00       	push   $0x8034af
  802346:	68 82 00 00 00       	push   $0x82
  80234b:	68 3f 3a 80 00       	push   $0x803a3f
  802350:	e8 c0 e6 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  802355:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80235a:	7e 19                	jle    802375 <devfile_read+0x6b>
  80235c:	68 4a 3a 80 00       	push   $0x803a4a
  802361:	68 af 34 80 00       	push   $0x8034af
  802366:	68 83 00 00 00       	push   $0x83
  80236b:	68 3f 3a 80 00       	push   $0x803a3f
  802370:	e8 a0 e6 ff ff       	call   800a15 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802375:	83 ec 04             	sub    $0x4,%esp
  802378:	50                   	push   %eax
  802379:	68 00 60 80 00       	push   $0x806000
  80237e:	ff 75 0c             	pushl  0xc(%ebp)
  802381:	e8 f1 ef ff ff       	call   801377 <memmove>
	return r;
  802386:	83 c4 10             	add    $0x10,%esp
}
  802389:	89 d8                	mov    %ebx,%eax
  80238b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238e:	5b                   	pop    %ebx
  80238f:	5e                   	pop    %esi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	53                   	push   %ebx
  802396:	83 ec 20             	sub    $0x20,%esp
  802399:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80239c:	53                   	push   %ebx
  80239d:	e8 0a ee ff ff       	call   8011ac <strlen>
  8023a2:	83 c4 10             	add    $0x10,%esp
  8023a5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023aa:	7f 67                	jg     802413 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023ac:	83 ec 0c             	sub    $0xc,%esp
  8023af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b2:	50                   	push   %eax
  8023b3:	e8 94 f8 ff ff       	call   801c4c <fd_alloc>
  8023b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8023bb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023bd:	85 c0                	test   %eax,%eax
  8023bf:	78 57                	js     802418 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023c1:	83 ec 08             	sub    $0x8,%esp
  8023c4:	53                   	push   %ebx
  8023c5:	68 00 60 80 00       	push   $0x806000
  8023ca:	e8 16 ee ff ff       	call   8011e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d2:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023da:	b8 01 00 00 00       	mov    $0x1,%eax
  8023df:	e8 f0 fd ff ff       	call   8021d4 <fsipc>
  8023e4:	89 c3                	mov    %eax,%ebx
  8023e6:	83 c4 10             	add    $0x10,%esp
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	79 14                	jns    802401 <open+0x6f>
		fd_close(fd, 0);
  8023ed:	83 ec 08             	sub    $0x8,%esp
  8023f0:	6a 00                	push   $0x0
  8023f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f5:	e8 4a f9 ff ff       	call   801d44 <fd_close>
		return r;
  8023fa:	83 c4 10             	add    $0x10,%esp
  8023fd:	89 da                	mov    %ebx,%edx
  8023ff:	eb 17                	jmp    802418 <open+0x86>
	}

	return fd2num(fd);
  802401:	83 ec 0c             	sub    $0xc,%esp
  802404:	ff 75 f4             	pushl  -0xc(%ebp)
  802407:	e8 19 f8 ff ff       	call   801c25 <fd2num>
  80240c:	89 c2                	mov    %eax,%edx
  80240e:	83 c4 10             	add    $0x10,%esp
  802411:	eb 05                	jmp    802418 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802413:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802418:	89 d0                	mov    %edx,%eax
  80241a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80241d:	c9                   	leave  
  80241e:	c3                   	ret    

0080241f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802425:	ba 00 00 00 00       	mov    $0x0,%edx
  80242a:	b8 08 00 00 00       	mov    $0x8,%eax
  80242f:	e8 a0 fd ff ff       	call   8021d4 <fsipc>
}
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802436:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80243a:	7e 37                	jle    802473 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	53                   	push   %ebx
  802440:	83 ec 08             	sub    $0x8,%esp
  802443:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802445:	ff 70 04             	pushl  0x4(%eax)
  802448:	8d 40 10             	lea    0x10(%eax),%eax
  80244b:	50                   	push   %eax
  80244c:	ff 33                	pushl  (%ebx)
  80244e:	e8 88 fb ff ff       	call   801fdb <write>
		if (result > 0)
  802453:	83 c4 10             	add    $0x10,%esp
  802456:	85 c0                	test   %eax,%eax
  802458:	7e 03                	jle    80245d <writebuf+0x27>
			b->result += result;
  80245a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80245d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802460:	74 0d                	je     80246f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802462:	85 c0                	test   %eax,%eax
  802464:	ba 00 00 00 00       	mov    $0x0,%edx
  802469:	0f 4f c2             	cmovg  %edx,%eax
  80246c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80246f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802472:	c9                   	leave  
  802473:	f3 c3                	repz ret 

00802475 <putch>:

static void
putch(int ch, void *thunk)
{
  802475:	55                   	push   %ebp
  802476:	89 e5                	mov    %esp,%ebp
  802478:	53                   	push   %ebx
  802479:	83 ec 04             	sub    $0x4,%esp
  80247c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80247f:	8b 53 04             	mov    0x4(%ebx),%edx
  802482:	8d 42 01             	lea    0x1(%edx),%eax
  802485:	89 43 04             	mov    %eax,0x4(%ebx)
  802488:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80248b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80248f:	3d 00 01 00 00       	cmp    $0x100,%eax
  802494:	75 0e                	jne    8024a4 <putch+0x2f>
		writebuf(b);
  802496:	89 d8                	mov    %ebx,%eax
  802498:	e8 99 ff ff ff       	call   802436 <writebuf>
		b->idx = 0;
  80249d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8024a4:	83 c4 04             	add    $0x4,%esp
  8024a7:	5b                   	pop    %ebx
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    

008024aa <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8024bc:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024c3:	00 00 00 
	b.result = 0;
  8024c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024cd:	00 00 00 
	b.error = 1;
  8024d0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024d7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024da:	ff 75 10             	pushl  0x10(%ebp)
  8024dd:	ff 75 0c             	pushl  0xc(%ebp)
  8024e0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024e6:	50                   	push   %eax
  8024e7:	68 75 24 80 00       	push   $0x802475
  8024ec:	e8 fa e6 ff ff       	call   800beb <vprintfmt>
	if (b.idx > 0)
  8024f1:	83 c4 10             	add    $0x10,%esp
  8024f4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024fb:	7e 0b                	jle    802508 <vfprintf+0x5e>
		writebuf(&b);
  8024fd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802503:	e8 2e ff ff ff       	call   802436 <writebuf>

	return (b.result ? b.result : b.error);
  802508:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80250e:	85 c0                	test   %eax,%eax
  802510:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802517:	c9                   	leave  
  802518:	c3                   	ret    

00802519 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802519:	55                   	push   %ebp
  80251a:	89 e5                	mov    %esp,%ebp
  80251c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80251f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802522:	50                   	push   %eax
  802523:	ff 75 0c             	pushl  0xc(%ebp)
  802526:	ff 75 08             	pushl  0x8(%ebp)
  802529:	e8 7c ff ff ff       	call   8024aa <vfprintf>
	va_end(ap);

	return cnt;
}
  80252e:	c9                   	leave  
  80252f:	c3                   	ret    

00802530 <printf>:

int
printf(const char *fmt, ...)
{
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802536:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802539:	50                   	push   %eax
  80253a:	ff 75 08             	pushl  0x8(%ebp)
  80253d:	6a 01                	push   $0x1
  80253f:	e8 66 ff ff ff       	call   8024aa <vfprintf>
	va_end(ap);

	return cnt;
}
  802544:	c9                   	leave  
  802545:	c3                   	ret    

00802546 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
  802549:	57                   	push   %edi
  80254a:	56                   	push   %esi
  80254b:	53                   	push   %ebx
  80254c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().
	
	// 打开文件
	if ((r = open(prog, O_RDONLY)) < 0)
  802552:	6a 00                	push   $0x0
  802554:	ff 75 08             	pushl  0x8(%ebp)
  802557:	e8 36 fe ff ff       	call   802392 <open>
  80255c:	89 c7                	mov    %eax,%edi
  80255e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802564:	83 c4 10             	add    $0x10,%esp
  802567:	85 c0                	test   %eax,%eax
  802569:	0f 88 95 04 00 00    	js     802a04 <spawn+0x4be>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80256f:	83 ec 04             	sub    $0x4,%esp
  802572:	68 00 02 00 00       	push   $0x200
  802577:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80257d:	50                   	push   %eax
  80257e:	57                   	push   %edi
  80257f:	e8 0e fa ff ff       	call   801f92 <readn>
  802584:	83 c4 10             	add    $0x10,%esp
  802587:	3d 00 02 00 00       	cmp    $0x200,%eax
  80258c:	75 0c                	jne    80259a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80258e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802595:	45 4c 46 
  802598:	74 33                	je     8025cd <spawn+0x87>
		close(fd);
  80259a:	83 ec 0c             	sub    $0xc,%esp
  80259d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8025a3:	e8 1d f8 ff ff       	call   801dc5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025a8:	83 c4 0c             	add    $0xc,%esp
  8025ab:	68 7f 45 4c 46       	push   $0x464c457f
  8025b0:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025b6:	68 56 3a 80 00       	push   $0x803a56
  8025bb:	e8 2e e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  8025c0:	83 c4 10             	add    $0x10,%esp
  8025c3:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025c8:	e9 da 04 00 00       	jmp    802aa7 <spawn+0x561>
  8025cd:	b8 07 00 00 00       	mov    $0x7,%eax
  8025d2:	cd 30                	int    $0x30
  8025d4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025da:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	0f 88 27 04 00 00    	js     802a0f <spawn+0x4c9>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	// 设置寄存器信息
	child_tf = envs[ENVX(child)].env_tf;
  8025e8:	89 c6                	mov    %eax,%esi
  8025ea:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025f0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025f3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025f9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025ff:	b9 11 00 00 00       	mov    $0x11,%ecx
  802604:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802606:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80260c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802612:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802617:	be 00 00 00 00       	mov    $0x0,%esi
  80261c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80261f:	eb 13                	jmp    802634 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802621:	83 ec 0c             	sub    $0xc,%esp
  802624:	50                   	push   %eax
  802625:	e8 82 eb ff ff       	call   8011ac <strlen>
  80262a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80262e:	83 c3 01             	add    $0x1,%ebx
  802631:	83 c4 10             	add    $0x10,%esp
  802634:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80263b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80263e:	85 c0                	test   %eax,%eax
  802640:	75 df                	jne    802621 <spawn+0xdb>
  802642:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802648:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80264e:	bf 00 10 40 00       	mov    $0x401000,%edi
  802653:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802655:	89 fa                	mov    %edi,%edx
  802657:	83 e2 fc             	and    $0xfffffffc,%edx
  80265a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802661:	29 c2                	sub    %eax,%edx
  802663:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802669:	8d 42 f8             	lea    -0x8(%edx),%eax
  80266c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802671:	0f 86 ae 03 00 00    	jbe    802a25 <spawn+0x4df>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802677:	83 ec 04             	sub    $0x4,%esp
  80267a:	6a 07                	push   $0x7
  80267c:	68 00 00 40 00       	push   $0x400000
  802681:	6a 00                	push   $0x0
  802683:	e8 60 ef ff ff       	call   8015e8 <sys_page_alloc>
  802688:	83 c4 10             	add    $0x10,%esp
  80268b:	85 c0                	test   %eax,%eax
  80268d:	0f 88 99 03 00 00    	js     802a2c <spawn+0x4e6>
  802693:	be 00 00 00 00       	mov    $0x0,%esi
  802698:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80269e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8026a1:	eb 30                	jmp    8026d3 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8026a3:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026a9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026af:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8026b2:	83 ec 08             	sub    $0x8,%esp
  8026b5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026b8:	57                   	push   %edi
  8026b9:	e8 27 eb ff ff       	call   8011e5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026be:	83 c4 04             	add    $0x4,%esp
  8026c1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026c4:	e8 e3 ea ff ff       	call   8011ac <strlen>
  8026c9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026cd:	83 c6 01             	add    $0x1,%esi
  8026d0:	83 c4 10             	add    $0x10,%esp
  8026d3:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026d9:	7f c8                	jg     8026a3 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026db:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026e1:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8026e7:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026ee:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026f4:	74 19                	je     80270f <spawn+0x1c9>
  8026f6:	68 e0 3a 80 00       	push   $0x803ae0
  8026fb:	68 af 34 80 00       	push   $0x8034af
  802700:	68 f8 00 00 00       	push   $0xf8
  802705:	68 70 3a 80 00       	push   $0x803a70
  80270a:	e8 06 e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80270f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802715:	89 f8                	mov    %edi,%eax
  802717:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80271c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80271f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802725:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802728:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80272e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802734:	83 ec 0c             	sub    $0xc,%esp
  802737:	6a 07                	push   $0x7
  802739:	68 00 d0 bf ee       	push   $0xeebfd000
  80273e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802744:	68 00 00 40 00       	push   $0x400000
  802749:	6a 00                	push   $0x0
  80274b:	e8 db ee ff ff       	call   80162b <sys_page_map>
  802750:	89 c3                	mov    %eax,%ebx
  802752:	83 c4 20             	add    $0x20,%esp
  802755:	85 c0                	test   %eax,%eax
  802757:	0f 88 38 03 00 00    	js     802a95 <spawn+0x54f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80275d:	83 ec 08             	sub    $0x8,%esp
  802760:	68 00 00 40 00       	push   $0x400000
  802765:	6a 00                	push   $0x0
  802767:	e8 01 ef ff ff       	call   80166d <sys_page_unmap>
  80276c:	89 c3                	mov    %eax,%ebx
  80276e:	83 c4 10             	add    $0x10,%esp
  802771:	85 c0                	test   %eax,%eax
  802773:	0f 88 1c 03 00 00    	js     802a95 <spawn+0x54f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// 加载程序到进程空间
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802779:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80277f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802786:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80278c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802793:	00 00 00 
  802796:	e9 88 01 00 00       	jmp    802923 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80279b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8027a1:	83 38 01             	cmpl   $0x1,(%eax)
  8027a4:	0f 85 6b 01 00 00    	jne    802915 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027aa:	89 c7                	mov    %eax,%edi
  8027ac:	8b 40 18             	mov    0x18(%eax),%eax
  8027af:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8027b5:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027b8:	83 f8 01             	cmp    $0x1,%eax
  8027bb:	19 c0                	sbb    %eax,%eax
  8027bd:	83 e0 fe             	and    $0xfffffffe,%eax
  8027c0:	83 c0 07             	add    $0x7,%eax
  8027c3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027c9:	89 f8                	mov    %edi,%eax
  8027cb:	8b 7f 04             	mov    0x4(%edi),%edi
  8027ce:	89 fa                	mov    %edi,%edx
  8027d0:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8027d6:	8b 78 10             	mov    0x10(%eax),%edi
  8027d9:	8b 48 14             	mov    0x14(%eax),%ecx
  8027dc:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8027e2:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027ec:	74 14                	je     802802 <spawn+0x2bc>
		va -= i;
  8027ee:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027f0:	01 c1                	add    %eax,%ecx
  8027f2:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  8027f8:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027fa:	29 c2                	sub    %eax,%edx
  8027fc:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802802:	bb 00 00 00 00       	mov    $0x0,%ebx
  802807:	e9 f7 00 00 00       	jmp    802903 <spawn+0x3bd>
		if (i >= filesz) {
  80280c:	39 fb                	cmp    %edi,%ebx
  80280e:	72 27                	jb     802837 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802810:	83 ec 04             	sub    $0x4,%esp
  802813:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802819:	56                   	push   %esi
  80281a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802820:	e8 c3 ed ff ff       	call   8015e8 <sys_page_alloc>
  802825:	83 c4 10             	add    $0x10,%esp
  802828:	85 c0                	test   %eax,%eax
  80282a:	0f 89 c7 00 00 00    	jns    8028f7 <spawn+0x3b1>
  802830:	89 c3                	mov    %eax,%ebx
  802832:	e9 03 02 00 00       	jmp    802a3a <spawn+0x4f4>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802837:	83 ec 04             	sub    $0x4,%esp
  80283a:	6a 07                	push   $0x7
  80283c:	68 00 00 40 00       	push   $0x400000
  802841:	6a 00                	push   $0x0
  802843:	e8 a0 ed ff ff       	call   8015e8 <sys_page_alloc>
  802848:	83 c4 10             	add    $0x10,%esp
  80284b:	85 c0                	test   %eax,%eax
  80284d:	0f 88 dd 01 00 00    	js     802a30 <spawn+0x4ea>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802853:	83 ec 08             	sub    $0x8,%esp
  802856:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80285c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802862:	50                   	push   %eax
  802863:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802869:	e8 f9 f7 ff ff       	call   802067 <seek>
  80286e:	83 c4 10             	add    $0x10,%esp
  802871:	85 c0                	test   %eax,%eax
  802873:	0f 88 bb 01 00 00    	js     802a34 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802879:	83 ec 04             	sub    $0x4,%esp
  80287c:	89 f8                	mov    %edi,%eax
  80287e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802884:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802889:	ba 00 10 00 00       	mov    $0x1000,%edx
  80288e:	0f 47 c2             	cmova  %edx,%eax
  802891:	50                   	push   %eax
  802892:	68 00 00 40 00       	push   $0x400000
  802897:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80289d:	e8 f0 f6 ff ff       	call   801f92 <readn>
  8028a2:	83 c4 10             	add    $0x10,%esp
  8028a5:	85 c0                	test   %eax,%eax
  8028a7:	0f 88 8b 01 00 00    	js     802a38 <spawn+0x4f2>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028ad:	83 ec 0c             	sub    $0xc,%esp
  8028b0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028b6:	56                   	push   %esi
  8028b7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028bd:	68 00 00 40 00       	push   $0x400000
  8028c2:	6a 00                	push   $0x0
  8028c4:	e8 62 ed ff ff       	call   80162b <sys_page_map>
  8028c9:	83 c4 20             	add    $0x20,%esp
  8028cc:	85 c0                	test   %eax,%eax
  8028ce:	79 15                	jns    8028e5 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8028d0:	50                   	push   %eax
  8028d1:	68 7c 3a 80 00       	push   $0x803a7c
  8028d6:	68 2b 01 00 00       	push   $0x12b
  8028db:	68 70 3a 80 00       	push   $0x803a70
  8028e0:	e8 30 e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  8028e5:	83 ec 08             	sub    $0x8,%esp
  8028e8:	68 00 00 40 00       	push   $0x400000
  8028ed:	6a 00                	push   $0x0
  8028ef:	e8 79 ed ff ff       	call   80166d <sys_page_unmap>
  8028f4:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028f7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028fd:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802903:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802909:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80290f:	0f 82 f7 fe ff ff    	jb     80280c <spawn+0x2c6>
		return r;

	// 加载程序到进程空间
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802915:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80291c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802923:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80292a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802930:	0f 8c 65 fe ff ff    	jl     80279b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802936:	83 ec 0c             	sub    $0xc,%esp
  802939:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80293f:	e8 81 f4 ff ff       	call   801dc5 <close>
  802944:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	void *addr;

	for (addr = 0; addr < (void *) USTACKTOP; addr += PGSIZE) {
  802947:	bb 00 00 00 00       	mov    $0x0,%ebx
  80294c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  802952:	89 d8                	mov    %ebx,%eax
  802954:	c1 e8 16             	shr    $0x16,%eax
  802957:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80295e:	a8 01                	test   $0x1,%al
  802960:	74 4e                	je     8029b0 <spawn+0x46a>
  802962:	89 d8                	mov    %ebx,%eax
  802964:	c1 e8 0c             	shr    $0xc,%eax
  802967:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80296e:	f6 c2 01             	test   $0x1,%dl
  802971:	74 3d                	je     8029b0 <spawn+0x46a>
			&& (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  802973:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80297a:	f6 c2 04             	test   $0x4,%dl
  80297d:	74 31                	je     8029b0 <spawn+0x46a>
  80297f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802986:	f6 c6 04             	test   $0x4,%dh
  802989:	74 25                	je     8029b0 <spawn+0x46a>
			if ((r = sys_page_map(0, addr, child, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0) 
  80298b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802992:	83 ec 0c             	sub    $0xc,%esp
  802995:	25 07 0e 00 00       	and    $0xe07,%eax
  80299a:	50                   	push   %eax
  80299b:	53                   	push   %ebx
  80299c:	56                   	push   %esi
  80299d:	53                   	push   %ebx
  80299e:	6a 00                	push   $0x0
  8029a0:	e8 86 ec ff ff       	call   80162b <sys_page_map>
  8029a5:	83 c4 20             	add    $0x20,%esp
  8029a8:	85 c0                	test   %eax,%eax
  8029aa:	0f 88 ab 00 00 00    	js     802a5b <spawn+0x515>
{
	// LAB 5: Your code here.
	int r;
	void *addr;

	for (addr = 0; addr < (void *) USTACKTOP; addr += PGSIZE) {
  8029b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8029b6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8029bc:	75 94                	jne    802952 <spawn+0x40c>
  8029be:	e9 ad 00 00 00       	jmp    802a70 <spawn+0x52a>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	// 初始化新建进程的寄存器信息
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8029c3:	50                   	push   %eax
  8029c4:	68 99 3a 80 00       	push   $0x803a99
  8029c9:	68 8b 00 00 00       	push   $0x8b
  8029ce:	68 70 3a 80 00       	push   $0x803a70
  8029d3:	e8 3d e0 ff ff       	call   800a15 <_panic>

	// 设置进程状态
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029d8:	83 ec 08             	sub    $0x8,%esp
  8029db:	6a 02                	push   $0x2
  8029dd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029e3:	e8 c7 ec ff ff       	call   8016af <sys_env_set_status>
  8029e8:	83 c4 10             	add    $0x10,%esp
  8029eb:	85 c0                	test   %eax,%eax
  8029ed:	79 2b                	jns    802a1a <spawn+0x4d4>
		panic("sys_env_set_status: %e", r);
  8029ef:	50                   	push   %eax
  8029f0:	68 b3 3a 80 00       	push   $0x803ab3
  8029f5:	68 8f 00 00 00       	push   $0x8f
  8029fa:	68 70 3a 80 00       	push   $0x803a70
  8029ff:	e8 11 e0 ff ff       	call   800a15 <_panic>
	//
	//   - Start the child process running with sys_env_set_status().
	
	// 打开文件
	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802a04:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802a0a:	e9 98 00 00 00       	jmp    802aa7 <spawn+0x561>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802a0f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a15:	e9 8d 00 00 00       	jmp    802aa7 <spawn+0x561>

	// 设置进程状态
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a1a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a20:	e9 82 00 00 00       	jmp    802aa7 <spawn+0x561>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a25:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a2a:	eb 7b                	jmp    802aa7 <spawn+0x561>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a2c:	89 c3                	mov    %eax,%ebx
  802a2e:	eb 77                	jmp    802aa7 <spawn+0x561>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a30:	89 c3                	mov    %eax,%ebx
  802a32:	eb 06                	jmp    802a3a <spawn+0x4f4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a34:	89 c3                	mov    %eax,%ebx
  802a36:	eb 02                	jmp    802a3a <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a38:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a3a:	83 ec 0c             	sub    $0xc,%esp
  802a3d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a43:	e8 21 eb ff ff       	call   801569 <sys_env_destroy>
	close(fd);
  802a48:	83 c4 04             	add    $0x4,%esp
  802a4b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a51:	e8 6f f3 ff ff       	call   801dc5 <close>
	return r;
  802a56:	83 c4 10             	add    $0x10,%esp
  802a59:	eb 4c                	jmp    802aa7 <spawn+0x561>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a5b:	50                   	push   %eax
  802a5c:	68 ca 3a 80 00       	push   $0x803aca
  802a61:	68 87 00 00 00       	push   $0x87
  802a66:	68 70 3a 80 00       	push   $0x803a70
  802a6b:	e8 a5 df ff ff       	call   800a15 <_panic>

	// 初始化新建进程的寄存器信息
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a70:	83 ec 08             	sub    $0x8,%esp
  802a73:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a79:	50                   	push   %eax
  802a7a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a80:	e8 6c ec ff ff       	call   8016f1 <sys_env_set_trapframe>
  802a85:	83 c4 10             	add    $0x10,%esp
  802a88:	85 c0                	test   %eax,%eax
  802a8a:	0f 89 48 ff ff ff    	jns    8029d8 <spawn+0x492>
  802a90:	e9 2e ff ff ff       	jmp    8029c3 <spawn+0x47d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a95:	83 ec 08             	sub    $0x8,%esp
  802a98:	68 00 00 40 00       	push   $0x400000
  802a9d:	6a 00                	push   $0x0
  802a9f:	e8 c9 eb ff ff       	call   80166d <sys_page_unmap>
  802aa4:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802aa7:	89 d8                	mov    %ebx,%eax
  802aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802aac:	5b                   	pop    %ebx
  802aad:	5e                   	pop    %esi
  802aae:	5f                   	pop    %edi
  802aaf:	5d                   	pop    %ebp
  802ab0:	c3                   	ret    

00802ab1 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802ab1:	55                   	push   %ebp
  802ab2:	89 e5                	mov    %esp,%ebp
  802ab4:	56                   	push   %esi
  802ab5:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ab6:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802ab9:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802abe:	eb 03                	jmp    802ac3 <spawnl+0x12>
		argc++;
  802ac0:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ac3:	83 c2 04             	add    $0x4,%edx
  802ac6:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802aca:	75 f4                	jne    802ac0 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802acc:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ad3:	83 e2 f0             	and    $0xfffffff0,%edx
  802ad6:	29 d4                	sub    %edx,%esp
  802ad8:	8d 54 24 03          	lea    0x3(%esp),%edx
  802adc:	c1 ea 02             	shr    $0x2,%edx
  802adf:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802ae6:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aeb:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802af2:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802af9:	00 
  802afa:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802afc:	b8 00 00 00 00       	mov    $0x0,%eax
  802b01:	eb 0a                	jmp    802b0d <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802b03:	83 c0 01             	add    $0x1,%eax
  802b06:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802b0a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b0d:	39 d0                	cmp    %edx,%eax
  802b0f:	75 f2                	jne    802b03 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802b11:	83 ec 08             	sub    $0x8,%esp
  802b14:	56                   	push   %esi
  802b15:	ff 75 08             	pushl  0x8(%ebp)
  802b18:	e8 29 fa ff ff       	call   802546 <spawn>
}
  802b1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b20:	5b                   	pop    %ebx
  802b21:	5e                   	pop    %esi
  802b22:	5d                   	pop    %ebp
  802b23:	c3                   	ret    

00802b24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b24:	55                   	push   %ebp
  802b25:	89 e5                	mov    %esp,%ebp
  802b27:	56                   	push   %esi
  802b28:	53                   	push   %ebx
  802b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b2c:	83 ec 0c             	sub    $0xc,%esp
  802b2f:	ff 75 08             	pushl  0x8(%ebp)
  802b32:	e8 fe f0 ff ff       	call   801c35 <fd2data>
  802b37:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b39:	83 c4 08             	add    $0x8,%esp
  802b3c:	68 08 3b 80 00       	push   $0x803b08
  802b41:	53                   	push   %ebx
  802b42:	e8 9e e6 ff ff       	call   8011e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b47:	8b 46 04             	mov    0x4(%esi),%eax
  802b4a:	2b 06                	sub    (%esi),%eax
  802b4c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b52:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b59:	00 00 00 
	stat->st_dev = &devpipe;
  802b5c:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b63:	40 80 00 
	return 0;
}
  802b66:	b8 00 00 00 00       	mov    $0x0,%eax
  802b6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b6e:	5b                   	pop    %ebx
  802b6f:	5e                   	pop    %esi
  802b70:	5d                   	pop    %ebp
  802b71:	c3                   	ret    

00802b72 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b72:	55                   	push   %ebp
  802b73:	89 e5                	mov    %esp,%ebp
  802b75:	53                   	push   %ebx
  802b76:	83 ec 0c             	sub    $0xc,%esp
  802b79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b7c:	53                   	push   %ebx
  802b7d:	6a 00                	push   $0x0
  802b7f:	e8 e9 ea ff ff       	call   80166d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b84:	89 1c 24             	mov    %ebx,(%esp)
  802b87:	e8 a9 f0 ff ff       	call   801c35 <fd2data>
  802b8c:	83 c4 08             	add    $0x8,%esp
  802b8f:	50                   	push   %eax
  802b90:	6a 00                	push   $0x0
  802b92:	e8 d6 ea ff ff       	call   80166d <sys_page_unmap>
}
  802b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b9a:	c9                   	leave  
  802b9b:	c3                   	ret    

00802b9c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b9c:	55                   	push   %ebp
  802b9d:	89 e5                	mov    %esp,%ebp
  802b9f:	57                   	push   %edi
  802ba0:	56                   	push   %esi
  802ba1:	53                   	push   %ebx
  802ba2:	83 ec 1c             	sub    $0x1c,%esp
  802ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802ba8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802baa:	a1 24 54 80 00       	mov    0x805424,%eax
  802baf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802bb2:	83 ec 0c             	sub    $0xc,%esp
  802bb5:	ff 75 e0             	pushl  -0x20(%ebp)
  802bb8:	e8 bb 04 00 00       	call   803078 <pageref>
  802bbd:	89 c3                	mov    %eax,%ebx
  802bbf:	89 3c 24             	mov    %edi,(%esp)
  802bc2:	e8 b1 04 00 00       	call   803078 <pageref>
  802bc7:	83 c4 10             	add    $0x10,%esp
  802bca:	39 c3                	cmp    %eax,%ebx
  802bcc:	0f 94 c1             	sete   %cl
  802bcf:	0f b6 c9             	movzbl %cl,%ecx
  802bd2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802bd5:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802bdb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802bde:	39 ce                	cmp    %ecx,%esi
  802be0:	74 1b                	je     802bfd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802be2:	39 c3                	cmp    %eax,%ebx
  802be4:	75 c4                	jne    802baa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802be6:	8b 42 58             	mov    0x58(%edx),%eax
  802be9:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bec:	50                   	push   %eax
  802bed:	56                   	push   %esi
  802bee:	68 0f 3b 80 00       	push   $0x803b0f
  802bf3:	e8 f6 de ff ff       	call   800aee <cprintf>
  802bf8:	83 c4 10             	add    $0x10,%esp
  802bfb:	eb ad                	jmp    802baa <_pipeisclosed+0xe>
	}
}
  802bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c03:	5b                   	pop    %ebx
  802c04:	5e                   	pop    %esi
  802c05:	5f                   	pop    %edi
  802c06:	5d                   	pop    %ebp
  802c07:	c3                   	ret    

00802c08 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c08:	55                   	push   %ebp
  802c09:	89 e5                	mov    %esp,%ebp
  802c0b:	57                   	push   %edi
  802c0c:	56                   	push   %esi
  802c0d:	53                   	push   %ebx
  802c0e:	83 ec 28             	sub    $0x28,%esp
  802c11:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802c14:	56                   	push   %esi
  802c15:	e8 1b f0 ff ff       	call   801c35 <fd2data>
  802c1a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c1c:	83 c4 10             	add    $0x10,%esp
  802c1f:	bf 00 00 00 00       	mov    $0x0,%edi
  802c24:	eb 4b                	jmp    802c71 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c26:	89 da                	mov    %ebx,%edx
  802c28:	89 f0                	mov    %esi,%eax
  802c2a:	e8 6d ff ff ff       	call   802b9c <_pipeisclosed>
  802c2f:	85 c0                	test   %eax,%eax
  802c31:	75 48                	jne    802c7b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c33:	e8 91 e9 ff ff       	call   8015c9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c38:	8b 43 04             	mov    0x4(%ebx),%eax
  802c3b:	8b 0b                	mov    (%ebx),%ecx
  802c3d:	8d 51 20             	lea    0x20(%ecx),%edx
  802c40:	39 d0                	cmp    %edx,%eax
  802c42:	73 e2                	jae    802c26 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c47:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c4b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c4e:	89 c2                	mov    %eax,%edx
  802c50:	c1 fa 1f             	sar    $0x1f,%edx
  802c53:	89 d1                	mov    %edx,%ecx
  802c55:	c1 e9 1b             	shr    $0x1b,%ecx
  802c58:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c5b:	83 e2 1f             	and    $0x1f,%edx
  802c5e:	29 ca                	sub    %ecx,%edx
  802c60:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c64:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c68:	83 c0 01             	add    $0x1,%eax
  802c6b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c6e:	83 c7 01             	add    $0x1,%edi
  802c71:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c74:	75 c2                	jne    802c38 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c76:	8b 45 10             	mov    0x10(%ebp),%eax
  802c79:	eb 05                	jmp    802c80 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c7b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c83:	5b                   	pop    %ebx
  802c84:	5e                   	pop    %esi
  802c85:	5f                   	pop    %edi
  802c86:	5d                   	pop    %ebp
  802c87:	c3                   	ret    

00802c88 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c88:	55                   	push   %ebp
  802c89:	89 e5                	mov    %esp,%ebp
  802c8b:	57                   	push   %edi
  802c8c:	56                   	push   %esi
  802c8d:	53                   	push   %ebx
  802c8e:	83 ec 18             	sub    $0x18,%esp
  802c91:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c94:	57                   	push   %edi
  802c95:	e8 9b ef ff ff       	call   801c35 <fd2data>
  802c9a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c9c:	83 c4 10             	add    $0x10,%esp
  802c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ca4:	eb 3d                	jmp    802ce3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802ca6:	85 db                	test   %ebx,%ebx
  802ca8:	74 04                	je     802cae <devpipe_read+0x26>
				return i;
  802caa:	89 d8                	mov    %ebx,%eax
  802cac:	eb 44                	jmp    802cf2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802cae:	89 f2                	mov    %esi,%edx
  802cb0:	89 f8                	mov    %edi,%eax
  802cb2:	e8 e5 fe ff ff       	call   802b9c <_pipeisclosed>
  802cb7:	85 c0                	test   %eax,%eax
  802cb9:	75 32                	jne    802ced <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802cbb:	e8 09 e9 ff ff       	call   8015c9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802cc0:	8b 06                	mov    (%esi),%eax
  802cc2:	3b 46 04             	cmp    0x4(%esi),%eax
  802cc5:	74 df                	je     802ca6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cc7:	99                   	cltd   
  802cc8:	c1 ea 1b             	shr    $0x1b,%edx
  802ccb:	01 d0                	add    %edx,%eax
  802ccd:	83 e0 1f             	and    $0x1f,%eax
  802cd0:	29 d0                	sub    %edx,%eax
  802cd2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cda:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802cdd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ce0:	83 c3 01             	add    $0x1,%ebx
  802ce3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802ce6:	75 d8                	jne    802cc0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802ce8:	8b 45 10             	mov    0x10(%ebp),%eax
  802ceb:	eb 05                	jmp    802cf2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802ced:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cf5:	5b                   	pop    %ebx
  802cf6:	5e                   	pop    %esi
  802cf7:	5f                   	pop    %edi
  802cf8:	5d                   	pop    %ebp
  802cf9:	c3                   	ret    

00802cfa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802cfa:	55                   	push   %ebp
  802cfb:	89 e5                	mov    %esp,%ebp
  802cfd:	56                   	push   %esi
  802cfe:	53                   	push   %ebx
  802cff:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d05:	50                   	push   %eax
  802d06:	e8 41 ef ff ff       	call   801c4c <fd_alloc>
  802d0b:	83 c4 10             	add    $0x10,%esp
  802d0e:	89 c2                	mov    %eax,%edx
  802d10:	85 c0                	test   %eax,%eax
  802d12:	0f 88 2c 01 00 00    	js     802e44 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d18:	83 ec 04             	sub    $0x4,%esp
  802d1b:	68 07 04 00 00       	push   $0x407
  802d20:	ff 75 f4             	pushl  -0xc(%ebp)
  802d23:	6a 00                	push   $0x0
  802d25:	e8 be e8 ff ff       	call   8015e8 <sys_page_alloc>
  802d2a:	83 c4 10             	add    $0x10,%esp
  802d2d:	89 c2                	mov    %eax,%edx
  802d2f:	85 c0                	test   %eax,%eax
  802d31:	0f 88 0d 01 00 00    	js     802e44 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d37:	83 ec 0c             	sub    $0xc,%esp
  802d3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d3d:	50                   	push   %eax
  802d3e:	e8 09 ef ff ff       	call   801c4c <fd_alloc>
  802d43:	89 c3                	mov    %eax,%ebx
  802d45:	83 c4 10             	add    $0x10,%esp
  802d48:	85 c0                	test   %eax,%eax
  802d4a:	0f 88 e2 00 00 00    	js     802e32 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d50:	83 ec 04             	sub    $0x4,%esp
  802d53:	68 07 04 00 00       	push   $0x407
  802d58:	ff 75 f0             	pushl  -0x10(%ebp)
  802d5b:	6a 00                	push   $0x0
  802d5d:	e8 86 e8 ff ff       	call   8015e8 <sys_page_alloc>
  802d62:	89 c3                	mov    %eax,%ebx
  802d64:	83 c4 10             	add    $0x10,%esp
  802d67:	85 c0                	test   %eax,%eax
  802d69:	0f 88 c3 00 00 00    	js     802e32 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d6f:	83 ec 0c             	sub    $0xc,%esp
  802d72:	ff 75 f4             	pushl  -0xc(%ebp)
  802d75:	e8 bb ee ff ff       	call   801c35 <fd2data>
  802d7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d7c:	83 c4 0c             	add    $0xc,%esp
  802d7f:	68 07 04 00 00       	push   $0x407
  802d84:	50                   	push   %eax
  802d85:	6a 00                	push   $0x0
  802d87:	e8 5c e8 ff ff       	call   8015e8 <sys_page_alloc>
  802d8c:	89 c3                	mov    %eax,%ebx
  802d8e:	83 c4 10             	add    $0x10,%esp
  802d91:	85 c0                	test   %eax,%eax
  802d93:	0f 88 89 00 00 00    	js     802e22 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d99:	83 ec 0c             	sub    $0xc,%esp
  802d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  802d9f:	e8 91 ee ff ff       	call   801c35 <fd2data>
  802da4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802dab:	50                   	push   %eax
  802dac:	6a 00                	push   $0x0
  802dae:	56                   	push   %esi
  802daf:	6a 00                	push   $0x0
  802db1:	e8 75 e8 ff ff       	call   80162b <sys_page_map>
  802db6:	89 c3                	mov    %eax,%ebx
  802db8:	83 c4 20             	add    $0x20,%esp
  802dbb:	85 c0                	test   %eax,%eax
  802dbd:	78 55                	js     802e14 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802dbf:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dc8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dcd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dd4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ddd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802de2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802de9:	83 ec 0c             	sub    $0xc,%esp
  802dec:	ff 75 f4             	pushl  -0xc(%ebp)
  802def:	e8 31 ee ff ff       	call   801c25 <fd2num>
  802df4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802df7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802df9:	83 c4 04             	add    $0x4,%esp
  802dfc:	ff 75 f0             	pushl  -0x10(%ebp)
  802dff:	e8 21 ee ff ff       	call   801c25 <fd2num>
  802e04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e07:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802e0a:	83 c4 10             	add    $0x10,%esp
  802e0d:	ba 00 00 00 00       	mov    $0x0,%edx
  802e12:	eb 30                	jmp    802e44 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802e14:	83 ec 08             	sub    $0x8,%esp
  802e17:	56                   	push   %esi
  802e18:	6a 00                	push   $0x0
  802e1a:	e8 4e e8 ff ff       	call   80166d <sys_page_unmap>
  802e1f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e22:	83 ec 08             	sub    $0x8,%esp
  802e25:	ff 75 f0             	pushl  -0x10(%ebp)
  802e28:	6a 00                	push   $0x0
  802e2a:	e8 3e e8 ff ff       	call   80166d <sys_page_unmap>
  802e2f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e32:	83 ec 08             	sub    $0x8,%esp
  802e35:	ff 75 f4             	pushl  -0xc(%ebp)
  802e38:	6a 00                	push   $0x0
  802e3a:	e8 2e e8 ff ff       	call   80166d <sys_page_unmap>
  802e3f:	83 c4 10             	add    $0x10,%esp
  802e42:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e44:	89 d0                	mov    %edx,%eax
  802e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e49:	5b                   	pop    %ebx
  802e4a:	5e                   	pop    %esi
  802e4b:	5d                   	pop    %ebp
  802e4c:	c3                   	ret    

00802e4d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e4d:	55                   	push   %ebp
  802e4e:	89 e5                	mov    %esp,%ebp
  802e50:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e56:	50                   	push   %eax
  802e57:	ff 75 08             	pushl  0x8(%ebp)
  802e5a:	e8 3c ee ff ff       	call   801c9b <fd_lookup>
  802e5f:	83 c4 10             	add    $0x10,%esp
  802e62:	85 c0                	test   %eax,%eax
  802e64:	78 18                	js     802e7e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e66:	83 ec 0c             	sub    $0xc,%esp
  802e69:	ff 75 f4             	pushl  -0xc(%ebp)
  802e6c:	e8 c4 ed ff ff       	call   801c35 <fd2data>
	return _pipeisclosed(fd, p);
  802e71:	89 c2                	mov    %eax,%edx
  802e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e76:	e8 21 fd ff ff       	call   802b9c <_pipeisclosed>
  802e7b:	83 c4 10             	add    $0x10,%esp
}
  802e7e:	c9                   	leave  
  802e7f:	c3                   	ret    

00802e80 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e80:	55                   	push   %ebp
  802e81:	89 e5                	mov    %esp,%ebp
  802e83:	56                   	push   %esi
  802e84:	53                   	push   %ebx
  802e85:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e88:	85 f6                	test   %esi,%esi
  802e8a:	75 16                	jne    802ea2 <wait+0x22>
  802e8c:	68 27 3b 80 00       	push   $0x803b27
  802e91:	68 af 34 80 00       	push   $0x8034af
  802e96:	6a 09                	push   $0x9
  802e98:	68 32 3b 80 00       	push   $0x803b32
  802e9d:	e8 73 db ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802ea2:	89 f3                	mov    %esi,%ebx
  802ea4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802eaa:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802ead:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802eb3:	eb 05                	jmp    802eba <wait+0x3a>
		sys_yield();
  802eb5:	e8 0f e7 ff ff       	call   8015c9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802eba:	8b 43 48             	mov    0x48(%ebx),%eax
  802ebd:	39 c6                	cmp    %eax,%esi
  802ebf:	75 07                	jne    802ec8 <wait+0x48>
  802ec1:	8b 43 54             	mov    0x54(%ebx),%eax
  802ec4:	85 c0                	test   %eax,%eax
  802ec6:	75 ed                	jne    802eb5 <wait+0x35>
		sys_yield();
}
  802ec8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ecb:	5b                   	pop    %ebx
  802ecc:	5e                   	pop    %esi
  802ecd:	5d                   	pop    %ebp
  802ece:	c3                   	ret    

00802ecf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ecf:	55                   	push   %ebp
  802ed0:	89 e5                	mov    %esp,%ebp
  802ed2:	53                   	push   %ebx
  802ed3:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  802ed6:	e8 cf e6 ff ff       	call   8015aa <sys_getenvid>
  802edb:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  802edd:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ee4:	75 29                	jne    802f0f <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  802ee6:	83 ec 04             	sub    $0x4,%esp
  802ee9:	6a 07                	push   $0x7
  802eeb:	68 00 f0 bf ee       	push   $0xeebff000
  802ef0:	50                   	push   %eax
  802ef1:	e8 f2 e6 ff ff       	call   8015e8 <sys_page_alloc>
  802ef6:	83 c4 10             	add    $0x10,%esp
  802ef9:	85 c0                	test   %eax,%eax
  802efb:	79 12                	jns    802f0f <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  802efd:	50                   	push   %eax
  802efe:	68 3d 3b 80 00       	push   $0x803b3d
  802f03:	6a 24                	push   $0x24
  802f05:	68 56 3b 80 00       	push   $0x803b56
  802f0a:	e8 06 db ff ff       	call   800a15 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  802f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f12:	a3 00 70 80 00       	mov    %eax,0x807000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  802f17:	83 ec 08             	sub    $0x8,%esp
  802f1a:	68 43 2f 80 00       	push   $0x802f43
  802f1f:	53                   	push   %ebx
  802f20:	e8 0e e8 ff ff       	call   801733 <sys_env_set_pgfault_upcall>
  802f25:	83 c4 10             	add    $0x10,%esp
  802f28:	85 c0                	test   %eax,%eax
  802f2a:	79 12                	jns    802f3e <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  802f2c:	50                   	push   %eax
  802f2d:	68 3d 3b 80 00       	push   $0x803b3d
  802f32:	6a 2e                	push   $0x2e
  802f34:	68 56 3b 80 00       	push   $0x803b56
  802f39:	e8 d7 da ff ff       	call   800a15 <_panic>
}
  802f3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f41:	c9                   	leave  
  802f42:	c3                   	ret    

00802f43 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f43:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f44:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f49:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f4b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  802f4e:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  802f52:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  802f55:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802f59:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  802f5b:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802f5f:	83 c4 08             	add    $0x8,%esp
	popal
  802f62:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802f63:	83 c4 04             	add    $0x4,%esp
	popfl
  802f66:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  802f67:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f68:	c3                   	ret    

00802f69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f69:	55                   	push   %ebp
  802f6a:	89 e5                	mov    %esp,%ebp
  802f6c:	57                   	push   %edi
  802f6d:	56                   	push   %esi
  802f6e:	53                   	push   %ebx
  802f6f:	83 ec 0c             	sub    $0xc,%esp
  802f72:	8b 75 08             	mov    0x8(%ebp),%esi
  802f75:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  802f7b:	85 f6                	test   %esi,%esi
  802f7d:	74 06                	je     802f85 <ipc_recv+0x1c>
		*from_env_store = 0;
  802f7f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  802f85:	85 db                	test   %ebx,%ebx
  802f87:	74 06                	je     802f8f <ipc_recv+0x26>
		*perm_store = 0;
  802f89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  802f8f:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  802f91:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802f96:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  802f99:	83 ec 0c             	sub    $0xc,%esp
  802f9c:	50                   	push   %eax
  802f9d:	e8 f6 e7 ff ff       	call   801798 <sys_ipc_recv>
  802fa2:	89 c7                	mov    %eax,%edi
  802fa4:	83 c4 10             	add    $0x10,%esp
  802fa7:	85 c0                	test   %eax,%eax
  802fa9:	79 14                	jns    802fbf <ipc_recv+0x56>
		cprintf("im dead");
  802fab:	83 ec 0c             	sub    $0xc,%esp
  802fae:	68 64 3b 80 00       	push   $0x803b64
  802fb3:	e8 36 db ff ff       	call   800aee <cprintf>
		return r;
  802fb8:	83 c4 10             	add    $0x10,%esp
  802fbb:	89 f8                	mov    %edi,%eax
  802fbd:	eb 24                	jmp    802fe3 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  802fbf:	85 f6                	test   %esi,%esi
  802fc1:	74 0a                	je     802fcd <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  802fc3:	a1 24 54 80 00       	mov    0x805424,%eax
  802fc8:	8b 40 74             	mov    0x74(%eax),%eax
  802fcb:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  802fcd:	85 db                	test   %ebx,%ebx
  802fcf:	74 0a                	je     802fdb <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  802fd1:	a1 24 54 80 00       	mov    0x805424,%eax
  802fd6:	8b 40 78             	mov    0x78(%eax),%eax
  802fd9:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  802fdb:	a1 24 54 80 00       	mov    0x805424,%eax
  802fe0:	8b 40 70             	mov    0x70(%eax),%eax
}
  802fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fe6:	5b                   	pop    %ebx
  802fe7:	5e                   	pop    %esi
  802fe8:	5f                   	pop    %edi
  802fe9:	5d                   	pop    %ebp
  802fea:	c3                   	ret    

00802feb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802feb:	55                   	push   %ebp
  802fec:	89 e5                	mov    %esp,%ebp
  802fee:	57                   	push   %edi
  802fef:	56                   	push   %esi
  802ff0:	53                   	push   %ebx
  802ff1:	83 ec 0c             	sub    $0xc,%esp
  802ff4:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ff7:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ffa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  802ffd:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  802fff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  803004:	0f 44 d8             	cmove  %eax,%ebx
  803007:	eb 1c                	jmp    803025 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  803009:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80300c:	74 12                	je     803020 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  80300e:	50                   	push   %eax
  80300f:	68 6c 3b 80 00       	push   $0x803b6c
  803014:	6a 4e                	push   $0x4e
  803016:	68 79 3b 80 00       	push   $0x803b79
  80301b:	e8 f5 d9 ff ff       	call   800a15 <_panic>
		sys_yield();
  803020:	e8 a4 e5 ff ff       	call   8015c9 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  803025:	ff 75 14             	pushl  0x14(%ebp)
  803028:	53                   	push   %ebx
  803029:	56                   	push   %esi
  80302a:	57                   	push   %edi
  80302b:	e8 45 e7 ff ff       	call   801775 <sys_ipc_try_send>
  803030:	83 c4 10             	add    $0x10,%esp
  803033:	85 c0                	test   %eax,%eax
  803035:	78 d2                	js     803009 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  803037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80303a:	5b                   	pop    %ebx
  80303b:	5e                   	pop    %esi
  80303c:	5f                   	pop    %edi
  80303d:	5d                   	pop    %ebp
  80303e:	c3                   	ret    

0080303f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80303f:	55                   	push   %ebp
  803040:	89 e5                	mov    %esp,%ebp
  803042:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80304a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80304d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803053:	8b 52 50             	mov    0x50(%edx),%edx
  803056:	39 ca                	cmp    %ecx,%edx
  803058:	75 0d                	jne    803067 <ipc_find_env+0x28>
			return envs[i].env_id;
  80305a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80305d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803062:	8b 40 48             	mov    0x48(%eax),%eax
  803065:	eb 0f                	jmp    803076 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803067:	83 c0 01             	add    $0x1,%eax
  80306a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80306f:	75 d9                	jne    80304a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803071:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803076:	5d                   	pop    %ebp
  803077:	c3                   	ret    

00803078 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803078:	55                   	push   %ebp
  803079:	89 e5                	mov    %esp,%ebp
  80307b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80307e:	89 d0                	mov    %edx,%eax
  803080:	c1 e8 16             	shr    $0x16,%eax
  803083:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80308a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80308f:	f6 c1 01             	test   $0x1,%cl
  803092:	74 1d                	je     8030b1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803094:	c1 ea 0c             	shr    $0xc,%edx
  803097:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80309e:	f6 c2 01             	test   $0x1,%dl
  8030a1:	74 0e                	je     8030b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030a3:	c1 ea 0c             	shr    $0xc,%edx
  8030a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030ad:	ef 
  8030ae:	0f b7 c0             	movzwl %ax,%eax
}
  8030b1:	5d                   	pop    %ebp
  8030b2:	c3                   	ret    
  8030b3:	66 90                	xchg   %ax,%ax
  8030b5:	66 90                	xchg   %ax,%ax
  8030b7:	66 90                	xchg   %ax,%ax
  8030b9:	66 90                	xchg   %ax,%ax
  8030bb:	66 90                	xchg   %ax,%ax
  8030bd:	66 90                	xchg   %ax,%ax
  8030bf:	90                   	nop

008030c0 <__udivdi3>:
  8030c0:	55                   	push   %ebp
  8030c1:	57                   	push   %edi
  8030c2:	56                   	push   %esi
  8030c3:	53                   	push   %ebx
  8030c4:	83 ec 1c             	sub    $0x1c,%esp
  8030c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8030cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8030cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8030d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8030d7:	85 f6                	test   %esi,%esi
  8030d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030dd:	89 ca                	mov    %ecx,%edx
  8030df:	89 f8                	mov    %edi,%eax
  8030e1:	75 3d                	jne    803120 <__udivdi3+0x60>
  8030e3:	39 cf                	cmp    %ecx,%edi
  8030e5:	0f 87 c5 00 00 00    	ja     8031b0 <__udivdi3+0xf0>
  8030eb:	85 ff                	test   %edi,%edi
  8030ed:	89 fd                	mov    %edi,%ebp
  8030ef:	75 0b                	jne    8030fc <__udivdi3+0x3c>
  8030f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8030f6:	31 d2                	xor    %edx,%edx
  8030f8:	f7 f7                	div    %edi
  8030fa:	89 c5                	mov    %eax,%ebp
  8030fc:	89 c8                	mov    %ecx,%eax
  8030fe:	31 d2                	xor    %edx,%edx
  803100:	f7 f5                	div    %ebp
  803102:	89 c1                	mov    %eax,%ecx
  803104:	89 d8                	mov    %ebx,%eax
  803106:	89 cf                	mov    %ecx,%edi
  803108:	f7 f5                	div    %ebp
  80310a:	89 c3                	mov    %eax,%ebx
  80310c:	89 d8                	mov    %ebx,%eax
  80310e:	89 fa                	mov    %edi,%edx
  803110:	83 c4 1c             	add    $0x1c,%esp
  803113:	5b                   	pop    %ebx
  803114:	5e                   	pop    %esi
  803115:	5f                   	pop    %edi
  803116:	5d                   	pop    %ebp
  803117:	c3                   	ret    
  803118:	90                   	nop
  803119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803120:	39 ce                	cmp    %ecx,%esi
  803122:	77 74                	ja     803198 <__udivdi3+0xd8>
  803124:	0f bd fe             	bsr    %esi,%edi
  803127:	83 f7 1f             	xor    $0x1f,%edi
  80312a:	0f 84 98 00 00 00    	je     8031c8 <__udivdi3+0x108>
  803130:	bb 20 00 00 00       	mov    $0x20,%ebx
  803135:	89 f9                	mov    %edi,%ecx
  803137:	89 c5                	mov    %eax,%ebp
  803139:	29 fb                	sub    %edi,%ebx
  80313b:	d3 e6                	shl    %cl,%esi
  80313d:	89 d9                	mov    %ebx,%ecx
  80313f:	d3 ed                	shr    %cl,%ebp
  803141:	89 f9                	mov    %edi,%ecx
  803143:	d3 e0                	shl    %cl,%eax
  803145:	09 ee                	or     %ebp,%esi
  803147:	89 d9                	mov    %ebx,%ecx
  803149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80314d:	89 d5                	mov    %edx,%ebp
  80314f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803153:	d3 ed                	shr    %cl,%ebp
  803155:	89 f9                	mov    %edi,%ecx
  803157:	d3 e2                	shl    %cl,%edx
  803159:	89 d9                	mov    %ebx,%ecx
  80315b:	d3 e8                	shr    %cl,%eax
  80315d:	09 c2                	or     %eax,%edx
  80315f:	89 d0                	mov    %edx,%eax
  803161:	89 ea                	mov    %ebp,%edx
  803163:	f7 f6                	div    %esi
  803165:	89 d5                	mov    %edx,%ebp
  803167:	89 c3                	mov    %eax,%ebx
  803169:	f7 64 24 0c          	mull   0xc(%esp)
  80316d:	39 d5                	cmp    %edx,%ebp
  80316f:	72 10                	jb     803181 <__udivdi3+0xc1>
  803171:	8b 74 24 08          	mov    0x8(%esp),%esi
  803175:	89 f9                	mov    %edi,%ecx
  803177:	d3 e6                	shl    %cl,%esi
  803179:	39 c6                	cmp    %eax,%esi
  80317b:	73 07                	jae    803184 <__udivdi3+0xc4>
  80317d:	39 d5                	cmp    %edx,%ebp
  80317f:	75 03                	jne    803184 <__udivdi3+0xc4>
  803181:	83 eb 01             	sub    $0x1,%ebx
  803184:	31 ff                	xor    %edi,%edi
  803186:	89 d8                	mov    %ebx,%eax
  803188:	89 fa                	mov    %edi,%edx
  80318a:	83 c4 1c             	add    $0x1c,%esp
  80318d:	5b                   	pop    %ebx
  80318e:	5e                   	pop    %esi
  80318f:	5f                   	pop    %edi
  803190:	5d                   	pop    %ebp
  803191:	c3                   	ret    
  803192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803198:	31 ff                	xor    %edi,%edi
  80319a:	31 db                	xor    %ebx,%ebx
  80319c:	89 d8                	mov    %ebx,%eax
  80319e:	89 fa                	mov    %edi,%edx
  8031a0:	83 c4 1c             	add    $0x1c,%esp
  8031a3:	5b                   	pop    %ebx
  8031a4:	5e                   	pop    %esi
  8031a5:	5f                   	pop    %edi
  8031a6:	5d                   	pop    %ebp
  8031a7:	c3                   	ret    
  8031a8:	90                   	nop
  8031a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031b0:	89 d8                	mov    %ebx,%eax
  8031b2:	f7 f7                	div    %edi
  8031b4:	31 ff                	xor    %edi,%edi
  8031b6:	89 c3                	mov    %eax,%ebx
  8031b8:	89 d8                	mov    %ebx,%eax
  8031ba:	89 fa                	mov    %edi,%edx
  8031bc:	83 c4 1c             	add    $0x1c,%esp
  8031bf:	5b                   	pop    %ebx
  8031c0:	5e                   	pop    %esi
  8031c1:	5f                   	pop    %edi
  8031c2:	5d                   	pop    %ebp
  8031c3:	c3                   	ret    
  8031c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031c8:	39 ce                	cmp    %ecx,%esi
  8031ca:	72 0c                	jb     8031d8 <__udivdi3+0x118>
  8031cc:	31 db                	xor    %ebx,%ebx
  8031ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8031d2:	0f 87 34 ff ff ff    	ja     80310c <__udivdi3+0x4c>
  8031d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8031dd:	e9 2a ff ff ff       	jmp    80310c <__udivdi3+0x4c>
  8031e2:	66 90                	xchg   %ax,%ax
  8031e4:	66 90                	xchg   %ax,%ax
  8031e6:	66 90                	xchg   %ax,%ax
  8031e8:	66 90                	xchg   %ax,%ax
  8031ea:	66 90                	xchg   %ax,%ax
  8031ec:	66 90                	xchg   %ax,%ax
  8031ee:	66 90                	xchg   %ax,%ax

008031f0 <__umoddi3>:
  8031f0:	55                   	push   %ebp
  8031f1:	57                   	push   %edi
  8031f2:	56                   	push   %esi
  8031f3:	53                   	push   %ebx
  8031f4:	83 ec 1c             	sub    $0x1c,%esp
  8031f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8031fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  803203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803207:	85 d2                	test   %edx,%edx
  803209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80320d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803211:	89 f3                	mov    %esi,%ebx
  803213:	89 3c 24             	mov    %edi,(%esp)
  803216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80321a:	75 1c                	jne    803238 <__umoddi3+0x48>
  80321c:	39 f7                	cmp    %esi,%edi
  80321e:	76 50                	jbe    803270 <__umoddi3+0x80>
  803220:	89 c8                	mov    %ecx,%eax
  803222:	89 f2                	mov    %esi,%edx
  803224:	f7 f7                	div    %edi
  803226:	89 d0                	mov    %edx,%eax
  803228:	31 d2                	xor    %edx,%edx
  80322a:	83 c4 1c             	add    $0x1c,%esp
  80322d:	5b                   	pop    %ebx
  80322e:	5e                   	pop    %esi
  80322f:	5f                   	pop    %edi
  803230:	5d                   	pop    %ebp
  803231:	c3                   	ret    
  803232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803238:	39 f2                	cmp    %esi,%edx
  80323a:	89 d0                	mov    %edx,%eax
  80323c:	77 52                	ja     803290 <__umoddi3+0xa0>
  80323e:	0f bd ea             	bsr    %edx,%ebp
  803241:	83 f5 1f             	xor    $0x1f,%ebp
  803244:	75 5a                	jne    8032a0 <__umoddi3+0xb0>
  803246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80324a:	0f 82 e0 00 00 00    	jb     803330 <__umoddi3+0x140>
  803250:	39 0c 24             	cmp    %ecx,(%esp)
  803253:	0f 86 d7 00 00 00    	jbe    803330 <__umoddi3+0x140>
  803259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80325d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803261:	83 c4 1c             	add    $0x1c,%esp
  803264:	5b                   	pop    %ebx
  803265:	5e                   	pop    %esi
  803266:	5f                   	pop    %edi
  803267:	5d                   	pop    %ebp
  803268:	c3                   	ret    
  803269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803270:	85 ff                	test   %edi,%edi
  803272:	89 fd                	mov    %edi,%ebp
  803274:	75 0b                	jne    803281 <__umoddi3+0x91>
  803276:	b8 01 00 00 00       	mov    $0x1,%eax
  80327b:	31 d2                	xor    %edx,%edx
  80327d:	f7 f7                	div    %edi
  80327f:	89 c5                	mov    %eax,%ebp
  803281:	89 f0                	mov    %esi,%eax
  803283:	31 d2                	xor    %edx,%edx
  803285:	f7 f5                	div    %ebp
  803287:	89 c8                	mov    %ecx,%eax
  803289:	f7 f5                	div    %ebp
  80328b:	89 d0                	mov    %edx,%eax
  80328d:	eb 99                	jmp    803228 <__umoddi3+0x38>
  80328f:	90                   	nop
  803290:	89 c8                	mov    %ecx,%eax
  803292:	89 f2                	mov    %esi,%edx
  803294:	83 c4 1c             	add    $0x1c,%esp
  803297:	5b                   	pop    %ebx
  803298:	5e                   	pop    %esi
  803299:	5f                   	pop    %edi
  80329a:	5d                   	pop    %ebp
  80329b:	c3                   	ret    
  80329c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8032a0:	8b 34 24             	mov    (%esp),%esi
  8032a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8032a8:	89 e9                	mov    %ebp,%ecx
  8032aa:	29 ef                	sub    %ebp,%edi
  8032ac:	d3 e0                	shl    %cl,%eax
  8032ae:	89 f9                	mov    %edi,%ecx
  8032b0:	89 f2                	mov    %esi,%edx
  8032b2:	d3 ea                	shr    %cl,%edx
  8032b4:	89 e9                	mov    %ebp,%ecx
  8032b6:	09 c2                	or     %eax,%edx
  8032b8:	89 d8                	mov    %ebx,%eax
  8032ba:	89 14 24             	mov    %edx,(%esp)
  8032bd:	89 f2                	mov    %esi,%edx
  8032bf:	d3 e2                	shl    %cl,%edx
  8032c1:	89 f9                	mov    %edi,%ecx
  8032c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8032cb:	d3 e8                	shr    %cl,%eax
  8032cd:	89 e9                	mov    %ebp,%ecx
  8032cf:	89 c6                	mov    %eax,%esi
  8032d1:	d3 e3                	shl    %cl,%ebx
  8032d3:	89 f9                	mov    %edi,%ecx
  8032d5:	89 d0                	mov    %edx,%eax
  8032d7:	d3 e8                	shr    %cl,%eax
  8032d9:	89 e9                	mov    %ebp,%ecx
  8032db:	09 d8                	or     %ebx,%eax
  8032dd:	89 d3                	mov    %edx,%ebx
  8032df:	89 f2                	mov    %esi,%edx
  8032e1:	f7 34 24             	divl   (%esp)
  8032e4:	89 d6                	mov    %edx,%esi
  8032e6:	d3 e3                	shl    %cl,%ebx
  8032e8:	f7 64 24 04          	mull   0x4(%esp)
  8032ec:	39 d6                	cmp    %edx,%esi
  8032ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032f2:	89 d1                	mov    %edx,%ecx
  8032f4:	89 c3                	mov    %eax,%ebx
  8032f6:	72 08                	jb     803300 <__umoddi3+0x110>
  8032f8:	75 11                	jne    80330b <__umoddi3+0x11b>
  8032fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8032fe:	73 0b                	jae    80330b <__umoddi3+0x11b>
  803300:	2b 44 24 04          	sub    0x4(%esp),%eax
  803304:	1b 14 24             	sbb    (%esp),%edx
  803307:	89 d1                	mov    %edx,%ecx
  803309:	89 c3                	mov    %eax,%ebx
  80330b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80330f:	29 da                	sub    %ebx,%edx
  803311:	19 ce                	sbb    %ecx,%esi
  803313:	89 f9                	mov    %edi,%ecx
  803315:	89 f0                	mov    %esi,%eax
  803317:	d3 e0                	shl    %cl,%eax
  803319:	89 e9                	mov    %ebp,%ecx
  80331b:	d3 ea                	shr    %cl,%edx
  80331d:	89 e9                	mov    %ebp,%ecx
  80331f:	d3 ee                	shr    %cl,%esi
  803321:	09 d0                	or     %edx,%eax
  803323:	89 f2                	mov    %esi,%edx
  803325:	83 c4 1c             	add    $0x1c,%esp
  803328:	5b                   	pop    %ebx
  803329:	5e                   	pop    %esi
  80332a:	5f                   	pop    %edi
  80332b:	5d                   	pop    %ebp
  80332c:	c3                   	ret    
  80332d:	8d 76 00             	lea    0x0(%esi),%esi
  803330:	29 f9                	sub    %edi,%ecx
  803332:	19 d6                	sbb    %edx,%esi
  803334:	89 74 24 04          	mov    %esi,0x4(%esp)
  803338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80333c:	e9 18 ff ff ff       	jmp    803259 <__umoddi3+0x69>
