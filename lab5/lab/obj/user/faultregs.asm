
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 24 80 00       	push   $0x802471
  800049:	68 40 24 80 00       	push   $0x802440
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 24 80 00       	push   $0x802450
  80005c:	68 54 24 80 00       	push   $0x802454
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 24 80 00       	push   $0x802464
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 68 24 80 00       	push   $0x802468
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 24 80 00       	push   $0x802472
  8000a6:	68 54 24 80 00       	push   $0x802454
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 24 80 00       	push   $0x802464
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 24 80 00       	push   $0x802468
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 24 80 00       	push   $0x802476
  8000ed:	68 54 24 80 00       	push   $0x802454
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 24 80 00       	push   $0x802464
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 24 80 00       	push   $0x802468
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 24 80 00       	push   $0x80247a
  800134:	68 54 24 80 00       	push   $0x802454
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 24 80 00       	push   $0x802464
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 24 80 00       	push   $0x802468
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 24 80 00       	push   $0x80247e
  80017b:	68 54 24 80 00       	push   $0x802454
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 24 80 00       	push   $0x802464
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 24 80 00       	push   $0x802468
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 24 80 00       	push   $0x802482
  8001c2:	68 54 24 80 00       	push   $0x802454
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 24 80 00       	push   $0x802464
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 24 80 00       	push   $0x802468
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 24 80 00       	push   $0x802486
  800209:	68 54 24 80 00       	push   $0x802454
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 24 80 00       	push   $0x802464
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 24 80 00       	push   $0x802468
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 24 80 00       	push   $0x80248a
  800250:	68 54 24 80 00       	push   $0x802454
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 24 80 00       	push   $0x802464
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 24 80 00       	push   $0x802468
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 24 80 00       	push   $0x80248e
  800297:	68 54 24 80 00       	push   $0x802454
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 24 80 00       	push   $0x802464
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 24 80 00       	push   $0x802495
  8002c4:	68 54 24 80 00       	push   $0x802454
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 68 24 80 00       	push   $0x802468
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 24 80 00       	push   $0x802495
  8002f3:	68 54 24 80 00       	push   $0x802454
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 24 80 00       	push   $0x802464
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 24 80 00       	push   $0x802499
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 68 24 80 00       	push   $0x802468
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 24 80 00       	push   $0x802499
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 24 80 00       	push   $0x802464
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 24 80 00       	push   $0x802468
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 64 24 80 00       	push   $0x802464
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 24 80 00       	push   $0x802499
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 00 25 80 00       	push   $0x802500
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 24 80 00       	push   $0x8024a7
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 bf 24 80 00       	push   $0x8024bf
  80043b:	68 cd 24 80 00       	push   $0x8024cd
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba b8 24 80 00       	mov    $0x8024b8,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 72 0c 00 00       	call   8010d7 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 d4 24 80 00       	push   $0x8024d4
  800472:	6a 5c                	push   $0x5c
  800474:	68 a7 24 80 00       	push   $0x8024a7
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 38 0e 00 00       	call   8012c8 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 34 25 80 00       	push   $0x802534
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 e7 24 80 00       	push   $0x8024e7
  800579:	68 f8 24 80 00       	push   $0x8024f8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba b8 24 80 00       	mov    $0x8024b8,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 f2 0a 00 00       	call   801099 <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 45 0f 00 00       	call   80152d <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 66 0a 00 00       	call   801058 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 8f 0a 00 00       	call   801099 <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 60 25 80 00       	push   $0x802560
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 70 24 80 00 	movl   $0x802470,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 ae 09 00 00       	call   80101b <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 1a 01 00 00       	call   8007cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 53 09 00 00       	call   80101b <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 68 1a 00 00       	call   8021a0 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 55 1b 00 00       	call   8022d0 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 83 25 80 00 	movsbl 0x802583(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800799:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80079d:	8b 10                	mov    (%eax),%edx
  80079f:	3b 50 04             	cmp    0x4(%eax),%edx
  8007a2:	73 0a                	jae    8007ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8007a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	88 02                	mov    %al,(%edx)
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 05 00 00 00       	call   8007cd <vprintfmt>
	va_end(ap);
}
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	57                   	push   %edi
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 2c             	sub    $0x2c,%esp
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007df:	eb 12                	jmp    8007f3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	0f 84 42 04 00 00    	je     800c2b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	50                   	push   %eax
  8007ee:	ff d6                	call   *%esi
  8007f0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f3:	83 c7 01             	add    $0x1,%edi
  8007f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007fa:	83 f8 25             	cmp    $0x25,%eax
  8007fd:	75 e2                	jne    8007e1 <vprintfmt+0x14>
  8007ff:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800803:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80080a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800811:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081d:	eb 07                	jmp    800826 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800822:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8d 47 01             	lea    0x1(%edi),%eax
  800829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082c:	0f b6 07             	movzbl (%edi),%eax
  80082f:	0f b6 d0             	movzbl %al,%edx
  800832:	83 e8 23             	sub    $0x23,%eax
  800835:	3c 55                	cmp    $0x55,%al
  800837:	0f 87 d3 03 00 00    	ja     800c10 <vprintfmt+0x443>
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80084a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80084e:	eb d6                	jmp    800826 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80085b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80085e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800862:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800865:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800868:	83 f9 09             	cmp    $0x9,%ecx
  80086b:	77 3f                	ja     8008ac <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80086d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800870:	eb e9                	jmp    80085b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 00                	mov    (%eax),%eax
  800877:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800886:	eb 2a                	jmp    8008b2 <vprintfmt+0xe5>
  800888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088b:	85 c0                	test   %eax,%eax
  80088d:	ba 00 00 00 00       	mov    $0x0,%edx
  800892:	0f 49 d0             	cmovns %eax,%edx
  800895:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089b:	eb 89                	jmp    800826 <vprintfmt+0x59>
  80089d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008a0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008a7:	e9 7a ff ff ff       	jmp    800826 <vprintfmt+0x59>
  8008ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008af:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008b6:	0f 89 6a ff ff ff    	jns    800826 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008c9:	e9 58 ff ff ff       	jmp    800826 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ce:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008d4:	e9 4d ff ff ff       	jmp    800826 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 78 04             	lea    0x4(%eax),%edi
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	ff 30                	pushl  (%eax)
  8008e5:	ff d6                	call   *%esi
			break;
  8008e7:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ea:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f0:	e9 fe fe ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 78 04             	lea    0x4(%eax),%edi
  8008fb:	8b 00                	mov    (%eax),%eax
  8008fd:	99                   	cltd   
  8008fe:	31 d0                	xor    %edx,%eax
  800900:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800902:	83 f8 0f             	cmp    $0xf,%eax
  800905:	7f 0b                	jg     800912 <vprintfmt+0x145>
  800907:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  80090e:	85 d2                	test   %edx,%edx
  800910:	75 1b                	jne    80092d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800912:	50                   	push   %eax
  800913:	68 9b 25 80 00       	push   $0x80259b
  800918:	53                   	push   %ebx
  800919:	56                   	push   %esi
  80091a:	e8 91 fe ff ff       	call   8007b0 <printfmt>
  80091f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800922:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800928:	e9 c6 fe ff ff       	jmp    8007f3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80092d:	52                   	push   %edx
  80092e:	68 7d 29 80 00       	push   $0x80297d
  800933:	53                   	push   %ebx
  800934:	56                   	push   %esi
  800935:	e8 76 fe ff ff       	call   8007b0 <printfmt>
  80093a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800943:	e9 ab fe ff ff       	jmp    8007f3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	83 c0 04             	add    $0x4,%eax
  80094e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800951:	8b 45 14             	mov    0x14(%ebp),%eax
  800954:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800956:	85 ff                	test   %edi,%edi
  800958:	b8 94 25 80 00       	mov    $0x802594,%eax
  80095d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800960:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800964:	0f 8e 94 00 00 00    	jle    8009fe <vprintfmt+0x231>
  80096a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80096e:	0f 84 98 00 00 00    	je     800a0c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	ff 75 d0             	pushl  -0x30(%ebp)
  80097a:	57                   	push   %edi
  80097b:	e8 33 03 00 00       	call   800cb3 <strnlen>
  800980:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800983:	29 c1                	sub    %eax,%ecx
  800985:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800988:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80098b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80098f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800992:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800995:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	eb 0f                	jmp    8009a8 <vprintfmt+0x1db>
					putch(padc, putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	ff 75 e0             	pushl  -0x20(%ebp)
  8009a0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ef 01             	sub    $0x1,%edi
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	85 ff                	test   %edi,%edi
  8009aa:	7f ed                	jg     800999 <vprintfmt+0x1cc>
  8009ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b9:	0f 49 c1             	cmovns %ecx,%eax
  8009bc:	29 c1                	sub    %eax,%ecx
  8009be:	89 75 08             	mov    %esi,0x8(%ebp)
  8009c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009c7:	89 cb                	mov    %ecx,%ebx
  8009c9:	eb 4d                	jmp    800a18 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009cf:	74 1b                	je     8009ec <vprintfmt+0x21f>
  8009d1:	0f be c0             	movsbl %al,%eax
  8009d4:	83 e8 20             	sub    $0x20,%eax
  8009d7:	83 f8 5e             	cmp    $0x5e,%eax
  8009da:	76 10                	jbe    8009ec <vprintfmt+0x21f>
					putch('?', putdat);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	6a 3f                	push   $0x3f
  8009e4:	ff 55 08             	call   *0x8(%ebp)
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	eb 0d                	jmp    8009f9 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8009ec:	83 ec 08             	sub    $0x8,%esp
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	52                   	push   %edx
  8009f3:	ff 55 08             	call   *0x8(%ebp)
  8009f6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f9:	83 eb 01             	sub    $0x1,%ebx
  8009fc:	eb 1a                	jmp    800a18 <vprintfmt+0x24b>
  8009fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800a01:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a04:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a07:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a0a:	eb 0c                	jmp    800a18 <vprintfmt+0x24b>
  800a0c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a0f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a12:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a15:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a18:	83 c7 01             	add    $0x1,%edi
  800a1b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a1f:	0f be d0             	movsbl %al,%edx
  800a22:	85 d2                	test   %edx,%edx
  800a24:	74 23                	je     800a49 <vprintfmt+0x27c>
  800a26:	85 f6                	test   %esi,%esi
  800a28:	78 a1                	js     8009cb <vprintfmt+0x1fe>
  800a2a:	83 ee 01             	sub    $0x1,%esi
  800a2d:	79 9c                	jns    8009cb <vprintfmt+0x1fe>
  800a2f:	89 df                	mov    %ebx,%edi
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a37:	eb 18                	jmp    800a51 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	53                   	push   %ebx
  800a3d:	6a 20                	push   $0x20
  800a3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	eb 08                	jmp    800a51 <vprintfmt+0x284>
  800a49:	89 df                	mov    %ebx,%edi
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a51:	85 ff                	test   %edi,%edi
  800a53:	7f e4                	jg     800a39 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a55:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a58:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5e:	e9 90 fd ff ff       	jmp    8007f3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a63:	83 f9 01             	cmp    $0x1,%ecx
  800a66:	7e 19                	jle    800a81 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800a68:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6b:	8b 50 04             	mov    0x4(%eax),%edx
  800a6e:	8b 00                	mov    (%eax),%eax
  800a70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a73:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 40 08             	lea    0x8(%eax),%eax
  800a7c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a7f:	eb 38                	jmp    800ab9 <vprintfmt+0x2ec>
	else if (lflag)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 1b                	je     800aa0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8b 00                	mov    (%eax),%eax
  800a8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8d:	89 c1                	mov    %eax,%ecx
  800a8f:	c1 f9 1f             	sar    $0x1f,%ecx
  800a92:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8d 40 04             	lea    0x4(%eax),%eax
  800a9b:	89 45 14             	mov    %eax,0x14(%ebp)
  800a9e:	eb 19                	jmp    800ab9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8b 00                	mov    (%eax),%eax
  800aa5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa8:	89 c1                	mov    %eax,%ecx
  800aaa:	c1 f9 1f             	sar    $0x1f,%ecx
  800aad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	8d 40 04             	lea    0x4(%eax),%eax
  800ab6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ab9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800abc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800abf:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ac8:	0f 89 0e 01 00 00    	jns    800bdc <vprintfmt+0x40f>
				putch('-', putdat);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	53                   	push   %ebx
  800ad2:	6a 2d                	push   $0x2d
  800ad4:	ff d6                	call   *%esi
				num = -(long long) num;
  800ad6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ad9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800adc:	f7 da                	neg    %edx
  800ade:	83 d1 00             	adc    $0x0,%ecx
  800ae1:	f7 d9                	neg    %ecx
  800ae3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ae6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aeb:	e9 ec 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af0:	83 f9 01             	cmp    $0x1,%ecx
  800af3:	7e 18                	jle    800b0d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800af5:	8b 45 14             	mov    0x14(%ebp),%eax
  800af8:	8b 10                	mov    (%eax),%edx
  800afa:	8b 48 04             	mov    0x4(%eax),%ecx
  800afd:	8d 40 08             	lea    0x8(%eax),%eax
  800b00:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b08:	e9 cf 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b0d:	85 c9                	test   %ecx,%ecx
  800b0f:	74 1a                	je     800b2b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800b11:	8b 45 14             	mov    0x14(%ebp),%eax
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	8d 40 04             	lea    0x4(%eax),%eax
  800b1e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b26:	e9 b1 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8b 10                	mov    (%eax),%edx
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8d 40 04             	lea    0x4(%eax),%eax
  800b38:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b40:	e9 97 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b45:	83 ec 08             	sub    $0x8,%esp
  800b48:	53                   	push   %ebx
  800b49:	6a 58                	push   $0x58
  800b4b:	ff d6                	call   *%esi
			putch('X', putdat);
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	53                   	push   %ebx
  800b51:	6a 58                	push   $0x58
  800b53:	ff d6                	call   *%esi
			putch('X', putdat);
  800b55:	83 c4 08             	add    $0x8,%esp
  800b58:	53                   	push   %ebx
  800b59:	6a 58                	push   $0x58
  800b5b:	ff d6                	call   *%esi
			break;
  800b5d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b63:	e9 8b fc ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800b68:	83 ec 08             	sub    $0x8,%esp
  800b6b:	53                   	push   %ebx
  800b6c:	6a 30                	push   $0x30
  800b6e:	ff d6                	call   *%esi
			putch('x', putdat);
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	53                   	push   %ebx
  800b74:	6a 78                	push   $0x78
  800b76:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b78:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7b:	8b 10                	mov    (%eax),%edx
  800b7d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b82:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b85:	8d 40 04             	lea    0x4(%eax),%eax
  800b88:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b8b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b90:	eb 4a                	jmp    800bdc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b92:	83 f9 01             	cmp    $0x1,%ecx
  800b95:	7e 15                	jle    800bac <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800b97:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9a:	8b 10                	mov    (%eax),%edx
  800b9c:	8b 48 04             	mov    0x4(%eax),%ecx
  800b9f:	8d 40 08             	lea    0x8(%eax),%eax
  800ba2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ba5:	b8 10 00 00 00       	mov    $0x10,%eax
  800baa:	eb 30                	jmp    800bdc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800bac:	85 c9                	test   %ecx,%ecx
  800bae:	74 17                	je     800bc7 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb3:	8b 10                	mov    (%eax),%edx
  800bb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bba:	8d 40 04             	lea    0x4(%eax),%eax
  800bbd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bc0:	b8 10 00 00 00       	mov    $0x10,%eax
  800bc5:	eb 15                	jmp    800bdc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8b 10                	mov    (%eax),%edx
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd1:	8d 40 04             	lea    0x4(%eax),%eax
  800bd4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bd7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800be3:	57                   	push   %edi
  800be4:	ff 75 e0             	pushl  -0x20(%ebp)
  800be7:	50                   	push   %eax
  800be8:	51                   	push   %ecx
  800be9:	52                   	push   %edx
  800bea:	89 da                	mov    %ebx,%edx
  800bec:	89 f0                	mov    %esi,%eax
  800bee:	e8 f1 fa ff ff       	call   8006e4 <printnum>
			break;
  800bf3:	83 c4 20             	add    $0x20,%esp
  800bf6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bf9:	e9 f5 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	53                   	push   %ebx
  800c02:	52                   	push   %edx
  800c03:	ff d6                	call   *%esi
			break;
  800c05:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c0b:	e9 e3 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	6a 25                	push   $0x25
  800c16:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	eb 03                	jmp    800c20 <vprintfmt+0x453>
  800c1d:	83 ef 01             	sub    $0x1,%edi
  800c20:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c24:	75 f7                	jne    800c1d <vprintfmt+0x450>
  800c26:	e9 c8 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 18             	sub    $0x18,%esp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c42:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c46:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	74 26                	je     800c7a <vsnprintf+0x47>
  800c54:	85 d2                	test   %edx,%edx
  800c56:	7e 22                	jle    800c7a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c58:	ff 75 14             	pushl  0x14(%ebp)
  800c5b:	ff 75 10             	pushl  0x10(%ebp)
  800c5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c61:	50                   	push   %eax
  800c62:	68 93 07 80 00       	push   $0x800793
  800c67:	e8 61 fb ff ff       	call   8007cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	eb 05                	jmp    800c7f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c87:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c8a:	50                   	push   %eax
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	e8 9a ff ff ff       	call   800c33 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	eb 03                	jmp    800cab <strlen+0x10>
		n++;
  800ca8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800caf:	75 f7                	jne    800ca8 <strlen+0xd>
		n++;
	return n;
}
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc1:	eb 03                	jmp    800cc6 <strnlen+0x13>
		n++;
  800cc3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc6:	39 c2                	cmp    %eax,%edx
  800cc8:	74 08                	je     800cd2 <strnlen+0x1f>
  800cca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cce:	75 f3                	jne    800cc3 <strnlen+0x10>
  800cd0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	53                   	push   %ebx
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	83 c1 01             	add    $0x1,%ecx
  800ce6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cea:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ced:	84 db                	test   %bl,%bl
  800cef:	75 ef                	jne    800ce0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cfb:	53                   	push   %ebx
  800cfc:	e8 9a ff ff ff       	call   800c9b <strlen>
  800d01:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d04:	ff 75 0c             	pushl  0xc(%ebp)
  800d07:	01 d8                	add    %ebx,%eax
  800d09:	50                   	push   %eax
  800d0a:	e8 c5 ff ff ff       	call   800cd4 <strcpy>
	return dst;
}
  800d0f:	89 d8                	mov    %ebx,%eax
  800d11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	89 f3                	mov    %esi,%ebx
  800d23:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d26:	89 f2                	mov    %esi,%edx
  800d28:	eb 0f                	jmp    800d39 <strncpy+0x23>
		*dst++ = *src;
  800d2a:	83 c2 01             	add    $0x1,%edx
  800d2d:	0f b6 01             	movzbl (%ecx),%eax
  800d30:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d33:	80 39 01             	cmpb   $0x1,(%ecx)
  800d36:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d39:	39 da                	cmp    %ebx,%edx
  800d3b:	75 ed                	jne    800d2a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d3d:	89 f0                	mov    %esi,%eax
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 10             	mov    0x10(%ebp),%edx
  800d51:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d53:	85 d2                	test   %edx,%edx
  800d55:	74 21                	je     800d78 <strlcpy+0x35>
  800d57:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d5b:	89 f2                	mov    %esi,%edx
  800d5d:	eb 09                	jmp    800d68 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d5f:	83 c2 01             	add    $0x1,%edx
  800d62:	83 c1 01             	add    $0x1,%ecx
  800d65:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d68:	39 c2                	cmp    %eax,%edx
  800d6a:	74 09                	je     800d75 <strlcpy+0x32>
  800d6c:	0f b6 19             	movzbl (%ecx),%ebx
  800d6f:	84 db                	test   %bl,%bl
  800d71:	75 ec                	jne    800d5f <strlcpy+0x1c>
  800d73:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d75:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d78:	29 f0                	sub    %esi,%eax
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d87:	eb 06                	jmp    800d8f <strcmp+0x11>
		p++, q++;
  800d89:	83 c1 01             	add    $0x1,%ecx
  800d8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d8f:	0f b6 01             	movzbl (%ecx),%eax
  800d92:	84 c0                	test   %al,%al
  800d94:	74 04                	je     800d9a <strcmp+0x1c>
  800d96:	3a 02                	cmp    (%edx),%al
  800d98:	74 ef                	je     800d89 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9a:	0f b6 c0             	movzbl %al,%eax
  800d9d:	0f b6 12             	movzbl (%edx),%edx
  800da0:	29 d0                	sub    %edx,%eax
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	53                   	push   %ebx
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800db3:	eb 06                	jmp    800dbb <strncmp+0x17>
		n--, p++, q++;
  800db5:	83 c0 01             	add    $0x1,%eax
  800db8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dbb:	39 d8                	cmp    %ebx,%eax
  800dbd:	74 15                	je     800dd4 <strncmp+0x30>
  800dbf:	0f b6 08             	movzbl (%eax),%ecx
  800dc2:	84 c9                	test   %cl,%cl
  800dc4:	74 04                	je     800dca <strncmp+0x26>
  800dc6:	3a 0a                	cmp    (%edx),%cl
  800dc8:	74 eb                	je     800db5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	0f b6 12             	movzbl (%edx),%edx
  800dd0:	29 d0                	sub    %edx,%eax
  800dd2:	eb 05                	jmp    800dd9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de6:	eb 07                	jmp    800def <strchr+0x13>
		if (*s == c)
  800de8:	38 ca                	cmp    %cl,%dl
  800dea:	74 0f                	je     800dfb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dec:	83 c0 01             	add    $0x1,%eax
  800def:	0f b6 10             	movzbl (%eax),%edx
  800df2:	84 d2                	test   %dl,%dl
  800df4:	75 f2                	jne    800de8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e07:	eb 03                	jmp    800e0c <strfind+0xf>
  800e09:	83 c0 01             	add    $0x1,%eax
  800e0c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e0f:	38 ca                	cmp    %cl,%dl
  800e11:	74 04                	je     800e17 <strfind+0x1a>
  800e13:	84 d2                	test   %dl,%dl
  800e15:	75 f2                	jne    800e09 <strfind+0xc>
			break;
	return (char *) s;
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e25:	85 c9                	test   %ecx,%ecx
  800e27:	74 36                	je     800e5f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e2f:	75 28                	jne    800e59 <memset+0x40>
  800e31:	f6 c1 03             	test   $0x3,%cl
  800e34:	75 23                	jne    800e59 <memset+0x40>
		c &= 0xFF;
  800e36:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e3a:	89 d3                	mov    %edx,%ebx
  800e3c:	c1 e3 08             	shl    $0x8,%ebx
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	c1 e6 18             	shl    $0x18,%esi
  800e44:	89 d0                	mov    %edx,%eax
  800e46:	c1 e0 10             	shl    $0x10,%eax
  800e49:	09 f0                	or     %esi,%eax
  800e4b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e4d:	89 d8                	mov    %ebx,%eax
  800e4f:	09 d0                	or     %edx,%eax
  800e51:	c1 e9 02             	shr    $0x2,%ecx
  800e54:	fc                   	cld    
  800e55:	f3 ab                	rep stos %eax,%es:(%edi)
  800e57:	eb 06                	jmp    800e5f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	fc                   	cld    
  800e5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5f:	89 f8                	mov    %edi,%eax
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e74:	39 c6                	cmp    %eax,%esi
  800e76:	73 35                	jae    800ead <memmove+0x47>
  800e78:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e7b:	39 d0                	cmp    %edx,%eax
  800e7d:	73 2e                	jae    800ead <memmove+0x47>
		s += n;
		d += n;
  800e7f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e82:	89 d6                	mov    %edx,%esi
  800e84:	09 fe                	or     %edi,%esi
  800e86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e8c:	75 13                	jne    800ea1 <memmove+0x3b>
  800e8e:	f6 c1 03             	test   $0x3,%cl
  800e91:	75 0e                	jne    800ea1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e93:	83 ef 04             	sub    $0x4,%edi
  800e96:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e99:	c1 e9 02             	shr    $0x2,%ecx
  800e9c:	fd                   	std    
  800e9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e9f:	eb 09                	jmp    800eaa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ea1:	83 ef 01             	sub    $0x1,%edi
  800ea4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ea7:	fd                   	std    
  800ea8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eaa:	fc                   	cld    
  800eab:	eb 1d                	jmp    800eca <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	09 c2                	or     %eax,%edx
  800eb1:	f6 c2 03             	test   $0x3,%dl
  800eb4:	75 0f                	jne    800ec5 <memmove+0x5f>
  800eb6:	f6 c1 03             	test   $0x3,%cl
  800eb9:	75 0a                	jne    800ec5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ebb:	c1 e9 02             	shr    $0x2,%ecx
  800ebe:	89 c7                	mov    %eax,%edi
  800ec0:	fc                   	cld    
  800ec1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec3:	eb 05                	jmp    800eca <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ec5:	89 c7                	mov    %eax,%edi
  800ec7:	fc                   	cld    
  800ec8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ed1:	ff 75 10             	pushl  0x10(%ebp)
  800ed4:	ff 75 0c             	pushl  0xc(%ebp)
  800ed7:	ff 75 08             	pushl  0x8(%ebp)
  800eda:	e8 87 ff ff ff       	call   800e66 <memmove>
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eec:	89 c6                	mov    %eax,%esi
  800eee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ef1:	eb 1a                	jmp    800f0d <memcmp+0x2c>
		if (*s1 != *s2)
  800ef3:	0f b6 08             	movzbl (%eax),%ecx
  800ef6:	0f b6 1a             	movzbl (%edx),%ebx
  800ef9:	38 d9                	cmp    %bl,%cl
  800efb:	74 0a                	je     800f07 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800efd:	0f b6 c1             	movzbl %cl,%eax
  800f00:	0f b6 db             	movzbl %bl,%ebx
  800f03:	29 d8                	sub    %ebx,%eax
  800f05:	eb 0f                	jmp    800f16 <memcmp+0x35>
		s1++, s2++;
  800f07:	83 c0 01             	add    $0x1,%eax
  800f0a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f0d:	39 f0                	cmp    %esi,%eax
  800f0f:	75 e2                	jne    800ef3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f21:	89 c1                	mov    %eax,%ecx
  800f23:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f26:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f2a:	eb 0a                	jmp    800f36 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f2c:	0f b6 10             	movzbl (%eax),%edx
  800f2f:	39 da                	cmp    %ebx,%edx
  800f31:	74 07                	je     800f3a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f33:	83 c0 01             	add    $0x1,%eax
  800f36:	39 c8                	cmp    %ecx,%eax
  800f38:	72 f2                	jb     800f2c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f3a:	5b                   	pop    %ebx
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f49:	eb 03                	jmp    800f4e <strtol+0x11>
		s++;
  800f4b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f4e:	0f b6 01             	movzbl (%ecx),%eax
  800f51:	3c 20                	cmp    $0x20,%al
  800f53:	74 f6                	je     800f4b <strtol+0xe>
  800f55:	3c 09                	cmp    $0x9,%al
  800f57:	74 f2                	je     800f4b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f59:	3c 2b                	cmp    $0x2b,%al
  800f5b:	75 0a                	jne    800f67 <strtol+0x2a>
		s++;
  800f5d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f60:	bf 00 00 00 00       	mov    $0x0,%edi
  800f65:	eb 11                	jmp    800f78 <strtol+0x3b>
  800f67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f6c:	3c 2d                	cmp    $0x2d,%al
  800f6e:	75 08                	jne    800f78 <strtol+0x3b>
		s++, neg = 1;
  800f70:	83 c1 01             	add    $0x1,%ecx
  800f73:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f7e:	75 15                	jne    800f95 <strtol+0x58>
  800f80:	80 39 30             	cmpb   $0x30,(%ecx)
  800f83:	75 10                	jne    800f95 <strtol+0x58>
  800f85:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f89:	75 7c                	jne    801007 <strtol+0xca>
		s += 2, base = 16;
  800f8b:	83 c1 02             	add    $0x2,%ecx
  800f8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f93:	eb 16                	jmp    800fab <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f95:	85 db                	test   %ebx,%ebx
  800f97:	75 12                	jne    800fab <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f99:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800fa1:	75 08                	jne    800fab <strtol+0x6e>
		s++, base = 8;
  800fa3:	83 c1 01             	add    $0x1,%ecx
  800fa6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fb3:	0f b6 11             	movzbl (%ecx),%edx
  800fb6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fb9:	89 f3                	mov    %esi,%ebx
  800fbb:	80 fb 09             	cmp    $0x9,%bl
  800fbe:	77 08                	ja     800fc8 <strtol+0x8b>
			dig = *s - '0';
  800fc0:	0f be d2             	movsbl %dl,%edx
  800fc3:	83 ea 30             	sub    $0x30,%edx
  800fc6:	eb 22                	jmp    800fea <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 19             	cmp    $0x19,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 57             	sub    $0x57,%edx
  800fd8:	eb 10                	jmp    800fea <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fda:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 16                	ja     800ffa <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fea:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fed:	7d 0b                	jge    800ffa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fef:	83 c1 01             	add    $0x1,%ecx
  800ff2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ff6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ff8:	eb b9                	jmp    800fb3 <strtol+0x76>

	if (endptr)
  800ffa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ffe:	74 0d                	je     80100d <strtol+0xd0>
		*endptr = (char *) s;
  801000:	8b 75 0c             	mov    0xc(%ebp),%esi
  801003:	89 0e                	mov    %ecx,(%esi)
  801005:	eb 06                	jmp    80100d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801007:	85 db                	test   %ebx,%ebx
  801009:	74 98                	je     800fa3 <strtol+0x66>
  80100b:	eb 9e                	jmp    800fab <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	f7 da                	neg    %edx
  801011:	85 ff                	test   %edi,%edi
  801013:	0f 45 c2             	cmovne %edx,%eax
}
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	89 c3                	mov    %eax,%ebx
  80102e:	89 c7                	mov    %eax,%edi
  801030:	89 c6                	mov    %eax,%esi
  801032:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_cgetc>:

int
sys_cgetc(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	ba 00 00 00 00       	mov    $0x0,%edx
  801044:	b8 01 00 00 00       	mov    $0x1,%eax
  801049:	89 d1                	mov    %edx,%ecx
  80104b:	89 d3                	mov    %edx,%ebx
  80104d:	89 d7                	mov    %edx,%edi
  80104f:	89 d6                	mov    %edx,%esi
  801051:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	b9 00 00 00 00       	mov    $0x0,%ecx
  801066:	b8 03 00 00 00       	mov    $0x3,%eax
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	89 cb                	mov    %ecx,%ebx
  801070:	89 cf                	mov    %ecx,%edi
  801072:	89 ce                	mov    %ecx,%esi
  801074:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	7e 17                	jle    801091 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	50                   	push   %eax
  80107e:	6a 03                	push   $0x3
  801080:	68 7f 28 80 00       	push   $0x80287f
  801085:	6a 23                	push   $0x23
  801087:	68 9c 28 80 00       	push   $0x80289c
  80108c:	e8 66 f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109f:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a9:	89 d1                	mov    %edx,%ecx
  8010ab:	89 d3                	mov    %edx,%ebx
  8010ad:	89 d7                	mov    %edx,%edi
  8010af:	89 d6                	mov    %edx,%esi
  8010b1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sys_yield>:

void
sys_yield(void)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010be:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010c8:	89 d1                	mov    %edx,%ecx
  8010ca:	89 d3                	mov    %edx,%ebx
  8010cc:	89 d7                	mov    %edx,%edi
  8010ce:	89 d6                	mov    %edx,%esi
  8010d0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	be 00 00 00 00       	mov    $0x0,%esi
  8010e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f3:	89 f7                	mov    %esi,%edi
  8010f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 17                	jle    801112 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	50                   	push   %eax
  8010ff:	6a 04                	push   $0x4
  801101:	68 7f 28 80 00       	push   $0x80287f
  801106:	6a 23                	push   $0x23
  801108:	68 9c 28 80 00       	push   $0x80289c
  80110d:	e8 e5 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801123:	b8 05 00 00 00       	mov    $0x5,%eax
  801128:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112b:	8b 55 08             	mov    0x8(%ebp),%edx
  80112e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801131:	8b 7d 14             	mov    0x14(%ebp),%edi
  801134:	8b 75 18             	mov    0x18(%ebp),%esi
  801137:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801139:	85 c0                	test   %eax,%eax
  80113b:	7e 17                	jle    801154 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	50                   	push   %eax
  801141:	6a 05                	push   $0x5
  801143:	68 7f 28 80 00       	push   $0x80287f
  801148:	6a 23                	push   $0x23
  80114a:	68 9c 28 80 00       	push   $0x80289c
  80114f:	e8 a3 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801154:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801165:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116a:	b8 06 00 00 00       	mov    $0x6,%eax
  80116f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801172:	8b 55 08             	mov    0x8(%ebp),%edx
  801175:	89 df                	mov    %ebx,%edi
  801177:	89 de                	mov    %ebx,%esi
  801179:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	7e 17                	jle    801196 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	50                   	push   %eax
  801183:	6a 06                	push   $0x6
  801185:	68 7f 28 80 00       	push   $0x80287f
  80118a:	6a 23                	push   $0x23
  80118c:	68 9c 28 80 00       	push   $0x80289c
  801191:	e8 61 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8011b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	89 df                	mov    %ebx,%edi
  8011b9:	89 de                	mov    %ebx,%esi
  8011bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	7e 17                	jle    8011d8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	50                   	push   %eax
  8011c5:	6a 08                	push   $0x8
  8011c7:	68 7f 28 80 00       	push   $0x80287f
  8011cc:	6a 23                	push   $0x23
  8011ce:	68 9c 28 80 00       	push   $0x80289c
  8011d3:	e8 1f f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f9:	89 df                	mov    %ebx,%edi
  8011fb:	89 de                	mov    %ebx,%esi
  8011fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ff:	85 c0                	test   %eax,%eax
  801201:	7e 17                	jle    80121a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	50                   	push   %eax
  801207:	6a 09                	push   $0x9
  801209:	68 7f 28 80 00       	push   $0x80287f
  80120e:	6a 23                	push   $0x23
  801210:	68 9c 28 80 00       	push   $0x80289c
  801215:	e8 dd f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801230:	b8 0a 00 00 00       	mov    $0xa,%eax
  801235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801238:	8b 55 08             	mov    0x8(%ebp),%edx
  80123b:	89 df                	mov    %ebx,%edi
  80123d:	89 de                	mov    %ebx,%esi
  80123f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801241:	85 c0                	test   %eax,%eax
  801243:	7e 17                	jle    80125c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	50                   	push   %eax
  801249:	6a 0a                	push   $0xa
  80124b:	68 7f 28 80 00       	push   $0x80287f
  801250:	6a 23                	push   $0x23
  801252:	68 9c 28 80 00       	push   $0x80289c
  801257:	e8 9b f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80125c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	57                   	push   %edi
  801268:	56                   	push   %esi
  801269:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126a:	be 00 00 00 00       	mov    $0x0,%esi
  80126f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801277:	8b 55 08             	mov    0x8(%ebp),%edx
  80127a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801280:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801290:	b9 00 00 00 00       	mov    $0x0,%ecx
  801295:	b8 0d 00 00 00       	mov    $0xd,%eax
  80129a:	8b 55 08             	mov    0x8(%ebp),%edx
  80129d:	89 cb                	mov    %ecx,%ebx
  80129f:	89 cf                	mov    %ecx,%edi
  8012a1:	89 ce                	mov    %ecx,%esi
  8012a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	7e 17                	jle    8012c0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	50                   	push   %eax
  8012ad:	6a 0d                	push   $0xd
  8012af:	68 7f 28 80 00       	push   $0x80287f
  8012b4:	6a 23                	push   $0x23
  8012b6:	68 9c 28 80 00       	push   $0x80289c
  8012bb:	e8 37 f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  8012cf:	e8 c5 fd ff ff       	call   801099 <sys_getenvid>
  8012d4:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  8012d6:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012dd:	75 29                	jne    801308 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	6a 07                	push   $0x7
  8012e4:	68 00 f0 bf ee       	push   $0xeebff000
  8012e9:	50                   	push   %eax
  8012ea:	e8 e8 fd ff ff       	call   8010d7 <sys_page_alloc>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	79 12                	jns    801308 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  8012f6:	50                   	push   %eax
  8012f7:	68 aa 28 80 00       	push   $0x8028aa
  8012fc:	6a 24                	push   $0x24
  8012fe:	68 c3 28 80 00       	push   $0x8028c3
  801303:	e8 ef f2 ff ff       	call   8005f7 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801308:	8b 45 08             	mov    0x8(%ebp),%eax
  80130b:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	68 3c 13 80 00       	push   $0x80133c
  801318:	53                   	push   %ebx
  801319:	e8 04 ff ff ff       	call   801222 <sys_env_set_pgfault_upcall>
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	79 12                	jns    801337 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801325:	50                   	push   %eax
  801326:	68 aa 28 80 00       	push   $0x8028aa
  80132b:	6a 2e                	push   $0x2e
  80132d:	68 c3 28 80 00       	push   $0x8028c3
  801332:	e8 c0 f2 ff ff       	call   8005f7 <_panic>
}
  801337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80133c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80133d:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801342:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801344:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801347:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80134b:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  80134e:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801352:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801354:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801358:	83 c4 08             	add    $0x8,%esp
	popal
  80135b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80135c:	83 c4 04             	add    $0x4,%esp
	popfl
  80135f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801360:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801361:	c3                   	ret    

00801362 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801365:	8b 45 08             	mov    0x8(%ebp),%eax
  801368:	05 00 00 00 30       	add    $0x30000000,%eax
  80136d:	c1 e8 0c             	shr    $0xc,%eax
}
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	05 00 00 00 30       	add    $0x30000000,%eax
  80137d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801382:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801394:	89 c2                	mov    %eax,%edx
  801396:	c1 ea 16             	shr    $0x16,%edx
  801399:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a0:	f6 c2 01             	test   $0x1,%dl
  8013a3:	74 11                	je     8013b6 <fd_alloc+0x2d>
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 0c             	shr    $0xc,%edx
  8013aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	75 09                	jne    8013bf <fd_alloc+0x36>
			*fd_store = fd;
  8013b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bd:	eb 17                	jmp    8013d6 <fd_alloc+0x4d>
  8013bf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c9:	75 c9                	jne    801394 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013de:	83 f8 1f             	cmp    $0x1f,%eax
  8013e1:	77 36                	ja     801419 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e3:	c1 e0 0c             	shl    $0xc,%eax
  8013e6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	c1 ea 16             	shr    $0x16,%edx
  8013f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f7:	f6 c2 01             	test   $0x1,%dl
  8013fa:	74 24                	je     801420 <fd_lookup+0x48>
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	c1 ea 0c             	shr    $0xc,%edx
  801401:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801408:	f6 c2 01             	test   $0x1,%dl
  80140b:	74 1a                	je     801427 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80140d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801410:	89 02                	mov    %eax,(%edx)
	return 0;
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
  801417:	eb 13                	jmp    80142c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141e:	eb 0c                	jmp    80142c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801425:	eb 05                	jmp    80142c <fd_lookup+0x54>
  801427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801437:	ba 54 29 80 00       	mov    $0x802954,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80143c:	eb 13                	jmp    801451 <dev_lookup+0x23>
  80143e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801441:	39 08                	cmp    %ecx,(%eax)
  801443:	75 0c                	jne    801451 <dev_lookup+0x23>
			*dev = devtab[i];
  801445:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801448:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	eb 2e                	jmp    80147f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801451:	8b 02                	mov    (%edx),%eax
  801453:	85 c0                	test   %eax,%eax
  801455:	75 e7                	jne    80143e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801457:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80145c:	8b 40 48             	mov    0x48(%eax),%eax
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	51                   	push   %ecx
  801463:	50                   	push   %eax
  801464:	68 d4 28 80 00       	push   $0x8028d4
  801469:	e8 62 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  80146e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801471:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	83 ec 10             	sub    $0x10,%esp
  801489:	8b 75 08             	mov    0x8(%ebp),%esi
  80148c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801499:	c1 e8 0c             	shr    $0xc,%eax
  80149c:	50                   	push   %eax
  80149d:	e8 36 ff ff ff       	call   8013d8 <fd_lookup>
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 05                	js     8014ae <fd_close+0x2d>
	    || fd != fd2)
  8014a9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ac:	74 0c                	je     8014ba <fd_close+0x39>
		return (must_exist ? r : 0);
  8014ae:	84 db                	test   %bl,%bl
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	0f 44 c2             	cmove  %edx,%eax
  8014b8:	eb 41                	jmp    8014fb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	ff 36                	pushl  (%esi)
  8014c3:	e8 66 ff ff ff       	call   80142e <dev_lookup>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 1a                	js     8014eb <fd_close+0x6a>
		if (dev->dev_close)
  8014d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	74 0b                	je     8014eb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	56                   	push   %esi
  8014e4:	ff d0                	call   *%eax
  8014e6:	89 c3                	mov    %eax,%ebx
  8014e8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	56                   	push   %esi
  8014ef:	6a 00                	push   $0x0
  8014f1:	e8 66 fc ff ff       	call   80115c <sys_page_unmap>
	return r;
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	89 d8                	mov    %ebx,%eax
}
  8014fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	ff 75 08             	pushl  0x8(%ebp)
  80150f:	e8 c4 fe ff ff       	call   8013d8 <fd_lookup>
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 10                	js     80152b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	6a 01                	push   $0x1
  801520:	ff 75 f4             	pushl  -0xc(%ebp)
  801523:	e8 59 ff ff ff       	call   801481 <fd_close>
  801528:	83 c4 10             	add    $0x10,%esp
}
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <close_all>:

void
close_all(void)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801534:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	53                   	push   %ebx
  80153d:	e8 c0 ff ff ff       	call   801502 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801542:	83 c3 01             	add    $0x1,%ebx
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	83 fb 20             	cmp    $0x20,%ebx
  80154b:	75 ec                	jne    801539 <close_all+0xc>
		close(i);
}
  80154d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	57                   	push   %edi
  801556:	56                   	push   %esi
  801557:	53                   	push   %ebx
  801558:	83 ec 2c             	sub    $0x2c,%esp
  80155b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	e8 6e fe ff ff       	call   8013d8 <fd_lookup>
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	0f 88 c1 00 00 00    	js     801636 <dup+0xe4>
		return r;
	close(newfdnum);
  801575:	83 ec 0c             	sub    $0xc,%esp
  801578:	56                   	push   %esi
  801579:	e8 84 ff ff ff       	call   801502 <close>

	newfd = INDEX2FD(newfdnum);
  80157e:	89 f3                	mov    %esi,%ebx
  801580:	c1 e3 0c             	shl    $0xc,%ebx
  801583:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801589:	83 c4 04             	add    $0x4,%esp
  80158c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158f:	e8 de fd ff ff       	call   801372 <fd2data>
  801594:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801596:	89 1c 24             	mov    %ebx,(%esp)
  801599:	e8 d4 fd ff ff       	call   801372 <fd2data>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a4:	89 f8                	mov    %edi,%eax
  8015a6:	c1 e8 16             	shr    $0x16,%eax
  8015a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b0:	a8 01                	test   $0x1,%al
  8015b2:	74 37                	je     8015eb <dup+0x99>
  8015b4:	89 f8                	mov    %edi,%eax
  8015b6:	c1 e8 0c             	shr    $0xc,%eax
  8015b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c0:	f6 c2 01             	test   $0x1,%dl
  8015c3:	74 26                	je     8015eb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d4:	50                   	push   %eax
  8015d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d8:	6a 00                	push   $0x0
  8015da:	57                   	push   %edi
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 38 fb ff ff       	call   80111a <sys_page_map>
  8015e2:	89 c7                	mov    %eax,%edi
  8015e4:	83 c4 20             	add    $0x20,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 2e                	js     801619 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	c1 e8 0c             	shr    $0xc,%eax
  8015f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801602:	50                   	push   %eax
  801603:	53                   	push   %ebx
  801604:	6a 00                	push   $0x0
  801606:	52                   	push   %edx
  801607:	6a 00                	push   $0x0
  801609:	e8 0c fb ff ff       	call   80111a <sys_page_map>
  80160e:	89 c7                	mov    %eax,%edi
  801610:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801613:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801615:	85 ff                	test   %edi,%edi
  801617:	79 1d                	jns    801636 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	53                   	push   %ebx
  80161d:	6a 00                	push   $0x0
  80161f:	e8 38 fb ff ff       	call   80115c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801624:	83 c4 08             	add    $0x8,%esp
  801627:	ff 75 d4             	pushl  -0x2c(%ebp)
  80162a:	6a 00                	push   $0x0
  80162c:	e8 2b fb ff ff       	call   80115c <sys_page_unmap>
	return r;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	89 f8                	mov    %edi,%eax
}
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	53                   	push   %ebx
  80164d:	e8 86 fd ff ff       	call   8013d8 <fd_lookup>
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	89 c2                	mov    %eax,%edx
  801657:	85 c0                	test   %eax,%eax
  801659:	78 6d                	js     8016c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 c2 fd ff ff       	call   80142e <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 4c                	js     8016bf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801673:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801676:	8b 42 08             	mov    0x8(%edx),%eax
  801679:	83 e0 03             	and    $0x3,%eax
  80167c:	83 f8 01             	cmp    $0x1,%eax
  80167f:	75 21                	jne    8016a2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801681:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801686:	8b 40 48             	mov    0x48(%eax),%eax
  801689:	83 ec 04             	sub    $0x4,%esp
  80168c:	53                   	push   %ebx
  80168d:	50                   	push   %eax
  80168e:	68 18 29 80 00       	push   $0x802918
  801693:	e8 38 f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a0:	eb 26                	jmp    8016c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a5:	8b 40 08             	mov    0x8(%eax),%eax
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	74 17                	je     8016c3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	ff 75 10             	pushl  0x10(%ebp)
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	52                   	push   %edx
  8016b6:	ff d0                	call   *%eax
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	eb 09                	jmp    8016c8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	eb 05                	jmp    8016c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016c8:	89 d0                	mov    %edx,%eax
  8016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	57                   	push   %edi
  8016d3:	56                   	push   %esi
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 0c             	sub    $0xc,%esp
  8016d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e3:	eb 21                	jmp    801706 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e5:	83 ec 04             	sub    $0x4,%esp
  8016e8:	89 f0                	mov    %esi,%eax
  8016ea:	29 d8                	sub    %ebx,%eax
  8016ec:	50                   	push   %eax
  8016ed:	89 d8                	mov    %ebx,%eax
  8016ef:	03 45 0c             	add    0xc(%ebp),%eax
  8016f2:	50                   	push   %eax
  8016f3:	57                   	push   %edi
  8016f4:	e8 45 ff ff ff       	call   80163e <read>
		if (m < 0)
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 10                	js     801710 <readn+0x41>
			return m;
		if (m == 0)
  801700:	85 c0                	test   %eax,%eax
  801702:	74 0a                	je     80170e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801704:	01 c3                	add    %eax,%ebx
  801706:	39 f3                	cmp    %esi,%ebx
  801708:	72 db                	jb     8016e5 <readn+0x16>
  80170a:	89 d8                	mov    %ebx,%eax
  80170c:	eb 02                	jmp    801710 <readn+0x41>
  80170e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5f                   	pop    %edi
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 14             	sub    $0x14,%esp
  80171f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	53                   	push   %ebx
  801727:	e8 ac fc ff ff       	call   8013d8 <fd_lookup>
  80172c:	83 c4 08             	add    $0x8,%esp
  80172f:	89 c2                	mov    %eax,%edx
  801731:	85 c0                	test   %eax,%eax
  801733:	78 68                	js     80179d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173f:	ff 30                	pushl  (%eax)
  801741:	e8 e8 fc ff ff       	call   80142e <dev_lookup>
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 47                	js     801794 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801750:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801754:	75 21                	jne    801777 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801756:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80175b:	8b 40 48             	mov    0x48(%eax),%eax
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	53                   	push   %ebx
  801762:	50                   	push   %eax
  801763:	68 34 29 80 00       	push   $0x802934
  801768:	e8 63 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801775:	eb 26                	jmp    80179d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801777:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177a:	8b 52 0c             	mov    0xc(%edx),%edx
  80177d:	85 d2                	test   %edx,%edx
  80177f:	74 17                	je     801798 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	ff 75 10             	pushl  0x10(%ebp)
  801787:	ff 75 0c             	pushl  0xc(%ebp)
  80178a:	50                   	push   %eax
  80178b:	ff d2                	call   *%edx
  80178d:	89 c2                	mov    %eax,%edx
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	eb 09                	jmp    80179d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801794:	89 c2                	mov    %eax,%edx
  801796:	eb 05                	jmp    80179d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801798:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80179d:	89 d0                	mov    %edx,%eax
  80179f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ad:	50                   	push   %eax
  8017ae:	ff 75 08             	pushl  0x8(%ebp)
  8017b1:	e8 22 fc ff ff       	call   8013d8 <fd_lookup>
  8017b6:	83 c4 08             	add    $0x8,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 0e                	js     8017cb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 14             	sub    $0x14,%esp
  8017d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017da:	50                   	push   %eax
  8017db:	53                   	push   %ebx
  8017dc:	e8 f7 fb ff ff       	call   8013d8 <fd_lookup>
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 65                	js     80184f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f0:	50                   	push   %eax
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	ff 30                	pushl  (%eax)
  8017f6:	e8 33 fc ff ff       	call   80142e <dev_lookup>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 44                	js     801846 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801809:	75 21                	jne    80182c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80180b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801810:	8b 40 48             	mov    0x48(%eax),%eax
  801813:	83 ec 04             	sub    $0x4,%esp
  801816:	53                   	push   %ebx
  801817:	50                   	push   %eax
  801818:	68 f4 28 80 00       	push   $0x8028f4
  80181d:	e8 ae ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182a:	eb 23                	jmp    80184f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80182c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182f:	8b 52 18             	mov    0x18(%edx),%edx
  801832:	85 d2                	test   %edx,%edx
  801834:	74 14                	je     80184a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	ff 75 0c             	pushl  0xc(%ebp)
  80183c:	50                   	push   %eax
  80183d:	ff d2                	call   *%edx
  80183f:	89 c2                	mov    %eax,%edx
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	eb 09                	jmp    80184f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801846:	89 c2                	mov    %eax,%edx
  801848:	eb 05                	jmp    80184f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80184a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80184f:	89 d0                	mov    %edx,%eax
  801851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 14             	sub    $0x14,%esp
  80185d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801860:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	ff 75 08             	pushl  0x8(%ebp)
  801867:	e8 6c fb ff ff       	call   8013d8 <fd_lookup>
  80186c:	83 c4 08             	add    $0x8,%esp
  80186f:	89 c2                	mov    %eax,%edx
  801871:	85 c0                	test   %eax,%eax
  801873:	78 58                	js     8018cd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187b:	50                   	push   %eax
  80187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187f:	ff 30                	pushl  (%eax)
  801881:	e8 a8 fb ff ff       	call   80142e <dev_lookup>
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 37                	js     8018c4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801890:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801894:	74 32                	je     8018c8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801896:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801899:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a0:	00 00 00 
	stat->st_isdir = 0;
  8018a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018aa:	00 00 00 
	stat->st_dev = dev;
  8018ad:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	53                   	push   %ebx
  8018b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ba:	ff 50 14             	call   *0x14(%eax)
  8018bd:	89 c2                	mov    %eax,%edx
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	eb 09                	jmp    8018cd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	eb 05                	jmp    8018cd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018cd:	89 d0                	mov    %edx,%eax
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	6a 00                	push   $0x0
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 e9 01 00 00       	call   801acf <open>
  8018e6:	89 c3                	mov    %eax,%ebx
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 1b                	js     80190a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	50                   	push   %eax
  8018f6:	e8 5b ff ff ff       	call   801856 <fstat>
  8018fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8018fd:	89 1c 24             	mov    %ebx,(%esp)
  801900:	e8 fd fb ff ff       	call   801502 <close>
	return r;
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	89 f0                	mov    %esi,%eax
}
  80190a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5e                   	pop    %esi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	89 c6                	mov    %eax,%esi
  801918:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80191a:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801921:	75 12                	jne    801935 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	6a 01                	push   $0x1
  801928:	e8 fb 07 00 00       	call   802128 <ipc_find_env>
  80192d:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801932:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801935:	6a 07                	push   $0x7
  801937:	68 00 50 80 00       	push   $0x805000
  80193c:	56                   	push   %esi
  80193d:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801943:	e8 8c 07 00 00       	call   8020d4 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801948:	83 c4 0c             	add    $0xc,%esp
  80194b:	6a 00                	push   $0x0
  80194d:	53                   	push   %ebx
  80194e:	6a 00                	push   $0x0
  801950:	e8 fd 06 00 00       	call   802052 <ipc_recv>
}
  801955:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	8b 40 0c             	mov    0xc(%eax),%eax
  801968:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80196d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801970:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801975:	ba 00 00 00 00       	mov    $0x0,%edx
  80197a:	b8 02 00 00 00       	mov    $0x2,%eax
  80197f:	e8 8d ff ff ff       	call   801911 <fsipc>
}
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	8b 40 0c             	mov    0xc(%eax),%eax
  801992:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801997:	ba 00 00 00 00       	mov    $0x0,%edx
  80199c:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a1:	e8 6b ff ff ff       	call   801911 <fsipc>
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 04             	sub    $0x4,%esp
  8019af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8019c7:	e8 45 ff ff ff       	call   801911 <fsipc>
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 2c                	js     8019fc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	68 00 50 80 00       	push   $0x805000
  8019d8:	53                   	push   %ebx
  8019d9:	e8 f6 f2 ff ff       	call   800cd4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019de:	a1 80 50 80 00       	mov    0x805080,%eax
  8019e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a0f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a14:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a17:	8b 55 08             	mov    0x8(%ebp),%edx
  801a1a:	8b 52 0c             	mov    0xc(%edx),%edx
  801a1d:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801a23:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801a28:	50                   	push   %eax
  801a29:	ff 75 0c             	pushl  0xc(%ebp)
  801a2c:	68 08 50 80 00       	push   $0x805008
  801a31:	e8 30 f4 ff ff       	call   800e66 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	b8 04 00 00 00       	mov    $0x4,%eax
  801a40:	e8 cc fe ff ff       	call   801911 <fsipc>
            return r;

    return r;
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a52:	8b 40 0c             	mov    0xc(%eax),%eax
  801a55:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5a:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a60:	ba 00 00 00 00       	mov    $0x0,%edx
  801a65:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6a:	e8 a2 fe ff ff       	call   801911 <fsipc>
  801a6f:	89 c3                	mov    %eax,%ebx
  801a71:	85 c0                	test   %eax,%eax
  801a73:	78 51                	js     801ac6 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801a75:	39 c6                	cmp    %eax,%esi
  801a77:	73 19                	jae    801a92 <devfile_read+0x4b>
  801a79:	68 64 29 80 00       	push   $0x802964
  801a7e:	68 6b 29 80 00       	push   $0x80296b
  801a83:	68 82 00 00 00       	push   $0x82
  801a88:	68 80 29 80 00       	push   $0x802980
  801a8d:	e8 65 eb ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801a92:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a97:	7e 19                	jle    801ab2 <devfile_read+0x6b>
  801a99:	68 8b 29 80 00       	push   $0x80298b
  801a9e:	68 6b 29 80 00       	push   $0x80296b
  801aa3:	68 83 00 00 00       	push   $0x83
  801aa8:	68 80 29 80 00       	push   $0x802980
  801aad:	e8 45 eb ff ff       	call   8005f7 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	50                   	push   %eax
  801ab6:	68 00 50 80 00       	push   $0x805000
  801abb:	ff 75 0c             	pushl  0xc(%ebp)
  801abe:	e8 a3 f3 ff ff       	call   800e66 <memmove>
	return r;
  801ac3:	83 c4 10             	add    $0x10,%esp
}
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 20             	sub    $0x20,%esp
  801ad6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad9:	53                   	push   %ebx
  801ada:	e8 bc f1 ff ff       	call   800c9b <strlen>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae7:	7f 67                	jg     801b50 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	e8 94 f8 ff ff       	call   801389 <fd_alloc>
  801af5:	83 c4 10             	add    $0x10,%esp
		return r;
  801af8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 57                	js     801b55 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	53                   	push   %ebx
  801b02:	68 00 50 80 00       	push   $0x805000
  801b07:	e8 c8 f1 ff ff       	call   800cd4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b17:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1c:	e8 f0 fd ff ff       	call   801911 <fsipc>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	79 14                	jns    801b3e <open+0x6f>
		fd_close(fd, 0);
  801b2a:	83 ec 08             	sub    $0x8,%esp
  801b2d:	6a 00                	push   $0x0
  801b2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b32:	e8 4a f9 ff ff       	call   801481 <fd_close>
		return r;
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	89 da                	mov    %ebx,%edx
  801b3c:	eb 17                	jmp    801b55 <open+0x86>
	}

	return fd2num(fd);
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	ff 75 f4             	pushl  -0xc(%ebp)
  801b44:	e8 19 f8 ff ff       	call   801362 <fd2num>
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	eb 05                	jmp    801b55 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b50:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b55:	89 d0                	mov    %edx,%eax
  801b57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
  801b67:	b8 08 00 00 00       	mov    $0x8,%eax
  801b6c:	e8 a0 fd ff ff       	call   801911 <fsipc>
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	ff 75 08             	pushl  0x8(%ebp)
  801b81:	e8 ec f7 ff ff       	call   801372 <fd2data>
  801b86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b88:	83 c4 08             	add    $0x8,%esp
  801b8b:	68 97 29 80 00       	push   $0x802997
  801b90:	53                   	push   %ebx
  801b91:	e8 3e f1 ff ff       	call   800cd4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b96:	8b 46 04             	mov    0x4(%esi),%eax
  801b99:	2b 06                	sub    (%esi),%eax
  801b9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ba1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ba8:	00 00 00 
	stat->st_dev = &devpipe;
  801bab:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bb2:	30 80 00 
	return 0;
}
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bcb:	53                   	push   %ebx
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 89 f5 ff ff       	call   80115c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bd3:	89 1c 24             	mov    %ebx,(%esp)
  801bd6:	e8 97 f7 ff ff       	call   801372 <fd2data>
  801bdb:	83 c4 08             	add    $0x8,%esp
  801bde:	50                   	push   %eax
  801bdf:	6a 00                	push   $0x0
  801be1:	e8 76 f5 ff ff       	call   80115c <sys_page_unmap>
}
  801be6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	57                   	push   %edi
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	83 ec 1c             	sub    $0x1c,%esp
  801bf4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bf7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bf9:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bfe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	ff 75 e0             	pushl  -0x20(%ebp)
  801c07:	e8 55 05 00 00       	call   802161 <pageref>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	89 3c 24             	mov    %edi,(%esp)
  801c11:	e8 4b 05 00 00       	call   802161 <pageref>
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	39 c3                	cmp    %eax,%ebx
  801c1b:	0f 94 c1             	sete   %cl
  801c1e:	0f b6 c9             	movzbl %cl,%ecx
  801c21:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c24:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801c2a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c2d:	39 ce                	cmp    %ecx,%esi
  801c2f:	74 1b                	je     801c4c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c31:	39 c3                	cmp    %eax,%ebx
  801c33:	75 c4                	jne    801bf9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c35:	8b 42 58             	mov    0x58(%edx),%eax
  801c38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c3b:	50                   	push   %eax
  801c3c:	56                   	push   %esi
  801c3d:	68 9e 29 80 00       	push   $0x80299e
  801c42:	e8 89 ea ff ff       	call   8006d0 <cprintf>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	eb ad                	jmp    801bf9 <_pipeisclosed+0xe>
	}
}
  801c4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	57                   	push   %edi
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 28             	sub    $0x28,%esp
  801c60:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c63:	56                   	push   %esi
  801c64:	e8 09 f7 ff ff       	call   801372 <fd2data>
  801c69:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c73:	eb 4b                	jmp    801cc0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c75:	89 da                	mov    %ebx,%edx
  801c77:	89 f0                	mov    %esi,%eax
  801c79:	e8 6d ff ff ff       	call   801beb <_pipeisclosed>
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	75 48                	jne    801cca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c82:	e8 31 f4 ff ff       	call   8010b8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c87:	8b 43 04             	mov    0x4(%ebx),%eax
  801c8a:	8b 0b                	mov    (%ebx),%ecx
  801c8c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c8f:	39 d0                	cmp    %edx,%eax
  801c91:	73 e2                	jae    801c75 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c96:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c9a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	c1 fa 1f             	sar    $0x1f,%edx
  801ca2:	89 d1                	mov    %edx,%ecx
  801ca4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ca7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801caa:	83 e2 1f             	and    $0x1f,%edx
  801cad:	29 ca                	sub    %ecx,%edx
  801caf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cb3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cb7:	83 c0 01             	add    $0x1,%eax
  801cba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbd:	83 c7 01             	add    $0x1,%edi
  801cc0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cc3:	75 c2                	jne    801c87 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc8:	eb 05                	jmp    801ccf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd2:	5b                   	pop    %ebx
  801cd3:	5e                   	pop    %esi
  801cd4:	5f                   	pop    %edi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 18             	sub    $0x18,%esp
  801ce0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ce3:	57                   	push   %edi
  801ce4:	e8 89 f6 ff ff       	call   801372 <fd2data>
  801ce9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf3:	eb 3d                	jmp    801d32 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cf5:	85 db                	test   %ebx,%ebx
  801cf7:	74 04                	je     801cfd <devpipe_read+0x26>
				return i;
  801cf9:	89 d8                	mov    %ebx,%eax
  801cfb:	eb 44                	jmp    801d41 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	e8 e5 fe ff ff       	call   801beb <_pipeisclosed>
  801d06:	85 c0                	test   %eax,%eax
  801d08:	75 32                	jne    801d3c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d0a:	e8 a9 f3 ff ff       	call   8010b8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d0f:	8b 06                	mov    (%esi),%eax
  801d11:	3b 46 04             	cmp    0x4(%esi),%eax
  801d14:	74 df                	je     801cf5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d16:	99                   	cltd   
  801d17:	c1 ea 1b             	shr    $0x1b,%edx
  801d1a:	01 d0                	add    %edx,%eax
  801d1c:	83 e0 1f             	and    $0x1f,%eax
  801d1f:	29 d0                	sub    %edx,%eax
  801d21:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d29:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d2c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2f:	83 c3 01             	add    $0x1,%ebx
  801d32:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d35:	75 d8                	jne    801d0f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d37:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3a:	eb 05                	jmp    801d41 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	56                   	push   %esi
  801d4d:	53                   	push   %ebx
  801d4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	50                   	push   %eax
  801d55:	e8 2f f6 ff ff       	call   801389 <fd_alloc>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	89 c2                	mov    %eax,%edx
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	0f 88 2c 01 00 00    	js     801e93 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	68 07 04 00 00       	push   $0x407
  801d6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d72:	6a 00                	push   $0x0
  801d74:	e8 5e f3 ff ff       	call   8010d7 <sys_page_alloc>
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	89 c2                	mov    %eax,%edx
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	0f 88 0d 01 00 00    	js     801e93 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d86:	83 ec 0c             	sub    $0xc,%esp
  801d89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d8c:	50                   	push   %eax
  801d8d:	e8 f7 f5 ff ff       	call   801389 <fd_alloc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	0f 88 e2 00 00 00    	js     801e81 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9f:	83 ec 04             	sub    $0x4,%esp
  801da2:	68 07 04 00 00       	push   $0x407
  801da7:	ff 75 f0             	pushl  -0x10(%ebp)
  801daa:	6a 00                	push   $0x0
  801dac:	e8 26 f3 ff ff       	call   8010d7 <sys_page_alloc>
  801db1:	89 c3                	mov    %eax,%ebx
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	0f 88 c3 00 00 00    	js     801e81 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dbe:	83 ec 0c             	sub    $0xc,%esp
  801dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc4:	e8 a9 f5 ff ff       	call   801372 <fd2data>
  801dc9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcb:	83 c4 0c             	add    $0xc,%esp
  801dce:	68 07 04 00 00       	push   $0x407
  801dd3:	50                   	push   %eax
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 fc f2 ff ff       	call   8010d7 <sys_page_alloc>
  801ddb:	89 c3                	mov    %eax,%ebx
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	85 c0                	test   %eax,%eax
  801de2:	0f 88 89 00 00 00    	js     801e71 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de8:	83 ec 0c             	sub    $0xc,%esp
  801deb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dee:	e8 7f f5 ff ff       	call   801372 <fd2data>
  801df3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dfa:	50                   	push   %eax
  801dfb:	6a 00                	push   $0x0
  801dfd:	56                   	push   %esi
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 15 f3 ff ff       	call   80111a <sys_page_map>
  801e05:	89 c3                	mov    %eax,%ebx
  801e07:	83 c4 20             	add    $0x20,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	78 55                	js     801e63 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e2c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e31:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3e:	e8 1f f5 ff ff       	call   801362 <fd2num>
  801e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e46:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e48:	83 c4 04             	add    $0x4,%esp
  801e4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4e:	e8 0f f5 ff ff       	call   801362 <fd2num>
  801e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e56:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e61:	eb 30                	jmp    801e93 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e63:	83 ec 08             	sub    $0x8,%esp
  801e66:	56                   	push   %esi
  801e67:	6a 00                	push   $0x0
  801e69:	e8 ee f2 ff ff       	call   80115c <sys_page_unmap>
  801e6e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e71:	83 ec 08             	sub    $0x8,%esp
  801e74:	ff 75 f0             	pushl  -0x10(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 de f2 ff ff       	call   80115c <sys_page_unmap>
  801e7e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e81:	83 ec 08             	sub    $0x8,%esp
  801e84:	ff 75 f4             	pushl  -0xc(%ebp)
  801e87:	6a 00                	push   $0x0
  801e89:	e8 ce f2 ff ff       	call   80115c <sys_page_unmap>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e93:	89 d0                	mov    %edx,%eax
  801e95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea5:	50                   	push   %eax
  801ea6:	ff 75 08             	pushl  0x8(%ebp)
  801ea9:	e8 2a f5 ff ff       	call   8013d8 <fd_lookup>
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 18                	js     801ecd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebb:	e8 b2 f4 ff ff       	call   801372 <fd2data>
	return _pipeisclosed(fd, p);
  801ec0:	89 c2                	mov    %eax,%edx
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	e8 21 fd ff ff       	call   801beb <_pipeisclosed>
  801eca:	83 c4 10             	add    $0x10,%esp
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801edf:	68 b6 29 80 00       	push   $0x8029b6
  801ee4:	ff 75 0c             	pushl  0xc(%ebp)
  801ee7:	e8 e8 ed ff ff       	call   800cd4 <strcpy>
	return 0;
}
  801eec:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	57                   	push   %edi
  801ef7:	56                   	push   %esi
  801ef8:	53                   	push   %ebx
  801ef9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f04:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0a:	eb 2d                	jmp    801f39 <devcons_write+0x46>
		m = n - tot;
  801f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f0f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f11:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f14:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f19:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f1c:	83 ec 04             	sub    $0x4,%esp
  801f1f:	53                   	push   %ebx
  801f20:	03 45 0c             	add    0xc(%ebp),%eax
  801f23:	50                   	push   %eax
  801f24:	57                   	push   %edi
  801f25:	e8 3c ef ff ff       	call   800e66 <memmove>
		sys_cputs(buf, m);
  801f2a:	83 c4 08             	add    $0x8,%esp
  801f2d:	53                   	push   %ebx
  801f2e:	57                   	push   %edi
  801f2f:	e8 e7 f0 ff ff       	call   80101b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f34:	01 de                	add    %ebx,%esi
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	89 f0                	mov    %esi,%eax
  801f3b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f3e:	72 cc                	jb     801f0c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    

00801f48 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 08             	sub    $0x8,%esp
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f57:	74 2a                	je     801f83 <devcons_read+0x3b>
  801f59:	eb 05                	jmp    801f60 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f5b:	e8 58 f1 ff ff       	call   8010b8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f60:	e8 d4 f0 ff ff       	call   801039 <sys_cgetc>
  801f65:	85 c0                	test   %eax,%eax
  801f67:	74 f2                	je     801f5b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 16                	js     801f83 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f6d:	83 f8 04             	cmp    $0x4,%eax
  801f70:	74 0c                	je     801f7e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f75:	88 02                	mov    %al,(%edx)
	return 1;
  801f77:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7c:	eb 05                	jmp    801f83 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f83:	c9                   	leave  
  801f84:	c3                   	ret    

00801f85 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f91:	6a 01                	push   $0x1
  801f93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f96:	50                   	push   %eax
  801f97:	e8 7f f0 ff ff       	call   80101b <sys_cputs>
}
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <getchar>:

int
getchar(void)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fa7:	6a 01                	push   $0x1
  801fa9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fac:	50                   	push   %eax
  801fad:	6a 00                	push   $0x0
  801faf:	e8 8a f6 ff ff       	call   80163e <read>
	if (r < 0)
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	78 0f                	js     801fca <getchar+0x29>
		return r;
	if (r < 1)
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	7e 06                	jle    801fc5 <getchar+0x24>
		return -E_EOF;
	return c;
  801fbf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fc3:	eb 05                	jmp    801fca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fc5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	ff 75 08             	pushl  0x8(%ebp)
  801fd9:	e8 fa f3 ff ff       	call   8013d8 <fd_lookup>
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 11                	js     801ff6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fee:	39 10                	cmp    %edx,(%eax)
  801ff0:	0f 94 c0             	sete   %al
  801ff3:	0f b6 c0             	movzbl %al,%eax
}
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <opencons>:

int
opencons(void)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ffe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802001:	50                   	push   %eax
  802002:	e8 82 f3 ff ff       	call   801389 <fd_alloc>
  802007:	83 c4 10             	add    $0x10,%esp
		return r;
  80200a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 3e                	js     80204e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802010:	83 ec 04             	sub    $0x4,%esp
  802013:	68 07 04 00 00       	push   $0x407
  802018:	ff 75 f4             	pushl  -0xc(%ebp)
  80201b:	6a 00                	push   $0x0
  80201d:	e8 b5 f0 ff ff       	call   8010d7 <sys_page_alloc>
  802022:	83 c4 10             	add    $0x10,%esp
		return r;
  802025:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802027:	85 c0                	test   %eax,%eax
  802029:	78 23                	js     80204e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80202b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802031:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802034:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802036:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802039:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802040:	83 ec 0c             	sub    $0xc,%esp
  802043:	50                   	push   %eax
  802044:	e8 19 f3 ff ff       	call   801362 <fd2num>
  802049:	89 c2                	mov    %eax,%edx
  80204b:	83 c4 10             	add    $0x10,%esp
}
  80204e:	89 d0                	mov    %edx,%eax
  802050:	c9                   	leave  
  802051:	c3                   	ret    

00802052 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	57                   	push   %edi
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	8b 75 08             	mov    0x8(%ebp),%esi
  80205e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  802064:	85 f6                	test   %esi,%esi
  802066:	74 06                	je     80206e <ipc_recv+0x1c>
		*from_env_store = 0;
  802068:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  80206e:	85 db                	test   %ebx,%ebx
  802070:	74 06                	je     802078 <ipc_recv+0x26>
		*perm_store = 0;
  802072:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  802078:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  80207a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80207f:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  802082:	83 ec 0c             	sub    $0xc,%esp
  802085:	50                   	push   %eax
  802086:	e8 fc f1 ff ff       	call   801287 <sys_ipc_recv>
  80208b:	89 c7                	mov    %eax,%edi
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	85 c0                	test   %eax,%eax
  802092:	79 14                	jns    8020a8 <ipc_recv+0x56>
		cprintf("im dead");
  802094:	83 ec 0c             	sub    $0xc,%esp
  802097:	68 c2 29 80 00       	push   $0x8029c2
  80209c:	e8 2f e6 ff ff       	call   8006d0 <cprintf>
		return r;
  8020a1:	83 c4 10             	add    $0x10,%esp
  8020a4:	89 f8                	mov    %edi,%eax
  8020a6:	eb 24                	jmp    8020cc <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  8020a8:	85 f6                	test   %esi,%esi
  8020aa:	74 0a                	je     8020b6 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  8020ac:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020b1:	8b 40 74             	mov    0x74(%eax),%eax
  8020b4:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  8020b6:	85 db                	test   %ebx,%ebx
  8020b8:	74 0a                	je     8020c4 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  8020ba:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020bf:	8b 40 78             	mov    0x78(%eax),%eax
  8020c2:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  8020c4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020c9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	57                   	push   %edi
  8020d8:	56                   	push   %esi
  8020d9:	53                   	push   %ebx
  8020da:	83 ec 0c             	sub    $0xc,%esp
  8020dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  8020e6:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  8020e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020ed:	0f 44 d8             	cmove  %eax,%ebx
  8020f0:	eb 1c                	jmp    80210e <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8020f2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020f5:	74 12                	je     802109 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  8020f7:	50                   	push   %eax
  8020f8:	68 ca 29 80 00       	push   $0x8029ca
  8020fd:	6a 4e                	push   $0x4e
  8020ff:	68 d7 29 80 00       	push   $0x8029d7
  802104:	e8 ee e4 ff ff       	call   8005f7 <_panic>
		sys_yield();
  802109:	e8 aa ef ff ff       	call   8010b8 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80210e:	ff 75 14             	pushl  0x14(%ebp)
  802111:	53                   	push   %ebx
  802112:	56                   	push   %esi
  802113:	57                   	push   %edi
  802114:	e8 4b f1 ff ff       	call   801264 <sys_ipc_try_send>
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	85 c0                	test   %eax,%eax
  80211e:	78 d2                	js     8020f2 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  802120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    

00802128 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802133:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802136:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80213c:	8b 52 50             	mov    0x50(%edx),%edx
  80213f:	39 ca                	cmp    %ecx,%edx
  802141:	75 0d                	jne    802150 <ipc_find_env+0x28>
			return envs[i].env_id;
  802143:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802146:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80214b:	8b 40 48             	mov    0x48(%eax),%eax
  80214e:	eb 0f                	jmp    80215f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802150:	83 c0 01             	add    $0x1,%eax
  802153:	3d 00 04 00 00       	cmp    $0x400,%eax
  802158:	75 d9                	jne    802133 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80215a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    

00802161 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802167:	89 d0                	mov    %edx,%eax
  802169:	c1 e8 16             	shr    $0x16,%eax
  80216c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802173:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802178:	f6 c1 01             	test   $0x1,%cl
  80217b:	74 1d                	je     80219a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80217d:	c1 ea 0c             	shr    $0xc,%edx
  802180:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802187:	f6 c2 01             	test   $0x1,%dl
  80218a:	74 0e                	je     80219a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80218c:	c1 ea 0c             	shr    $0xc,%edx
  80218f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802196:	ef 
  802197:	0f b7 c0             	movzwl %ax,%eax
}
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

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
