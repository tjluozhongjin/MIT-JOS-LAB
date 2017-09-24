
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 1e 0d 00 00       	call   800d65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 d6 13 00 00       	call   80142f <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 73 13 00 00       	call   8013db <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 e0 12 00 00       	call   801359 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 40 24 80 00       	mov    $0x802440,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 4b 24 80 00       	push   $0x80244b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 65 24 80 00       	push   $0x802465
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 00 26 80 00       	push   $0x802600
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 65 24 80 00       	push   $0x802465
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 75 24 80 00       	mov    $0x802475,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 7e 24 80 00       	push   $0x80247e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 65 24 80 00       	push   $0x802465
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 24 26 80 00       	push   $0x802624
  800119:	6a 27                	push   $0x27
  80011b:	68 65 24 80 00       	push   $0x802465
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 96 24 80 00       	push   $0x802496
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 aa 24 80 00       	push   $0x8024aa
  800154:	6a 2b                	push   $0x2b
  800156:	68 65 24 80 00       	push   $0x802465
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 be 0b 00 00       	call   800d2c <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 a8 0b 00 00       	call   800d2c <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 54 26 80 00       	push   $0x802654
  80018f:	6a 2d                	push   $0x2d
  800191:	68 65 24 80 00       	push   $0x802465
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 b8 24 80 00       	push   $0x8024b8
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 ec 0c 00 00       	call   800eaa <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 cb 24 80 00       	push   $0x8024cb
  8001df:	6a 32                	push   $0x32
  8001e1:	68 65 24 80 00       	push   $0x802465
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 0f 0c 00 00       	call   800e0f <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 d9 24 80 00       	push   $0x8024d9
  80020f:	6a 34                	push   $0x34
  800211:	68 65 24 80 00       	push   $0x802465
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 f7 24 80 00       	push   $0x8024f7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 0a 25 80 00       	push   $0x80250a
  800242:	6a 38                	push   $0x38
  800244:	68 65 24 80 00       	push   $0x802465
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 19 25 80 00       	push   $0x802519
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 63 0f 00 00       	call   8011ed <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 7c 26 80 00       	push   $0x80267c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 65 24 80 00       	push   $0x802465
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 2d 25 80 00       	push   $0x80252d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 43 25 80 00       	mov    $0x802543,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 4d 25 80 00       	push   $0x80254d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 65 24 80 00       	push   $0x802465
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 26 0a 00 00       	call   800d2c <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 05 0a 00 00       	call   800d2c <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 66 25 80 00       	push   $0x802566
  800334:	6a 4b                	push   $0x4b
  800336:	68 65 24 80 00       	push   $0x802465
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 75 25 80 00       	push   $0x802575
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 3d 0b 00 00       	call   800eaa <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 b4 26 80 00       	push   $0x8026b4
  800390:	6a 51                	push   $0x51
  800392:	68 65 24 80 00       	push   $0x802465
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 82 09 00 00       	call   800d2c <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 d4 26 80 00       	push   $0x8026d4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 65 24 80 00       	push   $0x802465
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 37 0a 00 00       	call   800e0f <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 0c 27 80 00       	push   $0x80270c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 65 24 80 00       	push   $0x802465
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 3c 27 80 00       	push   $0x80273c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 40 24 80 00       	push   $0x802440
  80040a:	e8 c6 17 00 00       	call   801bd5 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 51 24 80 00       	push   $0x802451
  800426:	6a 5a                	push   $0x5a
  800428:	68 65 24 80 00       	push   $0x802465
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 89 25 80 00       	push   $0x802589
  80043e:	6a 5c                	push   $0x5c
  800440:	68 65 24 80 00       	push   $0x802465
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 75 24 80 00       	push   $0x802475
  800454:	e8 7c 17 00 00       	call   801bd5 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 84 24 80 00       	push   $0x802484
  800466:	6a 5f                	push   $0x5f
  800468:	68 65 24 80 00       	push   $0x802465
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 60 27 80 00       	push   $0x802760
  800498:	6a 62                	push   $0x62
  80049a:	68 65 24 80 00       	push   $0x802465
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 9c 24 80 00       	push   $0x80249c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 a4 25 80 00       	push   $0x8025a4
  8004be:	e8 12 17 00 00       	call   801bd5 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 a9 25 80 00       	push   $0x8025a9
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 65 24 80 00       	push   $0x802465
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 b6 09 00 00       	call   800eaa <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 07 13 00 00       	call   80181e <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 b8 25 80 00       	push   $0x8025b8
  800528:	6a 6c                	push   $0x6c
  80052a:	68 65 24 80 00       	push   $0x802465
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 bc 10 00 00       	call   801608 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 a4 25 80 00       	push   $0x8025a4
  800556:	e8 7a 16 00 00       	call   801bd5 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 ca 25 80 00       	push   $0x8025ca
  80056a:	6a 71                	push   $0x71
  80056c:	68 65 24 80 00       	push   $0x802465
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 3f 12 00 00       	call   8017d5 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 d8 25 80 00       	push   $0x8025d8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 65 24 80 00       	push   $0x802465
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 88 27 80 00       	push   $0x802788
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 65 24 80 00       	push   $0x802465
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 b4 27 80 00       	push   $0x8027b4
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 65 24 80 00       	push   $0x802465
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 f7 0f 00 00       	call   801608 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 e9 25 80 00 	movl   $0x8025e9,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 f2 0a 00 00       	call   80112a <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 ba 0f 00 00       	call   801633 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 66 0a 00 00       	call   8010e9 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 8f 0a 00 00       	call   80112a <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 0c 28 80 00       	push   $0x80280c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 67 2c 80 00 	movl   $0x802c67,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 ae 09 00 00       	call   8010ac <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 1a 01 00 00       	call   80085e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 53 09 00 00       	call   8010ac <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 d7 19 00 00       	call   8021a0 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 c4 1a 00 00       	call   8022d0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 2f 28 80 00 	movsbl 0x80282f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	3b 50 04             	cmp    0x4(%eax),%edx
  800833:	73 0a                	jae    80083f <sprintputch+0x1b>
		*b->buf++ = ch;
  800835:	8d 4a 01             	lea    0x1(%edx),%ecx
  800838:	89 08                	mov    %ecx,(%eax)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	88 02                	mov    %al,(%edx)
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 05 00 00 00       	call   80085e <vprintfmt>
	va_end(ap);
}
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	83 ec 2c             	sub    $0x2c,%esp
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800870:	eb 12                	jmp    800884 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800872:	85 c0                	test   %eax,%eax
  800874:	0f 84 42 04 00 00    	je     800cbc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	50                   	push   %eax
  80087f:	ff d6                	call   *%esi
  800881:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088b:	83 f8 25             	cmp    $0x25,%eax
  80088e:	75 e2                	jne    800872 <vprintfmt+0x14>
  800890:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800894:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80089b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ae:	eb 07                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8d 47 01             	lea    0x1(%edi),%eax
  8008ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008bd:	0f b6 07             	movzbl (%edi),%eax
  8008c0:	0f b6 d0             	movzbl %al,%edx
  8008c3:	83 e8 23             	sub    $0x23,%eax
  8008c6:	3c 55                	cmp    $0x55,%al
  8008c8:	0f 87 d3 03 00 00    	ja     800ca1 <vprintfmt+0x443>
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8008d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008df:	eb d6                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ef:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008f3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008f6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008f9:	83 f9 09             	cmp    $0x9,%ecx
  8008fc:	77 3f                	ja     80093d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800901:	eb e9                	jmp    8008ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 00                	mov    (%eax),%eax
  800908:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 40 04             	lea    0x4(%eax),%eax
  800911:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800917:	eb 2a                	jmp    800943 <vprintfmt+0xe5>
  800919:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091c:	85 c0                	test   %eax,%eax
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	0f 49 d0             	cmovns %eax,%edx
  800926:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092c:	eb 89                	jmp    8008b7 <vprintfmt+0x59>
  80092e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800931:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800938:	e9 7a ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
  80093d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800940:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800943:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800947:	0f 89 6a ff ff ff    	jns    8008b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80094d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800950:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800953:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80095a:	e9 58 ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80095f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800965:	e9 4d ff ff ff       	jmp    8008b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8d 78 04             	lea    0x4(%eax),%edi
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	ff 30                	pushl  (%eax)
  800976:	ff d6                	call   *%esi
			break;
  800978:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80097b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800981:	e9 fe fe ff ff       	jmp    800884 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 78 04             	lea    0x4(%eax),%edi
  80098c:	8b 00                	mov    (%eax),%eax
  80098e:	99                   	cltd   
  80098f:	31 d0                	xor    %edx,%eax
  800991:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800993:	83 f8 0f             	cmp    $0xf,%eax
  800996:	7f 0b                	jg     8009a3 <vprintfmt+0x145>
  800998:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	75 1b                	jne    8009be <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8009a3:	50                   	push   %eax
  8009a4:	68 47 28 80 00       	push   $0x802847
  8009a9:	53                   	push   %ebx
  8009aa:	56                   	push   %esi
  8009ab:	e8 91 fe ff ff       	call   800841 <printfmt>
  8009b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009b9:	e9 c6 fe ff ff       	jmp    800884 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009be:	52                   	push   %edx
  8009bf:	68 35 2c 80 00       	push   $0x802c35
  8009c4:	53                   	push   %ebx
  8009c5:	56                   	push   %esi
  8009c6:	e8 76 fe ff ff       	call   800841 <printfmt>
  8009cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d4:	e9 ab fe ff ff       	jmp    800884 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	83 c0 04             	add    $0x4,%eax
  8009df:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009e7:	85 ff                	test   %edi,%edi
  8009e9:	b8 40 28 80 00       	mov    $0x802840,%eax
  8009ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009f5:	0f 8e 94 00 00 00    	jle    800a8f <vprintfmt+0x231>
  8009fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009ff:	0f 84 98 00 00 00    	je     800a9d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	ff 75 d0             	pushl  -0x30(%ebp)
  800a0b:	57                   	push   %edi
  800a0c:	e8 33 03 00 00       	call   800d44 <strnlen>
  800a11:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a14:	29 c1                	sub    %eax,%ecx
  800a16:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a1c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a23:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a26:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a28:	eb 0f                	jmp    800a39 <vprintfmt+0x1db>
					putch(padc, putdat);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	53                   	push   %ebx
  800a2e:	ff 75 e0             	pushl  -0x20(%ebp)
  800a31:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ef 01             	sub    $0x1,%edi
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	7f ed                	jg     800a2a <vprintfmt+0x1cc>
  800a3d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a40:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	0f 49 c1             	cmovns %ecx,%eax
  800a4d:	29 c1                	sub    %eax,%ecx
  800a4f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a52:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a55:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a58:	89 cb                	mov    %ecx,%ebx
  800a5a:	eb 4d                	jmp    800aa9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a5c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a60:	74 1b                	je     800a7d <vprintfmt+0x21f>
  800a62:	0f be c0             	movsbl %al,%eax
  800a65:	83 e8 20             	sub    $0x20,%eax
  800a68:	83 f8 5e             	cmp    $0x5e,%eax
  800a6b:	76 10                	jbe    800a7d <vprintfmt+0x21f>
					putch('?', putdat);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	6a 3f                	push   $0x3f
  800a75:	ff 55 08             	call   *0x8(%ebp)
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	eb 0d                	jmp    800a8a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	52                   	push   %edx
  800a84:	ff 55 08             	call   *0x8(%ebp)
  800a87:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8a:	83 eb 01             	sub    $0x1,%ebx
  800a8d:	eb 1a                	jmp    800aa9 <vprintfmt+0x24b>
  800a8f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a92:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a9b:	eb 0c                	jmp    800aa9 <vprintfmt+0x24b>
  800a9d:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aa9:	83 c7 01             	add    $0x1,%edi
  800aac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ab0:	0f be d0             	movsbl %al,%edx
  800ab3:	85 d2                	test   %edx,%edx
  800ab5:	74 23                	je     800ada <vprintfmt+0x27c>
  800ab7:	85 f6                	test   %esi,%esi
  800ab9:	78 a1                	js     800a5c <vprintfmt+0x1fe>
  800abb:	83 ee 01             	sub    $0x1,%esi
  800abe:	79 9c                	jns    800a5c <vprintfmt+0x1fe>
  800ac0:	89 df                	mov    %ebx,%edi
  800ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac8:	eb 18                	jmp    800ae2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 20                	push   $0x20
  800ad0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad2:	83 ef 01             	sub    $0x1,%edi
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	eb 08                	jmp    800ae2 <vprintfmt+0x284>
  800ada:	89 df                	mov    %ebx,%edi
  800adc:	8b 75 08             	mov    0x8(%ebp),%esi
  800adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	7f e4                	jg     800aca <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ae6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ae9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aef:	e9 90 fd ff ff       	jmp    800884 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af4:	83 f9 01             	cmp    $0x1,%ecx
  800af7:	7e 19                	jle    800b12 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 50 04             	mov    0x4(%eax),%edx
  800aff:	8b 00                	mov    (%eax),%eax
  800b01:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b04:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b07:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0a:	8d 40 08             	lea    0x8(%eax),%eax
  800b0d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b10:	eb 38                	jmp    800b4a <vprintfmt+0x2ec>
	else if (lflag)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 1b                	je     800b31 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8b 00                	mov    (%eax),%eax
  800b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1e:	89 c1                	mov    %eax,%ecx
  800b20:	c1 f9 1f             	sar    $0x1f,%ecx
  800b23:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b26:	8b 45 14             	mov    0x14(%ebp),%eax
  800b29:	8d 40 04             	lea    0x4(%eax),%eax
  800b2c:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2f:	eb 19                	jmp    800b4a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b31:	8b 45 14             	mov    0x14(%ebp),%eax
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b3e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 40 04             	lea    0x4(%eax),%eax
  800b47:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b4d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b59:	0f 89 0e 01 00 00    	jns    800c6d <vprintfmt+0x40f>
				putch('-', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 2d                	push   $0x2d
  800b65:	ff d6                	call   *%esi
				num = -(long long) num;
  800b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b6d:	f7 da                	neg    %edx
  800b6f:	83 d1 00             	adc    $0x0,%ecx
  800b72:	f7 d9                	neg    %ecx
  800b74:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	e9 ec 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b81:	83 f9 01             	cmp    $0x1,%ecx
  800b84:	7e 18                	jle    800b9e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8b 10                	mov    (%eax),%edx
  800b8b:	8b 48 04             	mov    0x4(%eax),%ecx
  800b8e:	8d 40 08             	lea    0x8(%eax),%eax
  800b91:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b99:	e9 cf 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b9e:	85 c9                	test   %ecx,%ecx
  800ba0:	74 1a                	je     800bbc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800ba2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba5:	8b 10                	mov    (%eax),%edx
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8d 40 04             	lea    0x4(%eax),%eax
  800baf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	e9 b1 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	8d 40 04             	lea    0x4(%eax),%eax
  800bc9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	e9 97 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800bd6:	83 ec 08             	sub    $0x8,%esp
  800bd9:	53                   	push   %ebx
  800bda:	6a 58                	push   $0x58
  800bdc:	ff d6                	call   *%esi
			putch('X', putdat);
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	53                   	push   %ebx
  800be2:	6a 58                	push   $0x58
  800be4:	ff d6                	call   *%esi
			putch('X', putdat);
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	53                   	push   %ebx
  800bea:	6a 58                	push   $0x58
  800bec:	ff d6                	call   *%esi
			break;
  800bee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800bf4:	e9 8b fc ff ff       	jmp    800884 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800bf9:	83 ec 08             	sub    $0x8,%esp
  800bfc:	53                   	push   %ebx
  800bfd:	6a 30                	push   $0x30
  800bff:	ff d6                	call   *%esi
			putch('x', putdat);
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	53                   	push   %ebx
  800c05:	6a 78                	push   $0x78
  800c07:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c09:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0c:	8b 10                	mov    (%eax),%edx
  800c0e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c13:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c16:	8d 40 04             	lea    0x4(%eax),%eax
  800c19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c21:	eb 4a                	jmp    800c6d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c23:	83 f9 01             	cmp    $0x1,%ecx
  800c26:	7e 15                	jle    800c3d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	8b 48 04             	mov    0x4(%eax),%ecx
  800c30:	8d 40 08             	lea    0x8(%eax),%eax
  800c33:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3b:	eb 30                	jmp    800c6d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800c3d:	85 c9                	test   %ecx,%ecx
  800c3f:	74 17                	je     800c58 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800c41:	8b 45 14             	mov    0x14(%ebp),%eax
  800c44:	8b 10                	mov    (%eax),%edx
  800c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4b:	8d 40 04             	lea    0x4(%eax),%eax
  800c4e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c51:	b8 10 00 00 00       	mov    $0x10,%eax
  800c56:	eb 15                	jmp    800c6d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800c58:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5b:	8b 10                	mov    (%eax),%edx
  800c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c62:	8d 40 04             	lea    0x4(%eax),%eax
  800c65:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c68:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c74:	57                   	push   %edi
  800c75:	ff 75 e0             	pushl  -0x20(%ebp)
  800c78:	50                   	push   %eax
  800c79:	51                   	push   %ecx
  800c7a:	52                   	push   %edx
  800c7b:	89 da                	mov    %ebx,%edx
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	e8 f1 fa ff ff       	call   800775 <printnum>
			break;
  800c84:	83 c4 20             	add    $0x20,%esp
  800c87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c8a:	e9 f5 fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	53                   	push   %ebx
  800c93:	52                   	push   %edx
  800c94:	ff d6                	call   *%esi
			break;
  800c96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c9c:	e9 e3 fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	53                   	push   %ebx
  800ca5:	6a 25                	push   $0x25
  800ca7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	eb 03                	jmp    800cb1 <vprintfmt+0x453>
  800cae:	83 ef 01             	sub    $0x1,%edi
  800cb1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800cb5:	75 f7                	jne    800cae <vprintfmt+0x450>
  800cb7:	e9 c8 fb ff ff       	jmp    800884 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 18             	sub    $0x18,%esp
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cd7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 26                	je     800d0b <vsnprintf+0x47>
  800ce5:	85 d2                	test   %edx,%edx
  800ce7:	7e 22                	jle    800d0b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ce9:	ff 75 14             	pushl  0x14(%ebp)
  800cec:	ff 75 10             	pushl  0x10(%ebp)
  800cef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cf2:	50                   	push   %eax
  800cf3:	68 24 08 80 00       	push   $0x800824
  800cf8:	e8 61 fb ff ff       	call   80085e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	eb 05                	jmp    800d10 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d1b:	50                   	push   %eax
  800d1c:	ff 75 10             	pushl  0x10(%ebp)
  800d1f:	ff 75 0c             	pushl  0xc(%ebp)
  800d22:	ff 75 08             	pushl  0x8(%ebp)
  800d25:	e8 9a ff ff ff       	call   800cc4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	eb 03                	jmp    800d3c <strlen+0x10>
		n++;
  800d39:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d3c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d40:	75 f7                	jne    800d39 <strlen+0xd>
		n++;
	return n;
}
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	eb 03                	jmp    800d57 <strnlen+0x13>
		n++;
  800d54:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d57:	39 c2                	cmp    %eax,%edx
  800d59:	74 08                	je     800d63 <strnlen+0x1f>
  800d5b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d5f:	75 f3                	jne    800d54 <strnlen+0x10>
  800d61:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	53                   	push   %ebx
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d7b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d7e:	84 db                	test   %bl,%bl
  800d80:	75 ef                	jne    800d71 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d82:	5b                   	pop    %ebx
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	53                   	push   %ebx
  800d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d8c:	53                   	push   %ebx
  800d8d:	e8 9a ff ff ff       	call   800d2c <strlen>
  800d92:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	01 d8                	add    %ebx,%eax
  800d9a:	50                   	push   %eax
  800d9b:	e8 c5 ff ff ff       	call   800d65 <strcpy>
	return dst;
}
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	8b 75 08             	mov    0x8(%ebp),%esi
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	89 f3                	mov    %esi,%ebx
  800db4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db7:	89 f2                	mov    %esi,%edx
  800db9:	eb 0f                	jmp    800dca <strncpy+0x23>
		*dst++ = *src;
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	0f b6 01             	movzbl (%ecx),%eax
  800dc1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dc4:	80 39 01             	cmpb   $0x1,(%ecx)
  800dc7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dca:	39 da                	cmp    %ebx,%edx
  800dcc:	75 ed                	jne    800dbb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dce:	89 f0                	mov    %esi,%eax
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 10             	mov    0x10(%ebp),%edx
  800de2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800de4:	85 d2                	test   %edx,%edx
  800de6:	74 21                	je     800e09 <strlcpy+0x35>
  800de8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dec:	89 f2                	mov    %esi,%edx
  800dee:	eb 09                	jmp    800df9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800df0:	83 c2 01             	add    $0x1,%edx
  800df3:	83 c1 01             	add    $0x1,%ecx
  800df6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df9:	39 c2                	cmp    %eax,%edx
  800dfb:	74 09                	je     800e06 <strlcpy+0x32>
  800dfd:	0f b6 19             	movzbl (%ecx),%ebx
  800e00:	84 db                	test   %bl,%bl
  800e02:	75 ec                	jne    800df0 <strlcpy+0x1c>
  800e04:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e06:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e09:	29 f0                	sub    %esi,%eax
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e18:	eb 06                	jmp    800e20 <strcmp+0x11>
		p++, q++;
  800e1a:	83 c1 01             	add    $0x1,%ecx
  800e1d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e20:	0f b6 01             	movzbl (%ecx),%eax
  800e23:	84 c0                	test   %al,%al
  800e25:	74 04                	je     800e2b <strcmp+0x1c>
  800e27:	3a 02                	cmp    (%edx),%al
  800e29:	74 ef                	je     800e1a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2b:	0f b6 c0             	movzbl %al,%eax
  800e2e:	0f b6 12             	movzbl (%edx),%edx
  800e31:	29 d0                	sub    %edx,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	53                   	push   %ebx
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	89 c3                	mov    %eax,%ebx
  800e41:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e44:	eb 06                	jmp    800e4c <strncmp+0x17>
		n--, p++, q++;
  800e46:	83 c0 01             	add    $0x1,%eax
  800e49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e4c:	39 d8                	cmp    %ebx,%eax
  800e4e:	74 15                	je     800e65 <strncmp+0x30>
  800e50:	0f b6 08             	movzbl (%eax),%ecx
  800e53:	84 c9                	test   %cl,%cl
  800e55:	74 04                	je     800e5b <strncmp+0x26>
  800e57:	3a 0a                	cmp    (%edx),%cl
  800e59:	74 eb                	je     800e46 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5b:	0f b6 00             	movzbl (%eax),%eax
  800e5e:	0f b6 12             	movzbl (%edx),%edx
  800e61:	29 d0                	sub    %edx,%eax
  800e63:	eb 05                	jmp    800e6a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e77:	eb 07                	jmp    800e80 <strchr+0x13>
		if (*s == c)
  800e79:	38 ca                	cmp    %cl,%dl
  800e7b:	74 0f                	je     800e8c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e7d:	83 c0 01             	add    $0x1,%eax
  800e80:	0f b6 10             	movzbl (%eax),%edx
  800e83:	84 d2                	test   %dl,%dl
  800e85:	75 f2                	jne    800e79 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e98:	eb 03                	jmp    800e9d <strfind+0xf>
  800e9a:	83 c0 01             	add    $0x1,%eax
  800e9d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ea0:	38 ca                	cmp    %cl,%dl
  800ea2:	74 04                	je     800ea8 <strfind+0x1a>
  800ea4:	84 d2                	test   %dl,%dl
  800ea6:	75 f2                	jne    800e9a <strfind+0xc>
			break;
	return (char *) s;
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb6:	85 c9                	test   %ecx,%ecx
  800eb8:	74 36                	je     800ef0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eba:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ec0:	75 28                	jne    800eea <memset+0x40>
  800ec2:	f6 c1 03             	test   $0x3,%cl
  800ec5:	75 23                	jne    800eea <memset+0x40>
		c &= 0xFF;
  800ec7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ecb:	89 d3                	mov    %edx,%ebx
  800ecd:	c1 e3 08             	shl    $0x8,%ebx
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	c1 e6 18             	shl    $0x18,%esi
  800ed5:	89 d0                	mov    %edx,%eax
  800ed7:	c1 e0 10             	shl    $0x10,%eax
  800eda:	09 f0                	or     %esi,%eax
  800edc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	09 d0                	or     %edx,%eax
  800ee2:	c1 e9 02             	shr    $0x2,%ecx
  800ee5:	fc                   	cld    
  800ee6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee8:	eb 06                	jmp    800ef0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	fc                   	cld    
  800eee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f05:	39 c6                	cmp    %eax,%esi
  800f07:	73 35                	jae    800f3e <memmove+0x47>
  800f09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f0c:	39 d0                	cmp    %edx,%eax
  800f0e:	73 2e                	jae    800f3e <memmove+0x47>
		s += n;
		d += n;
  800f10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f13:	89 d6                	mov    %edx,%esi
  800f15:	09 fe                	or     %edi,%esi
  800f17:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1d:	75 13                	jne    800f32 <memmove+0x3b>
  800f1f:	f6 c1 03             	test   $0x3,%cl
  800f22:	75 0e                	jne    800f32 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f24:	83 ef 04             	sub    $0x4,%edi
  800f27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f2a:	c1 e9 02             	shr    $0x2,%ecx
  800f2d:	fd                   	std    
  800f2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f30:	eb 09                	jmp    800f3b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f32:	83 ef 01             	sub    $0x1,%edi
  800f35:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f38:	fd                   	std    
  800f39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f3b:	fc                   	cld    
  800f3c:	eb 1d                	jmp    800f5b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3e:	89 f2                	mov    %esi,%edx
  800f40:	09 c2                	or     %eax,%edx
  800f42:	f6 c2 03             	test   $0x3,%dl
  800f45:	75 0f                	jne    800f56 <memmove+0x5f>
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 0a                	jne    800f56 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f4c:	c1 e9 02             	shr    $0x2,%ecx
  800f4f:	89 c7                	mov    %eax,%edi
  800f51:	fc                   	cld    
  800f52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f54:	eb 05                	jmp    800f5b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	fc                   	cld    
  800f59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f62:	ff 75 10             	pushl  0x10(%ebp)
  800f65:	ff 75 0c             	pushl  0xc(%ebp)
  800f68:	ff 75 08             	pushl  0x8(%ebp)
  800f6b:	e8 87 ff ff ff       	call   800ef7 <memmove>
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	89 c6                	mov    %eax,%esi
  800f7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f82:	eb 1a                	jmp    800f9e <memcmp+0x2c>
		if (*s1 != *s2)
  800f84:	0f b6 08             	movzbl (%eax),%ecx
  800f87:	0f b6 1a             	movzbl (%edx),%ebx
  800f8a:	38 d9                	cmp    %bl,%cl
  800f8c:	74 0a                	je     800f98 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f8e:	0f b6 c1             	movzbl %cl,%eax
  800f91:	0f b6 db             	movzbl %bl,%ebx
  800f94:	29 d8                	sub    %ebx,%eax
  800f96:	eb 0f                	jmp    800fa7 <memcmp+0x35>
		s1++, s2++;
  800f98:	83 c0 01             	add    $0x1,%eax
  800f9b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9e:	39 f0                	cmp    %esi,%eax
  800fa0:	75 e2                	jne    800f84 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800fb7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fbb:	eb 0a                	jmp    800fc7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fbd:	0f b6 10             	movzbl (%eax),%edx
  800fc0:	39 da                	cmp    %ebx,%edx
  800fc2:	74 07                	je     800fcb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fc4:	83 c0 01             	add    $0x1,%eax
  800fc7:	39 c8                	cmp    %ecx,%eax
  800fc9:	72 f2                	jb     800fbd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fda:	eb 03                	jmp    800fdf <strtol+0x11>
		s++;
  800fdc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fdf:	0f b6 01             	movzbl (%ecx),%eax
  800fe2:	3c 20                	cmp    $0x20,%al
  800fe4:	74 f6                	je     800fdc <strtol+0xe>
  800fe6:	3c 09                	cmp    $0x9,%al
  800fe8:	74 f2                	je     800fdc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fea:	3c 2b                	cmp    $0x2b,%al
  800fec:	75 0a                	jne    800ff8 <strtol+0x2a>
		s++;
  800fee:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ff1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff6:	eb 11                	jmp    801009 <strtol+0x3b>
  800ff8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ffd:	3c 2d                	cmp    $0x2d,%al
  800fff:	75 08                	jne    801009 <strtol+0x3b>
		s++, neg = 1;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801009:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80100f:	75 15                	jne    801026 <strtol+0x58>
  801011:	80 39 30             	cmpb   $0x30,(%ecx)
  801014:	75 10                	jne    801026 <strtol+0x58>
  801016:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80101a:	75 7c                	jne    801098 <strtol+0xca>
		s += 2, base = 16;
  80101c:	83 c1 02             	add    $0x2,%ecx
  80101f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801024:	eb 16                	jmp    80103c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801026:	85 db                	test   %ebx,%ebx
  801028:	75 12                	jne    80103c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80102a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80102f:	80 39 30             	cmpb   $0x30,(%ecx)
  801032:	75 08                	jne    80103c <strtol+0x6e>
		s++, base = 8;
  801034:	83 c1 01             	add    $0x1,%ecx
  801037:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801044:	0f b6 11             	movzbl (%ecx),%edx
  801047:	8d 72 d0             	lea    -0x30(%edx),%esi
  80104a:	89 f3                	mov    %esi,%ebx
  80104c:	80 fb 09             	cmp    $0x9,%bl
  80104f:	77 08                	ja     801059 <strtol+0x8b>
			dig = *s - '0';
  801051:	0f be d2             	movsbl %dl,%edx
  801054:	83 ea 30             	sub    $0x30,%edx
  801057:	eb 22                	jmp    80107b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801059:	8d 72 9f             	lea    -0x61(%edx),%esi
  80105c:	89 f3                	mov    %esi,%ebx
  80105e:	80 fb 19             	cmp    $0x19,%bl
  801061:	77 08                	ja     80106b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801063:	0f be d2             	movsbl %dl,%edx
  801066:	83 ea 57             	sub    $0x57,%edx
  801069:	eb 10                	jmp    80107b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80106b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80106e:	89 f3                	mov    %esi,%ebx
  801070:	80 fb 19             	cmp    $0x19,%bl
  801073:	77 16                	ja     80108b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801075:	0f be d2             	movsbl %dl,%edx
  801078:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80107b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80107e:	7d 0b                	jge    80108b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801080:	83 c1 01             	add    $0x1,%ecx
  801083:	0f af 45 10          	imul   0x10(%ebp),%eax
  801087:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801089:	eb b9                	jmp    801044 <strtol+0x76>

	if (endptr)
  80108b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80108f:	74 0d                	je     80109e <strtol+0xd0>
		*endptr = (char *) s;
  801091:	8b 75 0c             	mov    0xc(%ebp),%esi
  801094:	89 0e                	mov    %ecx,(%esi)
  801096:	eb 06                	jmp    80109e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801098:	85 db                	test   %ebx,%ebx
  80109a:	74 98                	je     801034 <strtol+0x66>
  80109c:	eb 9e                	jmp    80103c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	f7 da                	neg    %edx
  8010a2:	85 ff                	test   %edi,%edi
  8010a4:	0f 45 c2             	cmovne %edx,%eax
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	89 c7                	mov    %eax,%edi
  8010c1:	89 c6                	mov    %eax,%esi
  8010c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8010fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ff:	89 cb                	mov    %ecx,%ebx
  801101:	89 cf                	mov    %ecx,%edi
  801103:	89 ce                	mov    %ecx,%esi
  801105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801107:	85 c0                	test   %eax,%eax
  801109:	7e 17                	jle    801122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	50                   	push   %eax
  80110f:	6a 03                	push   $0x3
  801111:	68 3f 2b 80 00       	push   $0x802b3f
  801116:	6a 23                	push   $0x23
  801118:	68 5c 2b 80 00       	push   $0x802b5c
  80111d:	e8 66 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801130:	ba 00 00 00 00       	mov    $0x0,%edx
  801135:	b8 02 00 00 00       	mov    $0x2,%eax
  80113a:	89 d1                	mov    %edx,%ecx
  80113c:	89 d3                	mov    %edx,%ebx
  80113e:	89 d7                	mov    %edx,%edi
  801140:	89 d6                	mov    %edx,%esi
  801142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_yield>:

void
sys_yield(void)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114f:	ba 00 00 00 00       	mov    $0x0,%edx
  801154:	b8 0b 00 00 00       	mov    $0xb,%eax
  801159:	89 d1                	mov    %edx,%ecx
  80115b:	89 d3                	mov    %edx,%ebx
  80115d:	89 d7                	mov    %edx,%edi
  80115f:	89 d6                	mov    %edx,%esi
  801161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801171:	be 00 00 00 00       	mov    $0x0,%esi
  801176:	b8 04 00 00 00       	mov    $0x4,%eax
  80117b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117e:	8b 55 08             	mov    0x8(%ebp),%edx
  801181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801184:	89 f7                	mov    %esi,%edi
  801186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	7e 17                	jle    8011a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	50                   	push   %eax
  801190:	6a 04                	push   $0x4
  801192:	68 3f 2b 80 00       	push   $0x802b3f
  801197:	6a 23                	push   $0x23
  801199:	68 5c 2b 80 00       	push   $0x802b5c
  80119e:	e8 e5 f4 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8011b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8011c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	7e 17                	jle    8011e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	50                   	push   %eax
  8011d2:	6a 05                	push   $0x5
  8011d4:	68 3f 2b 80 00       	push   $0x802b3f
  8011d9:	6a 23                	push   $0x23
  8011db:	68 5c 2b 80 00       	push   $0x802b5c
  8011e0:	e8 a3 f4 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	89 df                	mov    %ebx,%edi
  801208:	89 de                	mov    %ebx,%esi
  80120a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 17                	jle    801227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	83 ec 0c             	sub    $0xc,%esp
  801213:	50                   	push   %eax
  801214:	6a 06                	push   $0x6
  801216:	68 3f 2b 80 00       	push   $0x802b3f
  80121b:	6a 23                	push   $0x23
  80121d:	68 5c 2b 80 00       	push   $0x802b5c
  801222:	e8 61 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5f                   	pop    %edi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123d:	b8 08 00 00 00       	mov    $0x8,%eax
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	8b 55 08             	mov    0x8(%ebp),%edx
  801248:	89 df                	mov    %ebx,%edi
  80124a:	89 de                	mov    %ebx,%esi
  80124c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124e:	85 c0                	test   %eax,%eax
  801250:	7e 17                	jle    801269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	50                   	push   %eax
  801256:	6a 08                	push   $0x8
  801258:	68 3f 2b 80 00       	push   $0x802b3f
  80125d:	6a 23                	push   $0x23
  80125f:	68 5c 2b 80 00       	push   $0x802b5c
  801264:	e8 1f f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127f:	b8 09 00 00 00       	mov    $0x9,%eax
  801284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801287:	8b 55 08             	mov    0x8(%ebp),%edx
  80128a:	89 df                	mov    %ebx,%edi
  80128c:	89 de                	mov    %ebx,%esi
  80128e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801290:	85 c0                	test   %eax,%eax
  801292:	7e 17                	jle    8012ab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801294:	83 ec 0c             	sub    $0xc,%esp
  801297:	50                   	push   %eax
  801298:	6a 09                	push   $0x9
  80129a:	68 3f 2b 80 00       	push   $0x802b3f
  80129f:	6a 23                	push   $0x23
  8012a1:	68 5c 2b 80 00       	push   $0x802b5c
  8012a6:	e8 dd f3 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	57                   	push   %edi
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cc:	89 df                	mov    %ebx,%edi
  8012ce:	89 de                	mov    %ebx,%esi
  8012d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	7e 17                	jle    8012ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	50                   	push   %eax
  8012da:	6a 0a                	push   $0xa
  8012dc:	68 3f 2b 80 00       	push   $0x802b3f
  8012e1:	6a 23                	push   $0x23
  8012e3:	68 5c 2b 80 00       	push   $0x802b5c
  8012e8:	e8 9b f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	57                   	push   %edi
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fb:	be 00 00 00 00       	mov    $0x0,%esi
  801300:	b8 0c 00 00 00       	mov    $0xc,%eax
  801305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801308:	8b 55 08             	mov    0x8(%ebp),%edx
  80130b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801311:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801321:	b9 00 00 00 00       	mov    $0x0,%ecx
  801326:	b8 0d 00 00 00       	mov    $0xd,%eax
  80132b:	8b 55 08             	mov    0x8(%ebp),%edx
  80132e:	89 cb                	mov    %ecx,%ebx
  801330:	89 cf                	mov    %ecx,%edi
  801332:	89 ce                	mov    %ecx,%esi
  801334:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801336:	85 c0                	test   %eax,%eax
  801338:	7e 17                	jle    801351 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	50                   	push   %eax
  80133e:	6a 0d                	push   $0xd
  801340:	68 3f 2b 80 00       	push   $0x802b3f
  801345:	6a 23                	push   $0x23
  801347:	68 5c 2b 80 00       	push   $0x802b5c
  80134c:	e8 37 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	57                   	push   %edi
  80135d:	56                   	push   %esi
  80135e:	53                   	push   %ebx
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	8b 75 08             	mov    0x8(%ebp),%esi
  801365:	8b 45 0c             	mov    0xc(%ebp),%eax
  801368:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  80136b:	85 f6                	test   %esi,%esi
  80136d:	74 06                	je     801375 <ipc_recv+0x1c>
		*from_env_store = 0;
  80136f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801375:	85 db                	test   %ebx,%ebx
  801377:	74 06                	je     80137f <ipc_recv+0x26>
		*perm_store = 0;
  801379:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  80137f:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801381:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801386:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	50                   	push   %eax
  80138d:	e8 86 ff ff ff       	call   801318 <sys_ipc_recv>
  801392:	89 c7                	mov    %eax,%edi
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	79 14                	jns    8013af <ipc_recv+0x56>
		cprintf("im dead");
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	68 6a 2b 80 00       	push   $0x802b6a
  8013a3:	e8 b9 f3 ff ff       	call   800761 <cprintf>
		return r;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	89 f8                	mov    %edi,%eax
  8013ad:	eb 24                	jmp    8013d3 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  8013af:	85 f6                	test   %esi,%esi
  8013b1:	74 0a                	je     8013bd <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  8013b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b8:	8b 40 74             	mov    0x74(%eax),%eax
  8013bb:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  8013bd:	85 db                	test   %ebx,%ebx
  8013bf:	74 0a                	je     8013cb <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  8013c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c6:	8b 40 78             	mov    0x78(%eax),%eax
  8013c9:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  8013cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	57                   	push   %edi
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  8013ed:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  8013ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013f4:	0f 44 d8             	cmove  %eax,%ebx
  8013f7:	eb 1c                	jmp    801415 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8013f9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013fc:	74 12                	je     801410 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  8013fe:	50                   	push   %eax
  8013ff:	68 72 2b 80 00       	push   $0x802b72
  801404:	6a 4e                	push   $0x4e
  801406:	68 7f 2b 80 00       	push   $0x802b7f
  80140b:	e8 78 f2 ff ff       	call   800688 <_panic>
		sys_yield();
  801410:	e8 34 fd ff ff       	call   801149 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801415:	ff 75 14             	pushl  0x14(%ebp)
  801418:	53                   	push   %ebx
  801419:	56                   	push   %esi
  80141a:	57                   	push   %edi
  80141b:	e8 d5 fe ff ff       	call   8012f5 <sys_ipc_try_send>
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 d2                	js     8013f9 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80143a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80143d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801443:	8b 52 50             	mov    0x50(%edx),%edx
  801446:	39 ca                	cmp    %ecx,%edx
  801448:	75 0d                	jne    801457 <ipc_find_env+0x28>
			return envs[i].env_id;
  80144a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80144d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	eb 0f                	jmp    801466 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801457:	83 c0 01             	add    $0x1,%eax
  80145a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80145f:	75 d9                	jne    80143a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801461:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	05 00 00 00 30       	add    $0x30000000,%eax
  801473:	c1 e8 0c             	shr    $0xc,%eax
}
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	05 00 00 00 30       	add    $0x30000000,%eax
  801483:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801488:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    

0080148f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801495:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	c1 ea 16             	shr    $0x16,%edx
  80149f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a6:	f6 c2 01             	test   $0x1,%dl
  8014a9:	74 11                	je     8014bc <fd_alloc+0x2d>
  8014ab:	89 c2                	mov    %eax,%edx
  8014ad:	c1 ea 0c             	shr    $0xc,%edx
  8014b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b7:	f6 c2 01             	test   $0x1,%dl
  8014ba:	75 09                	jne    8014c5 <fd_alloc+0x36>
			*fd_store = fd;
  8014bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014be:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c3:	eb 17                	jmp    8014dc <fd_alloc+0x4d>
  8014c5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014ca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014cf:	75 c9                	jne    80149a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014d7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e4:	83 f8 1f             	cmp    $0x1f,%eax
  8014e7:	77 36                	ja     80151f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e9:	c1 e0 0c             	shl    $0xc,%eax
  8014ec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	c1 ea 16             	shr    $0x16,%edx
  8014f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fd:	f6 c2 01             	test   $0x1,%dl
  801500:	74 24                	je     801526 <fd_lookup+0x48>
  801502:	89 c2                	mov    %eax,%edx
  801504:	c1 ea 0c             	shr    $0xc,%edx
  801507:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150e:	f6 c2 01             	test   $0x1,%dl
  801511:	74 1a                	je     80152d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801513:	8b 55 0c             	mov    0xc(%ebp),%edx
  801516:	89 02                	mov    %eax,(%edx)
	return 0;
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	eb 13                	jmp    801532 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801524:	eb 0c                	jmp    801532 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb 05                	jmp    801532 <fd_lookup+0x54>
  80152d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153d:	ba 0c 2c 80 00       	mov    $0x802c0c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801542:	eb 13                	jmp    801557 <dev_lookup+0x23>
  801544:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801547:	39 08                	cmp    %ecx,(%eax)
  801549:	75 0c                	jne    801557 <dev_lookup+0x23>
			*dev = devtab[i];
  80154b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	eb 2e                	jmp    801585 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801557:	8b 02                	mov    (%edx),%eax
  801559:	85 c0                	test   %eax,%eax
  80155b:	75 e7                	jne    801544 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80155d:	a1 04 40 80 00       	mov    0x804004,%eax
  801562:	8b 40 48             	mov    0x48(%eax),%eax
  801565:	83 ec 04             	sub    $0x4,%esp
  801568:	51                   	push   %ecx
  801569:	50                   	push   %eax
  80156a:	68 8c 2b 80 00       	push   $0x802b8c
  80156f:	e8 ed f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  801574:	8b 45 0c             	mov    0xc(%ebp),%eax
  801577:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	83 ec 10             	sub    $0x10,%esp
  80158f:	8b 75 08             	mov    0x8(%ebp),%esi
  801592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801595:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80159f:	c1 e8 0c             	shr    $0xc,%eax
  8015a2:	50                   	push   %eax
  8015a3:	e8 36 ff ff ff       	call   8014de <fd_lookup>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 05                	js     8015b4 <fd_close+0x2d>
	    || fd != fd2)
  8015af:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015b2:	74 0c                	je     8015c0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015b4:	84 db                	test   %bl,%bl
  8015b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bb:	0f 44 c2             	cmove  %edx,%eax
  8015be:	eb 41                	jmp    801601 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	ff 36                	pushl  (%esi)
  8015c9:	e8 66 ff ff ff       	call   801534 <dev_lookup>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 1a                	js     8015f1 <fd_close+0x6a>
		if (dev->dev_close)
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	74 0b                	je     8015f1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	56                   	push   %esi
  8015ea:	ff d0                	call   *%eax
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	56                   	push   %esi
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 f1 fb ff ff       	call   8011ed <sys_page_unmap>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 d8                	mov    %ebx,%eax
}
  801601:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	ff 75 08             	pushl  0x8(%ebp)
  801615:	e8 c4 fe ff ff       	call   8014de <fd_lookup>
  80161a:	83 c4 08             	add    $0x8,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 10                	js     801631 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	6a 01                	push   $0x1
  801626:	ff 75 f4             	pushl  -0xc(%ebp)
  801629:	e8 59 ff ff ff       	call   801587 <fd_close>
  80162e:	83 c4 10             	add    $0x10,%esp
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <close_all>:

void
close_all(void)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	53                   	push   %ebx
  801643:	e8 c0 ff ff ff       	call   801608 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801648:	83 c3 01             	add    $0x1,%ebx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	83 fb 20             	cmp    $0x20,%ebx
  801651:	75 ec                	jne    80163f <close_all+0xc>
		close(i);
}
  801653:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 2c             	sub    $0x2c,%esp
  801661:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801664:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	ff 75 08             	pushl  0x8(%ebp)
  80166b:	e8 6e fe ff ff       	call   8014de <fd_lookup>
  801670:	83 c4 08             	add    $0x8,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	0f 88 c1 00 00 00    	js     80173c <dup+0xe4>
		return r;
	close(newfdnum);
  80167b:	83 ec 0c             	sub    $0xc,%esp
  80167e:	56                   	push   %esi
  80167f:	e8 84 ff ff ff       	call   801608 <close>

	newfd = INDEX2FD(newfdnum);
  801684:	89 f3                	mov    %esi,%ebx
  801686:	c1 e3 0c             	shl    $0xc,%ebx
  801689:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80168f:	83 c4 04             	add    $0x4,%esp
  801692:	ff 75 e4             	pushl  -0x1c(%ebp)
  801695:	e8 de fd ff ff       	call   801478 <fd2data>
  80169a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80169c:	89 1c 24             	mov    %ebx,(%esp)
  80169f:	e8 d4 fd ff ff       	call   801478 <fd2data>
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016aa:	89 f8                	mov    %edi,%eax
  8016ac:	c1 e8 16             	shr    $0x16,%eax
  8016af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b6:	a8 01                	test   $0x1,%al
  8016b8:	74 37                	je     8016f1 <dup+0x99>
  8016ba:	89 f8                	mov    %edi,%eax
  8016bc:	c1 e8 0c             	shr    $0xc,%eax
  8016bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c6:	f6 c2 01             	test   $0x1,%dl
  8016c9:	74 26                	je     8016f1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8016da:	50                   	push   %eax
  8016db:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016de:	6a 00                	push   $0x0
  8016e0:	57                   	push   %edi
  8016e1:	6a 00                	push   $0x0
  8016e3:	e8 c3 fa ff ff       	call   8011ab <sys_page_map>
  8016e8:	89 c7                	mov    %eax,%edi
  8016ea:	83 c4 20             	add    $0x20,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 2e                	js     80171f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f4:	89 d0                	mov    %edx,%eax
  8016f6:	c1 e8 0c             	shr    $0xc,%eax
  8016f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801700:	83 ec 0c             	sub    $0xc,%esp
  801703:	25 07 0e 00 00       	and    $0xe07,%eax
  801708:	50                   	push   %eax
  801709:	53                   	push   %ebx
  80170a:	6a 00                	push   $0x0
  80170c:	52                   	push   %edx
  80170d:	6a 00                	push   $0x0
  80170f:	e8 97 fa ff ff       	call   8011ab <sys_page_map>
  801714:	89 c7                	mov    %eax,%edi
  801716:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801719:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171b:	85 ff                	test   %edi,%edi
  80171d:	79 1d                	jns    80173c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	53                   	push   %ebx
  801723:	6a 00                	push   $0x0
  801725:	e8 c3 fa ff ff       	call   8011ed <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172a:	83 c4 08             	add    $0x8,%esp
  80172d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801730:	6a 00                	push   $0x0
  801732:	e8 b6 fa ff ff       	call   8011ed <sys_page_unmap>
	return r;
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	89 f8                	mov    %edi,%eax
}
  80173c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5f                   	pop    %edi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 14             	sub    $0x14,%esp
  80174b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	53                   	push   %ebx
  801753:	e8 86 fd ff ff       	call   8014de <fd_lookup>
  801758:	83 c4 08             	add    $0x8,%esp
  80175b:	89 c2                	mov    %eax,%edx
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 6d                	js     8017ce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801767:	50                   	push   %eax
  801768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176b:	ff 30                	pushl  (%eax)
  80176d:	e8 c2 fd ff ff       	call   801534 <dev_lookup>
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	85 c0                	test   %eax,%eax
  801777:	78 4c                	js     8017c5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801779:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177c:	8b 42 08             	mov    0x8(%edx),%eax
  80177f:	83 e0 03             	and    $0x3,%eax
  801782:	83 f8 01             	cmp    $0x1,%eax
  801785:	75 21                	jne    8017a8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801787:	a1 04 40 80 00       	mov    0x804004,%eax
  80178c:	8b 40 48             	mov    0x48(%eax),%eax
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	53                   	push   %ebx
  801793:	50                   	push   %eax
  801794:	68 d0 2b 80 00       	push   $0x802bd0
  801799:	e8 c3 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a6:	eb 26                	jmp    8017ce <read+0x8a>
	}
	if (!dev->dev_read)
  8017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ab:	8b 40 08             	mov    0x8(%eax),%eax
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	74 17                	je     8017c9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	ff 75 10             	pushl  0x10(%ebp)
  8017b8:	ff 75 0c             	pushl  0xc(%ebp)
  8017bb:	52                   	push   %edx
  8017bc:	ff d0                	call   *%eax
  8017be:	89 c2                	mov    %eax,%edx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	eb 09                	jmp    8017ce <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	eb 05                	jmp    8017ce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017ce:	89 d0                	mov    %edx,%eax
  8017d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	57                   	push   %edi
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	83 ec 0c             	sub    $0xc,%esp
  8017de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e9:	eb 21                	jmp    80180c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	89 f0                	mov    %esi,%eax
  8017f0:	29 d8                	sub    %ebx,%eax
  8017f2:	50                   	push   %eax
  8017f3:	89 d8                	mov    %ebx,%eax
  8017f5:	03 45 0c             	add    0xc(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	57                   	push   %edi
  8017fa:	e8 45 ff ff ff       	call   801744 <read>
		if (m < 0)
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	85 c0                	test   %eax,%eax
  801804:	78 10                	js     801816 <readn+0x41>
			return m;
		if (m == 0)
  801806:	85 c0                	test   %eax,%eax
  801808:	74 0a                	je     801814 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180a:	01 c3                	add    %eax,%ebx
  80180c:	39 f3                	cmp    %esi,%ebx
  80180e:	72 db                	jb     8017eb <readn+0x16>
  801810:	89 d8                	mov    %ebx,%eax
  801812:	eb 02                	jmp    801816 <readn+0x41>
  801814:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5f                   	pop    %edi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	53                   	push   %ebx
  801822:	83 ec 14             	sub    $0x14,%esp
  801825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801828:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	53                   	push   %ebx
  80182d:	e8 ac fc ff ff       	call   8014de <fd_lookup>
  801832:	83 c4 08             	add    $0x8,%esp
  801835:	89 c2                	mov    %eax,%edx
  801837:	85 c0                	test   %eax,%eax
  801839:	78 68                	js     8018a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801841:	50                   	push   %eax
  801842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801845:	ff 30                	pushl  (%eax)
  801847:	e8 e8 fc ff ff       	call   801534 <dev_lookup>
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 47                	js     80189a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801856:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185a:	75 21                	jne    80187d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80185c:	a1 04 40 80 00       	mov    0x804004,%eax
  801861:	8b 40 48             	mov    0x48(%eax),%eax
  801864:	83 ec 04             	sub    $0x4,%esp
  801867:	53                   	push   %ebx
  801868:	50                   	push   %eax
  801869:	68 ec 2b 80 00       	push   $0x802bec
  80186e:	e8 ee ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80187b:	eb 26                	jmp    8018a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	8b 52 0c             	mov    0xc(%edx),%edx
  801883:	85 d2                	test   %edx,%edx
  801885:	74 17                	je     80189e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801887:	83 ec 04             	sub    $0x4,%esp
  80188a:	ff 75 10             	pushl  0x10(%ebp)
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	50                   	push   %eax
  801891:	ff d2                	call   *%edx
  801893:	89 c2                	mov    %eax,%edx
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	eb 09                	jmp    8018a3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189a:	89 c2                	mov    %eax,%edx
  80189c:	eb 05                	jmp    8018a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80189e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018a3:	89 d0                	mov    %edx,%eax
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018b3:	50                   	push   %eax
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	e8 22 fc ff ff       	call   8014de <fd_lookup>
  8018bc:	83 c4 08             	add    $0x8,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 0e                	js     8018d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 14             	sub    $0x14,%esp
  8018da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e0:	50                   	push   %eax
  8018e1:	53                   	push   %ebx
  8018e2:	e8 f7 fb ff ff       	call   8014de <fd_lookup>
  8018e7:	83 c4 08             	add    $0x8,%esp
  8018ea:	89 c2                	mov    %eax,%edx
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 65                	js     801955 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f6:	50                   	push   %eax
  8018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fa:	ff 30                	pushl  (%eax)
  8018fc:	e8 33 fc ff ff       	call   801534 <dev_lookup>
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 44                	js     80194c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80190f:	75 21                	jne    801932 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801911:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801916:	8b 40 48             	mov    0x48(%eax),%eax
  801919:	83 ec 04             	sub    $0x4,%esp
  80191c:	53                   	push   %ebx
  80191d:	50                   	push   %eax
  80191e:	68 ac 2b 80 00       	push   $0x802bac
  801923:	e8 39 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801930:	eb 23                	jmp    801955 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801932:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801935:	8b 52 18             	mov    0x18(%edx),%edx
  801938:	85 d2                	test   %edx,%edx
  80193a:	74 14                	je     801950 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	50                   	push   %eax
  801943:	ff d2                	call   *%edx
  801945:	89 c2                	mov    %eax,%edx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	eb 09                	jmp    801955 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194c:	89 c2                	mov    %eax,%edx
  80194e:	eb 05                	jmp    801955 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801950:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801955:	89 d0                	mov    %edx,%eax
  801957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 14             	sub    $0x14,%esp
  801963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801969:	50                   	push   %eax
  80196a:	ff 75 08             	pushl  0x8(%ebp)
  80196d:	e8 6c fb ff ff       	call   8014de <fd_lookup>
  801972:	83 c4 08             	add    $0x8,%esp
  801975:	89 c2                	mov    %eax,%edx
  801977:	85 c0                	test   %eax,%eax
  801979:	78 58                	js     8019d3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	ff 30                	pushl  (%eax)
  801987:	e8 a8 fb ff ff       	call   801534 <dev_lookup>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 37                	js     8019ca <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80199a:	74 32                	je     8019ce <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80199c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80199f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019a6:	00 00 00 
	stat->st_isdir = 0;
  8019a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b0:	00 00 00 
	stat->st_dev = dev;
  8019b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c0:	ff 50 14             	call   *0x14(%eax)
  8019c3:	89 c2                	mov    %eax,%edx
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	eb 09                	jmp    8019d3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ca:	89 c2                	mov    %eax,%edx
  8019cc:	eb 05                	jmp    8019d3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019d3:	89 d0                	mov    %edx,%eax
  8019d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	56                   	push   %esi
  8019de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019df:	83 ec 08             	sub    $0x8,%esp
  8019e2:	6a 00                	push   $0x0
  8019e4:	ff 75 08             	pushl  0x8(%ebp)
  8019e7:	e8 e9 01 00 00       	call   801bd5 <open>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 1b                	js     801a10 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	ff 75 0c             	pushl  0xc(%ebp)
  8019fb:	50                   	push   %eax
  8019fc:	e8 5b ff ff ff       	call   80195c <fstat>
  801a01:	89 c6                	mov    %eax,%esi
	close(fd);
  801a03:	89 1c 24             	mov    %ebx,(%esp)
  801a06:	e8 fd fb ff ff       	call   801608 <close>
	return r;
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	89 f0                	mov    %esi,%eax
}
  801a10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	89 c6                	mov    %eax,%esi
  801a1e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a20:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a27:	75 12                	jne    801a3b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	6a 01                	push   $0x1
  801a2e:	e8 fc f9 ff ff       	call   80142f <ipc_find_env>
  801a33:	a3 00 40 80 00       	mov    %eax,0x804000
  801a38:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a3b:	6a 07                	push   $0x7
  801a3d:	68 00 50 80 00       	push   $0x805000
  801a42:	56                   	push   %esi
  801a43:	ff 35 00 40 80 00    	pushl  0x804000
  801a49:	e8 8d f9 ff ff       	call   8013db <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801a4e:	83 c4 0c             	add    $0xc,%esp
  801a51:	6a 00                	push   $0x0
  801a53:	53                   	push   %ebx
  801a54:	6a 00                	push   $0x0
  801a56:	e8 fe f8 ff ff       	call   801359 <ipc_recv>
}
  801a5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a76:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	b8 02 00 00 00       	mov    $0x2,%eax
  801a85:	e8 8d ff ff ff       	call   801a17 <fsipc>
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	8b 40 0c             	mov    0xc(%eax),%eax
  801a98:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa2:	b8 06 00 00 00       	mov    $0x6,%eax
  801aa7:	e8 6b ff ff ff       	call   801a17 <fsipc>
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	8b 40 0c             	mov    0xc(%eax),%eax
  801abe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac8:	b8 05 00 00 00       	mov    $0x5,%eax
  801acd:	e8 45 ff ff ff       	call   801a17 <fsipc>
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 2c                	js     801b02 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ad6:	83 ec 08             	sub    $0x8,%esp
  801ad9:	68 00 50 80 00       	push   $0x805000
  801ade:	53                   	push   %ebx
  801adf:	e8 81 f2 ff ff       	call   800d65 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ae4:	a1 80 50 80 00       	mov    0x805080,%eax
  801ae9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aef:	a1 84 50 80 00       	mov    0x805084,%eax
  801af4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b10:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b15:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b1a:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b20:	8b 52 0c             	mov    0xc(%edx),%edx
  801b23:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801b29:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801b2e:	50                   	push   %eax
  801b2f:	ff 75 0c             	pushl  0xc(%ebp)
  801b32:	68 08 50 80 00       	push   $0x805008
  801b37:	e8 bb f3 ff ff       	call   800ef7 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b41:	b8 04 00 00 00       	mov    $0x4,%eax
  801b46:	e8 cc fe ff ff       	call   801a17 <fsipc>
            return r;

    return r;
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b60:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b66:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b70:	e8 a2 fe ff ff       	call   801a17 <fsipc>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 51                	js     801bcc <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801b7b:	39 c6                	cmp    %eax,%esi
  801b7d:	73 19                	jae    801b98 <devfile_read+0x4b>
  801b7f:	68 1c 2c 80 00       	push   $0x802c1c
  801b84:	68 23 2c 80 00       	push   $0x802c23
  801b89:	68 82 00 00 00       	push   $0x82
  801b8e:	68 38 2c 80 00       	push   $0x802c38
  801b93:	e8 f0 ea ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b98:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b9d:	7e 19                	jle    801bb8 <devfile_read+0x6b>
  801b9f:	68 43 2c 80 00       	push   $0x802c43
  801ba4:	68 23 2c 80 00       	push   $0x802c23
  801ba9:	68 83 00 00 00       	push   $0x83
  801bae:	68 38 2c 80 00       	push   $0x802c38
  801bb3:	e8 d0 ea ff ff       	call   800688 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	50                   	push   %eax
  801bbc:	68 00 50 80 00       	push   $0x805000
  801bc1:	ff 75 0c             	pushl  0xc(%ebp)
  801bc4:	e8 2e f3 ff ff       	call   800ef7 <memmove>
	return r;
  801bc9:	83 c4 10             	add    $0x10,%esp
}
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 20             	sub    $0x20,%esp
  801bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bdf:	53                   	push   %ebx
  801be0:	e8 47 f1 ff ff       	call   800d2c <strlen>
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bed:	7f 67                	jg     801c56 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf5:	50                   	push   %eax
  801bf6:	e8 94 f8 ff ff       	call   80148f <fd_alloc>
  801bfb:	83 c4 10             	add    $0x10,%esp
		return r;
  801bfe:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 57                	js     801c5b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c04:	83 ec 08             	sub    $0x8,%esp
  801c07:	53                   	push   %ebx
  801c08:	68 00 50 80 00       	push   $0x805000
  801c0d:	e8 53 f1 ff ff       	call   800d65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c22:	e8 f0 fd ff ff       	call   801a17 <fsipc>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	79 14                	jns    801c44 <open+0x6f>
		fd_close(fd, 0);
  801c30:	83 ec 08             	sub    $0x8,%esp
  801c33:	6a 00                	push   $0x0
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	e8 4a f9 ff ff       	call   801587 <fd_close>
		return r;
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	89 da                	mov    %ebx,%edx
  801c42:	eb 17                	jmp    801c5b <open+0x86>
	}

	return fd2num(fd);
  801c44:	83 ec 0c             	sub    $0xc,%esp
  801c47:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4a:	e8 19 f8 ff ff       	call   801468 <fd2num>
  801c4f:	89 c2                	mov    %eax,%edx
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	eb 05                	jmp    801c5b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c56:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c5b:	89 d0                	mov    %edx,%eax
  801c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c68:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6d:	b8 08 00 00 00       	mov    $0x8,%eax
  801c72:	e8 a0 fd ff ff       	call   801a17 <fsipc>
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 08             	pushl  0x8(%ebp)
  801c87:	e8 ec f7 ff ff       	call   801478 <fd2data>
  801c8c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c8e:	83 c4 08             	add    $0x8,%esp
  801c91:	68 4f 2c 80 00       	push   $0x802c4f
  801c96:	53                   	push   %ebx
  801c97:	e8 c9 f0 ff ff       	call   800d65 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c9c:	8b 46 04             	mov    0x4(%esi),%eax
  801c9f:	2b 06                	sub    (%esi),%eax
  801ca1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ca7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cae:	00 00 00 
	stat->st_dev = &devpipe;
  801cb1:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801cb8:	30 80 00 
	return 0;
}
  801cbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cd1:	53                   	push   %ebx
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 14 f5 ff ff       	call   8011ed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd9:	89 1c 24             	mov    %ebx,(%esp)
  801cdc:	e8 97 f7 ff ff       	call   801478 <fd2data>
  801ce1:	83 c4 08             	add    $0x8,%esp
  801ce4:	50                   	push   %eax
  801ce5:	6a 00                	push   $0x0
  801ce7:	e8 01 f5 ff ff       	call   8011ed <sys_page_unmap>
}
  801cec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	57                   	push   %edi
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 1c             	sub    $0x1c,%esp
  801cfa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cfd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cff:	a1 04 40 80 00       	mov    0x804004,%eax
  801d04:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d07:	83 ec 0c             	sub    $0xc,%esp
  801d0a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d0d:	e8 46 04 00 00       	call   802158 <pageref>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	89 3c 24             	mov    %edi,(%esp)
  801d17:	e8 3c 04 00 00       	call   802158 <pageref>
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	39 c3                	cmp    %eax,%ebx
  801d21:	0f 94 c1             	sete   %cl
  801d24:	0f b6 c9             	movzbl %cl,%ecx
  801d27:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d2a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d30:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d33:	39 ce                	cmp    %ecx,%esi
  801d35:	74 1b                	je     801d52 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d37:	39 c3                	cmp    %eax,%ebx
  801d39:	75 c4                	jne    801cff <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d3b:	8b 42 58             	mov    0x58(%edx),%eax
  801d3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d41:	50                   	push   %eax
  801d42:	56                   	push   %esi
  801d43:	68 56 2c 80 00       	push   $0x802c56
  801d48:	e8 14 ea ff ff       	call   800761 <cprintf>
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	eb ad                	jmp    801cff <_pipeisclosed+0xe>
	}
}
  801d52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 28             	sub    $0x28,%esp
  801d66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d69:	56                   	push   %esi
  801d6a:	e8 09 f7 ff ff       	call   801478 <fd2data>
  801d6f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	bf 00 00 00 00       	mov    $0x0,%edi
  801d79:	eb 4b                	jmp    801dc6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d7b:	89 da                	mov    %ebx,%edx
  801d7d:	89 f0                	mov    %esi,%eax
  801d7f:	e8 6d ff ff ff       	call   801cf1 <_pipeisclosed>
  801d84:	85 c0                	test   %eax,%eax
  801d86:	75 48                	jne    801dd0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d88:	e8 bc f3 ff ff       	call   801149 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d8d:	8b 43 04             	mov    0x4(%ebx),%eax
  801d90:	8b 0b                	mov    (%ebx),%ecx
  801d92:	8d 51 20             	lea    0x20(%ecx),%edx
  801d95:	39 d0                	cmp    %edx,%eax
  801d97:	73 e2                	jae    801d7b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801da0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	c1 fa 1f             	sar    $0x1f,%edx
  801da8:	89 d1                	mov    %edx,%ecx
  801daa:	c1 e9 1b             	shr    $0x1b,%ecx
  801dad:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801db0:	83 e2 1f             	and    $0x1f,%edx
  801db3:	29 ca                	sub    %ecx,%edx
  801db5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801db9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dbd:	83 c0 01             	add    $0x1,%eax
  801dc0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc3:	83 c7 01             	add    $0x1,%edi
  801dc6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dc9:	75 c2                	jne    801d8d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dce:	eb 05                	jmp    801dd5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	57                   	push   %edi
  801de1:	56                   	push   %esi
  801de2:	53                   	push   %ebx
  801de3:	83 ec 18             	sub    $0x18,%esp
  801de6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801de9:	57                   	push   %edi
  801dea:	e8 89 f6 ff ff       	call   801478 <fd2data>
  801def:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df9:	eb 3d                	jmp    801e38 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dfb:	85 db                	test   %ebx,%ebx
  801dfd:	74 04                	je     801e03 <devpipe_read+0x26>
				return i;
  801dff:	89 d8                	mov    %ebx,%eax
  801e01:	eb 44                	jmp    801e47 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	89 f8                	mov    %edi,%eax
  801e07:	e8 e5 fe ff ff       	call   801cf1 <_pipeisclosed>
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	75 32                	jne    801e42 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e10:	e8 34 f3 ff ff       	call   801149 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e15:	8b 06                	mov    (%esi),%eax
  801e17:	3b 46 04             	cmp    0x4(%esi),%eax
  801e1a:	74 df                	je     801dfb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e1c:	99                   	cltd   
  801e1d:	c1 ea 1b             	shr    $0x1b,%edx
  801e20:	01 d0                	add    %edx,%eax
  801e22:	83 e0 1f             	and    $0x1f,%eax
  801e25:	29 d0                	sub    %edx,%eax
  801e27:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e2f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e32:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e35:	83 c3 01             	add    $0x1,%ebx
  801e38:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e3b:	75 d8                	jne    801e15 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e40:	eb 05                	jmp    801e47 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e42:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4a:	5b                   	pop    %ebx
  801e4b:	5e                   	pop    %esi
  801e4c:	5f                   	pop    %edi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5a:	50                   	push   %eax
  801e5b:	e8 2f f6 ff ff       	call   80148f <fd_alloc>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	89 c2                	mov    %eax,%edx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	0f 88 2c 01 00 00    	js     801f99 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6d:	83 ec 04             	sub    $0x4,%esp
  801e70:	68 07 04 00 00       	push   $0x407
  801e75:	ff 75 f4             	pushl  -0xc(%ebp)
  801e78:	6a 00                	push   $0x0
  801e7a:	e8 e9 f2 ff ff       	call   801168 <sys_page_alloc>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	89 c2                	mov    %eax,%edx
  801e84:	85 c0                	test   %eax,%eax
  801e86:	0f 88 0d 01 00 00    	js     801f99 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	e8 f7 f5 ff ff       	call   80148f <fd_alloc>
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 e2 00 00 00    	js     801f87 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea5:	83 ec 04             	sub    $0x4,%esp
  801ea8:	68 07 04 00 00       	push   $0x407
  801ead:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb0:	6a 00                	push   $0x0
  801eb2:	e8 b1 f2 ff ff       	call   801168 <sys_page_alloc>
  801eb7:	89 c3                	mov    %eax,%ebx
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	0f 88 c3 00 00 00    	js     801f87 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eca:	e8 a9 f5 ff ff       	call   801478 <fd2data>
  801ecf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed1:	83 c4 0c             	add    $0xc,%esp
  801ed4:	68 07 04 00 00       	push   $0x407
  801ed9:	50                   	push   %eax
  801eda:	6a 00                	push   $0x0
  801edc:	e8 87 f2 ff ff       	call   801168 <sys_page_alloc>
  801ee1:	89 c3                	mov    %eax,%ebx
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	0f 88 89 00 00 00    	js     801f77 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef4:	e8 7f f5 ff ff       	call   801478 <fd2data>
  801ef9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f00:	50                   	push   %eax
  801f01:	6a 00                	push   $0x0
  801f03:	56                   	push   %esi
  801f04:	6a 00                	push   $0x0
  801f06:	e8 a0 f2 ff ff       	call   8011ab <sys_page_map>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	83 c4 20             	add    $0x20,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 55                	js     801f69 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f14:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f22:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f29:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f32:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f37:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	ff 75 f4             	pushl  -0xc(%ebp)
  801f44:	e8 1f f5 ff ff       	call   801468 <fd2num>
  801f49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f4e:	83 c4 04             	add    $0x4,%esp
  801f51:	ff 75 f0             	pushl  -0x10(%ebp)
  801f54:	e8 0f f5 ff ff       	call   801468 <fd2num>
  801f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f5c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	ba 00 00 00 00       	mov    $0x0,%edx
  801f67:	eb 30                	jmp    801f99 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f69:	83 ec 08             	sub    $0x8,%esp
  801f6c:	56                   	push   %esi
  801f6d:	6a 00                	push   $0x0
  801f6f:	e8 79 f2 ff ff       	call   8011ed <sys_page_unmap>
  801f74:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f77:	83 ec 08             	sub    $0x8,%esp
  801f7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 69 f2 ff ff       	call   8011ed <sys_page_unmap>
  801f84:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 59 f2 ff ff       	call   8011ed <sys_page_unmap>
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f99:	89 d0                	mov    %edx,%eax
  801f9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9e:	5b                   	pop    %ebx
  801f9f:	5e                   	pop    %esi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fab:	50                   	push   %eax
  801fac:	ff 75 08             	pushl  0x8(%ebp)
  801faf:	e8 2a f5 ff ff       	call   8014de <fd_lookup>
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	78 18                	js     801fd3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc1:	e8 b2 f4 ff ff       	call   801478 <fd2data>
	return _pipeisclosed(fd, p);
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	e8 21 fd ff ff       	call   801cf1 <_pipeisclosed>
  801fd0:	83 c4 10             	add    $0x10,%esp
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    

00801fdf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fe5:	68 6e 2c 80 00       	push   $0x802c6e
  801fea:	ff 75 0c             	pushl  0xc(%ebp)
  801fed:	e8 73 ed ff ff       	call   800d65 <strcpy>
	return 0;
}
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	57                   	push   %edi
  801ffd:	56                   	push   %esi
  801ffe:	53                   	push   %ebx
  801fff:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802005:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802010:	eb 2d                	jmp    80203f <devcons_write+0x46>
		m = n - tot;
  802012:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802015:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802017:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80201a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80201f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	53                   	push   %ebx
  802026:	03 45 0c             	add    0xc(%ebp),%eax
  802029:	50                   	push   %eax
  80202a:	57                   	push   %edi
  80202b:	e8 c7 ee ff ff       	call   800ef7 <memmove>
		sys_cputs(buf, m);
  802030:	83 c4 08             	add    $0x8,%esp
  802033:	53                   	push   %ebx
  802034:	57                   	push   %edi
  802035:	e8 72 f0 ff ff       	call   8010ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203a:	01 de                	add    %ebx,%esi
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	89 f0                	mov    %esi,%eax
  802041:	3b 75 10             	cmp    0x10(%ebp),%esi
  802044:	72 cc                	jb     802012 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802049:	5b                   	pop    %ebx
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	83 ec 08             	sub    $0x8,%esp
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802059:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205d:	74 2a                	je     802089 <devcons_read+0x3b>
  80205f:	eb 05                	jmp    802066 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802061:	e8 e3 f0 ff ff       	call   801149 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802066:	e8 5f f0 ff ff       	call   8010ca <sys_cgetc>
  80206b:	85 c0                	test   %eax,%eax
  80206d:	74 f2                	je     802061 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80206f:	85 c0                	test   %eax,%eax
  802071:	78 16                	js     802089 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802073:	83 f8 04             	cmp    $0x4,%eax
  802076:	74 0c                	je     802084 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802078:	8b 55 0c             	mov    0xc(%ebp),%edx
  80207b:	88 02                	mov    %al,(%edx)
	return 1;
  80207d:	b8 01 00 00 00       	mov    $0x1,%eax
  802082:	eb 05                	jmp    802089 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802084:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802091:	8b 45 08             	mov    0x8(%ebp),%eax
  802094:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802097:	6a 01                	push   $0x1
  802099:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209c:	50                   	push   %eax
  80209d:	e8 0a f0 ff ff       	call   8010ac <sys_cputs>
}
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	c9                   	leave  
  8020a6:	c3                   	ret    

008020a7 <getchar>:

int
getchar(void)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ad:	6a 01                	push   $0x1
  8020af:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b2:	50                   	push   %eax
  8020b3:	6a 00                	push   $0x0
  8020b5:	e8 8a f6 ff ff       	call   801744 <read>
	if (r < 0)
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 0f                	js     8020d0 <getchar+0x29>
		return r;
	if (r < 1)
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	7e 06                	jle    8020cb <getchar+0x24>
		return -E_EOF;
	return c;
  8020c5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020c9:	eb 05                	jmp    8020d0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020cb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020d0:	c9                   	leave  
  8020d1:	c3                   	ret    

008020d2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020db:	50                   	push   %eax
  8020dc:	ff 75 08             	pushl  0x8(%ebp)
  8020df:	e8 fa f3 ff ff       	call   8014de <fd_lookup>
  8020e4:	83 c4 10             	add    $0x10,%esp
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	78 11                	js     8020fc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ee:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020f4:	39 10                	cmp    %edx,(%eax)
  8020f6:	0f 94 c0             	sete   %al
  8020f9:	0f b6 c0             	movzbl %al,%eax
}
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <opencons>:

int
opencons(void)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802104:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802107:	50                   	push   %eax
  802108:	e8 82 f3 ff ff       	call   80148f <fd_alloc>
  80210d:	83 c4 10             	add    $0x10,%esp
		return r;
  802110:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802112:	85 c0                	test   %eax,%eax
  802114:	78 3e                	js     802154 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802116:	83 ec 04             	sub    $0x4,%esp
  802119:	68 07 04 00 00       	push   $0x407
  80211e:	ff 75 f4             	pushl  -0xc(%ebp)
  802121:	6a 00                	push   $0x0
  802123:	e8 40 f0 ff ff       	call   801168 <sys_page_alloc>
  802128:	83 c4 10             	add    $0x10,%esp
		return r;
  80212b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 23                	js     802154 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802131:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802137:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80213c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802146:	83 ec 0c             	sub    $0xc,%esp
  802149:	50                   	push   %eax
  80214a:	e8 19 f3 ff ff       	call   801468 <fd2num>
  80214f:	89 c2                	mov    %eax,%edx
  802151:	83 c4 10             	add    $0x10,%esp
}
  802154:	89 d0                	mov    %edx,%eax
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215e:	89 d0                	mov    %edx,%eax
  802160:	c1 e8 16             	shr    $0x16,%eax
  802163:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80216a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216f:	f6 c1 01             	test   $0x1,%cl
  802172:	74 1d                	je     802191 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802174:	c1 ea 0c             	shr    $0xc,%edx
  802177:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80217e:	f6 c2 01             	test   $0x1,%dl
  802181:	74 0e                	je     802191 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802183:	c1 ea 0c             	shr    $0xc,%edx
  802186:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80218d:	ef 
  80218e:	0f b7 c0             	movzwl %ax,%eax
}
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    
  802193:	66 90                	xchg   %ax,%ax
  802195:	66 90                	xchg   %ax,%ax
  802197:	66 90                	xchg   %ax,%ax
  802199:	66 90                	xchg   %ax,%ax
  80219b:	66 90                	xchg   %ax,%ax
  80219d:	66 90                	xchg   %ax,%ax
  80219f:	90                   	nop

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	89 ca                	mov    %ecx,%edx
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	75 3d                	jne    802200 <__udivdi3+0x60>
  8021c3:	39 cf                	cmp    %ecx,%edi
  8021c5:	0f 87 c5 00 00 00    	ja     802290 <__udivdi3+0xf0>
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	89 fd                	mov    %edi,%ebp
  8021cf:	75 0b                	jne    8021dc <__udivdi3+0x3c>
  8021d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d6:	31 d2                	xor    %edx,%edx
  8021d8:	f7 f7                	div    %edi
  8021da:	89 c5                	mov    %eax,%ebp
  8021dc:	89 c8                	mov    %ecx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f5                	div    %ebp
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	89 cf                	mov    %ecx,%edi
  8021e8:	f7 f5                	div    %ebp
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 ce                	cmp    %ecx,%esi
  802202:	77 74                	ja     802278 <__udivdi3+0xd8>
  802204:	0f bd fe             	bsr    %esi,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0x108>
  802210:	bb 20 00 00 00       	mov    $0x20,%ebx
  802215:	89 f9                	mov    %edi,%ecx
  802217:	89 c5                	mov    %eax,%ebp
  802219:	29 fb                	sub    %edi,%ebx
  80221b:	d3 e6                	shl    %cl,%esi
  80221d:	89 d9                	mov    %ebx,%ecx
  80221f:	d3 ed                	shr    %cl,%ebp
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e0                	shl    %cl,%eax
  802225:	09 ee                	or     %ebp,%esi
  802227:	89 d9                	mov    %ebx,%ecx
  802229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222d:	89 d5                	mov    %edx,%ebp
  80222f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802233:	d3 ed                	shr    %cl,%ebp
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e2                	shl    %cl,%edx
  802239:	89 d9                	mov    %ebx,%ecx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	09 c2                	or     %eax,%edx
  80223f:	89 d0                	mov    %edx,%eax
  802241:	89 ea                	mov    %ebp,%edx
  802243:	f7 f6                	div    %esi
  802245:	89 d5                	mov    %edx,%ebp
  802247:	89 c3                	mov    %eax,%ebx
  802249:	f7 64 24 0c          	mull   0xc(%esp)
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	72 10                	jb     802261 <__udivdi3+0xc1>
  802251:	8b 74 24 08          	mov    0x8(%esp),%esi
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e6                	shl    %cl,%esi
  802259:	39 c6                	cmp    %eax,%esi
  80225b:	73 07                	jae    802264 <__udivdi3+0xc4>
  80225d:	39 d5                	cmp    %edx,%ebp
  80225f:	75 03                	jne    802264 <__udivdi3+0xc4>
  802261:	83 eb 01             	sub    $0x1,%ebx
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 d8                	mov    %ebx,%eax
  802268:	89 fa                	mov    %edi,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	31 ff                	xor    %edi,%edi
  80227a:	31 db                	xor    %ebx,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d8                	mov    %ebx,%eax
  802292:	f7 f7                	div    %edi
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 c3                	mov    %eax,%ebx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 fa                	mov    %edi,%edx
  80229c:	83 c4 1c             	add    $0x1c,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5f                   	pop    %edi
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 ce                	cmp    %ecx,%esi
  8022aa:	72 0c                	jb     8022b8 <__udivdi3+0x118>
  8022ac:	31 db                	xor    %ebx,%ebx
  8022ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022b2:	0f 87 34 ff ff ff    	ja     8021ec <__udivdi3+0x4c>
  8022b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022bd:	e9 2a ff ff ff       	jmp    8021ec <__udivdi3+0x4c>
  8022c2:	66 90                	xchg   %ax,%ax
  8022c4:	66 90                	xchg   %ax,%ax
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 d2                	test   %edx,%edx
  8022e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 f3                	mov    %esi,%ebx
  8022f3:	89 3c 24             	mov    %edi,(%esp)
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	75 1c                	jne    802318 <__umoddi3+0x48>
  8022fc:	39 f7                	cmp    %esi,%edi
  8022fe:	76 50                	jbe    802350 <__umoddi3+0x80>
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	f7 f7                	div    %edi
  802306:	89 d0                	mov    %edx,%eax
  802308:	31 d2                	xor    %edx,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	77 52                	ja     802370 <__umoddi3+0xa0>
  80231e:	0f bd ea             	bsr    %edx,%ebp
  802321:	83 f5 1f             	xor    $0x1f,%ebp
  802324:	75 5a                	jne    802380 <__umoddi3+0xb0>
  802326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80232a:	0f 82 e0 00 00 00    	jb     802410 <__umoddi3+0x140>
  802330:	39 0c 24             	cmp    %ecx,(%esp)
  802333:	0f 86 d7 00 00 00    	jbe    802410 <__umoddi3+0x140>
  802339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80233d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802341:	83 c4 1c             	add    $0x1c,%esp
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	85 ff                	test   %edi,%edi
  802352:	89 fd                	mov    %edi,%ebp
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f7                	div    %edi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	89 f0                	mov    %esi,%eax
  802363:	31 d2                	xor    %edx,%edx
  802365:	f7 f5                	div    %ebp
  802367:	89 c8                	mov    %ecx,%eax
  802369:	f7 f5                	div    %ebp
  80236b:	89 d0                	mov    %edx,%eax
  80236d:	eb 99                	jmp    802308 <__umoddi3+0x38>
  80236f:	90                   	nop
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	83 c4 1c             	add    $0x1c,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5f                   	pop    %edi
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	8b 34 24             	mov    (%esp),%esi
  802383:	bf 20 00 00 00       	mov    $0x20,%edi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	29 ef                	sub    %ebp,%edi
  80238c:	d3 e0                	shl    %cl,%eax
  80238e:	89 f9                	mov    %edi,%ecx
  802390:	89 f2                	mov    %esi,%edx
  802392:	d3 ea                	shr    %cl,%edx
  802394:	89 e9                	mov    %ebp,%ecx
  802396:	09 c2                	or     %eax,%edx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 14 24             	mov    %edx,(%esp)
  80239d:	89 f2                	mov    %esi,%edx
  80239f:	d3 e2                	shl    %cl,%edx
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	d3 e3                	shl    %cl,%ebx
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	09 d8                	or     %ebx,%eax
  8023bd:	89 d3                	mov    %edx,%ebx
  8023bf:	89 f2                	mov    %esi,%edx
  8023c1:	f7 34 24             	divl   (%esp)
  8023c4:	89 d6                	mov    %edx,%esi
  8023c6:	d3 e3                	shl    %cl,%ebx
  8023c8:	f7 64 24 04          	mull   0x4(%esp)
  8023cc:	39 d6                	cmp    %edx,%esi
  8023ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	89 c3                	mov    %eax,%ebx
  8023d6:	72 08                	jb     8023e0 <__umoddi3+0x110>
  8023d8:	75 11                	jne    8023eb <__umoddi3+0x11b>
  8023da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023de:	73 0b                	jae    8023eb <__umoddi3+0x11b>
  8023e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023e4:	1b 14 24             	sbb    (%esp),%edx
  8023e7:	89 d1                	mov    %edx,%ecx
  8023e9:	89 c3                	mov    %eax,%ebx
  8023eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023ef:	29 da                	sub    %ebx,%edx
  8023f1:	19 ce                	sbb    %ecx,%esi
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	d3 e0                	shl    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	d3 ea                	shr    %cl,%edx
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	d3 ee                	shr    %cl,%esi
  802401:	09 d0                	or     %edx,%eax
  802403:	89 f2                	mov    %esi,%edx
  802405:	83 c4 1c             	add    $0x1c,%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	29 f9                	sub    %edi,%ecx
  802412:	19 d6                	sbb    %edx,%esi
  802414:	89 74 24 04          	mov    %esi,0x4(%esp)
  802418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241c:	e9 18 ff ff ff       	jmp    802339 <__umoddi3+0x69>
