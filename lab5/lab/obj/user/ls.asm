
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 42 23 80 00       	push   $0x802342
  80005f:	e8 f0 19 00 00       	call   801a54 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 4a 09 00 00       	call   8009c8 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba a8 23 80 00       	mov    $0x8023a8,%edx
  80008b:	b8 40 23 80 00       	mov    $0x802340,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 4b 23 80 00       	push   $0x80234b
  80009d:	e8 b2 19 00 00       	call   801a54 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 d5 27 80 00       	push   $0x8027d5
  8000b0:	e8 9f 19 00 00       	call   801a54 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 40 23 80 00       	push   $0x802340
  8000cf:	e8 80 19 00 00       	call   801a54 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 a7 23 80 00       	push   $0x8023a7
  8000df:	e8 70 19 00 00       	call   801a54 <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 b1 17 00 00       	call   8018b6 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 50 23 80 00       	push   $0x802350
  800118:	6a 1d                	push   $0x1d
  80011a:	68 5c 23 80 00       	push   $0x80235c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 52 13 00 00       	call   8014b6 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 66 23 80 00       	push   $0x802366
  800178:	6a 22                	push   $0x22
  80017a:	68 5c 23 80 00       	push   $0x80235c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 ac 23 80 00       	push   $0x8023ac
  800192:	6a 24                	push   $0x24
  800194:	68 5c 23 80 00       	push   $0x80235c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 fb 14 00 00       	call   8016bb <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 81 23 80 00       	push   $0x802381
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 5c 23 80 00       	push   $0x80235c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 8d 23 80 00       	push   $0x80238d
  800225:	e8 2a 18 00 00       	call   801a54 <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 a8 0d 00 00       	call   800ff5 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 a9 0d 00 00       	call   801025 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 a8 23 80 00       	push   $0x8023a8
  800296:	68 40 23 80 00       	push   $0x802340
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 f2 0a 00 00       	call   800dc6 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 ff 0f 00 00       	call   801314 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 66 0a 00 00       	call   800d85 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 8f 0a 00 00       	call   800dc6 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 d8 23 80 00       	push   $0x8023d8
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 a7 23 80 00 	movl   $0x8023a7,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 ae 09 00 00       	call   800d48 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 1a 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 53 09 00 00       	call   800d48 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 3b 1c 00 00       	call   8020a0 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 28 1d 00 00       	call   8021d0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004cf:	73 0a                	jae    8004db <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d4:	89 08                	mov    %ecx,(%eax)
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	88 02                	mov    %al,(%edx)
}
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e6:	50                   	push   %eax
  8004e7:	ff 75 10             	pushl  0x10(%ebp)
  8004ea:	ff 75 0c             	pushl  0xc(%ebp)
  8004ed:	ff 75 08             	pushl  0x8(%ebp)
  8004f0:	e8 05 00 00 00       	call   8004fa <vprintfmt>
	va_end(ap);
}
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 2c             	sub    $0x2c,%esp
  800503:	8b 75 08             	mov    0x8(%ebp),%esi
  800506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800509:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050c:	eb 12                	jmp    800520 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050e:	85 c0                	test   %eax,%eax
  800510:	0f 84 42 04 00 00    	je     800958 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	53                   	push   %ebx
  80051a:	50                   	push   %eax
  80051b:	ff d6                	call   *%esi
  80051d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800520:	83 c7 01             	add    $0x1,%edi
  800523:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800527:	83 f8 25             	cmp    $0x25,%eax
  80052a:	75 e2                	jne    80050e <vprintfmt+0x14>
  80052c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800530:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800537:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054a:	eb 07                	jmp    800553 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80054f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8d 47 01             	lea    0x1(%edi),%eax
  800556:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800559:	0f b6 07             	movzbl (%edi),%eax
  80055c:	0f b6 d0             	movzbl %al,%edx
  80055f:	83 e8 23             	sub    $0x23,%eax
  800562:	3c 55                	cmp    $0x55,%al
  800564:	0f 87 d3 03 00 00    	ja     80093d <vprintfmt+0x443>
  80056a:	0f b6 c0             	movzbl %al,%eax
  80056d:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800577:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80057b:	eb d6                	jmp    800553 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800588:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80058f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800592:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800595:	83 f9 09             	cmp    $0x9,%ecx
  800598:	77 3f                	ja     8005d9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80059a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80059d:	eb e9                	jmp    800588 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b3:	eb 2a                	jmp    8005df <vprintfmt+0xe5>
  8005b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bf:	0f 49 d0             	cmovns %eax,%edx
  8005c2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	eb 89                	jmp    800553 <vprintfmt+0x59>
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d4:	e9 7a ff ff ff       	jmp    800553 <vprintfmt+0x59>
  8005d9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e3:	0f 89 6a ff ff ff    	jns    800553 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f6:	e9 58 ff ff ff       	jmp    800553 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800601:	e9 4d ff ff ff       	jmp    800553 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 78 04             	lea    0x4(%eax),%edi
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	ff 30                	pushl  (%eax)
  800612:	ff d6                	call   *%esi
			break;
  800614:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800617:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80061d:	e9 fe fe ff ff       	jmp    800520 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 78 04             	lea    0x4(%eax),%edi
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	99                   	cltd   
  80062b:	31 d0                	xor    %edx,%eax
  80062d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062f:	83 f8 0f             	cmp    $0xf,%eax
  800632:	7f 0b                	jg     80063f <vprintfmt+0x145>
  800634:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80063b:	85 d2                	test   %edx,%edx
  80063d:	75 1b                	jne    80065a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80063f:	50                   	push   %eax
  800640:	68 13 24 80 00       	push   $0x802413
  800645:	53                   	push   %ebx
  800646:	56                   	push   %esi
  800647:	e8 91 fe ff ff       	call   8004dd <printfmt>
  80064c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800655:	e9 c6 fe ff ff       	jmp    800520 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80065a:	52                   	push   %edx
  80065b:	68 d5 27 80 00       	push   $0x8027d5
  800660:	53                   	push   %ebx
  800661:	56                   	push   %esi
  800662:	e8 76 fe ff ff       	call   8004dd <printfmt>
  800667:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800670:	e9 ab fe ff ff       	jmp    800520 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	83 c0 04             	add    $0x4,%eax
  80067b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800683:	85 ff                	test   %edi,%edi
  800685:	b8 0c 24 80 00       	mov    $0x80240c,%eax
  80068a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80068d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800691:	0f 8e 94 00 00 00    	jle    80072b <vprintfmt+0x231>
  800697:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80069b:	0f 84 98 00 00 00    	je     800739 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a7:	57                   	push   %edi
  8006a8:	e8 33 03 00 00       	call   8009e0 <strnlen>
  8006ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b0:	29 c1                	sub    %eax,%ecx
  8006b2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	eb 0f                	jmp    8006d5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ef 01             	sub    $0x1,%edi
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	7f ed                	jg     8006c6 <vprintfmt+0x1cc>
  8006d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	0f 49 c1             	cmovns %ecx,%eax
  8006e9:	29 c1                	sub    %eax,%ecx
  8006eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f4:	89 cb                	mov    %ecx,%ebx
  8006f6:	eb 4d                	jmp    800745 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fc:	74 1b                	je     800719 <vprintfmt+0x21f>
  8006fe:	0f be c0             	movsbl %al,%eax
  800701:	83 e8 20             	sub    $0x20,%eax
  800704:	83 f8 5e             	cmp    $0x5e,%eax
  800707:	76 10                	jbe    800719 <vprintfmt+0x21f>
					putch('?', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	6a 3f                	push   $0x3f
  800711:	ff 55 08             	call   *0x8(%ebp)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 0d                	jmp    800726 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 0c             	pushl  0xc(%ebp)
  80071f:	52                   	push   %edx
  800720:	ff 55 08             	call   *0x8(%ebp)
  800723:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	83 eb 01             	sub    $0x1,%ebx
  800729:	eb 1a                	jmp    800745 <vprintfmt+0x24b>
  80072b:	89 75 08             	mov    %esi,0x8(%ebp)
  80072e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800731:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800734:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800737:	eb 0c                	jmp    800745 <vprintfmt+0x24b>
  800739:	89 75 08             	mov    %esi,0x8(%ebp)
  80073c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80073f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800742:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800745:	83 c7 01             	add    $0x1,%edi
  800748:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074c:	0f be d0             	movsbl %al,%edx
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 23                	je     800776 <vprintfmt+0x27c>
  800753:	85 f6                	test   %esi,%esi
  800755:	78 a1                	js     8006f8 <vprintfmt+0x1fe>
  800757:	83 ee 01             	sub    $0x1,%esi
  80075a:	79 9c                	jns    8006f8 <vprintfmt+0x1fe>
  80075c:	89 df                	mov    %ebx,%edi
  80075e:	8b 75 08             	mov    0x8(%ebp),%esi
  800761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800764:	eb 18                	jmp    80077e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 20                	push   $0x20
  80076c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076e:	83 ef 01             	sub    $0x1,%edi
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 08                	jmp    80077e <vprintfmt+0x284>
  800776:	89 df                	mov    %ebx,%edi
  800778:	8b 75 08             	mov    0x8(%ebp),%esi
  80077b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077e:	85 ff                	test   %edi,%edi
  800780:	7f e4                	jg     800766 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800782:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078b:	e9 90 fd ff ff       	jmp    800520 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800790:	83 f9 01             	cmp    $0x1,%ecx
  800793:	7e 19                	jle    8007ae <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 50 04             	mov    0x4(%eax),%edx
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 40 08             	lea    0x8(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ac:	eb 38                	jmp    8007e6 <vprintfmt+0x2ec>
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1b                	je     8007cd <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	89 c1                	mov    %eax,%ecx
  8007bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 40 04             	lea    0x4(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cb:	eb 19                	jmp    8007e6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ec:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f5:	0f 89 0e 01 00 00    	jns    800909 <vprintfmt+0x40f>
				putch('-', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 2d                	push   $0x2d
  800801:	ff d6                	call   *%esi
				num = -(long long) num;
  800803:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800806:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800809:	f7 da                	neg    %edx
  80080b:	83 d1 00             	adc    $0x0,%ecx
  80080e:	f7 d9                	neg    %ecx
  800810:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
  800818:	e9 ec 00 00 00       	jmp    800909 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081d:	83 f9 01             	cmp    $0x1,%ecx
  800820:	7e 18                	jle    80083a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	8b 48 04             	mov    0x4(%eax),%ecx
  80082a:	8d 40 08             	lea    0x8(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
  800835:	e9 cf 00 00 00       	jmp    800909 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 1a                	je     800858 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800853:	e9 b1 00 00 00       	jmp    800909 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8b 10                	mov    (%eax),%edx
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	8d 40 04             	lea    0x4(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800868:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086d:	e9 97 00 00 00       	jmp    800909 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	6a 58                	push   $0x58
  800878:	ff d6                	call   *%esi
			putch('X', putdat);
  80087a:	83 c4 08             	add    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	6a 58                	push   $0x58
  800880:	ff d6                	call   *%esi
			putch('X', putdat);
  800882:	83 c4 08             	add    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	6a 58                	push   $0x58
  800888:	ff d6                	call   *%esi
			break;
  80088a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800890:	e9 8b fc ff ff       	jmp    800520 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 30                	push   $0x30
  80089b:	ff d6                	call   *%esi
			putch('x', putdat);
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	6a 78                	push   $0x78
  8008a3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8b 10                	mov    (%eax),%edx
  8008aa:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008af:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b2:	8d 40 04             	lea    0x4(%eax),%eax
  8008b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008bd:	eb 4a                	jmp    800909 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008bf:	83 f9 01             	cmp    $0x1,%ecx
  8008c2:	7e 15                	jle    8008d9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8b 10                	mov    (%eax),%edx
  8008c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008cc:	8d 40 08             	lea    0x8(%eax),%eax
  8008cf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8008d7:	eb 30                	jmp    800909 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008d9:	85 c9                	test   %ecx,%ecx
  8008db:	74 17                	je     8008f4 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8b 10                	mov    (%eax),%edx
  8008e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ea:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f2:	eb 15                	jmp    800909 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	8b 10                	mov    (%eax),%edx
  8008f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fe:	8d 40 04             	lea    0x4(%eax),%eax
  800901:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800904:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800909:	83 ec 0c             	sub    $0xc,%esp
  80090c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800910:	57                   	push   %edi
  800911:	ff 75 e0             	pushl  -0x20(%ebp)
  800914:	50                   	push   %eax
  800915:	51                   	push   %ecx
  800916:	52                   	push   %edx
  800917:	89 da                	mov    %ebx,%edx
  800919:	89 f0                	mov    %esi,%eax
  80091b:	e8 f1 fa ff ff       	call   800411 <printnum>
			break;
  800920:	83 c4 20             	add    $0x20,%esp
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800926:	e9 f5 fb ff ff       	jmp    800520 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	52                   	push   %edx
  800930:	ff d6                	call   *%esi
			break;
  800932:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800935:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800938:	e9 e3 fb ff ff       	jmp    800520 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	53                   	push   %ebx
  800941:	6a 25                	push   $0x25
  800943:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	eb 03                	jmp    80094d <vprintfmt+0x453>
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800951:	75 f7                	jne    80094a <vprintfmt+0x450>
  800953:	e9 c8 fb ff ff       	jmp    800520 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800958:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 18             	sub    $0x18,%esp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800973:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800976:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097d:	85 c0                	test   %eax,%eax
  80097f:	74 26                	je     8009a7 <vsnprintf+0x47>
  800981:	85 d2                	test   %edx,%edx
  800983:	7e 22                	jle    8009a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800985:	ff 75 14             	pushl  0x14(%ebp)
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098e:	50                   	push   %eax
  80098f:	68 c0 04 80 00       	push   $0x8004c0
  800994:	e8 61 fb ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800999:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80099c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a2:	83 c4 10             	add    $0x10,%esp
  8009a5:	eb 05                	jmp    8009ac <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b7:	50                   	push   %eax
  8009b8:	ff 75 10             	pushl  0x10(%ebp)
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	ff 75 08             	pushl  0x8(%ebp)
  8009c1:	e8 9a ff ff ff       	call   800960 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d3:	eb 03                	jmp    8009d8 <strlen+0x10>
		n++;
  8009d5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009dc:	75 f7                	jne    8009d5 <strlen+0xd>
		n++;
	return n;
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	eb 03                	jmp    8009f3 <strnlen+0x13>
		n++;
  8009f0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f3:	39 c2                	cmp    %eax,%edx
  8009f5:	74 08                	je     8009ff <strnlen+0x1f>
  8009f7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009fb:	75 f3                	jne    8009f0 <strnlen+0x10>
  8009fd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a17:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a1a:	84 db                	test   %bl,%bl
  800a1c:	75 ef                	jne    800a0d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	53                   	push   %ebx
  800a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a28:	53                   	push   %ebx
  800a29:	e8 9a ff ff ff       	call   8009c8 <strlen>
  800a2e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a31:	ff 75 0c             	pushl  0xc(%ebp)
  800a34:	01 d8                	add    %ebx,%eax
  800a36:	50                   	push   %eax
  800a37:	e8 c5 ff ff ff       	call   800a01 <strcpy>
	return dst;
}
  800a3c:	89 d8                	mov    %ebx,%eax
  800a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a53:	89 f2                	mov    %esi,%edx
  800a55:	eb 0f                	jmp    800a66 <strncpy+0x23>
		*dst++ = *src;
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	0f b6 01             	movzbl (%ecx),%eax
  800a5d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a60:	80 39 01             	cmpb   $0x1,(%ecx)
  800a63:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a66:	39 da                	cmp    %ebx,%edx
  800a68:	75 ed                	jne    800a57 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a6a:	89 f0                	mov    %esi,%eax
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 75 08             	mov    0x8(%ebp),%esi
  800a78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a7e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a80:	85 d2                	test   %edx,%edx
  800a82:	74 21                	je     800aa5 <strlcpy+0x35>
  800a84:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a88:	89 f2                	mov    %esi,%edx
  800a8a:	eb 09                	jmp    800a95 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a8c:	83 c2 01             	add    $0x1,%edx
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a95:	39 c2                	cmp    %eax,%edx
  800a97:	74 09                	je     800aa2 <strlcpy+0x32>
  800a99:	0f b6 19             	movzbl (%ecx),%ebx
  800a9c:	84 db                	test   %bl,%bl
  800a9e:	75 ec                	jne    800a8c <strlcpy+0x1c>
  800aa0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aa2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa5:	29 f0                	sub    %esi,%eax
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab4:	eb 06                	jmp    800abc <strcmp+0x11>
		p++, q++;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800abc:	0f b6 01             	movzbl (%ecx),%eax
  800abf:	84 c0                	test   %al,%al
  800ac1:	74 04                	je     800ac7 <strcmp+0x1c>
  800ac3:	3a 02                	cmp    (%edx),%al
  800ac5:	74 ef                	je     800ab6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac7:	0f b6 c0             	movzbl %al,%eax
  800aca:	0f b6 12             	movzbl (%edx),%edx
  800acd:	29 d0                	sub    %edx,%eax
}
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	53                   	push   %ebx
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae0:	eb 06                	jmp    800ae8 <strncmp+0x17>
		n--, p++, q++;
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae8:	39 d8                	cmp    %ebx,%eax
  800aea:	74 15                	je     800b01 <strncmp+0x30>
  800aec:	0f b6 08             	movzbl (%eax),%ecx
  800aef:	84 c9                	test   %cl,%cl
  800af1:	74 04                	je     800af7 <strncmp+0x26>
  800af3:	3a 0a                	cmp    (%edx),%cl
  800af5:	74 eb                	je     800ae2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af7:	0f b6 00             	movzbl (%eax),%eax
  800afa:	0f b6 12             	movzbl (%edx),%edx
  800afd:	29 d0                	sub    %edx,%eax
  800aff:	eb 05                	jmp    800b06 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b06:	5b                   	pop    %ebx
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b13:	eb 07                	jmp    800b1c <strchr+0x13>
		if (*s == c)
  800b15:	38 ca                	cmp    %cl,%dl
  800b17:	74 0f                	je     800b28 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b19:	83 c0 01             	add    $0x1,%eax
  800b1c:	0f b6 10             	movzbl (%eax),%edx
  800b1f:	84 d2                	test   %dl,%dl
  800b21:	75 f2                	jne    800b15 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b34:	eb 03                	jmp    800b39 <strfind+0xf>
  800b36:	83 c0 01             	add    $0x1,%eax
  800b39:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	74 04                	je     800b44 <strfind+0x1a>
  800b40:	84 d2                	test   %dl,%dl
  800b42:	75 f2                	jne    800b36 <strfind+0xc>
			break;
	return (char *) s;
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b52:	85 c9                	test   %ecx,%ecx
  800b54:	74 36                	je     800b8c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b56:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5c:	75 28                	jne    800b86 <memset+0x40>
  800b5e:	f6 c1 03             	test   $0x3,%cl
  800b61:	75 23                	jne    800b86 <memset+0x40>
		c &= 0xFF;
  800b63:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b67:	89 d3                	mov    %edx,%ebx
  800b69:	c1 e3 08             	shl    $0x8,%ebx
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	c1 e6 18             	shl    $0x18,%esi
  800b71:	89 d0                	mov    %edx,%eax
  800b73:	c1 e0 10             	shl    $0x10,%eax
  800b76:	09 f0                	or     %esi,%eax
  800b78:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b7a:	89 d8                	mov    %ebx,%eax
  800b7c:	09 d0                	or     %edx,%eax
  800b7e:	c1 e9 02             	shr    $0x2,%ecx
  800b81:	fc                   	cld    
  800b82:	f3 ab                	rep stos %eax,%es:(%edi)
  800b84:	eb 06                	jmp    800b8c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b89:	fc                   	cld    
  800b8a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b8c:	89 f8                	mov    %edi,%eax
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba1:	39 c6                	cmp    %eax,%esi
  800ba3:	73 35                	jae    800bda <memmove+0x47>
  800ba5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba8:	39 d0                	cmp    %edx,%eax
  800baa:	73 2e                	jae    800bda <memmove+0x47>
		s += n;
		d += n;
  800bac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	09 fe                	or     %edi,%esi
  800bb3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb9:	75 13                	jne    800bce <memmove+0x3b>
  800bbb:	f6 c1 03             	test   $0x3,%cl
  800bbe:	75 0e                	jne    800bce <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bc0:	83 ef 04             	sub    $0x4,%edi
  800bc3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc6:	c1 e9 02             	shr    $0x2,%ecx
  800bc9:	fd                   	std    
  800bca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcc:	eb 09                	jmp    800bd7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bce:	83 ef 01             	sub    $0x1,%edi
  800bd1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bd4:	fd                   	std    
  800bd5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd7:	fc                   	cld    
  800bd8:	eb 1d                	jmp    800bf7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bda:	89 f2                	mov    %esi,%edx
  800bdc:	09 c2                	or     %eax,%edx
  800bde:	f6 c2 03             	test   $0x3,%dl
  800be1:	75 0f                	jne    800bf2 <memmove+0x5f>
  800be3:	f6 c1 03             	test   $0x3,%cl
  800be6:	75 0a                	jne    800bf2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800be8:	c1 e9 02             	shr    $0x2,%ecx
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	fc                   	cld    
  800bee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf0:	eb 05                	jmp    800bf7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	fc                   	cld    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bfe:	ff 75 10             	pushl  0x10(%ebp)
  800c01:	ff 75 0c             	pushl  0xc(%ebp)
  800c04:	ff 75 08             	pushl  0x8(%ebp)
  800c07:	e8 87 ff ff ff       	call   800b93 <memmove>
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c19:	89 c6                	mov    %eax,%esi
  800c1b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1e:	eb 1a                	jmp    800c3a <memcmp+0x2c>
		if (*s1 != *s2)
  800c20:	0f b6 08             	movzbl (%eax),%ecx
  800c23:	0f b6 1a             	movzbl (%edx),%ebx
  800c26:	38 d9                	cmp    %bl,%cl
  800c28:	74 0a                	je     800c34 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c2a:	0f b6 c1             	movzbl %cl,%eax
  800c2d:	0f b6 db             	movzbl %bl,%ebx
  800c30:	29 d8                	sub    %ebx,%eax
  800c32:	eb 0f                	jmp    800c43 <memcmp+0x35>
		s1++, s2++;
  800c34:	83 c0 01             	add    $0x1,%eax
  800c37:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	39 f0                	cmp    %esi,%eax
  800c3c:	75 e2                	jne    800c20 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	53                   	push   %ebx
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c4e:	89 c1                	mov    %eax,%ecx
  800c50:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c53:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c57:	eb 0a                	jmp    800c63 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c59:	0f b6 10             	movzbl (%eax),%edx
  800c5c:	39 da                	cmp    %ebx,%edx
  800c5e:	74 07                	je     800c67 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c60:	83 c0 01             	add    $0x1,%eax
  800c63:	39 c8                	cmp    %ecx,%eax
  800c65:	72 f2                	jb     800c59 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c67:	5b                   	pop    %ebx
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c76:	eb 03                	jmp    800c7b <strtol+0x11>
		s++;
  800c78:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7b:	0f b6 01             	movzbl (%ecx),%eax
  800c7e:	3c 20                	cmp    $0x20,%al
  800c80:	74 f6                	je     800c78 <strtol+0xe>
  800c82:	3c 09                	cmp    $0x9,%al
  800c84:	74 f2                	je     800c78 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c86:	3c 2b                	cmp    $0x2b,%al
  800c88:	75 0a                	jne    800c94 <strtol+0x2a>
		s++;
  800c8a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c92:	eb 11                	jmp    800ca5 <strtol+0x3b>
  800c94:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c99:	3c 2d                	cmp    $0x2d,%al
  800c9b:	75 08                	jne    800ca5 <strtol+0x3b>
		s++, neg = 1;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cab:	75 15                	jne    800cc2 <strtol+0x58>
  800cad:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb0:	75 10                	jne    800cc2 <strtol+0x58>
  800cb2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cb6:	75 7c                	jne    800d34 <strtol+0xca>
		s += 2, base = 16;
  800cb8:	83 c1 02             	add    $0x2,%ecx
  800cbb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc0:	eb 16                	jmp    800cd8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cc2:	85 db                	test   %ebx,%ebx
  800cc4:	75 12                	jne    800cd8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cce:	75 08                	jne    800cd8 <strtol+0x6e>
		s++, base = 8;
  800cd0:	83 c1 01             	add    $0x1,%ecx
  800cd3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce0:	0f b6 11             	movzbl (%ecx),%edx
  800ce3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ce6:	89 f3                	mov    %esi,%ebx
  800ce8:	80 fb 09             	cmp    $0x9,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0x8b>
			dig = *s - '0';
  800ced:	0f be d2             	movsbl %dl,%edx
  800cf0:	83 ea 30             	sub    $0x30,%edx
  800cf3:	eb 22                	jmp    800d17 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cf5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cf8:	89 f3                	mov    %esi,%ebx
  800cfa:	80 fb 19             	cmp    $0x19,%bl
  800cfd:	77 08                	ja     800d07 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cff:	0f be d2             	movsbl %dl,%edx
  800d02:	83 ea 57             	sub    $0x57,%edx
  800d05:	eb 10                	jmp    800d17 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d07:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d0a:	89 f3                	mov    %esi,%ebx
  800d0c:	80 fb 19             	cmp    $0x19,%bl
  800d0f:	77 16                	ja     800d27 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d11:	0f be d2             	movsbl %dl,%edx
  800d14:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d17:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d1a:	7d 0b                	jge    800d27 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d1c:	83 c1 01             	add    $0x1,%ecx
  800d1f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d23:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d25:	eb b9                	jmp    800ce0 <strtol+0x76>

	if (endptr)
  800d27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d2b:	74 0d                	je     800d3a <strtol+0xd0>
		*endptr = (char *) s;
  800d2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d30:	89 0e                	mov    %ecx,(%esi)
  800d32:	eb 06                	jmp    800d3a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d34:	85 db                	test   %ebx,%ebx
  800d36:	74 98                	je     800cd0 <strtol+0x66>
  800d38:	eb 9e                	jmp    800cd8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	f7 da                	neg    %edx
  800d3e:	85 ff                	test   %edi,%edi
  800d40:	0f 45 c2             	cmovne %edx,%eax
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	89 c7                	mov    %eax,%edi
  800d5d:	89 c6                	mov    %eax,%esi
  800d5f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d93:	b8 03 00 00 00       	mov    $0x3,%eax
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 cb                	mov    %ecx,%ebx
  800d9d:	89 cf                	mov    %ecx,%edi
  800d9f:	89 ce                	mov    %ecx,%esi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 03                	push   $0x3
  800dad:	68 ff 26 80 00       	push   $0x8026ff
  800db2:	6a 23                	push   $0x23
  800db4:	68 1c 27 80 00       	push   $0x80271c
  800db9:	e8 66 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd1:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd6:	89 d1                	mov    %edx,%ecx
  800dd8:	89 d3                	mov    %edx,%ebx
  800dda:	89 d7                	mov    %edx,%edi
  800ddc:	89 d6                	mov    %edx,%esi
  800dde:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_yield>:

void
sys_yield(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0d:	be 00 00 00 00       	mov    $0x0,%esi
  800e12:	b8 04 00 00 00       	mov    $0x4,%eax
  800e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e20:	89 f7                	mov    %esi,%edi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 04                	push   $0x4
  800e2e:	68 ff 26 80 00       	push   $0x8026ff
  800e33:	6a 23                	push   $0x23
  800e35:	68 1c 27 80 00       	push   $0x80271c
  800e3a:	e8 e5 f4 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b8 05 00 00 00       	mov    $0x5,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	8b 75 18             	mov    0x18(%ebp),%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 17                	jle    800e81 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 05                	push   $0x5
  800e70:	68 ff 26 80 00       	push   $0x8026ff
  800e75:	6a 23                	push   $0x23
  800e77:	68 1c 27 80 00       	push   $0x80271c
  800e7c:	e8 a3 f4 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e97:	b8 06 00 00 00       	mov    $0x6,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 df                	mov    %ebx,%edi
  800ea4:	89 de                	mov    %ebx,%esi
  800ea6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	7e 17                	jle    800ec3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	50                   	push   %eax
  800eb0:	6a 06                	push   $0x6
  800eb2:	68 ff 26 80 00       	push   $0x8026ff
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 1c 27 80 00       	push   $0x80271c
  800ebe:	e8 61 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 08 00 00 00       	mov    $0x8,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	89 de                	mov    %ebx,%esi
  800ee8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 17                	jle    800f05 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	50                   	push   %eax
  800ef2:	6a 08                	push   $0x8
  800ef4:	68 ff 26 80 00       	push   $0x8026ff
  800ef9:	6a 23                	push   $0x23
  800efb:	68 1c 27 80 00       	push   $0x80271c
  800f00:	e8 1f f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 17                	jle    800f47 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	50                   	push   %eax
  800f34:	6a 09                	push   $0x9
  800f36:	68 ff 26 80 00       	push   $0x8026ff
  800f3b:	6a 23                	push   $0x23
  800f3d:	68 1c 27 80 00       	push   $0x80271c
  800f42:	e8 dd f3 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	89 df                	mov    %ebx,%edi
  800f6a:	89 de                	mov    %ebx,%esi
  800f6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 17                	jle    800f89 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	50                   	push   %eax
  800f76:	6a 0a                	push   $0xa
  800f78:	68 ff 26 80 00       	push   $0x8026ff
  800f7d:	6a 23                	push   $0x23
  800f7f:	68 1c 27 80 00       	push   $0x80271c
  800f84:	e8 9b f3 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	57                   	push   %edi
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f97:	be 00 00 00 00       	mov    $0x0,%esi
  800f9c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800faa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fad:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fca:	89 cb                	mov    %ecx,%ebx
  800fcc:	89 cf                	mov    %ecx,%edi
  800fce:	89 ce                	mov    %ecx,%esi
  800fd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	7e 17                	jle    800fed <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	6a 0d                	push   $0xd
  800fdc:	68 ff 26 80 00       	push   $0x8026ff
  800fe1:	6a 23                	push   $0x23
  800fe3:	68 1c 27 80 00       	push   $0x80271c
  800fe8:	e8 37 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801001:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801003:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801006:	83 3a 01             	cmpl   $0x1,(%edx)
  801009:	7e 09                	jle    801014 <argstart+0x1f>
  80100b:	ba a8 23 80 00       	mov    $0x8023a8,%edx
  801010:	85 c9                	test   %ecx,%ecx
  801012:	75 05                	jne    801019 <argstart+0x24>
  801014:	ba 00 00 00 00       	mov    $0x0,%edx
  801019:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80101c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <argnext>:

int
argnext(struct Argstate *args)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	53                   	push   %ebx
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80102f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801036:	8b 43 08             	mov    0x8(%ebx),%eax
  801039:	85 c0                	test   %eax,%eax
  80103b:	74 6f                	je     8010ac <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  80103d:	80 38 00             	cmpb   $0x0,(%eax)
  801040:	75 4e                	jne    801090 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801042:	8b 0b                	mov    (%ebx),%ecx
  801044:	83 39 01             	cmpl   $0x1,(%ecx)
  801047:	74 55                	je     80109e <argnext+0x79>
		    || args->argv[1][0] != '-'
  801049:	8b 53 04             	mov    0x4(%ebx),%edx
  80104c:	8b 42 04             	mov    0x4(%edx),%eax
  80104f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801052:	75 4a                	jne    80109e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801054:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801058:	74 44                	je     80109e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80105a:	83 c0 01             	add    $0x1,%eax
  80105d:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	8b 01                	mov    (%ecx),%eax
  801065:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80106c:	50                   	push   %eax
  80106d:	8d 42 08             	lea    0x8(%edx),%eax
  801070:	50                   	push   %eax
  801071:	83 c2 04             	add    $0x4,%edx
  801074:	52                   	push   %edx
  801075:	e8 19 fb ff ff       	call   800b93 <memmove>
		(*args->argc)--;
  80107a:	8b 03                	mov    (%ebx),%eax
  80107c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80107f:	8b 43 08             	mov    0x8(%ebx),%eax
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	80 38 2d             	cmpb   $0x2d,(%eax)
  801088:	75 06                	jne    801090 <argnext+0x6b>
  80108a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80108e:	74 0e                	je     80109e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801090:	8b 53 08             	mov    0x8(%ebx),%edx
  801093:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801096:	83 c2 01             	add    $0x1,%edx
  801099:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80109c:	eb 13                	jmp    8010b1 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80109e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010aa:	eb 05                	jmp    8010b1 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8010ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010c0:	8b 43 08             	mov    0x8(%ebx),%eax
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	74 58                	je     80111f <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8010c7:	80 38 00             	cmpb   $0x0,(%eax)
  8010ca:	74 0c                	je     8010d8 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8010cc:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010cf:	c7 43 08 a8 23 80 00 	movl   $0x8023a8,0x8(%ebx)
  8010d6:	eb 42                	jmp    80111a <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8010d8:	8b 13                	mov    (%ebx),%edx
  8010da:	83 3a 01             	cmpl   $0x1,(%edx)
  8010dd:	7e 2d                	jle    80110c <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8010df:	8b 43 04             	mov    0x4(%ebx),%eax
  8010e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8010e5:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	8b 12                	mov    (%edx),%edx
  8010ed:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010f4:	52                   	push   %edx
  8010f5:	8d 50 08             	lea    0x8(%eax),%edx
  8010f8:	52                   	push   %edx
  8010f9:	83 c0 04             	add    $0x4,%eax
  8010fc:	50                   	push   %eax
  8010fd:	e8 91 fa ff ff       	call   800b93 <memmove>
		(*args->argc)--;
  801102:	8b 03                	mov    (%ebx),%eax
  801104:	83 28 01             	subl   $0x1,(%eax)
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	eb 0e                	jmp    80111a <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80110c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801113:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80111a:	8b 43 0c             	mov    0xc(%ebx),%eax
  80111d:	eb 05                	jmp    801124 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801127:	c9                   	leave  
  801128:	c3                   	ret    

00801129 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801132:	8b 51 0c             	mov    0xc(%ecx),%edx
  801135:	89 d0                	mov    %edx,%eax
  801137:	85 d2                	test   %edx,%edx
  801139:	75 0c                	jne    801147 <argvalue+0x1e>
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	51                   	push   %ecx
  80113f:	e8 72 ff ff ff       	call   8010b6 <argnextvalue>
  801144:	83 c4 10             	add    $0x10,%esp
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	05 00 00 00 30       	add    $0x30000000,%eax
  801154:	c1 e8 0c             	shr    $0xc,%eax
}
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	05 00 00 00 30       	add    $0x30000000,%eax
  801164:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801169:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801176:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	c1 ea 16             	shr    $0x16,%edx
  801180:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801187:	f6 c2 01             	test   $0x1,%dl
  80118a:	74 11                	je     80119d <fd_alloc+0x2d>
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	c1 ea 0c             	shr    $0xc,%edx
  801191:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801198:	f6 c2 01             	test   $0x1,%dl
  80119b:	75 09                	jne    8011a6 <fd_alloc+0x36>
			*fd_store = fd;
  80119d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	eb 17                	jmp    8011bd <fd_alloc+0x4d>
  8011a6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ab:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b0:	75 c9                	jne    80117b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c5:	83 f8 1f             	cmp    $0x1f,%eax
  8011c8:	77 36                	ja     801200 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ca:	c1 e0 0c             	shl    $0xc,%eax
  8011cd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 16             	shr    $0x16,%edx
  8011d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	74 24                	je     801207 <fd_lookup+0x48>
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	c1 ea 0c             	shr    $0xc,%edx
  8011e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ef:	f6 c2 01             	test   $0x1,%dl
  8011f2:	74 1a                	je     80120e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fe:	eb 13                	jmp    801213 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801205:	eb 0c                	jmp    801213 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120c:	eb 05                	jmp    801213 <fd_lookup+0x54>
  80120e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121e:	ba ac 27 80 00       	mov    $0x8027ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801223:	eb 13                	jmp    801238 <dev_lookup+0x23>
  801225:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801228:	39 08                	cmp    %ecx,(%eax)
  80122a:	75 0c                	jne    801238 <dev_lookup+0x23>
			*dev = devtab[i];
  80122c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 2e                	jmp    801266 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801238:	8b 02                	mov    (%edx),%eax
  80123a:	85 c0                	test   %eax,%eax
  80123c:	75 e7                	jne    801225 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80123e:	a1 20 44 80 00       	mov    0x804420,%eax
  801243:	8b 40 48             	mov    0x48(%eax),%eax
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	51                   	push   %ecx
  80124a:	50                   	push   %eax
  80124b:	68 2c 27 80 00       	push   $0x80272c
  801250:	e8 a8 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  801255:	8b 45 0c             	mov    0xc(%ebp),%eax
  801258:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 10             	sub    $0x10,%esp
  801270:	8b 75 08             	mov    0x8(%ebp),%esi
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
  801283:	50                   	push   %eax
  801284:	e8 36 ff ff ff       	call   8011bf <fd_lookup>
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 05                	js     801295 <fd_close+0x2d>
	    || fd != fd2)
  801290:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801293:	74 0c                	je     8012a1 <fd_close+0x39>
		return (must_exist ? r : 0);
  801295:	84 db                	test   %bl,%bl
  801297:	ba 00 00 00 00       	mov    $0x0,%edx
  80129c:	0f 44 c2             	cmove  %edx,%eax
  80129f:	eb 41                	jmp    8012e2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 36                	pushl  (%esi)
  8012aa:	e8 66 ff ff ff       	call   801215 <dev_lookup>
  8012af:	89 c3                	mov    %eax,%ebx
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 1a                	js     8012d2 <fd_close+0x6a>
		if (dev->dev_close)
  8012b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	74 0b                	je     8012d2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	56                   	push   %esi
  8012cb:	ff d0                	call   *%eax
  8012cd:	89 c3                	mov    %eax,%ebx
  8012cf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	56                   	push   %esi
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 ac fb ff ff       	call   800e89 <sys_page_unmap>
	return r;
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	89 d8                	mov    %ebx,%eax
}
  8012e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 c4 fe ff ff       	call   8011bf <fd_lookup>
  8012fb:	83 c4 08             	add    $0x8,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 10                	js     801312 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	6a 01                	push   $0x1
  801307:	ff 75 f4             	pushl  -0xc(%ebp)
  80130a:	e8 59 ff ff ff       	call   801268 <fd_close>
  80130f:	83 c4 10             	add    $0x10,%esp
}
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <close_all>:

void
close_all(void)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	53                   	push   %ebx
  801318:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801320:	83 ec 0c             	sub    $0xc,%esp
  801323:	53                   	push   %ebx
  801324:	e8 c0 ff ff ff       	call   8012e9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801329:	83 c3 01             	add    $0x1,%ebx
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	83 fb 20             	cmp    $0x20,%ebx
  801332:	75 ec                	jne    801320 <close_all+0xc>
		close(i);
}
  801334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801337:	c9                   	leave  
  801338:	c3                   	ret    

00801339 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	57                   	push   %edi
  80133d:	56                   	push   %esi
  80133e:	53                   	push   %ebx
  80133f:	83 ec 2c             	sub    $0x2c,%esp
  801342:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801345:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	ff 75 08             	pushl  0x8(%ebp)
  80134c:	e8 6e fe ff ff       	call   8011bf <fd_lookup>
  801351:	83 c4 08             	add    $0x8,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	0f 88 c1 00 00 00    	js     80141d <dup+0xe4>
		return r;
	close(newfdnum);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	56                   	push   %esi
  801360:	e8 84 ff ff ff       	call   8012e9 <close>

	newfd = INDEX2FD(newfdnum);
  801365:	89 f3                	mov    %esi,%ebx
  801367:	c1 e3 0c             	shl    $0xc,%ebx
  80136a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801370:	83 c4 04             	add    $0x4,%esp
  801373:	ff 75 e4             	pushl  -0x1c(%ebp)
  801376:	e8 de fd ff ff       	call   801159 <fd2data>
  80137b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80137d:	89 1c 24             	mov    %ebx,(%esp)
  801380:	e8 d4 fd ff ff       	call   801159 <fd2data>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138b:	89 f8                	mov    %edi,%eax
  80138d:	c1 e8 16             	shr    $0x16,%eax
  801390:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801397:	a8 01                	test   $0x1,%al
  801399:	74 37                	je     8013d2 <dup+0x99>
  80139b:	89 f8                	mov    %edi,%eax
  80139d:	c1 e8 0c             	shr    $0xc,%eax
  8013a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a7:	f6 c2 01             	test   $0x1,%dl
  8013aa:	74 26                	je     8013d2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013bf:	6a 00                	push   $0x0
  8013c1:	57                   	push   %edi
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 7e fa ff ff       	call   800e47 <sys_page_map>
  8013c9:	89 c7                	mov    %eax,%edi
  8013cb:	83 c4 20             	add    $0x20,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 2e                	js     801400 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d5:	89 d0                	mov    %edx,%eax
  8013d7:	c1 e8 0c             	shr    $0xc,%eax
  8013da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e9:	50                   	push   %eax
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	52                   	push   %edx
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 52 fa ff ff       	call   800e47 <sys_page_map>
  8013f5:	89 c7                	mov    %eax,%edi
  8013f7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fc:	85 ff                	test   %edi,%edi
  8013fe:	79 1d                	jns    80141d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	53                   	push   %ebx
  801404:	6a 00                	push   $0x0
  801406:	e8 7e fa ff ff       	call   800e89 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801411:	6a 00                	push   $0x0
  801413:	e8 71 fa ff ff       	call   800e89 <sys_page_unmap>
	return r;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 f8                	mov    %edi,%eax
}
  80141d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	53                   	push   %ebx
  801429:	83 ec 14             	sub    $0x14,%esp
  80142c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	53                   	push   %ebx
  801434:	e8 86 fd ff ff       	call   8011bf <fd_lookup>
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 6d                	js     8014af <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144c:	ff 30                	pushl  (%eax)
  80144e:	e8 c2 fd ff ff       	call   801215 <dev_lookup>
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 4c                	js     8014a6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145d:	8b 42 08             	mov    0x8(%edx),%eax
  801460:	83 e0 03             	and    $0x3,%eax
  801463:	83 f8 01             	cmp    $0x1,%eax
  801466:	75 21                	jne    801489 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801468:	a1 20 44 80 00       	mov    0x804420,%eax
  80146d:	8b 40 48             	mov    0x48(%eax),%eax
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	53                   	push   %ebx
  801474:	50                   	push   %eax
  801475:	68 70 27 80 00       	push   $0x802770
  80147a:	e8 7e ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801487:	eb 26                	jmp    8014af <read+0x8a>
	}
	if (!dev->dev_read)
  801489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148c:	8b 40 08             	mov    0x8(%eax),%eax
  80148f:	85 c0                	test   %eax,%eax
  801491:	74 17                	je     8014aa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	ff 75 10             	pushl  0x10(%ebp)
  801499:	ff 75 0c             	pushl  0xc(%ebp)
  80149c:	52                   	push   %edx
  80149d:	ff d0                	call   *%eax
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	eb 09                	jmp    8014af <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	eb 05                	jmp    8014af <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014af:	89 d0                	mov    %edx,%eax
  8014b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b4:	c9                   	leave  
  8014b5:	c3                   	ret    

008014b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	57                   	push   %edi
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	eb 21                	jmp    8014ed <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	89 f0                	mov    %esi,%eax
  8014d1:	29 d8                	sub    %ebx,%eax
  8014d3:	50                   	push   %eax
  8014d4:	89 d8                	mov    %ebx,%eax
  8014d6:	03 45 0c             	add    0xc(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	57                   	push   %edi
  8014db:	e8 45 ff ff ff       	call   801425 <read>
		if (m < 0)
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 10                	js     8014f7 <readn+0x41>
			return m;
		if (m == 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	74 0a                	je     8014f5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014eb:	01 c3                	add    %eax,%ebx
  8014ed:	39 f3                	cmp    %esi,%ebx
  8014ef:	72 db                	jb     8014cc <readn+0x16>
  8014f1:	89 d8                	mov    %ebx,%eax
  8014f3:	eb 02                	jmp    8014f7 <readn+0x41>
  8014f5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	5f                   	pop    %edi
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	53                   	push   %ebx
  80150e:	e8 ac fc ff ff       	call   8011bf <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	89 c2                	mov    %eax,%edx
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 68                	js     801584 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	ff 30                	pushl  (%eax)
  801528:	e8 e8 fc ff ff       	call   801215 <dev_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 47                	js     80157b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801534:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801537:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153b:	75 21                	jne    80155e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153d:	a1 20 44 80 00       	mov    0x804420,%eax
  801542:	8b 40 48             	mov    0x48(%eax),%eax
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	53                   	push   %ebx
  801549:	50                   	push   %eax
  80154a:	68 8c 27 80 00       	push   $0x80278c
  80154f:	e8 a9 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155c:	eb 26                	jmp    801584 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	8b 52 0c             	mov    0xc(%edx),%edx
  801564:	85 d2                	test   %edx,%edx
  801566:	74 17                	je     80157f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801568:	83 ec 04             	sub    $0x4,%esp
  80156b:	ff 75 10             	pushl  0x10(%ebp)
  80156e:	ff 75 0c             	pushl  0xc(%ebp)
  801571:	50                   	push   %eax
  801572:	ff d2                	call   *%edx
  801574:	89 c2                	mov    %eax,%edx
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb 09                	jmp    801584 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	eb 05                	jmp    801584 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80157f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801584:	89 d0                	mov    %edx,%eax
  801586:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <seek>:

int
seek(int fdnum, off_t offset)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801591:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	ff 75 08             	pushl  0x8(%ebp)
  801598:	e8 22 fc ff ff       	call   8011bf <fd_lookup>
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 0e                	js     8015b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	53                   	push   %ebx
  8015c3:	e8 f7 fb ff ff       	call   8011bf <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 65                	js     801636 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	ff 30                	pushl  (%eax)
  8015dd:	e8 33 fc ff ff       	call   801215 <dev_lookup>
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 44                	js     80162d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f0:	75 21                	jne    801613 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f2:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015f7:	8b 40 48             	mov    0x48(%eax),%eax
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	53                   	push   %ebx
  8015fe:	50                   	push   %eax
  8015ff:	68 4c 27 80 00       	push   $0x80274c
  801604:	e8 f4 ed ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801611:	eb 23                	jmp    801636 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801613:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801616:	8b 52 18             	mov    0x18(%edx),%edx
  801619:	85 d2                	test   %edx,%edx
  80161b:	74 14                	je     801631 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	50                   	push   %eax
  801624:	ff d2                	call   *%edx
  801626:	89 c2                	mov    %eax,%edx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb 09                	jmp    801636 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	eb 05                	jmp    801636 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801631:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801636:	89 d0                	mov    %edx,%eax
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 14             	sub    $0x14,%esp
  801644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 75 08             	pushl  0x8(%ebp)
  80164e:	e8 6c fb ff ff       	call   8011bf <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	89 c2                	mov    %eax,%edx
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 58                	js     8016b4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	ff 30                	pushl  (%eax)
  801668:	e8 a8 fb ff ff       	call   801215 <dev_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 37                	js     8016ab <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167b:	74 32                	je     8016af <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801680:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801687:	00 00 00 
	stat->st_isdir = 0;
  80168a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801691:	00 00 00 
	stat->st_dev = dev;
  801694:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	53                   	push   %ebx
  80169e:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a1:	ff 50 14             	call   *0x14(%eax)
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	eb 09                	jmp    8016b4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	eb 05                	jmp    8016b4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b4:	89 d0                	mov    %edx,%eax
  8016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	6a 00                	push   $0x0
  8016c5:	ff 75 08             	pushl  0x8(%ebp)
  8016c8:	e8 e9 01 00 00       	call   8018b6 <open>
  8016cd:	89 c3                	mov    %eax,%ebx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 1b                	js     8016f1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	ff 75 0c             	pushl  0xc(%ebp)
  8016dc:	50                   	push   %eax
  8016dd:	e8 5b ff ff ff       	call   80163d <fstat>
  8016e2:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e4:	89 1c 24             	mov    %ebx,(%esp)
  8016e7:	e8 fd fb ff ff       	call   8012e9 <close>
	return r;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	89 f0                	mov    %esi,%eax
}
  8016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	89 c6                	mov    %eax,%esi
  8016ff:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801701:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801708:	75 12                	jne    80171c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	6a 01                	push   $0x1
  80170f:	e8 0b 09 00 00       	call   80201f <ipc_find_env>
  801714:	a3 00 40 80 00       	mov    %eax,0x804000
  801719:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171c:	6a 07                	push   $0x7
  80171e:	68 00 50 80 00       	push   $0x805000
  801723:	56                   	push   %esi
  801724:	ff 35 00 40 80 00    	pushl  0x804000
  80172a:	e8 9c 08 00 00       	call   801fcb <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80172f:	83 c4 0c             	add    $0xc,%esp
  801732:	6a 00                	push   $0x0
  801734:	53                   	push   %ebx
  801735:	6a 00                	push   $0x0
  801737:	e8 0d 08 00 00       	call   801f49 <ipc_recv>
}
  80173c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5d                   	pop    %ebp
  801742:	c3                   	ret    

00801743 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	8b 40 0c             	mov    0xc(%eax),%eax
  80174f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801754:	8b 45 0c             	mov    0xc(%ebp),%eax
  801757:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80175c:	ba 00 00 00 00       	mov    $0x0,%edx
  801761:	b8 02 00 00 00       	mov    $0x2,%eax
  801766:	e8 8d ff ff ff       	call   8016f8 <fsipc>
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	8b 40 0c             	mov    0xc(%eax),%eax
  801779:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	b8 06 00 00 00       	mov    $0x6,%eax
  801788:	e8 6b ff ff ff       	call   8016f8 <fsipc>
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	83 ec 04             	sub    $0x4,%esp
  801796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ae:	e8 45 ff ff ff       	call   8016f8 <fsipc>
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 2c                	js     8017e3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	68 00 50 80 00       	push   $0x805000
  8017bf:	53                   	push   %ebx
  8017c0:	e8 3c f2 ff ff       	call   800a01 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c5:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d0:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017fb:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801801:	8b 52 0c             	mov    0xc(%edx),%edx
  801804:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80180a:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80180f:	50                   	push   %eax
  801810:	ff 75 0c             	pushl  0xc(%ebp)
  801813:	68 08 50 80 00       	push   $0x805008
  801818:	e8 76 f3 ff ff       	call   800b93 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 04 00 00 00       	mov    $0x4,%eax
  801827:	e8 cc fe ff ff       	call   8016f8 <fsipc>
            return r;

    return r;
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	8b 40 0c             	mov    0xc(%eax),%eax
  80183c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801841:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801847:	ba 00 00 00 00       	mov    $0x0,%edx
  80184c:	b8 03 00 00 00       	mov    $0x3,%eax
  801851:	e8 a2 fe ff ff       	call   8016f8 <fsipc>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 51                	js     8018ad <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80185c:	39 c6                	cmp    %eax,%esi
  80185e:	73 19                	jae    801879 <devfile_read+0x4b>
  801860:	68 bc 27 80 00       	push   $0x8027bc
  801865:	68 c3 27 80 00       	push   $0x8027c3
  80186a:	68 82 00 00 00       	push   $0x82
  80186f:	68 d8 27 80 00       	push   $0x8027d8
  801874:	e8 ab ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801879:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80187e:	7e 19                	jle    801899 <devfile_read+0x6b>
  801880:	68 e3 27 80 00       	push   $0x8027e3
  801885:	68 c3 27 80 00       	push   $0x8027c3
  80188a:	68 83 00 00 00       	push   $0x83
  80188f:	68 d8 27 80 00       	push   $0x8027d8
  801894:	e8 8b ea ff ff       	call   800324 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	50                   	push   %eax
  80189d:	68 00 50 80 00       	push   $0x805000
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	e8 e9 f2 ff ff       	call   800b93 <memmove>
	return r;
  8018aa:	83 c4 10             	add    $0x10,%esp
}
  8018ad:	89 d8                	mov    %ebx,%eax
  8018af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 20             	sub    $0x20,%esp
  8018bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c0:	53                   	push   %ebx
  8018c1:	e8 02 f1 ff ff       	call   8009c8 <strlen>
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ce:	7f 67                	jg     801937 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d0:	83 ec 0c             	sub    $0xc,%esp
  8018d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d6:	50                   	push   %eax
  8018d7:	e8 94 f8 ff ff       	call   801170 <fd_alloc>
  8018dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8018df:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 57                	js     80193c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	68 00 50 80 00       	push   $0x805000
  8018ee:	e8 0e f1 ff ff       	call   800a01 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801903:	e8 f0 fd ff ff       	call   8016f8 <fsipc>
  801908:	89 c3                	mov    %eax,%ebx
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	79 14                	jns    801925 <open+0x6f>
		fd_close(fd, 0);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	6a 00                	push   $0x0
  801916:	ff 75 f4             	pushl  -0xc(%ebp)
  801919:	e8 4a f9 ff ff       	call   801268 <fd_close>
		return r;
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	89 da                	mov    %ebx,%edx
  801923:	eb 17                	jmp    80193c <open+0x86>
	}

	return fd2num(fd);
  801925:	83 ec 0c             	sub    $0xc,%esp
  801928:	ff 75 f4             	pushl  -0xc(%ebp)
  80192b:	e8 19 f8 ff ff       	call   801149 <fd2num>
  801930:	89 c2                	mov    %eax,%edx
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	eb 05                	jmp    80193c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801937:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80193c:	89 d0                	mov    %edx,%eax
  80193e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801949:	ba 00 00 00 00       	mov    $0x0,%edx
  80194e:	b8 08 00 00 00       	mov    $0x8,%eax
  801953:	e8 a0 fd ff ff       	call   8016f8 <fsipc>
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80195a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80195e:	7e 37                	jle    801997 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	53                   	push   %ebx
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801969:	ff 70 04             	pushl  0x4(%eax)
  80196c:	8d 40 10             	lea    0x10(%eax),%eax
  80196f:	50                   	push   %eax
  801970:	ff 33                	pushl  (%ebx)
  801972:	e8 88 fb ff ff       	call   8014ff <write>
		if (result > 0)
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	7e 03                	jle    801981 <writebuf+0x27>
			b->result += result;
  80197e:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801981:	3b 43 04             	cmp    0x4(%ebx),%eax
  801984:	74 0d                	je     801993 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801986:	85 c0                	test   %eax,%eax
  801988:	ba 00 00 00 00       	mov    $0x0,%edx
  80198d:	0f 4f c2             	cmovg  %edx,%eax
  801990:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801996:	c9                   	leave  
  801997:	f3 c3                	repz ret 

00801999 <putch>:

static void
putch(int ch, void *thunk)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	53                   	push   %ebx
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019a3:	8b 53 04             	mov    0x4(%ebx),%edx
  8019a6:	8d 42 01             	lea    0x1(%edx),%eax
  8019a9:	89 43 04             	mov    %eax,0x4(%ebx)
  8019ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019af:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019b3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019b8:	75 0e                	jne    8019c8 <putch+0x2f>
		writebuf(b);
  8019ba:	89 d8                	mov    %ebx,%eax
  8019bc:	e8 99 ff ff ff       	call   80195a <writebuf>
		b->idx = 0;
  8019c1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019c8:	83 c4 04             	add    $0x4,%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019e0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019e7:	00 00 00 
	b.result = 0;
  8019ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019f1:	00 00 00 
	b.error = 1;
  8019f4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019fb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019fe:	ff 75 10             	pushl  0x10(%ebp)
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a0a:	50                   	push   %eax
  801a0b:	68 99 19 80 00       	push   $0x801999
  801a10:	e8 e5 ea ff ff       	call   8004fa <vprintfmt>
	if (b.idx > 0)
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a1f:	7e 0b                	jle    801a2c <vfprintf+0x5e>
		writebuf(&b);
  801a21:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a27:	e8 2e ff ff ff       	call   80195a <writebuf>

	return (b.result ? b.result : b.error);
  801a2c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a32:	85 c0                	test   %eax,%eax
  801a34:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a43:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a46:	50                   	push   %eax
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	ff 75 08             	pushl  0x8(%ebp)
  801a4d:	e8 7c ff ff ff       	call   8019ce <vfprintf>
	va_end(ap);

	return cnt;
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <printf>:

int
printf(const char *fmt, ...)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a5a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a5d:	50                   	push   %eax
  801a5e:	ff 75 08             	pushl  0x8(%ebp)
  801a61:	6a 01                	push   $0x1
  801a63:	e8 66 ff ff ff       	call   8019ce <vfprintf>
	va_end(ap);

	return cnt;
}
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	ff 75 08             	pushl  0x8(%ebp)
  801a78:	e8 dc f6 ff ff       	call   801159 <fd2data>
  801a7d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7f:	83 c4 08             	add    $0x8,%esp
  801a82:	68 ef 27 80 00       	push   $0x8027ef
  801a87:	53                   	push   %ebx
  801a88:	e8 74 ef ff ff       	call   800a01 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a8d:	8b 46 04             	mov    0x4(%esi),%eax
  801a90:	2b 06                	sub    (%esi),%eax
  801a92:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a98:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9f:	00 00 00 
	stat->st_dev = &devpipe;
  801aa2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aa9:	30 80 00 
	return 0;
}
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac2:	53                   	push   %ebx
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 bf f3 ff ff       	call   800e89 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aca:	89 1c 24             	mov    %ebx,(%esp)
  801acd:	e8 87 f6 ff ff       	call   801159 <fd2data>
  801ad2:	83 c4 08             	add    $0x8,%esp
  801ad5:	50                   	push   %eax
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 ac f3 ff ff       	call   800e89 <sys_page_unmap>
}
  801add:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 1c             	sub    $0x1c,%esp
  801aeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aee:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af0:	a1 20 44 80 00       	mov    0x804420,%eax
  801af5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 e0             	pushl  -0x20(%ebp)
  801afe:	e8 55 05 00 00       	call   802058 <pageref>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	89 3c 24             	mov    %edi,(%esp)
  801b08:	e8 4b 05 00 00       	call   802058 <pageref>
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	39 c3                	cmp    %eax,%ebx
  801b12:	0f 94 c1             	sete   %cl
  801b15:	0f b6 c9             	movzbl %cl,%ecx
  801b18:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b1b:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b21:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b24:	39 ce                	cmp    %ecx,%esi
  801b26:	74 1b                	je     801b43 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b28:	39 c3                	cmp    %eax,%ebx
  801b2a:	75 c4                	jne    801af0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b2c:	8b 42 58             	mov    0x58(%edx),%eax
  801b2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b32:	50                   	push   %eax
  801b33:	56                   	push   %esi
  801b34:	68 f6 27 80 00       	push   $0x8027f6
  801b39:	e8 bf e8 ff ff       	call   8003fd <cprintf>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	eb ad                	jmp    801af0 <_pipeisclosed+0xe>
	}
}
  801b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5e                   	pop    %esi
  801b4b:	5f                   	pop    %edi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 28             	sub    $0x28,%esp
  801b57:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b5a:	56                   	push   %esi
  801b5b:	e8 f9 f5 ff ff       	call   801159 <fd2data>
  801b60:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	bf 00 00 00 00       	mov    $0x0,%edi
  801b6a:	eb 4b                	jmp    801bb7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b6c:	89 da                	mov    %ebx,%edx
  801b6e:	89 f0                	mov    %esi,%eax
  801b70:	e8 6d ff ff ff       	call   801ae2 <_pipeisclosed>
  801b75:	85 c0                	test   %eax,%eax
  801b77:	75 48                	jne    801bc1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b79:	e8 67 f2 ff ff       	call   800de5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b7e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b81:	8b 0b                	mov    (%ebx),%ecx
  801b83:	8d 51 20             	lea    0x20(%ecx),%edx
  801b86:	39 d0                	cmp    %edx,%eax
  801b88:	73 e2                	jae    801b6c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b91:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b94:	89 c2                	mov    %eax,%edx
  801b96:	c1 fa 1f             	sar    $0x1f,%edx
  801b99:	89 d1                	mov    %edx,%ecx
  801b9b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b9e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba1:	83 e2 1f             	and    $0x1f,%edx
  801ba4:	29 ca                	sub    %ecx,%edx
  801ba6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801baa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bae:	83 c0 01             	add    $0x1,%eax
  801bb1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb4:	83 c7 01             	add    $0x1,%edi
  801bb7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bba:	75 c2                	jne    801b7e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbf:	eb 05                	jmp    801bc6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5f                   	pop    %edi
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 18             	sub    $0x18,%esp
  801bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bda:	57                   	push   %edi
  801bdb:	e8 79 f5 ff ff       	call   801159 <fd2data>
  801be0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bea:	eb 3d                	jmp    801c29 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bec:	85 db                	test   %ebx,%ebx
  801bee:	74 04                	je     801bf4 <devpipe_read+0x26>
				return i;
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	eb 44                	jmp    801c38 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf4:	89 f2                	mov    %esi,%edx
  801bf6:	89 f8                	mov    %edi,%eax
  801bf8:	e8 e5 fe ff ff       	call   801ae2 <_pipeisclosed>
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	75 32                	jne    801c33 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c01:	e8 df f1 ff ff       	call   800de5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c06:	8b 06                	mov    (%esi),%eax
  801c08:	3b 46 04             	cmp    0x4(%esi),%eax
  801c0b:	74 df                	je     801bec <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0d:	99                   	cltd   
  801c0e:	c1 ea 1b             	shr    $0x1b,%edx
  801c11:	01 d0                	add    %edx,%eax
  801c13:	83 e0 1f             	and    $0x1f,%eax
  801c16:	29 d0                	sub    %edx,%eax
  801c18:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c20:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c23:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c26:	83 c3 01             	add    $0x1,%ebx
  801c29:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c2c:	75 d8                	jne    801c06 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c2e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c31:	eb 05                	jmp    801c38 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5f                   	pop    %edi
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4b:	50                   	push   %eax
  801c4c:	e8 1f f5 ff ff       	call   801170 <fd_alloc>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	85 c0                	test   %eax,%eax
  801c58:	0f 88 2c 01 00 00    	js     801d8a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5e:	83 ec 04             	sub    $0x4,%esp
  801c61:	68 07 04 00 00       	push   $0x407
  801c66:	ff 75 f4             	pushl  -0xc(%ebp)
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 94 f1 ff ff       	call   800e04 <sys_page_alloc>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	89 c2                	mov    %eax,%edx
  801c75:	85 c0                	test   %eax,%eax
  801c77:	0f 88 0d 01 00 00    	js     801d8a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c83:	50                   	push   %eax
  801c84:	e8 e7 f4 ff ff       	call   801170 <fd_alloc>
  801c89:	89 c3                	mov    %eax,%ebx
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	0f 88 e2 00 00 00    	js     801d78 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c96:	83 ec 04             	sub    $0x4,%esp
  801c99:	68 07 04 00 00       	push   $0x407
  801c9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca1:	6a 00                	push   $0x0
  801ca3:	e8 5c f1 ff ff       	call   800e04 <sys_page_alloc>
  801ca8:	89 c3                	mov    %eax,%ebx
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	85 c0                	test   %eax,%eax
  801caf:	0f 88 c3 00 00 00    	js     801d78 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb5:	83 ec 0c             	sub    $0xc,%esp
  801cb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbb:	e8 99 f4 ff ff       	call   801159 <fd2data>
  801cc0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc2:	83 c4 0c             	add    $0xc,%esp
  801cc5:	68 07 04 00 00       	push   $0x407
  801cca:	50                   	push   %eax
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 32 f1 ff ff       	call   800e04 <sys_page_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 89 00 00 00    	js     801d68 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce5:	e8 6f f4 ff ff       	call   801159 <fd2data>
  801cea:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf1:	50                   	push   %eax
  801cf2:	6a 00                	push   $0x0
  801cf4:	56                   	push   %esi
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 4b f1 ff ff       	call   800e47 <sys_page_map>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	83 c4 20             	add    $0x20,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 55                	js     801d5a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d23:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	ff 75 f4             	pushl  -0xc(%ebp)
  801d35:	e8 0f f4 ff ff       	call   801149 <fd2num>
  801d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d3f:	83 c4 04             	add    $0x4,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	e8 ff f3 ff ff       	call   801149 <fd2num>
  801d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	ba 00 00 00 00       	mov    $0x0,%edx
  801d58:	eb 30                	jmp    801d8a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d5a:	83 ec 08             	sub    $0x8,%esp
  801d5d:	56                   	push   %esi
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 24 f1 ff ff       	call   800e89 <sys_page_unmap>
  801d65:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d68:	83 ec 08             	sub    $0x8,%esp
  801d6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 14 f1 ff ff       	call   800e89 <sys_page_unmap>
  801d75:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 04 f1 ff ff       	call   800e89 <sys_page_unmap>
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9c:	50                   	push   %eax
  801d9d:	ff 75 08             	pushl  0x8(%ebp)
  801da0:	e8 1a f4 ff ff       	call   8011bf <fd_lookup>
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	85 c0                	test   %eax,%eax
  801daa:	78 18                	js     801dc4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dac:	83 ec 0c             	sub    $0xc,%esp
  801daf:	ff 75 f4             	pushl  -0xc(%ebp)
  801db2:	e8 a2 f3 ff ff       	call   801159 <fd2data>
	return _pipeisclosed(fd, p);
  801db7:	89 c2                	mov    %eax,%edx
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	e8 21 fd ff ff       	call   801ae2 <_pipeisclosed>
  801dc1:	83 c4 10             	add    $0x10,%esp
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd6:	68 0e 28 80 00       	push   $0x80280e
  801ddb:	ff 75 0c             	pushl  0xc(%ebp)
  801dde:	e8 1e ec ff ff       	call   800a01 <strcpy>
	return 0;
}
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	57                   	push   %edi
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e01:	eb 2d                	jmp    801e30 <devcons_write+0x46>
		m = n - tot;
  801e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e06:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e08:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e0b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e10:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e13:	83 ec 04             	sub    $0x4,%esp
  801e16:	53                   	push   %ebx
  801e17:	03 45 0c             	add    0xc(%ebp),%eax
  801e1a:	50                   	push   %eax
  801e1b:	57                   	push   %edi
  801e1c:	e8 72 ed ff ff       	call   800b93 <memmove>
		sys_cputs(buf, m);
  801e21:	83 c4 08             	add    $0x8,%esp
  801e24:	53                   	push   %ebx
  801e25:	57                   	push   %edi
  801e26:	e8 1d ef ff ff       	call   800d48 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2b:	01 de                	add    %ebx,%esi
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e35:	72 cc                	jb     801e03 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	5f                   	pop    %edi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 08             	sub    $0x8,%esp
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e4e:	74 2a                	je     801e7a <devcons_read+0x3b>
  801e50:	eb 05                	jmp    801e57 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e52:	e8 8e ef ff ff       	call   800de5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e57:	e8 0a ef ff ff       	call   800d66 <sys_cgetc>
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	74 f2                	je     801e52 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 16                	js     801e7a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e64:	83 f8 04             	cmp    $0x4,%eax
  801e67:	74 0c                	je     801e75 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6c:	88 02                	mov    %al,(%edx)
	return 1;
  801e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e73:	eb 05                	jmp    801e7a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e88:	6a 01                	push   $0x1
  801e8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8d:	50                   	push   %eax
  801e8e:	e8 b5 ee ff ff       	call   800d48 <sys_cputs>
}
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <getchar>:

int
getchar(void)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e9e:	6a 01                	push   $0x1
  801ea0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	6a 00                	push   $0x0
  801ea6:	e8 7a f5 ff ff       	call   801425 <read>
	if (r < 0)
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 0f                	js     801ec1 <getchar+0x29>
		return r;
	if (r < 1)
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	7e 06                	jle    801ebc <getchar+0x24>
		return -E_EOF;
	return c;
  801eb6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eba:	eb 05                	jmp    801ec1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ebc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	ff 75 08             	pushl  0x8(%ebp)
  801ed0:	e8 ea f2 ff ff       	call   8011bf <fd_lookup>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 11                	js     801eed <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee5:	39 10                	cmp    %edx,(%eax)
  801ee7:	0f 94 c0             	sete   %al
  801eea:	0f b6 c0             	movzbl %al,%eax
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <opencons>:

int
opencons(void)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef8:	50                   	push   %eax
  801ef9:	e8 72 f2 ff ff       	call   801170 <fd_alloc>
  801efe:	83 c4 10             	add    $0x10,%esp
		return r;
  801f01:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 3e                	js     801f45 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f07:	83 ec 04             	sub    $0x4,%esp
  801f0a:	68 07 04 00 00       	push   $0x407
  801f0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f12:	6a 00                	push   $0x0
  801f14:	e8 eb ee ff ff       	call   800e04 <sys_page_alloc>
  801f19:	83 c4 10             	add    $0x10,%esp
		return r;
  801f1c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 23                	js     801f45 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f22:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f30:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f37:	83 ec 0c             	sub    $0xc,%esp
  801f3a:	50                   	push   %eax
  801f3b:	e8 09 f2 ff ff       	call   801149 <fd2num>
  801f40:	89 c2                	mov    %eax,%edx
  801f42:	83 c4 10             	add    $0x10,%esp
}
  801f45:	89 d0                	mov    %edx,%eax
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	57                   	push   %edi
  801f4d:	56                   	push   %esi
  801f4e:	53                   	push   %ebx
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	8b 75 08             	mov    0x8(%ebp),%esi
  801f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801f5b:	85 f6                	test   %esi,%esi
  801f5d:	74 06                	je     801f65 <ipc_recv+0x1c>
		*from_env_store = 0;
  801f5f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801f65:	85 db                	test   %ebx,%ebx
  801f67:	74 06                	je     801f6f <ipc_recv+0x26>
		*perm_store = 0;
  801f69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801f6f:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801f71:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f76:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	50                   	push   %eax
  801f7d:	e8 32 f0 ff ff       	call   800fb4 <sys_ipc_recv>
  801f82:	89 c7                	mov    %eax,%edi
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	79 14                	jns    801f9f <ipc_recv+0x56>
		cprintf("im dead");
  801f8b:	83 ec 0c             	sub    $0xc,%esp
  801f8e:	68 1a 28 80 00       	push   $0x80281a
  801f93:	e8 65 e4 ff ff       	call   8003fd <cprintf>
		return r;
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	89 f8                	mov    %edi,%eax
  801f9d:	eb 24                	jmp    801fc3 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801f9f:	85 f6                	test   %esi,%esi
  801fa1:	74 0a                	je     801fad <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801fa3:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa8:	8b 40 74             	mov    0x74(%eax),%eax
  801fab:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801fad:	85 db                	test   %ebx,%ebx
  801faf:	74 0a                	je     801fbb <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801fb1:	a1 20 44 80 00       	mov    0x804420,%eax
  801fb6:	8b 40 78             	mov    0x78(%eax),%eax
  801fb9:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801fbb:	a1 20 44 80 00       	mov    0x804420,%eax
  801fc0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc6:	5b                   	pop    %ebx
  801fc7:	5e                   	pop    %esi
  801fc8:	5f                   	pop    %edi
  801fc9:	5d                   	pop    %ebp
  801fca:	c3                   	ret    

00801fcb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	57                   	push   %edi
  801fcf:	56                   	push   %esi
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 0c             	sub    $0xc,%esp
  801fd4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801fdd:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fe4:	0f 44 d8             	cmove  %eax,%ebx
  801fe7:	eb 1c                	jmp    802005 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801fe9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fec:	74 12                	je     802000 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801fee:	50                   	push   %eax
  801fef:	68 22 28 80 00       	push   $0x802822
  801ff4:	6a 4e                	push   $0x4e
  801ff6:	68 2f 28 80 00       	push   $0x80282f
  801ffb:	e8 24 e3 ff ff       	call   800324 <_panic>
		sys_yield();
  802000:	e8 e0 ed ff ff       	call   800de5 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802005:	ff 75 14             	pushl  0x14(%ebp)
  802008:	53                   	push   %ebx
  802009:	56                   	push   %esi
  80200a:	57                   	push   %edi
  80200b:	e8 81 ef ff ff       	call   800f91 <sys_ipc_try_send>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	78 d2                	js     801fe9 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  802017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201a:	5b                   	pop    %ebx
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80202a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80202d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802033:	8b 52 50             	mov    0x50(%edx),%edx
  802036:	39 ca                	cmp    %ecx,%edx
  802038:	75 0d                	jne    802047 <ipc_find_env+0x28>
			return envs[i].env_id;
  80203a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80203d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802042:	8b 40 48             	mov    0x48(%eax),%eax
  802045:	eb 0f                	jmp    802056 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802047:	83 c0 01             	add    $0x1,%eax
  80204a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80204f:	75 d9                	jne    80202a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802051:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    

00802058 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205e:	89 d0                	mov    %edx,%eax
  802060:	c1 e8 16             	shr    $0x16,%eax
  802063:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206f:	f6 c1 01             	test   $0x1,%cl
  802072:	74 1d                	je     802091 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802074:	c1 ea 0c             	shr    $0xc,%edx
  802077:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207e:	f6 c2 01             	test   $0x1,%dl
  802081:	74 0e                	je     802091 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802083:	c1 ea 0c             	shr    $0xc,%edx
  802086:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80208d:	ef 
  80208e:	0f b7 c0             	movzwl %ax,%eax
}
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    
  802093:	66 90                	xchg   %ax,%ax
  802095:	66 90                	xchg   %ax,%ax
  802097:	66 90                	xchg   %ax,%ax
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
