
obj/user/faultnostack.debug:     file format elf32-i386


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
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
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
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ad 04 00 00       	call   800552 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 0a 1f 80 00       	push   $0x801f0a
  80011e:	6a 23                	push   $0x23
  800120:	68 27 1f 80 00       	push   $0x801f27
  800125:	e8 4d 0f 00 00       	call   801077 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 0a 1f 80 00       	push   $0x801f0a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 27 1f 80 00       	push   $0x801f27
  8001a6:	e8 cc 0e 00 00       	call   801077 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 0a 1f 80 00       	push   $0x801f0a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 27 1f 80 00       	push   $0x801f27
  8001e8:	e8 8a 0e 00 00       	call   801077 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 0a 1f 80 00       	push   $0x801f0a
  800223:	6a 23                	push   $0x23
  800225:	68 27 1f 80 00       	push   $0x801f27
  80022a:	e8 48 0e 00 00       	call   801077 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 0a 1f 80 00       	push   $0x801f0a
  800265:	6a 23                	push   $0x23
  800267:	68 27 1f 80 00       	push   $0x801f27
  80026c:	e8 06 0e 00 00       	call   801077 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 0a 1f 80 00       	push   $0x801f0a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 27 1f 80 00       	push   $0x801f27
  8002ae:	e8 c4 0d 00 00       	call   801077 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 0a 1f 80 00       	push   $0x801f0a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 27 1f 80 00       	push   $0x801f27
  8002f0:	e8 82 0d 00 00       	call   801077 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 0a 1f 80 00       	push   $0x801f0a
  80034d:	6a 23                	push   $0x23
  80034f:	68 27 1f 80 00       	push   $0x801f27
  800354:	e8 1e 0d 00 00       	call   801077 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  80036c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800370:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  800373:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800377:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  800379:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80037d:	83 c4 08             	add    $0x8,%esp
	popal
  800380:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800381:	83 c4 04             	add    $0x4,%esp
	popfl
  800384:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  800385:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800386:	c3                   	ret    

00800387 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	05 00 00 00 30       	add    $0x30000000,%eax
  800392:	c1 e8 0c             	shr    $0xc,%eax
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 16             	shr    $0x16,%edx
  8003be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	74 11                	je     8003db <fd_alloc+0x2d>
  8003ca:	89 c2                	mov    %eax,%edx
  8003cc:	c1 ea 0c             	shr    $0xc,%edx
  8003cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d6:	f6 c2 01             	test   $0x1,%dl
  8003d9:	75 09                	jne    8003e4 <fd_alloc+0x36>
			*fd_store = fd;
  8003db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e2:	eb 17                	jmp    8003fb <fd_alloc+0x4d>
  8003e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ee:	75 c9                	jne    8003b9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800403:	83 f8 1f             	cmp    $0x1f,%eax
  800406:	77 36                	ja     80043e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800408:	c1 e0 0c             	shl    $0xc,%eax
  80040b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 16             	shr    $0x16,%edx
  800415:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 24                	je     800445 <fd_lookup+0x48>
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 0c             	shr    $0xc,%edx
  800426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 1a                	je     80044c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 02                	mov    %eax,(%edx)
	return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 13                	jmp    800451 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800443:	eb 0c                	jmp    800451 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb 05                	jmp    800451 <fd_lookup+0x54>
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800451:	5d                   	pop    %ebp
  800452:	c3                   	ret    

00800453 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045c:	ba b4 1f 80 00       	mov    $0x801fb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	eb 13                	jmp    800476 <dev_lookup+0x23>
  800463:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800466:	39 08                	cmp    %ecx,(%eax)
  800468:	75 0c                	jne    800476 <dev_lookup+0x23>
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb 2e                	jmp    8004a4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800476:	8b 02                	mov    (%edx),%eax
  800478:	85 c0                	test   %eax,%eax
  80047a:	75 e7                	jne    800463 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047c:	a1 04 40 80 00       	mov    0x804004,%eax
  800481:	8b 40 48             	mov    0x48(%eax),%eax
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	51                   	push   %ecx
  800488:	50                   	push   %eax
  800489:	68 38 1f 80 00       	push   $0x801f38
  80048e:	e8 bd 0c 00 00       	call   801150 <cprintf>
	*dev = 0;
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
  800496:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	56                   	push   %esi
  8004aa:	53                   	push   %ebx
  8004ab:	83 ec 10             	sub    $0x10,%esp
  8004ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004be:	c1 e8 0c             	shr    $0xc,%eax
  8004c1:	50                   	push   %eax
  8004c2:	e8 36 ff ff ff       	call   8003fd <fd_lookup>
  8004c7:	83 c4 08             	add    $0x8,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 05                	js     8004d3 <fd_close+0x2d>
	    || fd != fd2)
  8004ce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d1:	74 0c                	je     8004df <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d3:	84 db                	test   %bl,%bl
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	0f 44 c2             	cmove  %edx,%eax
  8004dd:	eb 41                	jmp    800520 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e5:	50                   	push   %eax
  8004e6:	ff 36                	pushl  (%esi)
  8004e8:	e8 66 ff ff ff       	call   800453 <dev_lookup>
  8004ed:	89 c3                	mov    %eax,%ebx
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	78 1a                	js     800510 <fd_close+0x6a>
		if (dev->dev_close)
  8004f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800501:	85 c0                	test   %eax,%eax
  800503:	74 0b                	je     800510 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800505:	83 ec 0c             	sub    $0xc,%esp
  800508:	56                   	push   %esi
  800509:	ff d0                	call   *%eax
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 00                	push   $0x0
  800516:	e8 da fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	89 d8                	mov    %ebx,%eax
}
  800520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800523:	5b                   	pop    %ebx
  800524:	5e                   	pop    %esi
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800530:	50                   	push   %eax
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 c4 fe ff ff       	call   8003fd <fd_lookup>
  800539:	83 c4 08             	add    $0x8,%esp
  80053c:	85 c0                	test   %eax,%eax
  80053e:	78 10                	js     800550 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	6a 01                	push   $0x1
  800545:	ff 75 f4             	pushl  -0xc(%ebp)
  800548:	e8 59 ff ff ff       	call   8004a6 <fd_close>
  80054d:	83 c4 10             	add    $0x10,%esp
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <close_all>:

void
close_all(void)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	53                   	push   %ebx
  800556:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	53                   	push   %ebx
  800562:	e8 c0 ff ff ff       	call   800527 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800567:	83 c3 01             	add    $0x1,%ebx
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	83 fb 20             	cmp    $0x20,%ebx
  800570:	75 ec                	jne    80055e <close_all+0xc>
		close(i);
}
  800572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 2c             	sub    $0x2c,%esp
  800580:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800583:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800586:	50                   	push   %eax
  800587:	ff 75 08             	pushl  0x8(%ebp)
  80058a:	e8 6e fe ff ff       	call   8003fd <fd_lookup>
  80058f:	83 c4 08             	add    $0x8,%esp
  800592:	85 c0                	test   %eax,%eax
  800594:	0f 88 c1 00 00 00    	js     80065b <dup+0xe4>
		return r;
	close(newfdnum);
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	56                   	push   %esi
  80059e:	e8 84 ff ff ff       	call   800527 <close>

	newfd = INDEX2FD(newfdnum);
  8005a3:	89 f3                	mov    %esi,%ebx
  8005a5:	c1 e3 0c             	shl    $0xc,%ebx
  8005a8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ae:	83 c4 04             	add    $0x4,%esp
  8005b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b4:	e8 de fd ff ff       	call   800397 <fd2data>
  8005b9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005bb:	89 1c 24             	mov    %ebx,(%esp)
  8005be:	e8 d4 fd ff ff       	call   800397 <fd2data>
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c9:	89 f8                	mov    %edi,%eax
  8005cb:	c1 e8 16             	shr    $0x16,%eax
  8005ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d5:	a8 01                	test   $0x1,%al
  8005d7:	74 37                	je     800610 <dup+0x99>
  8005d9:	89 f8                	mov    %edi,%eax
  8005db:	c1 e8 0c             	shr    $0xc,%eax
  8005de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e5:	f6 c2 01             	test   $0x1,%dl
  8005e8:	74 26                	je     800610 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fd:	6a 00                	push   $0x0
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	e8 ac fb ff ff       	call   8001b3 <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
  80060c:	85 c0                	test   %eax,%eax
  80060e:	78 2e                	js     80063e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	89 d0                	mov    %edx,%eax
  800615:	c1 e8 0c             	shr    $0xc,%eax
  800618:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061f:	83 ec 0c             	sub    $0xc,%esp
  800622:	25 07 0e 00 00       	and    $0xe07,%eax
  800627:	50                   	push   %eax
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	52                   	push   %edx
  80062c:	6a 00                	push   $0x0
  80062e:	e8 80 fb ff ff       	call   8001b3 <sys_page_map>
  800633:	89 c7                	mov    %eax,%edi
  800635:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800638:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	85 ff                	test   %edi,%edi
  80063c:	79 1d                	jns    80065b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 00                	push   $0x0
  800644:	e8 ac fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064f:	6a 00                	push   $0x0
  800651:	e8 9f fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	89 f8                	mov    %edi,%eax
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	53                   	push   %ebx
  800667:	83 ec 14             	sub    $0x14,%esp
  80066a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800670:	50                   	push   %eax
  800671:	53                   	push   %ebx
  800672:	e8 86 fd ff ff       	call   8003fd <fd_lookup>
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	89 c2                	mov    %eax,%edx
  80067c:	85 c0                	test   %eax,%eax
  80067e:	78 6d                	js     8006ed <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068a:	ff 30                	pushl  (%eax)
  80068c:	e8 c2 fd ff ff       	call   800453 <dev_lookup>
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	85 c0                	test   %eax,%eax
  800696:	78 4c                	js     8006e4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069b:	8b 42 08             	mov    0x8(%edx),%eax
  80069e:	83 e0 03             	and    $0x3,%eax
  8006a1:	83 f8 01             	cmp    $0x1,%eax
  8006a4:	75 21                	jne    8006c7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ab:	8b 40 48             	mov    0x48(%eax),%eax
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	50                   	push   %eax
  8006b3:	68 79 1f 80 00       	push   $0x801f79
  8006b8:	e8 93 0a 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c5:	eb 26                	jmp    8006ed <read+0x8a>
	}
	if (!dev->dev_read)
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	8b 40 08             	mov    0x8(%eax),%eax
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 17                	je     8006e8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	52                   	push   %edx
  8006db:	ff d0                	call   *%eax
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 09                	jmp    8006ed <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	eb 05                	jmp    8006ed <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ed:	89 d0                	mov    %edx,%eax
  8006ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800700:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800703:	bb 00 00 00 00       	mov    $0x0,%ebx
  800708:	eb 21                	jmp    80072b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070a:	83 ec 04             	sub    $0x4,%esp
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	29 d8                	sub    %ebx,%eax
  800711:	50                   	push   %eax
  800712:	89 d8                	mov    %ebx,%eax
  800714:	03 45 0c             	add    0xc(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	57                   	push   %edi
  800719:	e8 45 ff ff ff       	call   800663 <read>
		if (m < 0)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	85 c0                	test   %eax,%eax
  800723:	78 10                	js     800735 <readn+0x41>
			return m;
		if (m == 0)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 0a                	je     800733 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800729:	01 c3                	add    %eax,%ebx
  80072b:	39 f3                	cmp    %esi,%ebx
  80072d:	72 db                	jb     80070a <readn+0x16>
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	eb 02                	jmp    800735 <readn+0x41>
  800733:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	83 ec 14             	sub    $0x14,%esp
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800747:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	53                   	push   %ebx
  80074c:	e8 ac fc ff ff       	call   8003fd <fd_lookup>
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	89 c2                	mov    %eax,%edx
  800756:	85 c0                	test   %eax,%eax
  800758:	78 68                	js     8007c2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	ff 30                	pushl  (%eax)
  800766:	e8 e8 fc ff ff       	call   800453 <dev_lookup>
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 47                	js     8007b9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800775:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800779:	75 21                	jne    80079c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077b:	a1 04 40 80 00       	mov    0x804004,%eax
  800780:	8b 40 48             	mov    0x48(%eax),%eax
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	53                   	push   %ebx
  800787:	50                   	push   %eax
  800788:	68 95 1f 80 00       	push   $0x801f95
  80078d:	e8 be 09 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80079a:	eb 26                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079f:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	74 17                	je     8007bd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	50                   	push   %eax
  8007b0:	ff d2                	call   *%edx
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 09                	jmp    8007c2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	eb 05                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c2:	89 d0                	mov    %edx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 22 fc ff ff       	call   8003fd <fd_lookup>
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 0e                	js     8007f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 14             	sub    $0x14,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	53                   	push   %ebx
  800801:	e8 f7 fb ff ff       	call   8003fd <fd_lookup>
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	89 c2                	mov    %eax,%edx
  80080b:	85 c0                	test   %eax,%eax
  80080d:	78 65                	js     800874 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800815:	50                   	push   %eax
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	ff 30                	pushl  (%eax)
  80081b:	e8 33 fc ff ff       	call   800453 <dev_lookup>
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	85 c0                	test   %eax,%eax
  800825:	78 44                	js     80086b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082e:	75 21                	jne    800851 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800830:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800835:	8b 40 48             	mov    0x48(%eax),%eax
  800838:	83 ec 04             	sub    $0x4,%esp
  80083b:	53                   	push   %ebx
  80083c:	50                   	push   %eax
  80083d:	68 58 1f 80 00       	push   $0x801f58
  800842:	e8 09 09 00 00       	call   801150 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084f:	eb 23                	jmp    800874 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800851:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800854:	8b 52 18             	mov    0x18(%edx),%edx
  800857:	85 d2                	test   %edx,%edx
  800859:	74 14                	je     80086f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	50                   	push   %eax
  800862:	ff d2                	call   *%edx
  800864:	89 c2                	mov    %eax,%edx
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	eb 09                	jmp    800874 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	eb 05                	jmp    800874 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800874:	89 d0                	mov    %edx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 14             	sub    $0x14,%esp
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	ff 75 08             	pushl  0x8(%ebp)
  80088c:	e8 6c fb ff ff       	call   8003fd <fd_lookup>
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	89 c2                	mov    %eax,%edx
  800896:	85 c0                	test   %eax,%eax
  800898:	78 58                	js     8008f2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	ff 30                	pushl  (%eax)
  8008a6:	e8 a8 fb ff ff       	call   800453 <dev_lookup>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 37                	js     8008e9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b9:	74 32                	je     8008ed <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c5:	00 00 00 
	stat->st_isdir = 0;
  8008c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cf:	00 00 00 
	stat->st_dev = dev;
  8008d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008df:	ff 50 14             	call   *0x14(%eax)
  8008e2:	89 c2                	mov    %eax,%edx
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 09                	jmp    8008f2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	eb 05                	jmp    8008f2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	6a 00                	push   $0x0
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 e9 01 00 00       	call   800af4 <open>
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	85 c0                	test   %eax,%eax
  800912:	78 1b                	js     80092f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	50                   	push   %eax
  80091b:	e8 5b ff ff ff       	call   80087b <fstat>
  800920:	89 c6                	mov    %eax,%esi
	close(fd);
  800922:	89 1c 24             	mov    %ebx,(%esp)
  800925:	e8 fd fb ff ff       	call   800527 <close>
	return r;
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	89 f0                	mov    %esi,%eax
}
  80092f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800946:	75 12                	jne    80095a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800948:	83 ec 0c             	sub    $0xc,%esp
  80094b:	6a 01                	push   $0x1
  80094d:	e8 93 12 00 00       	call   801be5 <ipc_find_env>
  800952:	a3 00 40 80 00       	mov    %eax,0x804000
  800957:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095a:	6a 07                	push   $0x7
  80095c:	68 00 50 80 00       	push   $0x805000
  800961:	56                   	push   %esi
  800962:	ff 35 00 40 80 00    	pushl  0x804000
  800968:	e8 24 12 00 00       	call   801b91 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80096d:	83 c4 0c             	add    $0xc,%esp
  800970:	6a 00                	push   $0x0
  800972:	53                   	push   %ebx
  800973:	6a 00                	push   $0x0
  800975:	e8 95 11 00 00       	call   801b0f <ipc_recv>
}
  80097a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 40 0c             	mov    0xc(%eax),%eax
  80098d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a4:	e8 8d ff ff ff       	call   800936 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c6:	e8 6b ff ff ff       	call   800936 <fsipc>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ec:	e8 45 ff ff ff       	call   800936 <fsipc>
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 2c                	js     800a21 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	68 00 50 80 00       	push   $0x805000
  8009fd:	53                   	push   %ebx
  8009fe:	e8 51 0d 00 00       	call   801754 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a03:	a1 80 50 80 00       	mov    0x805080,%eax
  800a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a13:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a34:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a39:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a42:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a48:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a4d:	50                   	push   %eax
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	68 08 50 80 00       	push   $0x805008
  800a56:	e8 8b 0e 00 00       	call   8018e6 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 04 00 00 00       	mov    $0x4,%eax
  800a65:	e8 cc fe ff ff       	call   800936 <fsipc>
            return r;

    return r;
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7f:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	e8 a2 fe ff ff       	call   800936 <fsipc>
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	85 c0                	test   %eax,%eax
  800a98:	78 51                	js     800aeb <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a9a:	39 c6                	cmp    %eax,%esi
  800a9c:	73 19                	jae    800ab7 <devfile_read+0x4b>
  800a9e:	68 c4 1f 80 00       	push   $0x801fc4
  800aa3:	68 cb 1f 80 00       	push   $0x801fcb
  800aa8:	68 82 00 00 00       	push   $0x82
  800aad:	68 e0 1f 80 00       	push   $0x801fe0
  800ab2:	e8 c0 05 00 00       	call   801077 <_panic>
	assert(r <= PGSIZE);
  800ab7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800abc:	7e 19                	jle    800ad7 <devfile_read+0x6b>
  800abe:	68 eb 1f 80 00       	push   $0x801feb
  800ac3:	68 cb 1f 80 00       	push   $0x801fcb
  800ac8:	68 83 00 00 00       	push   $0x83
  800acd:	68 e0 1f 80 00       	push   $0x801fe0
  800ad2:	e8 a0 05 00 00       	call   801077 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad7:	83 ec 04             	sub    $0x4,%esp
  800ada:	50                   	push   %eax
  800adb:	68 00 50 80 00       	push   $0x805000
  800ae0:	ff 75 0c             	pushl  0xc(%ebp)
  800ae3:	e8 fe 0d 00 00       	call   8018e6 <memmove>
	return r;
  800ae8:	83 c4 10             	add    $0x10,%esp
}
  800aeb:	89 d8                	mov    %ebx,%eax
  800aed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	53                   	push   %ebx
  800af8:	83 ec 20             	sub    $0x20,%esp
  800afb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800afe:	53                   	push   %ebx
  800aff:	e8 17 0c 00 00       	call   80171b <strlen>
  800b04:	83 c4 10             	add    $0x10,%esp
  800b07:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0c:	7f 67                	jg     800b75 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b14:	50                   	push   %eax
  800b15:	e8 94 f8 ff ff       	call   8003ae <fd_alloc>
  800b1a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	78 57                	js     800b7a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	68 00 50 80 00       	push   $0x805000
  800b2c:	e8 23 0c 00 00       	call   801754 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b34:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b41:	e8 f0 fd ff ff       	call   800936 <fsipc>
  800b46:	89 c3                	mov    %eax,%ebx
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	79 14                	jns    800b63 <open+0x6f>
		fd_close(fd, 0);
  800b4f:	83 ec 08             	sub    $0x8,%esp
  800b52:	6a 00                	push   $0x0
  800b54:	ff 75 f4             	pushl  -0xc(%ebp)
  800b57:	e8 4a f9 ff ff       	call   8004a6 <fd_close>
		return r;
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	89 da                	mov    %ebx,%edx
  800b61:	eb 17                	jmp    800b7a <open+0x86>
	}

	return fd2num(fd);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	ff 75 f4             	pushl  -0xc(%ebp)
  800b69:	e8 19 f8 ff ff       	call   800387 <fd2num>
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	83 c4 10             	add    $0x10,%esp
  800b73:	eb 05                	jmp    800b7a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b75:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7a:	89 d0                	mov    %edx,%eax
  800b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b91:	e8 a0 fd ff ff       	call   800936 <fsipc>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	ff 75 08             	pushl  0x8(%ebp)
  800ba6:	e8 ec f7 ff ff       	call   800397 <fd2data>
  800bab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bad:	83 c4 08             	add    $0x8,%esp
  800bb0:	68 f7 1f 80 00       	push   $0x801ff7
  800bb5:	53                   	push   %ebx
  800bb6:	e8 99 0b 00 00       	call   801754 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbb:	8b 46 04             	mov    0x4(%esi),%eax
  800bbe:	2b 06                	sub    (%esi),%eax
  800bc0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bcd:	00 00 00 
	stat->st_dev = &devpipe;
  800bd0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd7:	30 80 00 
	return 0;
}
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf0:	53                   	push   %ebx
  800bf1:	6a 00                	push   $0x0
  800bf3:	e8 fd f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf8:	89 1c 24             	mov    %ebx,(%esp)
  800bfb:	e8 97 f7 ff ff       	call   800397 <fd2data>
  800c00:	83 c4 08             	add    $0x8,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 00                	push   $0x0
  800c06:	e8 ea f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 1c             	sub    $0x1c,%esp
  800c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c1e:	a1 04 40 80 00       	mov    0x804004,%eax
  800c23:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2c:	e8 ed 0f 00 00       	call   801c1e <pageref>
  800c31:	89 c3                	mov    %eax,%ebx
  800c33:	89 3c 24             	mov    %edi,(%esp)
  800c36:	e8 e3 0f 00 00       	call   801c1e <pageref>
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	39 c3                	cmp    %eax,%ebx
  800c40:	0f 94 c1             	sete   %cl
  800c43:	0f b6 c9             	movzbl %cl,%ecx
  800c46:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c49:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c4f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c52:	39 ce                	cmp    %ecx,%esi
  800c54:	74 1b                	je     800c71 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c56:	39 c3                	cmp    %eax,%ebx
  800c58:	75 c4                	jne    800c1e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5a:	8b 42 58             	mov    0x58(%edx),%eax
  800c5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c60:	50                   	push   %eax
  800c61:	56                   	push   %esi
  800c62:	68 fe 1f 80 00       	push   $0x801ffe
  800c67:	e8 e4 04 00 00       	call   801150 <cprintf>
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	eb ad                	jmp    800c1e <_pipeisclosed+0xe>
	}
}
  800c71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 28             	sub    $0x28,%esp
  800c85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c88:	56                   	push   %esi
  800c89:	e8 09 f7 ff ff       	call   800397 <fd2data>
  800c8e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c90:	83 c4 10             	add    $0x10,%esp
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
  800c98:	eb 4b                	jmp    800ce5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9a:	89 da                	mov    %ebx,%edx
  800c9c:	89 f0                	mov    %esi,%eax
  800c9e:	e8 6d ff ff ff       	call   800c10 <_pipeisclosed>
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	75 48                	jne    800cef <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca7:	e8 a5 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cac:	8b 43 04             	mov    0x4(%ebx),%eax
  800caf:	8b 0b                	mov    (%ebx),%ecx
  800cb1:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb4:	39 d0                	cmp    %edx,%eax
  800cb6:	73 e2                	jae    800c9a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cbf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc2:	89 c2                	mov    %eax,%edx
  800cc4:	c1 fa 1f             	sar    $0x1f,%edx
  800cc7:	89 d1                	mov    %edx,%ecx
  800cc9:	c1 e9 1b             	shr    $0x1b,%ecx
  800ccc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ccf:	83 e2 1f             	and    $0x1f,%edx
  800cd2:	29 ca                	sub    %ecx,%edx
  800cd4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cdc:	83 c0 01             	add    $0x1,%eax
  800cdf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce2:	83 c7 01             	add    $0x1,%edi
  800ce5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce8:	75 c2                	jne    800cac <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ced:	eb 05                	jmp    800cf4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 18             	sub    $0x18,%esp
  800d05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d08:	57                   	push   %edi
  800d09:	e8 89 f6 ff ff       	call   800397 <fd2data>
  800d0e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	eb 3d                	jmp    800d57 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1a:	85 db                	test   %ebx,%ebx
  800d1c:	74 04                	je     800d22 <devpipe_read+0x26>
				return i;
  800d1e:	89 d8                	mov    %ebx,%eax
  800d20:	eb 44                	jmp    800d66 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	89 f8                	mov    %edi,%eax
  800d26:	e8 e5 fe ff ff       	call   800c10 <_pipeisclosed>
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	75 32                	jne    800d61 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d2f:	e8 1d f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d34:	8b 06                	mov    (%esi),%eax
  800d36:	3b 46 04             	cmp    0x4(%esi),%eax
  800d39:	74 df                	je     800d1a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3b:	99                   	cltd   
  800d3c:	c1 ea 1b             	shr    $0x1b,%edx
  800d3f:	01 d0                	add    %edx,%eax
  800d41:	83 e0 1f             	and    $0x1f,%eax
  800d44:	29 d0                	sub    %edx,%eax
  800d46:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d51:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d54:	83 c3 01             	add    $0x1,%ebx
  800d57:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5a:	75 d8                	jne    800d34 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5f:	eb 05                	jmp    800d66 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d79:	50                   	push   %eax
  800d7a:	e8 2f f6 ff ff       	call   8003ae <fd_alloc>
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	85 c0                	test   %eax,%eax
  800d86:	0f 88 2c 01 00 00    	js     800eb8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8c:	83 ec 04             	sub    $0x4,%esp
  800d8f:	68 07 04 00 00       	push   $0x407
  800d94:	ff 75 f4             	pushl  -0xc(%ebp)
  800d97:	6a 00                	push   $0x0
  800d99:	e8 d2 f3 ff ff       	call   800170 <sys_page_alloc>
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	85 c0                	test   %eax,%eax
  800da5:	0f 88 0d 01 00 00    	js     800eb8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db1:	50                   	push   %eax
  800db2:	e8 f7 f5 ff ff       	call   8003ae <fd_alloc>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	0f 88 e2 00 00 00    	js     800ea6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	68 07 04 00 00       	push   $0x407
  800dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 9a f3 ff ff       	call   800170 <sys_page_alloc>
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	0f 88 c3 00 00 00    	js     800ea6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	ff 75 f4             	pushl  -0xc(%ebp)
  800de9:	e8 a9 f5 ff ff       	call   800397 <fd2data>
  800dee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df0:	83 c4 0c             	add    $0xc,%esp
  800df3:	68 07 04 00 00       	push   $0x407
  800df8:	50                   	push   %eax
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 70 f3 ff ff       	call   800170 <sys_page_alloc>
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	0f 88 89 00 00 00    	js     800e96 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	ff 75 f0             	pushl  -0x10(%ebp)
  800e13:	e8 7f f5 ff ff       	call   800397 <fd2data>
  800e18:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e1f:	50                   	push   %eax
  800e20:	6a 00                	push   $0x0
  800e22:	56                   	push   %esi
  800e23:	6a 00                	push   $0x0
  800e25:	e8 89 f3 ff ff       	call   8001b3 <sys_page_map>
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	83 c4 20             	add    $0x20,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	78 55                	js     800e88 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e51:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e56:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	ff 75 f4             	pushl  -0xc(%ebp)
  800e63:	e8 1f f5 ff ff       	call   800387 <fd2num>
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6d:	83 c4 04             	add    $0x4,%esp
  800e70:	ff 75 f0             	pushl  -0x10(%ebp)
  800e73:	e8 0f f5 ff ff       	call   800387 <fd2num>
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	ba 00 00 00 00       	mov    $0x0,%edx
  800e86:	eb 30                	jmp    800eb8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	56                   	push   %esi
  800e8c:	6a 00                	push   $0x0
  800e8e:	e8 62 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e93:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 52 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eac:	6a 00                	push   $0x0
  800eae:	e8 42 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb8:	89 d0                	mov    %edx,%eax
  800eba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eca:	50                   	push   %eax
  800ecb:	ff 75 08             	pushl  0x8(%ebp)
  800ece:	e8 2a f5 ff ff       	call   8003fd <fd_lookup>
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 18                	js     800ef2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee0:	e8 b2 f4 ff ff       	call   800397 <fd2data>
	return _pipeisclosed(fd, p);
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eea:	e8 21 fd ff ff       	call   800c10 <_pipeisclosed>
  800eef:	83 c4 10             	add    $0x10,%esp
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f04:	68 16 20 80 00       	push   $0x802016
  800f09:	ff 75 0c             	pushl  0xc(%ebp)
  800f0c:	e8 43 08 00 00       	call   801754 <strcpy>
	return 0;
}
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f24:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f29:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2f:	eb 2d                	jmp    800f5e <devcons_write+0x46>
		m = n - tot;
  800f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f34:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f36:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f39:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f3e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	53                   	push   %ebx
  800f45:	03 45 0c             	add    0xc(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	57                   	push   %edi
  800f4a:	e8 97 09 00 00       	call   8018e6 <memmove>
		sys_cputs(buf, m);
  800f4f:	83 c4 08             	add    $0x8,%esp
  800f52:	53                   	push   %ebx
  800f53:	57                   	push   %edi
  800f54:	e8 5b f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f59:	01 de                	add    %ebx,%esi
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f63:	72 cc                	jb     800f31 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7c:	74 2a                	je     800fa8 <devcons_read+0x3b>
  800f7e:	eb 05                	jmp    800f85 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f80:	e8 cc f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f85:	e8 48 f1 ff ff       	call   8000d2 <sys_cgetc>
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	74 f2                	je     800f80 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 16                	js     800fa8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f92:	83 f8 04             	cmp    $0x4,%eax
  800f95:	74 0c                	je     800fa3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9a:	88 02                	mov    %al,(%edx)
	return 1;
  800f9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa1:	eb 05                	jmp    800fa8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb6:	6a 01                	push   $0x1
  800fb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	e8 f3 f0 ff ff       	call   8000b4 <sys_cputs>
}
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <getchar>:

int
getchar(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fcc:	6a 01                	push   $0x1
  800fce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 8a f6 ff ff       	call   800663 <read>
	if (r < 0)
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 0f                	js     800fef <getchar+0x29>
		return r;
	if (r < 1)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	7e 06                	jle    800fea <getchar+0x24>
		return -E_EOF;
	return c;
  800fe4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe8:	eb 05                	jmp    800fef <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 fa f3 ff ff       	call   8003fd <fd_lookup>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 11                	js     80101b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801013:	39 10                	cmp    %edx,(%eax)
  801015:	0f 94 c0             	sete   %al
  801018:	0f b6 c0             	movzbl %al,%eax
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <opencons>:

int
opencons(void)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801023:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801026:	50                   	push   %eax
  801027:	e8 82 f3 ff ff       	call   8003ae <fd_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
		return r;
  80102f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	78 3e                	js     801073 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	68 07 04 00 00       	push   $0x407
  80103d:	ff 75 f4             	pushl  -0xc(%ebp)
  801040:	6a 00                	push   $0x0
  801042:	e8 29 f1 ff ff       	call   800170 <sys_page_alloc>
  801047:	83 c4 10             	add    $0x10,%esp
		return r;
  80104a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 23                	js     801073 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801050:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	50                   	push   %eax
  801069:	e8 19 f3 ff ff       	call   800387 <fd2num>
  80106e:	89 c2                	mov    %eax,%edx
  801070:	83 c4 10             	add    $0x10,%esp
}
  801073:	89 d0                	mov    %edx,%eax
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80107f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801085:	e8 a8 f0 ff ff       	call   800132 <sys_getenvid>
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	ff 75 0c             	pushl  0xc(%ebp)
  801090:	ff 75 08             	pushl  0x8(%ebp)
  801093:	56                   	push   %esi
  801094:	50                   	push   %eax
  801095:	68 24 20 80 00       	push   $0x802024
  80109a:	e8 b1 00 00 00       	call   801150 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80109f:	83 c4 18             	add    $0x18,%esp
  8010a2:	53                   	push   %ebx
  8010a3:	ff 75 10             	pushl  0x10(%ebp)
  8010a6:	e8 54 00 00 00       	call   8010ff <vcprintf>
	cprintf("\n");
  8010ab:	c7 04 24 0f 20 80 00 	movl   $0x80200f,(%esp)
  8010b2:	e8 99 00 00 00       	call   801150 <cprintf>
  8010b7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ba:	cc                   	int3   
  8010bb:	eb fd                	jmp    8010ba <_panic+0x43>

008010bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c7:	8b 13                	mov    (%ebx),%edx
  8010c9:	8d 42 01             	lea    0x1(%edx),%eax
  8010cc:	89 03                	mov    %eax,(%ebx)
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010da:	75 1a                	jne    8010f6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	68 ff 00 00 00       	push   $0xff
  8010e4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e7:	50                   	push   %eax
  8010e8:	e8 c7 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80110f:	00 00 00 
	b.cnt = 0;
  801112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111c:	ff 75 0c             	pushl  0xc(%ebp)
  80111f:	ff 75 08             	pushl  0x8(%ebp)
  801122:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801128:	50                   	push   %eax
  801129:	68 bd 10 80 00       	push   $0x8010bd
  80112e:	e8 1a 01 00 00       	call   80124d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801133:	83 c4 08             	add    $0x8,%esp
  801136:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	e8 6c ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801148:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801156:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801159:	50                   	push   %eax
  80115a:	ff 75 08             	pushl  0x8(%ebp)
  80115d:	e8 9d ff ff ff       	call   8010ff <vcprintf>
	va_end(ap);

	return cnt;
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 1c             	sub    $0x1c,%esp
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	89 d6                	mov    %edx,%esi
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801188:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118b:	39 d3                	cmp    %edx,%ebx
  80118d:	72 05                	jb     801194 <printnum+0x30>
  80118f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801192:	77 45                	ja     8011d9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	ff 75 18             	pushl  0x18(%ebp)
  80119a:	8b 45 14             	mov    0x14(%ebp),%eax
  80119d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a0:	53                   	push   %ebx
  8011a1:	ff 75 10             	pushl  0x10(%ebp)
  8011a4:	83 ec 08             	sub    $0x8,%esp
  8011a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b3:	e8 a8 0a 00 00       	call   801c60 <__udivdi3>
  8011b8:	83 c4 18             	add    $0x18,%esp
  8011bb:	52                   	push   %edx
  8011bc:	50                   	push   %eax
  8011bd:	89 f2                	mov    %esi,%edx
  8011bf:	89 f8                	mov    %edi,%eax
  8011c1:	e8 9e ff ff ff       	call   801164 <printnum>
  8011c6:	83 c4 20             	add    $0x20,%esp
  8011c9:	eb 18                	jmp    8011e3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	56                   	push   %esi
  8011cf:	ff 75 18             	pushl  0x18(%ebp)
  8011d2:	ff d7                	call   *%edi
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	eb 03                	jmp    8011dc <printnum+0x78>
  8011d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011dc:	83 eb 01             	sub    $0x1,%ebx
  8011df:	85 db                	test   %ebx,%ebx
  8011e1:	7f e8                	jg     8011cb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	56                   	push   %esi
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f6:	e8 95 0b 00 00       	call   801d90 <__umoddi3>
  8011fb:	83 c4 14             	add    $0x14,%esp
  8011fe:	0f be 80 47 20 80 00 	movsbl 0x802047(%eax),%eax
  801205:	50                   	push   %eax
  801206:	ff d7                	call   *%edi
}
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120e:	5b                   	pop    %ebx
  80120f:	5e                   	pop    %esi
  801210:	5f                   	pop    %edi
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801219:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80121d:	8b 10                	mov    (%eax),%edx
  80121f:	3b 50 04             	cmp    0x4(%eax),%edx
  801222:	73 0a                	jae    80122e <sprintputch+0x1b>
		*b->buf++ = ch;
  801224:	8d 4a 01             	lea    0x1(%edx),%ecx
  801227:	89 08                	mov    %ecx,(%eax)
  801229:	8b 45 08             	mov    0x8(%ebp),%eax
  80122c:	88 02                	mov    %al,(%edx)
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801236:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801239:	50                   	push   %eax
  80123a:	ff 75 10             	pushl  0x10(%ebp)
  80123d:	ff 75 0c             	pushl  0xc(%ebp)
  801240:	ff 75 08             	pushl  0x8(%ebp)
  801243:	e8 05 00 00 00       	call   80124d <vprintfmt>
	va_end(ap);
}
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	57                   	push   %edi
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 2c             	sub    $0x2c,%esp
  801256:	8b 75 08             	mov    0x8(%ebp),%esi
  801259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80125c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80125f:	eb 12                	jmp    801273 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801261:	85 c0                	test   %eax,%eax
  801263:	0f 84 42 04 00 00    	je     8016ab <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	53                   	push   %ebx
  80126d:	50                   	push   %eax
  80126e:	ff d6                	call   *%esi
  801270:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801273:	83 c7 01             	add    $0x1,%edi
  801276:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80127a:	83 f8 25             	cmp    $0x25,%eax
  80127d:	75 e2                	jne    801261 <vprintfmt+0x14>
  80127f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801283:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80128a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801291:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801298:	b9 00 00 00 00       	mov    $0x0,%ecx
  80129d:	eb 07                	jmp    8012a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a6:	8d 47 01             	lea    0x1(%edi),%eax
  8012a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ac:	0f b6 07             	movzbl (%edi),%eax
  8012af:	0f b6 d0             	movzbl %al,%edx
  8012b2:	83 e8 23             	sub    $0x23,%eax
  8012b5:	3c 55                	cmp    $0x55,%al
  8012b7:	0f 87 d3 03 00 00    	ja     801690 <vprintfmt+0x443>
  8012bd:	0f b6 c0             	movzbl %al,%eax
  8012c0:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
  8012c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012ca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012ce:	eb d6                	jmp    8012a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012de:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012e2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012e5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012e8:	83 f9 09             	cmp    $0x9,%ecx
  8012eb:	77 3f                	ja     80132c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f0:	eb e9                	jmp    8012db <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f5:	8b 00                	mov    (%eax),%eax
  8012f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fd:	8d 40 04             	lea    0x4(%eax),%eax
  801300:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801306:	eb 2a                	jmp    801332 <vprintfmt+0xe5>
  801308:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130b:	85 c0                	test   %eax,%eax
  80130d:	ba 00 00 00 00       	mov    $0x0,%edx
  801312:	0f 49 d0             	cmovns %eax,%edx
  801315:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131b:	eb 89                	jmp    8012a6 <vprintfmt+0x59>
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801320:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801327:	e9 7a ff ff ff       	jmp    8012a6 <vprintfmt+0x59>
  80132c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80132f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801332:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801336:	0f 89 6a ff ff ff    	jns    8012a6 <vprintfmt+0x59>
				width = precision, precision = -1;
  80133c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80133f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801342:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801349:	e9 58 ff ff ff       	jmp    8012a6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80134e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801354:	e9 4d ff ff ff       	jmp    8012a6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801359:	8b 45 14             	mov    0x14(%ebp),%eax
  80135c:	8d 78 04             	lea    0x4(%eax),%edi
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	53                   	push   %ebx
  801363:	ff 30                	pushl  (%eax)
  801365:	ff d6                	call   *%esi
			break;
  801367:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80136a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801370:	e9 fe fe ff ff       	jmp    801273 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801375:	8b 45 14             	mov    0x14(%ebp),%eax
  801378:	8d 78 04             	lea    0x4(%eax),%edi
  80137b:	8b 00                	mov    (%eax),%eax
  80137d:	99                   	cltd   
  80137e:	31 d0                	xor    %edx,%eax
  801380:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801382:	83 f8 0f             	cmp    $0xf,%eax
  801385:	7f 0b                	jg     801392 <vprintfmt+0x145>
  801387:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  80138e:	85 d2                	test   %edx,%edx
  801390:	75 1b                	jne    8013ad <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801392:	50                   	push   %eax
  801393:	68 5f 20 80 00       	push   $0x80205f
  801398:	53                   	push   %ebx
  801399:	56                   	push   %esi
  80139a:	e8 91 fe ff ff       	call   801230 <printfmt>
  80139f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013a2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a8:	e9 c6 fe ff ff       	jmp    801273 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ad:	52                   	push   %edx
  8013ae:	68 dd 1f 80 00       	push   $0x801fdd
  8013b3:	53                   	push   %ebx
  8013b4:	56                   	push   %esi
  8013b5:	e8 76 fe ff ff       	call   801230 <printfmt>
  8013ba:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013bd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c3:	e9 ab fe ff ff       	jmp    801273 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cb:	83 c0 04             	add    $0x4,%eax
  8013ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013d6:	85 ff                	test   %edi,%edi
  8013d8:	b8 58 20 80 00       	mov    $0x802058,%eax
  8013dd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013e4:	0f 8e 94 00 00 00    	jle    80147e <vprintfmt+0x231>
  8013ea:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ee:	0f 84 98 00 00 00    	je     80148c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8013fa:	57                   	push   %edi
  8013fb:	e8 33 03 00 00       	call   801733 <strnlen>
  801400:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801403:	29 c1                	sub    %eax,%ecx
  801405:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801408:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80140b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80140f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801412:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801415:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801417:	eb 0f                	jmp    801428 <vprintfmt+0x1db>
					putch(padc, putdat);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	53                   	push   %ebx
  80141d:	ff 75 e0             	pushl  -0x20(%ebp)
  801420:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801422:	83 ef 01             	sub    $0x1,%edi
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 ff                	test   %edi,%edi
  80142a:	7f ed                	jg     801419 <vprintfmt+0x1cc>
  80142c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80142f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801432:	85 c9                	test   %ecx,%ecx
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
  801439:	0f 49 c1             	cmovns %ecx,%eax
  80143c:	29 c1                	sub    %eax,%ecx
  80143e:	89 75 08             	mov    %esi,0x8(%ebp)
  801441:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801444:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801447:	89 cb                	mov    %ecx,%ebx
  801449:	eb 4d                	jmp    801498 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80144b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80144f:	74 1b                	je     80146c <vprintfmt+0x21f>
  801451:	0f be c0             	movsbl %al,%eax
  801454:	83 e8 20             	sub    $0x20,%eax
  801457:	83 f8 5e             	cmp    $0x5e,%eax
  80145a:	76 10                	jbe    80146c <vprintfmt+0x21f>
					putch('?', putdat);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	ff 75 0c             	pushl  0xc(%ebp)
  801462:	6a 3f                	push   $0x3f
  801464:	ff 55 08             	call   *0x8(%ebp)
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	eb 0d                	jmp    801479 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	52                   	push   %edx
  801473:	ff 55 08             	call   *0x8(%ebp)
  801476:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801479:	83 eb 01             	sub    $0x1,%ebx
  80147c:	eb 1a                	jmp    801498 <vprintfmt+0x24b>
  80147e:	89 75 08             	mov    %esi,0x8(%ebp)
  801481:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801487:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80148a:	eb 0c                	jmp    801498 <vprintfmt+0x24b>
  80148c:	89 75 08             	mov    %esi,0x8(%ebp)
  80148f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801492:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801495:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801498:	83 c7 01             	add    $0x1,%edi
  80149b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80149f:	0f be d0             	movsbl %al,%edx
  8014a2:	85 d2                	test   %edx,%edx
  8014a4:	74 23                	je     8014c9 <vprintfmt+0x27c>
  8014a6:	85 f6                	test   %esi,%esi
  8014a8:	78 a1                	js     80144b <vprintfmt+0x1fe>
  8014aa:	83 ee 01             	sub    $0x1,%esi
  8014ad:	79 9c                	jns    80144b <vprintfmt+0x1fe>
  8014af:	89 df                	mov    %ebx,%edi
  8014b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b7:	eb 18                	jmp    8014d1 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	53                   	push   %ebx
  8014bd:	6a 20                	push   $0x20
  8014bf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c1:	83 ef 01             	sub    $0x1,%edi
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	eb 08                	jmp    8014d1 <vprintfmt+0x284>
  8014c9:	89 df                	mov    %ebx,%edi
  8014cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d1:	85 ff                	test   %edi,%edi
  8014d3:	7f e4                	jg     8014b9 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014d8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014de:	e9 90 fd ff ff       	jmp    801273 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014e3:	83 f9 01             	cmp    $0x1,%ecx
  8014e6:	7e 19                	jle    801501 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8b 50 04             	mov    0x4(%eax),%edx
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f9:	8d 40 08             	lea    0x8(%eax),%eax
  8014fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ff:	eb 38                	jmp    801539 <vprintfmt+0x2ec>
	else if (lflag)
  801501:	85 c9                	test   %ecx,%ecx
  801503:	74 1b                	je     801520 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8b 00                	mov    (%eax),%eax
  80150a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	c1 f9 1f             	sar    $0x1f,%ecx
  801512:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801515:	8b 45 14             	mov    0x14(%ebp),%eax
  801518:	8d 40 04             	lea    0x4(%eax),%eax
  80151b:	89 45 14             	mov    %eax,0x14(%ebp)
  80151e:	eb 19                	jmp    801539 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8b 00                	mov    (%eax),%eax
  801525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801528:	89 c1                	mov    %eax,%ecx
  80152a:	c1 f9 1f             	sar    $0x1f,%ecx
  80152d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8d 40 04             	lea    0x4(%eax),%eax
  801536:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801539:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80153c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80153f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801544:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801548:	0f 89 0e 01 00 00    	jns    80165c <vprintfmt+0x40f>
				putch('-', putdat);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	53                   	push   %ebx
  801552:	6a 2d                	push   $0x2d
  801554:	ff d6                	call   *%esi
				num = -(long long) num;
  801556:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801559:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80155c:	f7 da                	neg    %edx
  80155e:	83 d1 00             	adc    $0x0,%ecx
  801561:	f7 d9                	neg    %ecx
  801563:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156b:	e9 ec 00 00 00       	jmp    80165c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801570:	83 f9 01             	cmp    $0x1,%ecx
  801573:	7e 18                	jle    80158d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801575:	8b 45 14             	mov    0x14(%ebp),%eax
  801578:	8b 10                	mov    (%eax),%edx
  80157a:	8b 48 04             	mov    0x4(%eax),%ecx
  80157d:	8d 40 08             	lea    0x8(%eax),%eax
  801580:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801583:	b8 0a 00 00 00       	mov    $0xa,%eax
  801588:	e9 cf 00 00 00       	jmp    80165c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80158d:	85 c9                	test   %ecx,%ecx
  80158f:	74 1a                	je     8015ab <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801591:	8b 45 14             	mov    0x14(%ebp),%eax
  801594:	8b 10                	mov    (%eax),%edx
  801596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159b:	8d 40 04             	lea    0x4(%eax),%eax
  80159e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8015a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015a6:	e9 b1 00 00 00       	jmp    80165c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8015ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ae:	8b 10                	mov    (%eax),%edx
  8015b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015b5:	8d 40 04             	lea    0x4(%eax),%eax
  8015b8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8015bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015c0:	e9 97 00 00 00       	jmp    80165c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	6a 58                	push   $0x58
  8015cb:	ff d6                	call   *%esi
			putch('X', putdat);
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	6a 58                	push   $0x58
  8015d3:	ff d6                	call   *%esi
			putch('X', putdat);
  8015d5:	83 c4 08             	add    $0x8,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	6a 58                	push   $0x58
  8015db:	ff d6                	call   *%esi
			break;
  8015dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015e3:	e9 8b fc ff ff       	jmp    801273 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	6a 30                	push   $0x30
  8015ee:	ff d6                	call   *%esi
			putch('x', putdat);
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	53                   	push   %ebx
  8015f4:	6a 78                	push   $0x78
  8015f6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fb:	8b 10                	mov    (%eax),%edx
  8015fd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801602:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801605:	8d 40 04             	lea    0x4(%eax),%eax
  801608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80160b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801610:	eb 4a                	jmp    80165c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801612:	83 f9 01             	cmp    $0x1,%ecx
  801615:	7e 15                	jle    80162c <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801617:	8b 45 14             	mov    0x14(%ebp),%eax
  80161a:	8b 10                	mov    (%eax),%edx
  80161c:	8b 48 04             	mov    0x4(%eax),%ecx
  80161f:	8d 40 08             	lea    0x8(%eax),%eax
  801622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801625:	b8 10 00 00 00       	mov    $0x10,%eax
  80162a:	eb 30                	jmp    80165c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80162c:	85 c9                	test   %ecx,%ecx
  80162e:	74 17                	je     801647 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801630:	8b 45 14             	mov    0x14(%ebp),%eax
  801633:	8b 10                	mov    (%eax),%edx
  801635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80163a:	8d 40 04             	lea    0x4(%eax),%eax
  80163d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801640:	b8 10 00 00 00       	mov    $0x10,%eax
  801645:	eb 15                	jmp    80165c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801647:	8b 45 14             	mov    0x14(%ebp),%eax
  80164a:	8b 10                	mov    (%eax),%edx
  80164c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801651:	8d 40 04             	lea    0x4(%eax),%eax
  801654:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801657:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801663:	57                   	push   %edi
  801664:	ff 75 e0             	pushl  -0x20(%ebp)
  801667:	50                   	push   %eax
  801668:	51                   	push   %ecx
  801669:	52                   	push   %edx
  80166a:	89 da                	mov    %ebx,%edx
  80166c:	89 f0                	mov    %esi,%eax
  80166e:	e8 f1 fa ff ff       	call   801164 <printnum>
			break;
  801673:	83 c4 20             	add    $0x20,%esp
  801676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801679:	e9 f5 fb ff ff       	jmp    801273 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	53                   	push   %ebx
  801682:	52                   	push   %edx
  801683:	ff d6                	call   *%esi
			break;
  801685:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80168b:	e9 e3 fb ff ff       	jmp    801273 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	53                   	push   %ebx
  801694:	6a 25                	push   $0x25
  801696:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	eb 03                	jmp    8016a0 <vprintfmt+0x453>
  80169d:	83 ef 01             	sub    $0x1,%edi
  8016a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016a4:	75 f7                	jne    80169d <vprintfmt+0x450>
  8016a6:	e9 c8 fb ff ff       	jmp    801273 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5f                   	pop    %edi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 18             	sub    $0x18,%esp
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	74 26                	je     8016fa <vsnprintf+0x47>
  8016d4:	85 d2                	test   %edx,%edx
  8016d6:	7e 22                	jle    8016fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016d8:	ff 75 14             	pushl  0x14(%ebp)
  8016db:	ff 75 10             	pushl  0x10(%ebp)
  8016de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	68 13 12 80 00       	push   $0x801213
  8016e7:	e8 61 fb ff ff       	call   80124d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 05                	jmp    8016ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801707:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80170a:	50                   	push   %eax
  80170b:	ff 75 10             	pushl  0x10(%ebp)
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	ff 75 08             	pushl  0x8(%ebp)
  801714:	e8 9a ff ff ff       	call   8016b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801721:	b8 00 00 00 00       	mov    $0x0,%eax
  801726:	eb 03                	jmp    80172b <strlen+0x10>
		n++;
  801728:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80172b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80172f:	75 f7                	jne    801728 <strlen+0xd>
		n++;
	return n;
}
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801739:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80173c:	ba 00 00 00 00       	mov    $0x0,%edx
  801741:	eb 03                	jmp    801746 <strnlen+0x13>
		n++;
  801743:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801746:	39 c2                	cmp    %eax,%edx
  801748:	74 08                	je     801752 <strnlen+0x1f>
  80174a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80174e:	75 f3                	jne    801743 <strnlen+0x10>
  801750:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	53                   	push   %ebx
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80175e:	89 c2                	mov    %eax,%edx
  801760:	83 c2 01             	add    $0x1,%edx
  801763:	83 c1 01             	add    $0x1,%ecx
  801766:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80176a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80176d:	84 db                	test   %bl,%bl
  80176f:	75 ef                	jne    801760 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801771:	5b                   	pop    %ebx
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80177b:	53                   	push   %ebx
  80177c:	e8 9a ff ff ff       	call   80171b <strlen>
  801781:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801784:	ff 75 0c             	pushl  0xc(%ebp)
  801787:	01 d8                	add    %ebx,%eax
  801789:	50                   	push   %eax
  80178a:	e8 c5 ff ff ff       	call   801754 <strcpy>
	return dst;
}
  80178f:	89 d8                	mov    %ebx,%eax
  801791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
  80179b:	8b 75 08             	mov    0x8(%ebp),%esi
  80179e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a1:	89 f3                	mov    %esi,%ebx
  8017a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017a6:	89 f2                	mov    %esi,%edx
  8017a8:	eb 0f                	jmp    8017b9 <strncpy+0x23>
		*dst++ = *src;
  8017aa:	83 c2 01             	add    $0x1,%edx
  8017ad:	0f b6 01             	movzbl (%ecx),%eax
  8017b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8017b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017b9:	39 da                	cmp    %ebx,%edx
  8017bb:	75 ed                	jne    8017aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017bd:	89 f0                	mov    %esi,%eax
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ce:	8b 55 10             	mov    0x10(%ebp),%edx
  8017d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017d3:	85 d2                	test   %edx,%edx
  8017d5:	74 21                	je     8017f8 <strlcpy+0x35>
  8017d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017db:	89 f2                	mov    %esi,%edx
  8017dd:	eb 09                	jmp    8017e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017df:	83 c2 01             	add    $0x1,%edx
  8017e2:	83 c1 01             	add    $0x1,%ecx
  8017e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017e8:	39 c2                	cmp    %eax,%edx
  8017ea:	74 09                	je     8017f5 <strlcpy+0x32>
  8017ec:	0f b6 19             	movzbl (%ecx),%ebx
  8017ef:	84 db                	test   %bl,%bl
  8017f1:	75 ec                	jne    8017df <strlcpy+0x1c>
  8017f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017f8:	29 f0                	sub    %esi,%eax
}
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    

008017fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801804:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801807:	eb 06                	jmp    80180f <strcmp+0x11>
		p++, q++;
  801809:	83 c1 01             	add    $0x1,%ecx
  80180c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80180f:	0f b6 01             	movzbl (%ecx),%eax
  801812:	84 c0                	test   %al,%al
  801814:	74 04                	je     80181a <strcmp+0x1c>
  801816:	3a 02                	cmp    (%edx),%al
  801818:	74 ef                	je     801809 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80181a:	0f b6 c0             	movzbl %al,%eax
  80181d:	0f b6 12             	movzbl (%edx),%edx
  801820:	29 d0                	sub    %edx,%eax
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801833:	eb 06                	jmp    80183b <strncmp+0x17>
		n--, p++, q++;
  801835:	83 c0 01             	add    $0x1,%eax
  801838:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80183b:	39 d8                	cmp    %ebx,%eax
  80183d:	74 15                	je     801854 <strncmp+0x30>
  80183f:	0f b6 08             	movzbl (%eax),%ecx
  801842:	84 c9                	test   %cl,%cl
  801844:	74 04                	je     80184a <strncmp+0x26>
  801846:	3a 0a                	cmp    (%edx),%cl
  801848:	74 eb                	je     801835 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80184a:	0f b6 00             	movzbl (%eax),%eax
  80184d:	0f b6 12             	movzbl (%edx),%edx
  801850:	29 d0                	sub    %edx,%eax
  801852:	eb 05                	jmp    801859 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801859:	5b                   	pop    %ebx
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801866:	eb 07                	jmp    80186f <strchr+0x13>
		if (*s == c)
  801868:	38 ca                	cmp    %cl,%dl
  80186a:	74 0f                	je     80187b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80186c:	83 c0 01             	add    $0x1,%eax
  80186f:	0f b6 10             	movzbl (%eax),%edx
  801872:	84 d2                	test   %dl,%dl
  801874:	75 f2                	jne    801868 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801887:	eb 03                	jmp    80188c <strfind+0xf>
  801889:	83 c0 01             	add    $0x1,%eax
  80188c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80188f:	38 ca                	cmp    %cl,%dl
  801891:	74 04                	je     801897 <strfind+0x1a>
  801893:	84 d2                	test   %dl,%dl
  801895:	75 f2                	jne    801889 <strfind+0xc>
			break;
	return (char *) s;
}
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	57                   	push   %edi
  80189d:	56                   	push   %esi
  80189e:	53                   	push   %ebx
  80189f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018a5:	85 c9                	test   %ecx,%ecx
  8018a7:	74 36                	je     8018df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018af:	75 28                	jne    8018d9 <memset+0x40>
  8018b1:	f6 c1 03             	test   $0x3,%cl
  8018b4:	75 23                	jne    8018d9 <memset+0x40>
		c &= 0xFF;
  8018b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018ba:	89 d3                	mov    %edx,%ebx
  8018bc:	c1 e3 08             	shl    $0x8,%ebx
  8018bf:	89 d6                	mov    %edx,%esi
  8018c1:	c1 e6 18             	shl    $0x18,%esi
  8018c4:	89 d0                	mov    %edx,%eax
  8018c6:	c1 e0 10             	shl    $0x10,%eax
  8018c9:	09 f0                	or     %esi,%eax
  8018cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018cd:	89 d8                	mov    %ebx,%eax
  8018cf:	09 d0                	or     %edx,%eax
  8018d1:	c1 e9 02             	shr    $0x2,%ecx
  8018d4:	fc                   	cld    
  8018d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8018d7:	eb 06                	jmp    8018df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018dc:	fc                   	cld    
  8018dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018df:	89 f8                	mov    %edi,%eax
  8018e1:	5b                   	pop    %ebx
  8018e2:	5e                   	pop    %esi
  8018e3:	5f                   	pop    %edi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	57                   	push   %edi
  8018ea:	56                   	push   %esi
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018f4:	39 c6                	cmp    %eax,%esi
  8018f6:	73 35                	jae    80192d <memmove+0x47>
  8018f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018fb:	39 d0                	cmp    %edx,%eax
  8018fd:	73 2e                	jae    80192d <memmove+0x47>
		s += n;
		d += n;
  8018ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801902:	89 d6                	mov    %edx,%esi
  801904:	09 fe                	or     %edi,%esi
  801906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80190c:	75 13                	jne    801921 <memmove+0x3b>
  80190e:	f6 c1 03             	test   $0x3,%cl
  801911:	75 0e                	jne    801921 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801913:	83 ef 04             	sub    $0x4,%edi
  801916:	8d 72 fc             	lea    -0x4(%edx),%esi
  801919:	c1 e9 02             	shr    $0x2,%ecx
  80191c:	fd                   	std    
  80191d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80191f:	eb 09                	jmp    80192a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801921:	83 ef 01             	sub    $0x1,%edi
  801924:	8d 72 ff             	lea    -0x1(%edx),%esi
  801927:	fd                   	std    
  801928:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80192a:	fc                   	cld    
  80192b:	eb 1d                	jmp    80194a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80192d:	89 f2                	mov    %esi,%edx
  80192f:	09 c2                	or     %eax,%edx
  801931:	f6 c2 03             	test   $0x3,%dl
  801934:	75 0f                	jne    801945 <memmove+0x5f>
  801936:	f6 c1 03             	test   $0x3,%cl
  801939:	75 0a                	jne    801945 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80193b:	c1 e9 02             	shr    $0x2,%ecx
  80193e:	89 c7                	mov    %eax,%edi
  801940:	fc                   	cld    
  801941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801943:	eb 05                	jmp    80194a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801945:	89 c7                	mov    %eax,%edi
  801947:	fc                   	cld    
  801948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80194a:	5e                   	pop    %esi
  80194b:	5f                   	pop    %edi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801951:	ff 75 10             	pushl  0x10(%ebp)
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	ff 75 08             	pushl  0x8(%ebp)
  80195a:	e8 87 ff ff ff       	call   8018e6 <memmove>
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	56                   	push   %esi
  801965:	53                   	push   %ebx
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196c:	89 c6                	mov    %eax,%esi
  80196e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801971:	eb 1a                	jmp    80198d <memcmp+0x2c>
		if (*s1 != *s2)
  801973:	0f b6 08             	movzbl (%eax),%ecx
  801976:	0f b6 1a             	movzbl (%edx),%ebx
  801979:	38 d9                	cmp    %bl,%cl
  80197b:	74 0a                	je     801987 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80197d:	0f b6 c1             	movzbl %cl,%eax
  801980:	0f b6 db             	movzbl %bl,%ebx
  801983:	29 d8                	sub    %ebx,%eax
  801985:	eb 0f                	jmp    801996 <memcmp+0x35>
		s1++, s2++;
  801987:	83 c0 01             	add    $0x1,%eax
  80198a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80198d:	39 f0                	cmp    %esi,%eax
  80198f:	75 e2                	jne    801973 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	53                   	push   %ebx
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019a1:	89 c1                	mov    %eax,%ecx
  8019a3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019a6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019aa:	eb 0a                	jmp    8019b6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019ac:	0f b6 10             	movzbl (%eax),%edx
  8019af:	39 da                	cmp    %ebx,%edx
  8019b1:	74 07                	je     8019ba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019b3:	83 c0 01             	add    $0x1,%eax
  8019b6:	39 c8                	cmp    %ecx,%eax
  8019b8:	72 f2                	jb     8019ac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019ba:	5b                   	pop    %ebx
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	57                   	push   %edi
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c9:	eb 03                	jmp    8019ce <strtol+0x11>
		s++;
  8019cb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019ce:	0f b6 01             	movzbl (%ecx),%eax
  8019d1:	3c 20                	cmp    $0x20,%al
  8019d3:	74 f6                	je     8019cb <strtol+0xe>
  8019d5:	3c 09                	cmp    $0x9,%al
  8019d7:	74 f2                	je     8019cb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019d9:	3c 2b                	cmp    $0x2b,%al
  8019db:	75 0a                	jne    8019e7 <strtol+0x2a>
		s++;
  8019dd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e5:	eb 11                	jmp    8019f8 <strtol+0x3b>
  8019e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019ec:	3c 2d                	cmp    $0x2d,%al
  8019ee:	75 08                	jne    8019f8 <strtol+0x3b>
		s++, neg = 1;
  8019f0:	83 c1 01             	add    $0x1,%ecx
  8019f3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019fe:	75 15                	jne    801a15 <strtol+0x58>
  801a00:	80 39 30             	cmpb   $0x30,(%ecx)
  801a03:	75 10                	jne    801a15 <strtol+0x58>
  801a05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a09:	75 7c                	jne    801a87 <strtol+0xca>
		s += 2, base = 16;
  801a0b:	83 c1 02             	add    $0x2,%ecx
  801a0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a13:	eb 16                	jmp    801a2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a15:	85 db                	test   %ebx,%ebx
  801a17:	75 12                	jne    801a2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1e:	80 39 30             	cmpb   $0x30,(%ecx)
  801a21:	75 08                	jne    801a2b <strtol+0x6e>
		s++, base = 8;
  801a23:	83 c1 01             	add    $0x1,%ecx
  801a26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a33:	0f b6 11             	movzbl (%ecx),%edx
  801a36:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a39:	89 f3                	mov    %esi,%ebx
  801a3b:	80 fb 09             	cmp    $0x9,%bl
  801a3e:	77 08                	ja     801a48 <strtol+0x8b>
			dig = *s - '0';
  801a40:	0f be d2             	movsbl %dl,%edx
  801a43:	83 ea 30             	sub    $0x30,%edx
  801a46:	eb 22                	jmp    801a6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a48:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a4b:	89 f3                	mov    %esi,%ebx
  801a4d:	80 fb 19             	cmp    $0x19,%bl
  801a50:	77 08                	ja     801a5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a52:	0f be d2             	movsbl %dl,%edx
  801a55:	83 ea 57             	sub    $0x57,%edx
  801a58:	eb 10                	jmp    801a6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a5d:	89 f3                	mov    %esi,%ebx
  801a5f:	80 fb 19             	cmp    $0x19,%bl
  801a62:	77 16                	ja     801a7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a64:	0f be d2             	movsbl %dl,%edx
  801a67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a6d:	7d 0b                	jge    801a7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a6f:	83 c1 01             	add    $0x1,%ecx
  801a72:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a78:	eb b9                	jmp    801a33 <strtol+0x76>

	if (endptr)
  801a7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a7e:	74 0d                	je     801a8d <strtol+0xd0>
		*endptr = (char *) s;
  801a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a83:	89 0e                	mov    %ecx,(%esi)
  801a85:	eb 06                	jmp    801a8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a87:	85 db                	test   %ebx,%ebx
  801a89:	74 98                	je     801a23 <strtol+0x66>
  801a8b:	eb 9e                	jmp    801a2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	f7 da                	neg    %edx
  801a91:	85 ff                	test   %edi,%edi
  801a93:	0f 45 c2             	cmovne %edx,%eax
}
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5f                   	pop    %edi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	53                   	push   %ebx
  801a9f:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801aa2:	e8 8b e6 ff ff       	call   800132 <sys_getenvid>
  801aa7:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801aa9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ab0:	75 29                	jne    801adb <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	6a 07                	push   $0x7
  801ab7:	68 00 f0 bf ee       	push   $0xeebff000
  801abc:	50                   	push   %eax
  801abd:	e8 ae e6 ff ff       	call   800170 <sys_page_alloc>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	79 12                	jns    801adb <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801ac9:	50                   	push   %eax
  801aca:	68 40 23 80 00       	push   $0x802340
  801acf:	6a 24                	push   $0x24
  801ad1:	68 59 23 80 00       	push   $0x802359
  801ad6:	e8 9c f5 ff ff       	call   801077 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801ae3:	83 ec 08             	sub    $0x8,%esp
  801ae6:	68 61 03 80 00       	push   $0x800361
  801aeb:	53                   	push   %ebx
  801aec:	e8 ca e7 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	79 12                	jns    801b0a <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801af8:	50                   	push   %eax
  801af9:	68 40 23 80 00       	push   $0x802340
  801afe:	6a 2e                	push   $0x2e
  801b00:	68 59 23 80 00       	push   $0x802359
  801b05:	e8 6d f5 ff ff       	call   801077 <_panic>
}
  801b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	8b 75 08             	mov    0x8(%ebp),%esi
  801b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801b21:	85 f6                	test   %esi,%esi
  801b23:	74 06                	je     801b2b <ipc_recv+0x1c>
		*from_env_store = 0;
  801b25:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801b2b:	85 db                	test   %ebx,%ebx
  801b2d:	74 06                	je     801b35 <ipc_recv+0x26>
		*perm_store = 0;
  801b2f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801b35:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801b37:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b3c:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	50                   	push   %eax
  801b43:	e8 d8 e7 ff ff       	call   800320 <sys_ipc_recv>
  801b48:	89 c7                	mov    %eax,%edi
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	79 14                	jns    801b65 <ipc_recv+0x56>
		cprintf("im dead");
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	68 67 23 80 00       	push   $0x802367
  801b59:	e8 f2 f5 ff ff       	call   801150 <cprintf>
		return r;
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	89 f8                	mov    %edi,%eax
  801b63:	eb 24                	jmp    801b89 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801b65:	85 f6                	test   %esi,%esi
  801b67:	74 0a                	je     801b73 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801b69:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6e:	8b 40 74             	mov    0x74(%eax),%eax
  801b71:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801b73:	85 db                	test   %ebx,%ebx
  801b75:	74 0a                	je     801b81 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801b77:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7c:	8b 40 78             	mov    0x78(%eax),%eax
  801b7f:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801b81:	a1 04 40 80 00       	mov    0x804004,%eax
  801b86:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801ba3:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801baa:	0f 44 d8             	cmove  %eax,%ebx
  801bad:	eb 1c                	jmp    801bcb <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801baf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb2:	74 12                	je     801bc6 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801bb4:	50                   	push   %eax
  801bb5:	68 6f 23 80 00       	push   $0x80236f
  801bba:	6a 4e                	push   $0x4e
  801bbc:	68 7c 23 80 00       	push   $0x80237c
  801bc1:	e8 b1 f4 ff ff       	call   801077 <_panic>
		sys_yield();
  801bc6:	e8 86 e5 ff ff       	call   800151 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bcb:	ff 75 14             	pushl  0x14(%ebp)
  801bce:	53                   	push   %ebx
  801bcf:	56                   	push   %esi
  801bd0:	57                   	push   %edi
  801bd1:	e8 27 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 d2                	js     801baf <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be0:	5b                   	pop    %ebx
  801be1:	5e                   	pop    %esi
  801be2:	5f                   	pop    %edi
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bf0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bf3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf9:	8b 52 50             	mov    0x50(%edx),%edx
  801bfc:	39 ca                	cmp    %ecx,%edx
  801bfe:	75 0d                	jne    801c0d <ipc_find_env+0x28>
			return envs[i].env_id;
  801c00:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c03:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c08:	8b 40 48             	mov    0x48(%eax),%eax
  801c0b:	eb 0f                	jmp    801c1c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c0d:	83 c0 01             	add    $0x1,%eax
  801c10:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c15:	75 d9                	jne    801bf0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c24:	89 d0                	mov    %edx,%eax
  801c26:	c1 e8 16             	shr    $0x16,%eax
  801c29:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c35:	f6 c1 01             	test   $0x1,%cl
  801c38:	74 1d                	je     801c57 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c3a:	c1 ea 0c             	shr    $0xc,%edx
  801c3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c44:	f6 c2 01             	test   $0x1,%dl
  801c47:	74 0e                	je     801c57 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c49:	c1 ea 0c             	shr    $0xc,%edx
  801c4c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c53:	ef 
  801c54:	0f b7 c0             	movzwl %ax,%eax
}
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__udivdi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 f6                	test   %esi,%esi
  801c79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7d:	89 ca                	mov    %ecx,%edx
  801c7f:	89 f8                	mov    %edi,%eax
  801c81:	75 3d                	jne    801cc0 <__udivdi3+0x60>
  801c83:	39 cf                	cmp    %ecx,%edi
  801c85:	0f 87 c5 00 00 00    	ja     801d50 <__udivdi3+0xf0>
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	89 fd                	mov    %edi,%ebp
  801c8f:	75 0b                	jne    801c9c <__udivdi3+0x3c>
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	31 d2                	xor    %edx,%edx
  801c98:	f7 f7                	div    %edi
  801c9a:	89 c5                	mov    %eax,%ebp
  801c9c:	89 c8                	mov    %ecx,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	f7 f5                	div    %ebp
  801ca2:	89 c1                	mov    %eax,%ecx
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	89 cf                	mov    %ecx,%edi
  801ca8:	f7 f5                	div    %ebp
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	39 ce                	cmp    %ecx,%esi
  801cc2:	77 74                	ja     801d38 <__udivdi3+0xd8>
  801cc4:	0f bd fe             	bsr    %esi,%edi
  801cc7:	83 f7 1f             	xor    $0x1f,%edi
  801cca:	0f 84 98 00 00 00    	je     801d68 <__udivdi3+0x108>
  801cd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	89 c5                	mov    %eax,%ebp
  801cd9:	29 fb                	sub    %edi,%ebx
  801cdb:	d3 e6                	shl    %cl,%esi
  801cdd:	89 d9                	mov    %ebx,%ecx
  801cdf:	d3 ed                	shr    %cl,%ebp
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	d3 e0                	shl    %cl,%eax
  801ce5:	09 ee                	or     %ebp,%esi
  801ce7:	89 d9                	mov    %ebx,%ecx
  801ce9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ced:	89 d5                	mov    %edx,%ebp
  801cef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cf3:	d3 ed                	shr    %cl,%ebp
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e2                	shl    %cl,%edx
  801cf9:	89 d9                	mov    %ebx,%ecx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	09 c2                	or     %eax,%edx
  801cff:	89 d0                	mov    %edx,%eax
  801d01:	89 ea                	mov    %ebp,%edx
  801d03:	f7 f6                	div    %esi
  801d05:	89 d5                	mov    %edx,%ebp
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	f7 64 24 0c          	mull   0xc(%esp)
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	72 10                	jb     801d21 <__udivdi3+0xc1>
  801d11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e6                	shl    %cl,%esi
  801d19:	39 c6                	cmp    %eax,%esi
  801d1b:	73 07                	jae    801d24 <__udivdi3+0xc4>
  801d1d:	39 d5                	cmp    %edx,%ebp
  801d1f:	75 03                	jne    801d24 <__udivdi3+0xc4>
  801d21:	83 eb 01             	sub    $0x1,%ebx
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 d8                	mov    %ebx,%eax
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	31 db                	xor    %ebx,%ebx
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	83 c4 1c             	add    $0x1c,%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
  801d48:	90                   	nop
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	f7 f7                	div    %edi
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 fa                	mov    %edi,%edx
  801d5c:	83 c4 1c             	add    $0x1c,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5f                   	pop    %edi
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    
  801d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d68:	39 ce                	cmp    %ecx,%esi
  801d6a:	72 0c                	jb     801d78 <__udivdi3+0x118>
  801d6c:	31 db                	xor    %ebx,%ebx
  801d6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d72:	0f 87 34 ff ff ff    	ja     801cac <__udivdi3+0x4c>
  801d78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d7d:	e9 2a ff ff ff       	jmp    801cac <__udivdi3+0x4c>
  801d82:	66 90                	xchg   %ax,%ax
  801d84:	66 90                	xchg   %ax,%ax
  801d86:	66 90                	xchg   %ax,%ax
  801d88:	66 90                	xchg   %ax,%ax
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	85 d2                	test   %edx,%edx
  801da9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db1:	89 f3                	mov    %esi,%ebx
  801db3:	89 3c 24             	mov    %edi,(%esp)
  801db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dba:	75 1c                	jne    801dd8 <__umoddi3+0x48>
  801dbc:	39 f7                	cmp    %esi,%edi
  801dbe:	76 50                	jbe    801e10 <__umoddi3+0x80>
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	f7 f7                	div    %edi
  801dc6:	89 d0                	mov    %edx,%eax
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	83 c4 1c             	add    $0x1c,%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
  801dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	77 52                	ja     801e30 <__umoddi3+0xa0>
  801dde:	0f bd ea             	bsr    %edx,%ebp
  801de1:	83 f5 1f             	xor    $0x1f,%ebp
  801de4:	75 5a                	jne    801e40 <__umoddi3+0xb0>
  801de6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	39 0c 24             	cmp    %ecx,(%esp)
  801df3:	0f 86 d7 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801df9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	85 ff                	test   %edi,%edi
  801e12:	89 fd                	mov    %edi,%ebp
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 c8                	mov    %ecx,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	eb 99                	jmp    801dc8 <__umoddi3+0x38>
  801e2f:	90                   	nop
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	83 c4 1c             	add    $0x1c,%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    
  801e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e40:	8b 34 24             	mov    (%esp),%esi
  801e43:	bf 20 00 00 00       	mov    $0x20,%edi
  801e48:	89 e9                	mov    %ebp,%ecx
  801e4a:	29 ef                	sub    %ebp,%edi
  801e4c:	d3 e0                	shl    %cl,%eax
  801e4e:	89 f9                	mov    %edi,%ecx
  801e50:	89 f2                	mov    %esi,%edx
  801e52:	d3 ea                	shr    %cl,%edx
  801e54:	89 e9                	mov    %ebp,%ecx
  801e56:	09 c2                	or     %eax,%edx
  801e58:	89 d8                	mov    %ebx,%eax
  801e5a:	89 14 24             	mov    %edx,(%esp)
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	d3 e2                	shl    %cl,%edx
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	89 c6                	mov    %eax,%esi
  801e71:	d3 e3                	shl    %cl,%ebx
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 d0                	mov    %edx,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	09 d8                	or     %ebx,%eax
  801e7d:	89 d3                	mov    %edx,%ebx
  801e7f:	89 f2                	mov    %esi,%edx
  801e81:	f7 34 24             	divl   (%esp)
  801e84:	89 d6                	mov    %edx,%esi
  801e86:	d3 e3                	shl    %cl,%ebx
  801e88:	f7 64 24 04          	mull   0x4(%esp)
  801e8c:	39 d6                	cmp    %edx,%esi
  801e8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e92:	89 d1                	mov    %edx,%ecx
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	72 08                	jb     801ea0 <__umoddi3+0x110>
  801e98:	75 11                	jne    801eab <__umoddi3+0x11b>
  801e9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e9e:	73 0b                	jae    801eab <__umoddi3+0x11b>
  801ea0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ea4:	1b 14 24             	sbb    (%esp),%edx
  801ea7:	89 d1                	mov    %edx,%ecx
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eaf:	29 da                	sub    %ebx,%edx
  801eb1:	19 ce                	sbb    %ecx,%esi
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	89 f0                	mov    %esi,%eax
  801eb7:	d3 e0                	shl    %cl,%eax
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	d3 ea                	shr    %cl,%edx
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	d3 ee                	shr    %cl,%esi
  801ec1:	09 d0                	or     %edx,%eax
  801ec3:	89 f2                	mov    %esi,%edx
  801ec5:	83 c4 1c             	add    $0x1c,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 f9                	sub    %edi,%ecx
  801ed2:	19 d6                	sbb    %edx,%esi
  801ed4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801edc:	e9 18 ff ff ff       	jmp    801df9 <__umoddi3+0x69>
