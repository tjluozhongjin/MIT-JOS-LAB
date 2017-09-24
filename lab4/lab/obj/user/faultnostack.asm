
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 8a 10 80 00       	push   $0x80108a
  800116:	6a 23                	push   $0x23
  800118:	68 a7 10 80 00       	push   $0x8010a7
  80011d:	e8 1b 02 00 00       	call   80033d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 8a 10 80 00       	push   $0x80108a
  800197:	6a 23                	push   $0x23
  800199:	68 a7 10 80 00       	push   $0x8010a7
  80019e:	e8 9a 01 00 00       	call   80033d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 8a 10 80 00       	push   $0x80108a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 a7 10 80 00       	push   $0x8010a7
  8001e0:	e8 58 01 00 00       	call   80033d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 8a 10 80 00       	push   $0x80108a
  80021b:	6a 23                	push   $0x23
  80021d:	68 a7 10 80 00       	push   $0x8010a7
  800222:	e8 16 01 00 00       	call   80033d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 8a 10 80 00       	push   $0x80108a
  80025d:	6a 23                	push   $0x23
  80025f:	68 a7 10 80 00       	push   $0x8010a7
  800264:	e8 d4 00 00 00       	call   80033d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 8a 10 80 00       	push   $0x80108a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 a7 10 80 00       	push   $0x8010a7
  8002a6:	e8 92 00 00 00       	call   80033d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 8a 10 80 00       	push   $0x80108a
  800303:	6a 23                	push   $0x23
  800305:	68 a7 10 80 00       	push   $0x8010a7
  80030a:	e8 2e 00 00 00       	call   80033d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800322:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800326:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  800329:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80032d:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  80032f:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800333:	83 c4 08             	add    $0x8,%esp
	popal
  800336:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800337:	83 c4 04             	add    $0x4,%esp
	popfl
  80033a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  80033b:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80033c:	c3                   	ret    

0080033d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800345:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034b:	e8 da fd ff ff       	call   80012a <sys_getenvid>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	56                   	push   %esi
  80035a:	50                   	push   %eax
  80035b:	68 b8 10 80 00       	push   $0x8010b8
  800360:	e8 b1 00 00 00       	call   800416 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	e8 54 00 00 00       	call   8003c5 <vcprintf>
	cprintf("\n");
  800371:	c7 04 24 3b 13 80 00 	movl   $0x80133b,(%esp)
  800378:	e8 99 00 00 00       	call   800416 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x43>

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 04             	sub    $0x4,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 13                	mov    (%ebx),%edx
  80038f:	8d 42 01             	lea    0x1(%edx),%eax
  800392:	89 03                	mov    %eax,(%ebx)
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	75 1a                	jne    8003bc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	68 ff 00 00 00       	push   $0xff
  8003aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ad:	50                   	push   %eax
  8003ae:	e8 f9 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d5:	00 00 00 
	b.cnt = 0;
  8003d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e2:	ff 75 0c             	pushl  0xc(%ebp)
  8003e5:	ff 75 08             	pushl  0x8(%ebp)
  8003e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ee:	50                   	push   %eax
  8003ef:	68 83 03 80 00       	push   $0x800383
  8003f4:	e8 1a 01 00 00       	call   800513 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f9:	83 c4 08             	add    $0x8,%esp
  8003fc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800402:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800408:	50                   	push   %eax
  800409:	e8 9e fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800414:	c9                   	leave  
  800415:	c3                   	ret    

00800416 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041f:	50                   	push   %eax
  800420:	ff 75 08             	pushl  0x8(%ebp)
  800423:	e8 9d ff ff ff       	call   8003c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 1c             	sub    $0x1c,%esp
  800433:	89 c7                	mov    %eax,%edi
  800435:	89 d6                	mov    %edx,%esi
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800440:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800443:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800446:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800451:	39 d3                	cmp    %edx,%ebx
  800453:	72 05                	jb     80045a <printnum+0x30>
  800455:	39 45 10             	cmp    %eax,0x10(%ebp)
  800458:	77 45                	ja     80049f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045a:	83 ec 0c             	sub    $0xc,%esp
  80045d:	ff 75 18             	pushl  0x18(%ebp)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800466:	53                   	push   %ebx
  800467:	ff 75 10             	pushl  0x10(%ebp)
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff 75 dc             	pushl  -0x24(%ebp)
  800476:	ff 75 d8             	pushl  -0x28(%ebp)
  800479:	e8 62 09 00 00       	call   800de0 <__udivdi3>
  80047e:	83 c4 18             	add    $0x18,%esp
  800481:	52                   	push   %edx
  800482:	50                   	push   %eax
  800483:	89 f2                	mov    %esi,%edx
  800485:	89 f8                	mov    %edi,%eax
  800487:	e8 9e ff ff ff       	call   80042a <printnum>
  80048c:	83 c4 20             	add    $0x20,%esp
  80048f:	eb 18                	jmp    8004a9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	ff 75 18             	pushl  0x18(%ebp)
  800498:	ff d7                	call   *%edi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	eb 03                	jmp    8004a2 <printnum+0x78>
  80049f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	85 db                	test   %ebx,%ebx
  8004a7:	7f e8                	jg     800491 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	83 ec 04             	sub    $0x4,%esp
  8004b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bc:	e8 4f 0a 00 00       	call   800f10 <__umoddi3>
  8004c1:	83 c4 14             	add    $0x14,%esp
  8004c4:	0f be 80 dc 10 80 00 	movsbl 0x8010dc(%eax),%eax
  8004cb:	50                   	push   %eax
  8004cc:	ff d7                	call   *%edi
}
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d4:	5b                   	pop    %ebx
  8004d5:	5e                   	pop    %esi
  8004d6:	5f                   	pop    %edi
  8004d7:	5d                   	pop    %ebp
  8004d8:	c3                   	ret    

008004d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e3:	8b 10                	mov    (%eax),%edx
  8004e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e8:	73 0a                	jae    8004f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ed:	89 08                	mov    %ecx,(%eax)
  8004ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f2:	88 02                	mov    %al,(%edx)
}
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    

008004f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ff:	50                   	push   %eax
  800500:	ff 75 10             	pushl  0x10(%ebp)
  800503:	ff 75 0c             	pushl  0xc(%ebp)
  800506:	ff 75 08             	pushl  0x8(%ebp)
  800509:	e8 05 00 00 00       	call   800513 <vprintfmt>
	va_end(ap);
}
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	c9                   	leave  
  800512:	c3                   	ret    

00800513 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	57                   	push   %edi
  800517:	56                   	push   %esi
  800518:	53                   	push   %ebx
  800519:	83 ec 2c             	sub    $0x2c,%esp
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	8b 7d 10             	mov    0x10(%ebp),%edi
  800525:	eb 12                	jmp    800539 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800527:	85 c0                	test   %eax,%eax
  800529:	0f 84 42 04 00 00    	je     800971 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	50                   	push   %eax
  800534:	ff d6                	call   *%esi
  800536:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800540:	83 f8 25             	cmp    $0x25,%eax
  800543:	75 e2                	jne    800527 <vprintfmt+0x14>
  800545:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800549:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800550:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800557:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800563:	eb 07                	jmp    80056c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800568:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8d 47 01             	lea    0x1(%edi),%eax
  80056f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800572:	0f b6 07             	movzbl (%edi),%eax
  800575:	0f b6 d0             	movzbl %al,%edx
  800578:	83 e8 23             	sub    $0x23,%eax
  80057b:	3c 55                	cmp    $0x55,%al
  80057d:	0f 87 d3 03 00 00    	ja     800956 <vprintfmt+0x443>
  800583:	0f b6 c0             	movzbl %al,%eax
  800586:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800590:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800594:	eb d6                	jmp    80056c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	b8 00 00 00 00       	mov    $0x0,%eax
  80059e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005ab:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ae:	83 f9 09             	cmp    $0x9,%ecx
  8005b1:	77 3f                	ja     8005f2 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b6:	eb e9                	jmp    8005a1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cc:	eb 2a                	jmp    8005f8 <vprintfmt+0xe5>
  8005ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d8:	0f 49 d0             	cmovns %eax,%edx
  8005db:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e1:	eb 89                	jmp    80056c <vprintfmt+0x59>
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ed:	e9 7a ff ff ff       	jmp    80056c <vprintfmt+0x59>
  8005f2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fc:	0f 89 6a ff ff ff    	jns    80056c <vprintfmt+0x59>
				width = precision, precision = -1;
  800602:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800605:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800608:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80060f:	e9 58 ff ff ff       	jmp    80056c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800614:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061a:	e9 4d ff ff ff       	jmp    80056c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 78 04             	lea    0x4(%eax),%edi
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	ff 30                	pushl  (%eax)
  80062b:	ff d6                	call   *%esi
			break;
  80062d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800630:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800636:	e9 fe fe ff ff       	jmp    800539 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 78 04             	lea    0x4(%eax),%edi
  800641:	8b 00                	mov    (%eax),%eax
  800643:	99                   	cltd   
  800644:	31 d0                	xor    %edx,%eax
  800646:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800648:	83 f8 08             	cmp    $0x8,%eax
  80064b:	7f 0b                	jg     800658 <vprintfmt+0x145>
  80064d:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	75 1b                	jne    800673 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800658:	50                   	push   %eax
  800659:	68 f4 10 80 00       	push   $0x8010f4
  80065e:	53                   	push   %ebx
  80065f:	56                   	push   %esi
  800660:	e8 91 fe ff ff       	call   8004f6 <printfmt>
  800665:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800668:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066e:	e9 c6 fe ff ff       	jmp    800539 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800673:	52                   	push   %edx
  800674:	68 fd 10 80 00       	push   $0x8010fd
  800679:	53                   	push   %ebx
  80067a:	56                   	push   %esi
  80067b:	e8 76 fe ff ff       	call   8004f6 <printfmt>
  800680:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800683:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800689:	e9 ab fe ff ff       	jmp    800539 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	83 c0 04             	add    $0x4,%eax
  800694:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069c:	85 ff                	test   %edi,%edi
  80069e:	b8 ed 10 80 00       	mov    $0x8010ed,%eax
  8006a3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006aa:	0f 8e 94 00 00 00    	jle    800744 <vprintfmt+0x231>
  8006b0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b4:	0f 84 98 00 00 00    	je     800752 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c0:	57                   	push   %edi
  8006c1:	e8 33 03 00 00       	call   8009f9 <strnlen>
  8006c6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c9:	29 c1                	sub    %eax,%ecx
  8006cb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006ce:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006db:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	eb 0f                	jmp    8006ee <vprintfmt+0x1db>
					putch(padc, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 ff                	test   %edi,%edi
  8006f0:	7f ed                	jg     8006df <vprintfmt+0x1cc>
  8006f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	0f 49 c1             	cmovns %ecx,%eax
  800702:	29 c1                	sub    %eax,%ecx
  800704:	89 75 08             	mov    %esi,0x8(%ebp)
  800707:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070d:	89 cb                	mov    %ecx,%ebx
  80070f:	eb 4d                	jmp    80075e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800715:	74 1b                	je     800732 <vprintfmt+0x21f>
  800717:	0f be c0             	movsbl %al,%eax
  80071a:	83 e8 20             	sub    $0x20,%eax
  80071d:	83 f8 5e             	cmp    $0x5e,%eax
  800720:	76 10                	jbe    800732 <vprintfmt+0x21f>
					putch('?', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	6a 3f                	push   $0x3f
  80072a:	ff 55 08             	call   *0x8(%ebp)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 0d                	jmp    80073f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	52                   	push   %edx
  800739:	ff 55 08             	call   *0x8(%ebp)
  80073c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073f:	83 eb 01             	sub    $0x1,%ebx
  800742:	eb 1a                	jmp    80075e <vprintfmt+0x24b>
  800744:	89 75 08             	mov    %esi,0x8(%ebp)
  800747:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800750:	eb 0c                	jmp    80075e <vprintfmt+0x24b>
  800752:	89 75 08             	mov    %esi,0x8(%ebp)
  800755:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800758:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075e:	83 c7 01             	add    $0x1,%edi
  800761:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800765:	0f be d0             	movsbl %al,%edx
  800768:	85 d2                	test   %edx,%edx
  80076a:	74 23                	je     80078f <vprintfmt+0x27c>
  80076c:	85 f6                	test   %esi,%esi
  80076e:	78 a1                	js     800711 <vprintfmt+0x1fe>
  800770:	83 ee 01             	sub    $0x1,%esi
  800773:	79 9c                	jns    800711 <vprintfmt+0x1fe>
  800775:	89 df                	mov    %ebx,%edi
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077d:	eb 18                	jmp    800797 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 20                	push   $0x20
  800785:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800787:	83 ef 01             	sub    $0x1,%edi
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	eb 08                	jmp    800797 <vprintfmt+0x284>
  80078f:	89 df                	mov    %ebx,%edi
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800797:	85 ff                	test   %edi,%edi
  800799:	7f e4                	jg     80077f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80079b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a4:	e9 90 fd ff ff       	jmp    800539 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a9:	83 f9 01             	cmp    $0x1,%ecx
  8007ac:	7e 19                	jle    8007c7 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8b 50 04             	mov    0x4(%eax),%edx
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 40 08             	lea    0x8(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c5:	eb 38                	jmp    8007ff <vprintfmt+0x2ec>
	else if (lflag)
  8007c7:	85 c9                	test   %ecx,%ecx
  8007c9:	74 1b                	je     8007e6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e4:	eb 19                	jmp    8007ff <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 c1                	mov    %eax,%ecx
  8007f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800802:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800805:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080e:	0f 89 0e 01 00 00    	jns    800922 <vprintfmt+0x40f>
				putch('-', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	6a 2d                	push   $0x2d
  80081a:	ff d6                	call   *%esi
				num = -(long long) num;
  80081c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800822:	f7 da                	neg    %edx
  800824:	83 d1 00             	adc    $0x0,%ecx
  800827:	f7 d9                	neg    %ecx
  800829:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800831:	e9 ec 00 00 00       	jmp    800922 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800836:	83 f9 01             	cmp    $0x1,%ecx
  800839:	7e 18                	jle    800853 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8b 48 04             	mov    0x4(%eax),%ecx
  800843:	8d 40 08             	lea    0x8(%eax),%eax
  800846:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800849:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084e:	e9 cf 00 00 00       	jmp    800922 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800853:	85 c9                	test   %ecx,%ecx
  800855:	74 1a                	je     800871 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800861:	8d 40 04             	lea    0x4(%eax),%eax
  800864:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800867:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086c:	e9 b1 00 00 00       	jmp    800922 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8b 10                	mov    (%eax),%edx
  800876:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087b:	8d 40 04             	lea    0x4(%eax),%eax
  80087e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800881:	b8 0a 00 00 00       	mov    $0xa,%eax
  800886:	e9 97 00 00 00       	jmp    800922 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	6a 58                	push   $0x58
  800891:	ff d6                	call   *%esi
			putch('X', putdat);
  800893:	83 c4 08             	add    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 58                	push   $0x58
  800899:	ff d6                	call   *%esi
			putch('X', putdat);
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 58                	push   $0x58
  8008a1:	ff d6                	call   *%esi
			break;
  8008a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008a9:	e9 8b fc ff ff       	jmp    800539 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	6a 30                	push   $0x30
  8008b4:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b6:	83 c4 08             	add    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	6a 78                	push   $0x78
  8008bc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008be:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c1:	8b 10                	mov    (%eax),%edx
  8008c3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008c8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008cb:	8d 40 04             	lea    0x4(%eax),%eax
  8008ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d6:	eb 4a                	jmp    800922 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d8:	83 f9 01             	cmp    $0x1,%ecx
  8008db:	7e 15                	jle    8008f2 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8b 10                	mov    (%eax),%edx
  8008e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e5:	8d 40 08             	lea    0x8(%eax),%eax
  8008e8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f0:	eb 30                	jmp    800922 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008f2:	85 c9                	test   %ecx,%ecx
  8008f4:	74 17                	je     80090d <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8b 10                	mov    (%eax),%edx
  8008fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800900:	8d 40 04             	lea    0x4(%eax),%eax
  800903:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800906:	b8 10 00 00 00       	mov    $0x10,%eax
  80090b:	eb 15                	jmp    800922 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8b 10                	mov    (%eax),%edx
  800912:	b9 00 00 00 00       	mov    $0x0,%ecx
  800917:	8d 40 04             	lea    0x4(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80091d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800922:	83 ec 0c             	sub    $0xc,%esp
  800925:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800929:	57                   	push   %edi
  80092a:	ff 75 e0             	pushl  -0x20(%ebp)
  80092d:	50                   	push   %eax
  80092e:	51                   	push   %ecx
  80092f:	52                   	push   %edx
  800930:	89 da                	mov    %ebx,%edx
  800932:	89 f0                	mov    %esi,%eax
  800934:	e8 f1 fa ff ff       	call   80042a <printnum>
			break;
  800939:	83 c4 20             	add    $0x20,%esp
  80093c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093f:	e9 f5 fb ff ff       	jmp    800539 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800944:	83 ec 08             	sub    $0x8,%esp
  800947:	53                   	push   %ebx
  800948:	52                   	push   %edx
  800949:	ff d6                	call   *%esi
			break;
  80094b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800951:	e9 e3 fb ff ff       	jmp    800539 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 25                	push   $0x25
  80095c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095e:	83 c4 10             	add    $0x10,%esp
  800961:	eb 03                	jmp    800966 <vprintfmt+0x453>
  800963:	83 ef 01             	sub    $0x1,%edi
  800966:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80096a:	75 f7                	jne    800963 <vprintfmt+0x450>
  80096c:	e9 c8 fb ff ff       	jmp    800539 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800971:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 18             	sub    $0x18,%esp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800985:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800988:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800996:	85 c0                	test   %eax,%eax
  800998:	74 26                	je     8009c0 <vsnprintf+0x47>
  80099a:	85 d2                	test   %edx,%edx
  80099c:	7e 22                	jle    8009c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099e:	ff 75 14             	pushl  0x14(%ebp)
  8009a1:	ff 75 10             	pushl  0x10(%ebp)
  8009a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a7:	50                   	push   %eax
  8009a8:	68 d9 04 80 00       	push   $0x8004d9
  8009ad:	e8 61 fb ff ff       	call   800513 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	eb 05                	jmp    8009c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d0:	50                   	push   %eax
  8009d1:	ff 75 10             	pushl  0x10(%ebp)
  8009d4:	ff 75 0c             	pushl  0xc(%ebp)
  8009d7:	ff 75 08             	pushl  0x8(%ebp)
  8009da:	e8 9a ff ff ff       	call   800979 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ec:	eb 03                	jmp    8009f1 <strlen+0x10>
		n++;
  8009ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f5:	75 f7                	jne    8009ee <strlen+0xd>
		n++;
	return n;
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	eb 03                	jmp    800a0c <strnlen+0x13>
		n++;
  800a09:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0c:	39 c2                	cmp    %eax,%edx
  800a0e:	74 08                	je     800a18 <strnlen+0x1f>
  800a10:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a14:	75 f3                	jne    800a09 <strnlen+0x10>
  800a16:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a24:	89 c2                	mov    %eax,%edx
  800a26:	83 c2 01             	add    $0x1,%edx
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a30:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a33:	84 db                	test   %bl,%bl
  800a35:	75 ef                	jne    800a26 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	53                   	push   %ebx
  800a3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a41:	53                   	push   %ebx
  800a42:	e8 9a ff ff ff       	call   8009e1 <strlen>
  800a47:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4a:	ff 75 0c             	pushl  0xc(%ebp)
  800a4d:	01 d8                	add    %ebx,%eax
  800a4f:	50                   	push   %eax
  800a50:	e8 c5 ff ff ff       	call   800a1a <strcpy>
	return dst;
}
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 75 08             	mov    0x8(%ebp),%esi
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a67:	89 f3                	mov    %esi,%ebx
  800a69:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6c:	89 f2                	mov    %esi,%edx
  800a6e:	eb 0f                	jmp    800a7f <strncpy+0x23>
		*dst++ = *src;
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	0f b6 01             	movzbl (%ecx),%eax
  800a76:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a79:	80 39 01             	cmpb   $0x1,(%ecx)
  800a7c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7f:	39 da                	cmp    %ebx,%edx
  800a81:	75 ed                	jne    800a70 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a83:	89 f0                	mov    %esi,%eax
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a94:	8b 55 10             	mov    0x10(%ebp),%edx
  800a97:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a99:	85 d2                	test   %edx,%edx
  800a9b:	74 21                	je     800abe <strlcpy+0x35>
  800a9d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa1:	89 f2                	mov    %esi,%edx
  800aa3:	eb 09                	jmp    800aae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aa5:	83 c2 01             	add    $0x1,%edx
  800aa8:	83 c1 01             	add    $0x1,%ecx
  800aab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aae:	39 c2                	cmp    %eax,%edx
  800ab0:	74 09                	je     800abb <strlcpy+0x32>
  800ab2:	0f b6 19             	movzbl (%ecx),%ebx
  800ab5:	84 db                	test   %bl,%bl
  800ab7:	75 ec                	jne    800aa5 <strlcpy+0x1c>
  800ab9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800abb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800abe:	29 f0                	sub    %esi,%eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800acd:	eb 06                	jmp    800ad5 <strcmp+0x11>
		p++, q++;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad5:	0f b6 01             	movzbl (%ecx),%eax
  800ad8:	84 c0                	test   %al,%al
  800ada:	74 04                	je     800ae0 <strcmp+0x1c>
  800adc:	3a 02                	cmp    (%edx),%al
  800ade:	74 ef                	je     800acf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae0:	0f b6 c0             	movzbl %al,%eax
  800ae3:	0f b6 12             	movzbl (%edx),%edx
  800ae6:	29 d0                	sub    %edx,%eax
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	53                   	push   %ebx
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af4:	89 c3                	mov    %eax,%ebx
  800af6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800af9:	eb 06                	jmp    800b01 <strncmp+0x17>
		n--, p++, q++;
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b01:	39 d8                	cmp    %ebx,%eax
  800b03:	74 15                	je     800b1a <strncmp+0x30>
  800b05:	0f b6 08             	movzbl (%eax),%ecx
  800b08:	84 c9                	test   %cl,%cl
  800b0a:	74 04                	je     800b10 <strncmp+0x26>
  800b0c:	3a 0a                	cmp    (%edx),%cl
  800b0e:	74 eb                	je     800afb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b10:	0f b6 00             	movzbl (%eax),%eax
  800b13:	0f b6 12             	movzbl (%edx),%edx
  800b16:	29 d0                	sub    %edx,%eax
  800b18:	eb 05                	jmp    800b1f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2c:	eb 07                	jmp    800b35 <strchr+0x13>
		if (*s == c)
  800b2e:	38 ca                	cmp    %cl,%dl
  800b30:	74 0f                	je     800b41 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	75 f2                	jne    800b2e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b4d:	eb 03                	jmp    800b52 <strfind+0xf>
  800b4f:	83 c0 01             	add    $0x1,%eax
  800b52:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b55:	38 ca                	cmp    %cl,%dl
  800b57:	74 04                	je     800b5d <strfind+0x1a>
  800b59:	84 d2                	test   %dl,%dl
  800b5b:	75 f2                	jne    800b4f <strfind+0xc>
			break;
	return (char *) s;
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b6b:	85 c9                	test   %ecx,%ecx
  800b6d:	74 36                	je     800ba5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b75:	75 28                	jne    800b9f <memset+0x40>
  800b77:	f6 c1 03             	test   $0x3,%cl
  800b7a:	75 23                	jne    800b9f <memset+0x40>
		c &= 0xFF;
  800b7c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	c1 e3 08             	shl    $0x8,%ebx
  800b85:	89 d6                	mov    %edx,%esi
  800b87:	c1 e6 18             	shl    $0x18,%esi
  800b8a:	89 d0                	mov    %edx,%eax
  800b8c:	c1 e0 10             	shl    $0x10,%eax
  800b8f:	09 f0                	or     %esi,%eax
  800b91:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b93:	89 d8                	mov    %ebx,%eax
  800b95:	09 d0                	or     %edx,%eax
  800b97:	c1 e9 02             	shr    $0x2,%ecx
  800b9a:	fc                   	cld    
  800b9b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9d:	eb 06                	jmp    800ba5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba2:	fc                   	cld    
  800ba3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bba:	39 c6                	cmp    %eax,%esi
  800bbc:	73 35                	jae    800bf3 <memmove+0x47>
  800bbe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc1:	39 d0                	cmp    %edx,%eax
  800bc3:	73 2e                	jae    800bf3 <memmove+0x47>
		s += n;
		d += n;
  800bc5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	09 fe                	or     %edi,%esi
  800bcc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd2:	75 13                	jne    800be7 <memmove+0x3b>
  800bd4:	f6 c1 03             	test   $0x3,%cl
  800bd7:	75 0e                	jne    800be7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bd9:	83 ef 04             	sub    $0x4,%edi
  800bdc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bdf:	c1 e9 02             	shr    $0x2,%ecx
  800be2:	fd                   	std    
  800be3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be5:	eb 09                	jmp    800bf0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be7:	83 ef 01             	sub    $0x1,%edi
  800bea:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bed:	fd                   	std    
  800bee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf0:	fc                   	cld    
  800bf1:	eb 1d                	jmp    800c10 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf3:	89 f2                	mov    %esi,%edx
  800bf5:	09 c2                	or     %eax,%edx
  800bf7:	f6 c2 03             	test   $0x3,%dl
  800bfa:	75 0f                	jne    800c0b <memmove+0x5f>
  800bfc:	f6 c1 03             	test   $0x3,%cl
  800bff:	75 0a                	jne    800c0b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c01:	c1 e9 02             	shr    $0x2,%ecx
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	fc                   	cld    
  800c07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c09:	eb 05                	jmp    800c10 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	fc                   	cld    
  800c0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c17:	ff 75 10             	pushl  0x10(%ebp)
  800c1a:	ff 75 0c             	pushl  0xc(%ebp)
  800c1d:	ff 75 08             	pushl  0x8(%ebp)
  800c20:	e8 87 ff ff ff       	call   800bac <memmove>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c32:	89 c6                	mov    %eax,%esi
  800c34:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c37:	eb 1a                	jmp    800c53 <memcmp+0x2c>
		if (*s1 != *s2)
  800c39:	0f b6 08             	movzbl (%eax),%ecx
  800c3c:	0f b6 1a             	movzbl (%edx),%ebx
  800c3f:	38 d9                	cmp    %bl,%cl
  800c41:	74 0a                	je     800c4d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c43:	0f b6 c1             	movzbl %cl,%eax
  800c46:	0f b6 db             	movzbl %bl,%ebx
  800c49:	29 d8                	sub    %ebx,%eax
  800c4b:	eb 0f                	jmp    800c5c <memcmp+0x35>
		s1++, s2++;
  800c4d:	83 c0 01             	add    $0x1,%eax
  800c50:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c53:	39 f0                	cmp    %esi,%eax
  800c55:	75 e2                	jne    800c39 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	53                   	push   %ebx
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c67:	89 c1                	mov    %eax,%ecx
  800c69:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c70:	eb 0a                	jmp    800c7c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c72:	0f b6 10             	movzbl (%eax),%edx
  800c75:	39 da                	cmp    %ebx,%edx
  800c77:	74 07                	je     800c80 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c79:	83 c0 01             	add    $0x1,%eax
  800c7c:	39 c8                	cmp    %ecx,%eax
  800c7e:	72 f2                	jb     800c72 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c80:	5b                   	pop    %ebx
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8f:	eb 03                	jmp    800c94 <strtol+0x11>
		s++;
  800c91:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c94:	0f b6 01             	movzbl (%ecx),%eax
  800c97:	3c 20                	cmp    $0x20,%al
  800c99:	74 f6                	je     800c91 <strtol+0xe>
  800c9b:	3c 09                	cmp    $0x9,%al
  800c9d:	74 f2                	je     800c91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9f:	3c 2b                	cmp    $0x2b,%al
  800ca1:	75 0a                	jne    800cad <strtol+0x2a>
		s++;
  800ca3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	eb 11                	jmp    800cbe <strtol+0x3b>
  800cad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb2:	3c 2d                	cmp    $0x2d,%al
  800cb4:	75 08                	jne    800cbe <strtol+0x3b>
		s++, neg = 1;
  800cb6:	83 c1 01             	add    $0x1,%ecx
  800cb9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc4:	75 15                	jne    800cdb <strtol+0x58>
  800cc6:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc9:	75 10                	jne    800cdb <strtol+0x58>
  800ccb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ccf:	75 7c                	jne    800d4d <strtol+0xca>
		s += 2, base = 16;
  800cd1:	83 c1 02             	add    $0x2,%ecx
  800cd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd9:	eb 16                	jmp    800cf1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	75 12                	jne    800cf1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cdf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce7:	75 08                	jne    800cf1 <strtol+0x6e>
		s++, base = 8;
  800ce9:	83 c1 01             	add    $0x1,%ecx
  800cec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf9:	0f b6 11             	movzbl (%ecx),%edx
  800cfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cff:	89 f3                	mov    %esi,%ebx
  800d01:	80 fb 09             	cmp    $0x9,%bl
  800d04:	77 08                	ja     800d0e <strtol+0x8b>
			dig = *s - '0';
  800d06:	0f be d2             	movsbl %dl,%edx
  800d09:	83 ea 30             	sub    $0x30,%edx
  800d0c:	eb 22                	jmp    800d30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d11:	89 f3                	mov    %esi,%ebx
  800d13:	80 fb 19             	cmp    $0x19,%bl
  800d16:	77 08                	ja     800d20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d18:	0f be d2             	movsbl %dl,%edx
  800d1b:	83 ea 57             	sub    $0x57,%edx
  800d1e:	eb 10                	jmp    800d30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d23:	89 f3                	mov    %esi,%ebx
  800d25:	80 fb 19             	cmp    $0x19,%bl
  800d28:	77 16                	ja     800d40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d2a:	0f be d2             	movsbl %dl,%edx
  800d2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d33:	7d 0b                	jge    800d40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d35:	83 c1 01             	add    $0x1,%ecx
  800d38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d3e:	eb b9                	jmp    800cf9 <strtol+0x76>

	if (endptr)
  800d40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d44:	74 0d                	je     800d53 <strtol+0xd0>
		*endptr = (char *) s;
  800d46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d49:	89 0e                	mov    %ecx,(%esi)
  800d4b:	eb 06                	jmp    800d53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4d:	85 db                	test   %ebx,%ebx
  800d4f:	74 98                	je     800ce9 <strtol+0x66>
  800d51:	eb 9e                	jmp    800cf1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d53:	89 c2                	mov    %eax,%edx
  800d55:	f7 da                	neg    %edx
  800d57:	85 ff                	test   %edi,%edi
  800d59:	0f 45 c2             	cmovne %edx,%eax
}
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	53                   	push   %ebx
  800d65:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  800d68:	e8 bd f3 ff ff       	call   80012a <sys_getenvid>
  800d6d:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800d6f:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d76:	75 29                	jne    800da1 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	6a 07                	push   $0x7
  800d7d:	68 00 f0 bf ee       	push   $0xeebff000
  800d82:	50                   	push   %eax
  800d83:	e8 e0 f3 ff ff       	call   800168 <sys_page_alloc>
  800d88:	83 c4 10             	add    $0x10,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	79 12                	jns    800da1 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  800d8f:	50                   	push   %eax
  800d90:	68 24 13 80 00       	push   $0x801324
  800d95:	6a 24                	push   $0x24
  800d97:	68 3d 13 80 00       	push   $0x80133d
  800d9c:	e8 9c f5 ff ff       	call   80033d <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	a3 08 20 80 00       	mov    %eax,0x802008
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800da9:	83 ec 08             	sub    $0x8,%esp
  800dac:	68 17 03 80 00       	push   $0x800317
  800db1:	53                   	push   %ebx
  800db2:	e8 ba f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	79 12                	jns    800dd0 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  800dbe:	50                   	push   %eax
  800dbf:	68 24 13 80 00       	push   $0x801324
  800dc4:	6a 2e                	push   $0x2e
  800dc6:	68 3d 13 80 00       	push   $0x80133d
  800dcb:	e8 6d f5 ff ff       	call   80033d <_panic>
}
  800dd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    
  800dd5:	66 90                	xchg   %ax,%ax
  800dd7:	66 90                	xchg   %ax,%ax
  800dd9:	66 90                	xchg   %ax,%ax
  800ddb:	66 90                	xchg   %ax,%ax
  800ddd:	66 90                	xchg   %ax,%ax
  800ddf:	90                   	nop

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800deb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800def:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df7:	85 f6                	test   %esi,%esi
  800df9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dfd:	89 ca                	mov    %ecx,%edx
  800dff:	89 f8                	mov    %edi,%eax
  800e01:	75 3d                	jne    800e40 <__udivdi3+0x60>
  800e03:	39 cf                	cmp    %ecx,%edi
  800e05:	0f 87 c5 00 00 00    	ja     800ed0 <__udivdi3+0xf0>
  800e0b:	85 ff                	test   %edi,%edi
  800e0d:	89 fd                	mov    %edi,%ebp
  800e0f:	75 0b                	jne    800e1c <__udivdi3+0x3c>
  800e11:	b8 01 00 00 00       	mov    $0x1,%eax
  800e16:	31 d2                	xor    %edx,%edx
  800e18:	f7 f7                	div    %edi
  800e1a:	89 c5                	mov    %eax,%ebp
  800e1c:	89 c8                	mov    %ecx,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f5                	div    %ebp
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	89 d8                	mov    %ebx,%eax
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	f7 f5                	div    %ebp
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	89 d8                	mov    %ebx,%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	83 c4 1c             	add    $0x1c,%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 ce                	cmp    %ecx,%esi
  800e42:	77 74                	ja     800eb8 <__udivdi3+0xd8>
  800e44:	0f bd fe             	bsr    %esi,%edi
  800e47:	83 f7 1f             	xor    $0x1f,%edi
  800e4a:	0f 84 98 00 00 00    	je     800ee8 <__udivdi3+0x108>
  800e50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	89 c5                	mov    %eax,%ebp
  800e59:	29 fb                	sub    %edi,%ebx
  800e5b:	d3 e6                	shl    %cl,%esi
  800e5d:	89 d9                	mov    %ebx,%ecx
  800e5f:	d3 ed                	shr    %cl,%ebp
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e0                	shl    %cl,%eax
  800e65:	09 ee                	or     %ebp,%esi
  800e67:	89 d9                	mov    %ebx,%ecx
  800e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6d:	89 d5                	mov    %edx,%ebp
  800e6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e73:	d3 ed                	shr    %cl,%ebp
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e2                	shl    %cl,%edx
  800e79:	89 d9                	mov    %ebx,%ecx
  800e7b:	d3 e8                	shr    %cl,%eax
  800e7d:	09 c2                	or     %eax,%edx
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	89 ea                	mov    %ebp,%edx
  800e83:	f7 f6                	div    %esi
  800e85:	89 d5                	mov    %edx,%ebp
  800e87:	89 c3                	mov    %eax,%ebx
  800e89:	f7 64 24 0c          	mull   0xc(%esp)
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	72 10                	jb     800ea1 <__udivdi3+0xc1>
  800e91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	d3 e6                	shl    %cl,%esi
  800e99:	39 c6                	cmp    %eax,%esi
  800e9b:	73 07                	jae    800ea4 <__udivdi3+0xc4>
  800e9d:	39 d5                	cmp    %edx,%ebp
  800e9f:	75 03                	jne    800ea4 <__udivdi3+0xc4>
  800ea1:	83 eb 01             	sub    $0x1,%ebx
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	89 fa                	mov    %edi,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	31 ff                	xor    %edi,%edi
  800eba:	31 db                	xor    %ebx,%ebx
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	89 fa                	mov    %edi,%edx
  800ec0:	83 c4 1c             	add    $0x1c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	f7 f7                	div    %edi
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 c3                	mov    %eax,%ebx
  800ed8:	89 d8                	mov    %ebx,%eax
  800eda:	89 fa                	mov    %edi,%edx
  800edc:	83 c4 1c             	add    $0x1c,%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	39 ce                	cmp    %ecx,%esi
  800eea:	72 0c                	jb     800ef8 <__udivdi3+0x118>
  800eec:	31 db                	xor    %ebx,%ebx
  800eee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ef2:	0f 87 34 ff ff ff    	ja     800e2c <__udivdi3+0x4c>
  800ef8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800efd:	e9 2a ff ff ff       	jmp    800e2c <__udivdi3+0x4c>
  800f02:	66 90                	xchg   %ax,%ax
  800f04:	66 90                	xchg   %ax,%ax
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 d2                	test   %edx,%edx
  800f29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f31:	89 f3                	mov    %esi,%ebx
  800f33:	89 3c 24             	mov    %edi,(%esp)
  800f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3a:	75 1c                	jne    800f58 <__umoddi3+0x48>
  800f3c:	39 f7                	cmp    %esi,%edi
  800f3e:	76 50                	jbe    800f90 <__umoddi3+0x80>
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	f7 f7                	div    %edi
  800f46:	89 d0                	mov    %edx,%eax
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	77 52                	ja     800fb0 <__umoddi3+0xa0>
  800f5e:	0f bd ea             	bsr    %edx,%ebp
  800f61:	83 f5 1f             	xor    $0x1f,%ebp
  800f64:	75 5a                	jne    800fc0 <__umoddi3+0xb0>
  800f66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	39 0c 24             	cmp    %ecx,(%esp)
  800f73:	0f 86 d7 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f79:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f81:	83 c4 1c             	add    $0x1c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	85 ff                	test   %edi,%edi
  800f92:	89 fd                	mov    %edi,%ebp
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 c8                	mov    %ecx,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	eb 99                	jmp    800f48 <__umoddi3+0x38>
  800faf:	90                   	nop
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	83 c4 1c             	add    $0x1c,%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	8b 34 24             	mov    (%esp),%esi
  800fc3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	29 ef                	sub    %ebp,%edi
  800fcc:	d3 e0                	shl    %cl,%eax
  800fce:	89 f9                	mov    %edi,%ecx
  800fd0:	89 f2                	mov    %esi,%edx
  800fd2:	d3 ea                	shr    %cl,%edx
  800fd4:	89 e9                	mov    %ebp,%ecx
  800fd6:	09 c2                	or     %eax,%edx
  800fd8:	89 d8                	mov    %ebx,%eax
  800fda:	89 14 24             	mov    %edx,(%esp)
  800fdd:	89 f2                	mov    %esi,%edx
  800fdf:	d3 e2                	shl    %cl,%edx
  800fe1:	89 f9                	mov    %edi,%ecx
  800fe3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800feb:	d3 e8                	shr    %cl,%eax
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	89 c6                	mov    %eax,%esi
  800ff1:	d3 e3                	shl    %cl,%ebx
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 d0                	mov    %edx,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	09 d8                	or     %ebx,%eax
  800ffd:	89 d3                	mov    %edx,%ebx
  800fff:	89 f2                	mov    %esi,%edx
  801001:	f7 34 24             	divl   (%esp)
  801004:	89 d6                	mov    %edx,%esi
  801006:	d3 e3                	shl    %cl,%ebx
  801008:	f7 64 24 04          	mull   0x4(%esp)
  80100c:	39 d6                	cmp    %edx,%esi
  80100e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801012:	89 d1                	mov    %edx,%ecx
  801014:	89 c3                	mov    %eax,%ebx
  801016:	72 08                	jb     801020 <__umoddi3+0x110>
  801018:	75 11                	jne    80102b <__umoddi3+0x11b>
  80101a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80101e:	73 0b                	jae    80102b <__umoddi3+0x11b>
  801020:	2b 44 24 04          	sub    0x4(%esp),%eax
  801024:	1b 14 24             	sbb    (%esp),%edx
  801027:	89 d1                	mov    %edx,%ecx
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80102f:	29 da                	sub    %ebx,%edx
  801031:	19 ce                	sbb    %ecx,%esi
  801033:	89 f9                	mov    %edi,%ecx
  801035:	89 f0                	mov    %esi,%eax
  801037:	d3 e0                	shl    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	d3 ea                	shr    %cl,%edx
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	d3 ee                	shr    %cl,%esi
  801041:	09 d0                	or     %edx,%eax
  801043:	89 f2                	mov    %esi,%edx
  801045:	83 c4 1c             	add    $0x1c,%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 f9                	sub    %edi,%ecx
  801052:	19 d6                	sbb    %edx,%esi
  801054:	89 74 24 04          	mov    %esi,0x4(%esp)
  801058:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105c:	e9 18 ff ff ff       	jmp    800f79 <__umoddi3+0x69>
