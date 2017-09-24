
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 60 	movl   $0x801e60,0x803000
  800040:	1e 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 6f 1e 80 00       	push   $0x801e6f
  800114:	6a 23                	push   $0x23
  800116:	68 8c 1e 80 00       	push   $0x801e8c
  80011b:	e8 27 0f 00 00       	call   801047 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 6f 1e 80 00       	push   $0x801e6f
  800195:	6a 23                	push   $0x23
  800197:	68 8c 1e 80 00       	push   $0x801e8c
  80019c:	e8 a6 0e 00 00       	call   801047 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 6f 1e 80 00       	push   $0x801e6f
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 8c 1e 80 00       	push   $0x801e8c
  8001de:	e8 64 0e 00 00       	call   801047 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 6f 1e 80 00       	push   $0x801e6f
  800219:	6a 23                	push   $0x23
  80021b:	68 8c 1e 80 00       	push   $0x801e8c
  800220:	e8 22 0e 00 00       	call   801047 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 6f 1e 80 00       	push   $0x801e6f
  80025b:	6a 23                	push   $0x23
  80025d:	68 8c 1e 80 00       	push   $0x801e8c
  800262:	e8 e0 0d 00 00       	call   801047 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 6f 1e 80 00       	push   $0x801e6f
  80029d:	6a 23                	push   $0x23
  80029f:	68 8c 1e 80 00       	push   $0x801e8c
  8002a4:	e8 9e 0d 00 00       	call   801047 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 6f 1e 80 00       	push   $0x801e6f
  8002df:	6a 23                	push   $0x23
  8002e1:	68 8c 1e 80 00       	push   $0x801e8c
  8002e6:	e8 5c 0d 00 00       	call   801047 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 6f 1e 80 00       	push   $0x801e6f
  800343:	6a 23                	push   $0x23
  800345:	68 8c 1e 80 00       	push   $0x801e8c
  80034a:	e8 f8 0c 00 00       	call   801047 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 18 1f 80 00       	mov    $0x801f18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 9c 1e 80 00       	push   $0x801e9c
  80045e:	e8 bd 0c 00 00       	call   801120 <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 dd 1e 80 00       	push   $0x801edd
  800688:	e8 93 0a 00 00       	call   801120 <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 f9 1e 80 00       	push   $0x801ef9
  80075d:	e8 be 09 00 00       	call   801120 <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 bc 1e 80 00       	push   $0x801ebc
  800812:	e8 09 09 00 00       	call   801120 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 e9 01 00 00       	call   800ac4 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 1f 12 00 00       	call   801b41 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 b0 11 00 00       	call   801aed <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 21 11 00 00       	call   801a6b <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 51 0d 00 00       	call   801724 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a04:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a09:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a12:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a18:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a1d:	50                   	push   %eax
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	68 08 50 80 00       	push   $0x805008
  800a26:	e8 8b 0e 00 00       	call   8018b6 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 cc fe ff ff       	call   800906 <fsipc>
            return r;

    return r;
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	e8 a2 fe ff ff       	call   800906 <fsipc>
  800a64:	89 c3                	mov    %eax,%ebx
  800a66:	85 c0                	test   %eax,%eax
  800a68:	78 51                	js     800abb <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a6a:	39 c6                	cmp    %eax,%esi
  800a6c:	73 19                	jae    800a87 <devfile_read+0x4b>
  800a6e:	68 28 1f 80 00       	push   $0x801f28
  800a73:	68 2f 1f 80 00       	push   $0x801f2f
  800a78:	68 82 00 00 00       	push   $0x82
  800a7d:	68 44 1f 80 00       	push   $0x801f44
  800a82:	e8 c0 05 00 00       	call   801047 <_panic>
	assert(r <= PGSIZE);
  800a87:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8c:	7e 19                	jle    800aa7 <devfile_read+0x6b>
  800a8e:	68 4f 1f 80 00       	push   $0x801f4f
  800a93:	68 2f 1f 80 00       	push   $0x801f2f
  800a98:	68 83 00 00 00       	push   $0x83
  800a9d:	68 44 1f 80 00       	push   $0x801f44
  800aa2:	e8 a0 05 00 00       	call   801047 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa7:	83 ec 04             	sub    $0x4,%esp
  800aaa:	50                   	push   %eax
  800aab:	68 00 50 80 00       	push   $0x805000
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	e8 fe 0d 00 00       	call   8018b6 <memmove>
	return r;
  800ab8:	83 c4 10             	add    $0x10,%esp
}
  800abb:	89 d8                	mov    %ebx,%eax
  800abd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 20             	sub    $0x20,%esp
  800acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ace:	53                   	push   %ebx
  800acf:	e8 17 0c 00 00       	call   8016eb <strlen>
  800ad4:	83 c4 10             	add    $0x10,%esp
  800ad7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800adc:	7f 67                	jg     800b45 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae4:	50                   	push   %eax
  800ae5:	e8 94 f8 ff ff       	call   80037e <fd_alloc>
  800aea:	83 c4 10             	add    $0x10,%esp
		return r;
  800aed:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 57                	js     800b4a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	53                   	push   %ebx
  800af7:	68 00 50 80 00       	push   $0x805000
  800afc:	e8 23 0c 00 00       	call   801724 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	e8 f0 fd ff ff       	call   800906 <fsipc>
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	79 14                	jns    800b33 <open+0x6f>
		fd_close(fd, 0);
  800b1f:	83 ec 08             	sub    $0x8,%esp
  800b22:	6a 00                	push   $0x0
  800b24:	ff 75 f4             	pushl  -0xc(%ebp)
  800b27:	e8 4a f9 ff ff       	call   800476 <fd_close>
		return r;
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	89 da                	mov    %ebx,%edx
  800b31:	eb 17                	jmp    800b4a <open+0x86>
	}

	return fd2num(fd);
  800b33:	83 ec 0c             	sub    $0xc,%esp
  800b36:	ff 75 f4             	pushl  -0xc(%ebp)
  800b39:	e8 19 f8 ff ff       	call   800357 <fd2num>
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	eb 05                	jmp    800b4a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b45:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b4a:	89 d0                	mov    %edx,%eax
  800b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b61:	e8 a0 fd ff ff       	call   800906 <fsipc>
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	ff 75 08             	pushl  0x8(%ebp)
  800b76:	e8 ec f7 ff ff       	call   800367 <fd2data>
  800b7b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7d:	83 c4 08             	add    $0x8,%esp
  800b80:	68 5b 1f 80 00       	push   $0x801f5b
  800b85:	53                   	push   %ebx
  800b86:	e8 99 0b 00 00       	call   801724 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b8b:	8b 46 04             	mov    0x4(%esi),%eax
  800b8e:	2b 06                	sub    (%esi),%eax
  800b90:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b96:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9d:	00 00 00 
	stat->st_dev = &devpipe;
  800ba0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba7:	30 80 00 
	return 0;
}
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc0:	53                   	push   %ebx
  800bc1:	6a 00                	push   $0x0
  800bc3:	e8 23 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc8:	89 1c 24             	mov    %ebx,(%esp)
  800bcb:	e8 97 f7 ff ff       	call   800367 <fd2data>
  800bd0:	83 c4 08             	add    $0x8,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 00                	push   $0x0
  800bd6:	e8 10 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 1c             	sub    $0x1c,%esp
  800be9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bec:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bee:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	ff 75 e0             	pushl  -0x20(%ebp)
  800bfc:	e8 79 0f 00 00       	call   801b7a <pageref>
  800c01:	89 c3                	mov    %eax,%ebx
  800c03:	89 3c 24             	mov    %edi,(%esp)
  800c06:	e8 6f 0f 00 00       	call   801b7a <pageref>
  800c0b:	83 c4 10             	add    $0x10,%esp
  800c0e:	39 c3                	cmp    %eax,%ebx
  800c10:	0f 94 c1             	sete   %cl
  800c13:	0f b6 c9             	movzbl %cl,%ecx
  800c16:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c19:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c22:	39 ce                	cmp    %ecx,%esi
  800c24:	74 1b                	je     800c41 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c26:	39 c3                	cmp    %eax,%ebx
  800c28:	75 c4                	jne    800bee <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c2a:	8b 42 58             	mov    0x58(%edx),%eax
  800c2d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c30:	50                   	push   %eax
  800c31:	56                   	push   %esi
  800c32:	68 62 1f 80 00       	push   $0x801f62
  800c37:	e8 e4 04 00 00       	call   801120 <cprintf>
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	eb ad                	jmp    800bee <_pipeisclosed+0xe>
	}
}
  800c41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 28             	sub    $0x28,%esp
  800c55:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c58:	56                   	push   %esi
  800c59:	e8 09 f7 ff ff       	call   800367 <fd2data>
  800c5e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
  800c68:	eb 4b                	jmp    800cb5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c6a:	89 da                	mov    %ebx,%edx
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	e8 6d ff ff ff       	call   800be0 <_pipeisclosed>
  800c73:	85 c0                	test   %eax,%eax
  800c75:	75 48                	jne    800cbf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c77:	e8 cb f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7f:	8b 0b                	mov    (%ebx),%ecx
  800c81:	8d 51 20             	lea    0x20(%ecx),%edx
  800c84:	39 d0                	cmp    %edx,%eax
  800c86:	73 e2                	jae    800c6a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	c1 fa 1f             	sar    $0x1f,%edx
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9f:	83 e2 1f             	and    $0x1f,%edx
  800ca2:	29 ca                	sub    %ecx,%edx
  800ca4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cac:	83 c0 01             	add    $0x1,%eax
  800caf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb2:	83 c7 01             	add    $0x1,%edi
  800cb5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb8:	75 c2                	jne    800c7c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cba:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbd:	eb 05                	jmp    800cc4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 18             	sub    $0x18,%esp
  800cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd8:	57                   	push   %edi
  800cd9:	e8 89 f6 ff ff       	call   800367 <fd2data>
  800cde:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	eb 3d                	jmp    800d27 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cea:	85 db                	test   %ebx,%ebx
  800cec:	74 04                	je     800cf2 <devpipe_read+0x26>
				return i;
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	eb 44                	jmp    800d36 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf2:	89 f2                	mov    %esi,%edx
  800cf4:	89 f8                	mov    %edi,%eax
  800cf6:	e8 e5 fe ff ff       	call   800be0 <_pipeisclosed>
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 32                	jne    800d31 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cff:	e8 43 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d04:	8b 06                	mov    (%esi),%eax
  800d06:	3b 46 04             	cmp    0x4(%esi),%eax
  800d09:	74 df                	je     800cea <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0b:	99                   	cltd   
  800d0c:	c1 ea 1b             	shr    $0x1b,%edx
  800d0f:	01 d0                	add    %edx,%eax
  800d11:	83 e0 1f             	and    $0x1f,%eax
  800d14:	29 d0                	sub    %edx,%eax
  800d16:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d21:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d24:	83 c3 01             	add    $0x1,%ebx
  800d27:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d2a:	75 d8                	jne    800d04 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2f:	eb 05                	jmp    800d36 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d49:	50                   	push   %eax
  800d4a:	e8 2f f6 ff ff       	call   80037e <fd_alloc>
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	85 c0                	test   %eax,%eax
  800d56:	0f 88 2c 01 00 00    	js     800e88 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	68 07 04 00 00       	push   $0x407
  800d64:	ff 75 f4             	pushl  -0xc(%ebp)
  800d67:	6a 00                	push   $0x0
  800d69:	e8 f8 f3 ff ff       	call   800166 <sys_page_alloc>
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	85 c0                	test   %eax,%eax
  800d75:	0f 88 0d 01 00 00    	js     800e88 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d81:	50                   	push   %eax
  800d82:	e8 f7 f5 ff ff       	call   80037e <fd_alloc>
  800d87:	89 c3                	mov    %eax,%ebx
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	0f 88 e2 00 00 00    	js     800e76 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	68 07 04 00 00       	push   $0x407
  800d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 c0 f3 ff ff       	call   800166 <sys_page_alloc>
  800da6:	89 c3                	mov    %eax,%ebx
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	0f 88 c3 00 00 00    	js     800e76 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	ff 75 f4             	pushl  -0xc(%ebp)
  800db9:	e8 a9 f5 ff ff       	call   800367 <fd2data>
  800dbe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc0:	83 c4 0c             	add    $0xc,%esp
  800dc3:	68 07 04 00 00       	push   $0x407
  800dc8:	50                   	push   %eax
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 96 f3 ff ff       	call   800166 <sys_page_alloc>
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 88 89 00 00 00    	js     800e66 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	ff 75 f0             	pushl  -0x10(%ebp)
  800de3:	e8 7f f5 ff ff       	call   800367 <fd2data>
  800de8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800def:	50                   	push   %eax
  800df0:	6a 00                	push   $0x0
  800df2:	56                   	push   %esi
  800df3:	6a 00                	push   $0x0
  800df5:	e8 af f3 ff ff       	call   8001a9 <sys_page_map>
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	83 c4 20             	add    $0x20,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 55                	js     800e58 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	ff 75 f4             	pushl  -0xc(%ebp)
  800e33:	e8 1f f5 ff ff       	call   800357 <fd2num>
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3d:	83 c4 04             	add    $0x4,%esp
  800e40:	ff 75 f0             	pushl  -0x10(%ebp)
  800e43:	e8 0f f5 ff ff       	call   800357 <fd2num>
  800e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	eb 30                	jmp    800e88 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	56                   	push   %esi
  800e5c:	6a 00                	push   $0x0
  800e5e:	e8 88 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e63:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 78 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e73:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 68 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e88:	89 d0                	mov    %edx,%eax
  800e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9a:	50                   	push   %eax
  800e9b:	ff 75 08             	pushl  0x8(%ebp)
  800e9e:	e8 2a f5 ff ff       	call   8003cd <fd_lookup>
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 18                	js     800ec2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb0:	e8 b2 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eba:	e8 21 fd ff ff       	call   800be0 <_pipeisclosed>
  800ebf:	83 c4 10             	add    $0x10,%esp
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed4:	68 7a 1f 80 00       	push   $0x801f7a
  800ed9:	ff 75 0c             	pushl  0xc(%ebp)
  800edc:	e8 43 08 00 00       	call   801724 <strcpy>
	return 0;
}
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	c9                   	leave  
  800ee7:	c3                   	ret    

00800ee8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eff:	eb 2d                	jmp    800f2e <devcons_write+0x46>
		m = n - tot;
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f04:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f06:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f09:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f0e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	53                   	push   %ebx
  800f15:	03 45 0c             	add    0xc(%ebp),%eax
  800f18:	50                   	push   %eax
  800f19:	57                   	push   %edi
  800f1a:	e8 97 09 00 00       	call   8018b6 <memmove>
		sys_cputs(buf, m);
  800f1f:	83 c4 08             	add    $0x8,%esp
  800f22:	53                   	push   %ebx
  800f23:	57                   	push   %edi
  800f24:	e8 81 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f29:	01 de                	add    %ebx,%esi
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	89 f0                	mov    %esi,%eax
  800f30:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f33:	72 cc                	jb     800f01 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 08             	sub    $0x8,%esp
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4c:	74 2a                	je     800f78 <devcons_read+0x3b>
  800f4e:	eb 05                	jmp    800f55 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f50:	e8 f2 f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f55:	e8 6e f1 ff ff       	call   8000c8 <sys_cgetc>
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	74 f2                	je     800f50 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 16                	js     800f78 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f62:	83 f8 04             	cmp    $0x4,%eax
  800f65:	74 0c                	je     800f73 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6a:	88 02                	mov    %al,(%edx)
	return 1;
  800f6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f71:	eb 05                	jmp    800f78 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f86:	6a 01                	push   $0x1
  800f88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	e8 19 f1 ff ff       	call   8000aa <sys_cputs>
}
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	c9                   	leave  
  800f95:	c3                   	ret    

00800f96 <getchar>:

int
getchar(void)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f9c:	6a 01                	push   $0x1
  800f9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa1:	50                   	push   %eax
  800fa2:	6a 00                	push   $0x0
  800fa4:	e8 8a f6 ff ff       	call   800633 <read>
	if (r < 0)
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 0f                	js     800fbf <getchar+0x29>
		return r;
	if (r < 1)
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	7e 06                	jle    800fba <getchar+0x24>
		return -E_EOF;
	return c;
  800fb4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb8:	eb 05                	jmp    800fbf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	ff 75 08             	pushl  0x8(%ebp)
  800fce:	e8 fa f3 ff ff       	call   8003cd <fd_lookup>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 11                	js     800feb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe3:	39 10                	cmp    %edx,(%eax)
  800fe5:	0f 94 c0             	sete   %al
  800fe8:	0f b6 c0             	movzbl %al,%eax
}
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <opencons>:

int
opencons(void)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff6:	50                   	push   %eax
  800ff7:	e8 82 f3 ff ff       	call   80037e <fd_alloc>
  800ffc:	83 c4 10             	add    $0x10,%esp
		return r;
  800fff:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	78 3e                	js     801043 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	68 07 04 00 00       	push   $0x407
  80100d:	ff 75 f4             	pushl  -0xc(%ebp)
  801010:	6a 00                	push   $0x0
  801012:	e8 4f f1 ff ff       	call   800166 <sys_page_alloc>
  801017:	83 c4 10             	add    $0x10,%esp
		return r;
  80101a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 23                	js     801043 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801026:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801029:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80102b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	50                   	push   %eax
  801039:	e8 19 f3 ff ff       	call   800357 <fd2num>
  80103e:	89 c2                	mov    %eax,%edx
  801040:	83 c4 10             	add    $0x10,%esp
}
  801043:	89 d0                	mov    %edx,%eax
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801055:	e8 ce f0 ff ff       	call   800128 <sys_getenvid>
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	ff 75 0c             	pushl  0xc(%ebp)
  801060:	ff 75 08             	pushl  0x8(%ebp)
  801063:	56                   	push   %esi
  801064:	50                   	push   %eax
  801065:	68 88 1f 80 00       	push   $0x801f88
  80106a:	e8 b1 00 00 00       	call   801120 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106f:	83 c4 18             	add    $0x18,%esp
  801072:	53                   	push   %ebx
  801073:	ff 75 10             	pushl  0x10(%ebp)
  801076:	e8 54 00 00 00       	call   8010cf <vcprintf>
	cprintf("\n");
  80107b:	c7 04 24 73 1f 80 00 	movl   $0x801f73,(%esp)
  801082:	e8 99 00 00 00       	call   801120 <cprintf>
  801087:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108a:	cc                   	int3   
  80108b:	eb fd                	jmp    80108a <_panic+0x43>

0080108d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	53                   	push   %ebx
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801097:	8b 13                	mov    (%ebx),%edx
  801099:	8d 42 01             	lea    0x1(%edx),%eax
  80109c:	89 03                	mov    %eax,(%ebx)
  80109e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010aa:	75 1a                	jne    8010c6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	68 ff 00 00 00       	push   $0xff
  8010b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b7:	50                   	push   %eax
  8010b8:	e8 ed ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010df:	00 00 00 
	b.cnt = 0;
  8010e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ec:	ff 75 0c             	pushl  0xc(%ebp)
  8010ef:	ff 75 08             	pushl  0x8(%ebp)
  8010f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f8:	50                   	push   %eax
  8010f9:	68 8d 10 80 00       	push   $0x80108d
  8010fe:	e8 1a 01 00 00       	call   80121d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801103:	83 c4 08             	add    $0x8,%esp
  801106:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80110c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801112:	50                   	push   %eax
  801113:	e8 92 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801118:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111e:	c9                   	leave  
  80111f:	c3                   	ret    

00801120 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801126:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801129:	50                   	push   %eax
  80112a:	ff 75 08             	pushl  0x8(%ebp)
  80112d:	e8 9d ff ff ff       	call   8010cf <vcprintf>
	va_end(ap);

	return cnt;
}
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 1c             	sub    $0x1c,%esp
  80113d:	89 c7                	mov    %eax,%edi
  80113f:	89 d6                	mov    %edx,%esi
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	8b 55 0c             	mov    0xc(%ebp),%edx
  801147:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80114a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80114d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801150:	bb 00 00 00 00       	mov    $0x0,%ebx
  801155:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801158:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80115b:	39 d3                	cmp    %edx,%ebx
  80115d:	72 05                	jb     801164 <printnum+0x30>
  80115f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801162:	77 45                	ja     8011a9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	ff 75 18             	pushl  0x18(%ebp)
  80116a:	8b 45 14             	mov    0x14(%ebp),%eax
  80116d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801170:	53                   	push   %ebx
  801171:	ff 75 10             	pushl  0x10(%ebp)
  801174:	83 ec 08             	sub    $0x8,%esp
  801177:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117a:	ff 75 e0             	pushl  -0x20(%ebp)
  80117d:	ff 75 dc             	pushl  -0x24(%ebp)
  801180:	ff 75 d8             	pushl  -0x28(%ebp)
  801183:	e8 38 0a 00 00       	call   801bc0 <__udivdi3>
  801188:	83 c4 18             	add    $0x18,%esp
  80118b:	52                   	push   %edx
  80118c:	50                   	push   %eax
  80118d:	89 f2                	mov    %esi,%edx
  80118f:	89 f8                	mov    %edi,%eax
  801191:	e8 9e ff ff ff       	call   801134 <printnum>
  801196:	83 c4 20             	add    $0x20,%esp
  801199:	eb 18                	jmp    8011b3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	56                   	push   %esi
  80119f:	ff 75 18             	pushl  0x18(%ebp)
  8011a2:	ff d7                	call   *%edi
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	eb 03                	jmp    8011ac <printnum+0x78>
  8011a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ac:	83 eb 01             	sub    $0x1,%ebx
  8011af:	85 db                	test   %ebx,%ebx
  8011b1:	7f e8                	jg     80119b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	56                   	push   %esi
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c6:	e8 25 0b 00 00       	call   801cf0 <__umoddi3>
  8011cb:	83 c4 14             	add    $0x14,%esp
  8011ce:	0f be 80 ab 1f 80 00 	movsbl 0x801fab(%eax),%eax
  8011d5:	50                   	push   %eax
  8011d6:	ff d7                	call   *%edi
}
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ed:	8b 10                	mov    (%eax),%edx
  8011ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f2:	73 0a                	jae    8011fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f7:	89 08                	mov    %ecx,(%eax)
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	88 02                	mov    %al,(%edx)
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801206:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801209:	50                   	push   %eax
  80120a:	ff 75 10             	pushl  0x10(%ebp)
  80120d:	ff 75 0c             	pushl  0xc(%ebp)
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 05 00 00 00       	call   80121d <vprintfmt>
	va_end(ap);
}
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	57                   	push   %edi
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 2c             	sub    $0x2c,%esp
  801226:	8b 75 08             	mov    0x8(%ebp),%esi
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80122c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122f:	eb 12                	jmp    801243 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801231:	85 c0                	test   %eax,%eax
  801233:	0f 84 42 04 00 00    	je     80167b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	53                   	push   %ebx
  80123d:	50                   	push   %eax
  80123e:	ff d6                	call   *%esi
  801240:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801243:	83 c7 01             	add    $0x1,%edi
  801246:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80124a:	83 f8 25             	cmp    $0x25,%eax
  80124d:	75 e2                	jne    801231 <vprintfmt+0x14>
  80124f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801253:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80125a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801261:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801268:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126d:	eb 07                	jmp    801276 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801272:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801276:	8d 47 01             	lea    0x1(%edi),%eax
  801279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127c:	0f b6 07             	movzbl (%edi),%eax
  80127f:	0f b6 d0             	movzbl %al,%edx
  801282:	83 e8 23             	sub    $0x23,%eax
  801285:	3c 55                	cmp    $0x55,%al
  801287:	0f 87 d3 03 00 00    	ja     801660 <vprintfmt+0x443>
  80128d:	0f b6 c0             	movzbl %al,%eax
  801290:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80129a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80129e:	eb d6                	jmp    801276 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ae:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012b2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012b5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b8:	83 f9 09             	cmp    $0x9,%ecx
  8012bb:	77 3f                	ja     8012fc <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012c0:	eb e9                	jmp    8012ab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c5:	8b 00                	mov    (%eax),%eax
  8012c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cd:	8d 40 04             	lea    0x4(%eax),%eax
  8012d0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d6:	eb 2a                	jmp    801302 <vprintfmt+0xe5>
  8012d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e2:	0f 49 d0             	cmovns %eax,%edx
  8012e5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012eb:	eb 89                	jmp    801276 <vprintfmt+0x59>
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f7:	e9 7a ff ff ff       	jmp    801276 <vprintfmt+0x59>
  8012fc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ff:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801302:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801306:	0f 89 6a ff ff ff    	jns    801276 <vprintfmt+0x59>
				width = precision, precision = -1;
  80130c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801312:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801319:	e9 58 ff ff ff       	jmp    801276 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80131e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801324:	e9 4d ff ff ff       	jmp    801276 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801329:	8b 45 14             	mov    0x14(%ebp),%eax
  80132c:	8d 78 04             	lea    0x4(%eax),%edi
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	53                   	push   %ebx
  801333:	ff 30                	pushl  (%eax)
  801335:	ff d6                	call   *%esi
			break;
  801337:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80133a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801340:	e9 fe fe ff ff       	jmp    801243 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801345:	8b 45 14             	mov    0x14(%ebp),%eax
  801348:	8d 78 04             	lea    0x4(%eax),%edi
  80134b:	8b 00                	mov    (%eax),%eax
  80134d:	99                   	cltd   
  80134e:	31 d0                	xor    %edx,%eax
  801350:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801352:	83 f8 0f             	cmp    $0xf,%eax
  801355:	7f 0b                	jg     801362 <vprintfmt+0x145>
  801357:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80135e:	85 d2                	test   %edx,%edx
  801360:	75 1b                	jne    80137d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801362:	50                   	push   %eax
  801363:	68 c3 1f 80 00       	push   $0x801fc3
  801368:	53                   	push   %ebx
  801369:	56                   	push   %esi
  80136a:	e8 91 fe ff ff       	call   801200 <printfmt>
  80136f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801372:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801378:	e9 c6 fe ff ff       	jmp    801243 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80137d:	52                   	push   %edx
  80137e:	68 41 1f 80 00       	push   $0x801f41
  801383:	53                   	push   %ebx
  801384:	56                   	push   %esi
  801385:	e8 76 fe ff ff       	call   801200 <printfmt>
  80138a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801393:	e9 ab fe ff ff       	jmp    801243 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801398:	8b 45 14             	mov    0x14(%ebp),%eax
  80139b:	83 c0 04             	add    $0x4,%eax
  80139e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a6:	85 ff                	test   %edi,%edi
  8013a8:	b8 bc 1f 80 00       	mov    $0x801fbc,%eax
  8013ad:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b4:	0f 8e 94 00 00 00    	jle    80144e <vprintfmt+0x231>
  8013ba:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013be:	0f 84 98 00 00 00    	je     80145c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ca:	57                   	push   %edi
  8013cb:	e8 33 03 00 00       	call   801703 <strnlen>
  8013d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013d3:	29 c1                	sub    %eax,%ecx
  8013d5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013db:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e7:	eb 0f                	jmp    8013f8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8013f0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f2:	83 ef 01             	sub    $0x1,%edi
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 ff                	test   %edi,%edi
  8013fa:	7f ed                	jg     8013e9 <vprintfmt+0x1cc>
  8013fc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ff:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801402:	85 c9                	test   %ecx,%ecx
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	0f 49 c1             	cmovns %ecx,%eax
  80140c:	29 c1                	sub    %eax,%ecx
  80140e:	89 75 08             	mov    %esi,0x8(%ebp)
  801411:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801414:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801417:	89 cb                	mov    %ecx,%ebx
  801419:	eb 4d                	jmp    801468 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80141b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141f:	74 1b                	je     80143c <vprintfmt+0x21f>
  801421:	0f be c0             	movsbl %al,%eax
  801424:	83 e8 20             	sub    $0x20,%eax
  801427:	83 f8 5e             	cmp    $0x5e,%eax
  80142a:	76 10                	jbe    80143c <vprintfmt+0x21f>
					putch('?', putdat);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	6a 3f                	push   $0x3f
  801434:	ff 55 08             	call   *0x8(%ebp)
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	eb 0d                	jmp    801449 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	ff 75 0c             	pushl  0xc(%ebp)
  801442:	52                   	push   %edx
  801443:	ff 55 08             	call   *0x8(%ebp)
  801446:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801449:	83 eb 01             	sub    $0x1,%ebx
  80144c:	eb 1a                	jmp    801468 <vprintfmt+0x24b>
  80144e:	89 75 08             	mov    %esi,0x8(%ebp)
  801451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801457:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145a:	eb 0c                	jmp    801468 <vprintfmt+0x24b>
  80145c:	89 75 08             	mov    %esi,0x8(%ebp)
  80145f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801462:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801465:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801468:	83 c7 01             	add    $0x1,%edi
  80146b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146f:	0f be d0             	movsbl %al,%edx
  801472:	85 d2                	test   %edx,%edx
  801474:	74 23                	je     801499 <vprintfmt+0x27c>
  801476:	85 f6                	test   %esi,%esi
  801478:	78 a1                	js     80141b <vprintfmt+0x1fe>
  80147a:	83 ee 01             	sub    $0x1,%esi
  80147d:	79 9c                	jns    80141b <vprintfmt+0x1fe>
  80147f:	89 df                	mov    %ebx,%edi
  801481:	8b 75 08             	mov    0x8(%ebp),%esi
  801484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801487:	eb 18                	jmp    8014a1 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	6a 20                	push   $0x20
  80148f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801491:	83 ef 01             	sub    $0x1,%edi
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	eb 08                	jmp    8014a1 <vprintfmt+0x284>
  801499:	89 df                	mov    %ebx,%edi
  80149b:	8b 75 08             	mov    0x8(%ebp),%esi
  80149e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a1:	85 ff                	test   %edi,%edi
  8014a3:	7f e4                	jg     801489 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014a8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ae:	e9 90 fd ff ff       	jmp    801243 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b3:	83 f9 01             	cmp    $0x1,%ecx
  8014b6:	7e 19                	jle    8014d1 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bb:	8b 50 04             	mov    0x4(%eax),%edx
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c9:	8d 40 08             	lea    0x8(%eax),%eax
  8014cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cf:	eb 38                	jmp    801509 <vprintfmt+0x2ec>
	else if (lflag)
  8014d1:	85 c9                	test   %ecx,%ecx
  8014d3:	74 1b                	je     8014f0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d8:	8b 00                	mov    (%eax),%eax
  8014da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e8:	8d 40 04             	lea    0x4(%eax),%eax
  8014eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ee:	eb 19                	jmp    801509 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8b 00                	mov    (%eax),%eax
  8014f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f8:	89 c1                	mov    %eax,%ecx
  8014fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 40 04             	lea    0x4(%eax),%eax
  801506:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801509:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801514:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801518:	0f 89 0e 01 00 00    	jns    80162c <vprintfmt+0x40f>
				putch('-', putdat);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	53                   	push   %ebx
  801522:	6a 2d                	push   $0x2d
  801524:	ff d6                	call   *%esi
				num = -(long long) num;
  801526:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801529:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80152c:	f7 da                	neg    %edx
  80152e:	83 d1 00             	adc    $0x0,%ecx
  801531:	f7 d9                	neg    %ecx
  801533:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801536:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153b:	e9 ec 00 00 00       	jmp    80162c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801540:	83 f9 01             	cmp    $0x1,%ecx
  801543:	7e 18                	jle    80155d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801545:	8b 45 14             	mov    0x14(%ebp),%eax
  801548:	8b 10                	mov    (%eax),%edx
  80154a:	8b 48 04             	mov    0x4(%eax),%ecx
  80154d:	8d 40 08             	lea    0x8(%eax),%eax
  801550:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801553:	b8 0a 00 00 00       	mov    $0xa,%eax
  801558:	e9 cf 00 00 00       	jmp    80162c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80155d:	85 c9                	test   %ecx,%ecx
  80155f:	74 1a                	je     80157b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801561:	8b 45 14             	mov    0x14(%ebp),%eax
  801564:	8b 10                	mov    (%eax),%edx
  801566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156b:	8d 40 04             	lea    0x4(%eax),%eax
  80156e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801571:	b8 0a 00 00 00       	mov    $0xa,%eax
  801576:	e9 b1 00 00 00       	jmp    80162c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80157b:	8b 45 14             	mov    0x14(%ebp),%eax
  80157e:	8b 10                	mov    (%eax),%edx
  801580:	b9 00 00 00 00       	mov    $0x0,%ecx
  801585:	8d 40 04             	lea    0x4(%eax),%eax
  801588:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80158b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801590:	e9 97 00 00 00       	jmp    80162c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 58                	push   $0x58
  80159b:	ff d6                	call   *%esi
			putch('X', putdat);
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	6a 58                	push   $0x58
  8015a3:	ff d6                	call   *%esi
			putch('X', putdat);
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	6a 58                	push   $0x58
  8015ab:	ff d6                	call   *%esi
			break;
  8015ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015b3:	e9 8b fc ff ff       	jmp    801243 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	6a 30                	push   $0x30
  8015be:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	6a 78                	push   $0x78
  8015c6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cb:	8b 10                	mov    (%eax),%edx
  8015cd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015d5:	8d 40 04             	lea    0x4(%eax),%eax
  8015d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015db:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015e0:	eb 4a                	jmp    80162c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015e2:	83 f9 01             	cmp    $0x1,%ecx
  8015e5:	7e 15                	jle    8015fc <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ea:	8b 10                	mov    (%eax),%edx
  8015ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ef:	8d 40 08             	lea    0x8(%eax),%eax
  8015f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f5:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fa:	eb 30                	jmp    80162c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015fc:	85 c9                	test   %ecx,%ecx
  8015fe:	74 17                	je     801617 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801600:	8b 45 14             	mov    0x14(%ebp),%eax
  801603:	8b 10                	mov    (%eax),%edx
  801605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160a:	8d 40 04             	lea    0x4(%eax),%eax
  80160d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801610:	b8 10 00 00 00       	mov    $0x10,%eax
  801615:	eb 15                	jmp    80162c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801617:	8b 45 14             	mov    0x14(%ebp),%eax
  80161a:	8b 10                	mov    (%eax),%edx
  80161c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801621:	8d 40 04             	lea    0x4(%eax),%eax
  801624:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801627:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80162c:	83 ec 0c             	sub    $0xc,%esp
  80162f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801633:	57                   	push   %edi
  801634:	ff 75 e0             	pushl  -0x20(%ebp)
  801637:	50                   	push   %eax
  801638:	51                   	push   %ecx
  801639:	52                   	push   %edx
  80163a:	89 da                	mov    %ebx,%edx
  80163c:	89 f0                	mov    %esi,%eax
  80163e:	e8 f1 fa ff ff       	call   801134 <printnum>
			break;
  801643:	83 c4 20             	add    $0x20,%esp
  801646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801649:	e9 f5 fb ff ff       	jmp    801243 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	53                   	push   %ebx
  801652:	52                   	push   %edx
  801653:	ff d6                	call   *%esi
			break;
  801655:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80165b:	e9 e3 fb ff ff       	jmp    801243 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	53                   	push   %ebx
  801664:	6a 25                	push   $0x25
  801666:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	eb 03                	jmp    801670 <vprintfmt+0x453>
  80166d:	83 ef 01             	sub    $0x1,%edi
  801670:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801674:	75 f7                	jne    80166d <vprintfmt+0x450>
  801676:	e9 c8 fb ff ff       	jmp    801243 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80167b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5f                   	pop    %edi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 18             	sub    $0x18,%esp
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80168f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801692:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801696:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801699:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	74 26                	je     8016ca <vsnprintf+0x47>
  8016a4:	85 d2                	test   %edx,%edx
  8016a6:	7e 22                	jle    8016ca <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a8:	ff 75 14             	pushl  0x14(%ebp)
  8016ab:	ff 75 10             	pushl  0x10(%ebp)
  8016ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	68 e3 11 80 00       	push   $0x8011e3
  8016b7:	e8 61 fb ff ff       	call   80121d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	eb 05                	jmp    8016cf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016da:	50                   	push   %eax
  8016db:	ff 75 10             	pushl  0x10(%ebp)
  8016de:	ff 75 0c             	pushl  0xc(%ebp)
  8016e1:	ff 75 08             	pushl  0x8(%ebp)
  8016e4:	e8 9a ff ff ff       	call   801683 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f6:	eb 03                	jmp    8016fb <strlen+0x10>
		n++;
  8016f8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016fb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ff:	75 f7                	jne    8016f8 <strlen+0xd>
		n++;
	return n;
}
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801709:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170c:	ba 00 00 00 00       	mov    $0x0,%edx
  801711:	eb 03                	jmp    801716 <strnlen+0x13>
		n++;
  801713:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801716:	39 c2                	cmp    %eax,%edx
  801718:	74 08                	je     801722 <strnlen+0x1f>
  80171a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80171e:	75 f3                	jne    801713 <strnlen+0x10>
  801720:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80172e:	89 c2                	mov    %eax,%edx
  801730:	83 c2 01             	add    $0x1,%edx
  801733:	83 c1 01             	add    $0x1,%ecx
  801736:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80173a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80173d:	84 db                	test   %bl,%bl
  80173f:	75 ef                	jne    801730 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801741:	5b                   	pop    %ebx
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80174b:	53                   	push   %ebx
  80174c:	e8 9a ff ff ff       	call   8016eb <strlen>
  801751:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	01 d8                	add    %ebx,%eax
  801759:	50                   	push   %eax
  80175a:	e8 c5 ff ff ff       	call   801724 <strcpy>
	return dst;
}
  80175f:	89 d8                	mov    %ebx,%eax
  801761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	8b 75 08             	mov    0x8(%ebp),%esi
  80176e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801771:	89 f3                	mov    %esi,%ebx
  801773:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801776:	89 f2                	mov    %esi,%edx
  801778:	eb 0f                	jmp    801789 <strncpy+0x23>
		*dst++ = *src;
  80177a:	83 c2 01             	add    $0x1,%edx
  80177d:	0f b6 01             	movzbl (%ecx),%eax
  801780:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801783:	80 39 01             	cmpb   $0x1,(%ecx)
  801786:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801789:	39 da                	cmp    %ebx,%edx
  80178b:	75 ed                	jne    80177a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80178d:	89 f0                	mov    %esi,%eax
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
  801798:	8b 75 08             	mov    0x8(%ebp),%esi
  80179b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179e:	8b 55 10             	mov    0x10(%ebp),%edx
  8017a1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017a3:	85 d2                	test   %edx,%edx
  8017a5:	74 21                	je     8017c8 <strlcpy+0x35>
  8017a7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017ab:	89 f2                	mov    %esi,%edx
  8017ad:	eb 09                	jmp    8017b8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017af:	83 c2 01             	add    $0x1,%edx
  8017b2:	83 c1 01             	add    $0x1,%ecx
  8017b5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017b8:	39 c2                	cmp    %eax,%edx
  8017ba:	74 09                	je     8017c5 <strlcpy+0x32>
  8017bc:	0f b6 19             	movzbl (%ecx),%ebx
  8017bf:	84 db                	test   %bl,%bl
  8017c1:	75 ec                	jne    8017af <strlcpy+0x1c>
  8017c3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017c5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c8:	29 f0                	sub    %esi,%eax
}
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d7:	eb 06                	jmp    8017df <strcmp+0x11>
		p++, q++;
  8017d9:	83 c1 01             	add    $0x1,%ecx
  8017dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017df:	0f b6 01             	movzbl (%ecx),%eax
  8017e2:	84 c0                	test   %al,%al
  8017e4:	74 04                	je     8017ea <strcmp+0x1c>
  8017e6:	3a 02                	cmp    (%edx),%al
  8017e8:	74 ef                	je     8017d9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ea:	0f b6 c0             	movzbl %al,%eax
  8017ed:	0f b6 12             	movzbl (%edx),%edx
  8017f0:	29 d0                	sub    %edx,%eax
}
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801803:	eb 06                	jmp    80180b <strncmp+0x17>
		n--, p++, q++;
  801805:	83 c0 01             	add    $0x1,%eax
  801808:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80180b:	39 d8                	cmp    %ebx,%eax
  80180d:	74 15                	je     801824 <strncmp+0x30>
  80180f:	0f b6 08             	movzbl (%eax),%ecx
  801812:	84 c9                	test   %cl,%cl
  801814:	74 04                	je     80181a <strncmp+0x26>
  801816:	3a 0a                	cmp    (%edx),%cl
  801818:	74 eb                	je     801805 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80181a:	0f b6 00             	movzbl (%eax),%eax
  80181d:	0f b6 12             	movzbl (%edx),%edx
  801820:	29 d0                	sub    %edx,%eax
  801822:	eb 05                	jmp    801829 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801829:	5b                   	pop    %ebx
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801836:	eb 07                	jmp    80183f <strchr+0x13>
		if (*s == c)
  801838:	38 ca                	cmp    %cl,%dl
  80183a:	74 0f                	je     80184b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80183c:	83 c0 01             	add    $0x1,%eax
  80183f:	0f b6 10             	movzbl (%eax),%edx
  801842:	84 d2                	test   %dl,%dl
  801844:	75 f2                	jne    801838 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801846:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	8b 45 08             	mov    0x8(%ebp),%eax
  801853:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801857:	eb 03                	jmp    80185c <strfind+0xf>
  801859:	83 c0 01             	add    $0x1,%eax
  80185c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80185f:	38 ca                	cmp    %cl,%dl
  801861:	74 04                	je     801867 <strfind+0x1a>
  801863:	84 d2                	test   %dl,%dl
  801865:	75 f2                	jne    801859 <strfind+0xc>
			break;
	return (char *) s;
}
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801875:	85 c9                	test   %ecx,%ecx
  801877:	74 36                	je     8018af <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801879:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187f:	75 28                	jne    8018a9 <memset+0x40>
  801881:	f6 c1 03             	test   $0x3,%cl
  801884:	75 23                	jne    8018a9 <memset+0x40>
		c &= 0xFF;
  801886:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80188a:	89 d3                	mov    %edx,%ebx
  80188c:	c1 e3 08             	shl    $0x8,%ebx
  80188f:	89 d6                	mov    %edx,%esi
  801891:	c1 e6 18             	shl    $0x18,%esi
  801894:	89 d0                	mov    %edx,%eax
  801896:	c1 e0 10             	shl    $0x10,%eax
  801899:	09 f0                	or     %esi,%eax
  80189b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80189d:	89 d8                	mov    %ebx,%eax
  80189f:	09 d0                	or     %edx,%eax
  8018a1:	c1 e9 02             	shr    $0x2,%ecx
  8018a4:	fc                   	cld    
  8018a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a7:	eb 06                	jmp    8018af <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ac:	fc                   	cld    
  8018ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018af:	89 f8                	mov    %edi,%eax
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	57                   	push   %edi
  8018ba:	56                   	push   %esi
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c4:	39 c6                	cmp    %eax,%esi
  8018c6:	73 35                	jae    8018fd <memmove+0x47>
  8018c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018cb:	39 d0                	cmp    %edx,%eax
  8018cd:	73 2e                	jae    8018fd <memmove+0x47>
		s += n;
		d += n;
  8018cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d2:	89 d6                	mov    %edx,%esi
  8018d4:	09 fe                	or     %edi,%esi
  8018d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018dc:	75 13                	jne    8018f1 <memmove+0x3b>
  8018de:	f6 c1 03             	test   $0x3,%cl
  8018e1:	75 0e                	jne    8018f1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018e3:	83 ef 04             	sub    $0x4,%edi
  8018e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e9:	c1 e9 02             	shr    $0x2,%ecx
  8018ec:	fd                   	std    
  8018ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ef:	eb 09                	jmp    8018fa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018f1:	83 ef 01             	sub    $0x1,%edi
  8018f4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018f7:	fd                   	std    
  8018f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018fa:	fc                   	cld    
  8018fb:	eb 1d                	jmp    80191a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fd:	89 f2                	mov    %esi,%edx
  8018ff:	09 c2                	or     %eax,%edx
  801901:	f6 c2 03             	test   $0x3,%dl
  801904:	75 0f                	jne    801915 <memmove+0x5f>
  801906:	f6 c1 03             	test   $0x3,%cl
  801909:	75 0a                	jne    801915 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80190b:	c1 e9 02             	shr    $0x2,%ecx
  80190e:	89 c7                	mov    %eax,%edi
  801910:	fc                   	cld    
  801911:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801913:	eb 05                	jmp    80191a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801915:	89 c7                	mov    %eax,%edi
  801917:	fc                   	cld    
  801918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801921:	ff 75 10             	pushl  0x10(%ebp)
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	ff 75 08             	pushl  0x8(%ebp)
  80192a:	e8 87 ff ff ff       	call   8018b6 <memmove>
}
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	56                   	push   %esi
  801935:	53                   	push   %ebx
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193c:	89 c6                	mov    %eax,%esi
  80193e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801941:	eb 1a                	jmp    80195d <memcmp+0x2c>
		if (*s1 != *s2)
  801943:	0f b6 08             	movzbl (%eax),%ecx
  801946:	0f b6 1a             	movzbl (%edx),%ebx
  801949:	38 d9                	cmp    %bl,%cl
  80194b:	74 0a                	je     801957 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80194d:	0f b6 c1             	movzbl %cl,%eax
  801950:	0f b6 db             	movzbl %bl,%ebx
  801953:	29 d8                	sub    %ebx,%eax
  801955:	eb 0f                	jmp    801966 <memcmp+0x35>
		s1++, s2++;
  801957:	83 c0 01             	add    $0x1,%eax
  80195a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80195d:	39 f0                	cmp    %esi,%eax
  80195f:	75 e2                	jne    801943 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	53                   	push   %ebx
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801971:	89 c1                	mov    %eax,%ecx
  801973:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801976:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197a:	eb 0a                	jmp    801986 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197c:	0f b6 10             	movzbl (%eax),%edx
  80197f:	39 da                	cmp    %ebx,%edx
  801981:	74 07                	je     80198a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801983:	83 c0 01             	add    $0x1,%eax
  801986:	39 c8                	cmp    %ecx,%eax
  801988:	72 f2                	jb     80197c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80198a:	5b                   	pop    %ebx
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801996:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801999:	eb 03                	jmp    80199e <strtol+0x11>
		s++;
  80199b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80199e:	0f b6 01             	movzbl (%ecx),%eax
  8019a1:	3c 20                	cmp    $0x20,%al
  8019a3:	74 f6                	je     80199b <strtol+0xe>
  8019a5:	3c 09                	cmp    $0x9,%al
  8019a7:	74 f2                	je     80199b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a9:	3c 2b                	cmp    $0x2b,%al
  8019ab:	75 0a                	jne    8019b7 <strtol+0x2a>
		s++;
  8019ad:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b5:	eb 11                	jmp    8019c8 <strtol+0x3b>
  8019b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019bc:	3c 2d                	cmp    $0x2d,%al
  8019be:	75 08                	jne    8019c8 <strtol+0x3b>
		s++, neg = 1;
  8019c0:	83 c1 01             	add    $0x1,%ecx
  8019c3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019ce:	75 15                	jne    8019e5 <strtol+0x58>
  8019d0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d3:	75 10                	jne    8019e5 <strtol+0x58>
  8019d5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d9:	75 7c                	jne    801a57 <strtol+0xca>
		s += 2, base = 16;
  8019db:	83 c1 02             	add    $0x2,%ecx
  8019de:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e3:	eb 16                	jmp    8019fb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019e5:	85 db                	test   %ebx,%ebx
  8019e7:	75 12                	jne    8019fb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ee:	80 39 30             	cmpb   $0x30,(%ecx)
  8019f1:	75 08                	jne    8019fb <strtol+0x6e>
		s++, base = 8;
  8019f3:	83 c1 01             	add    $0x1,%ecx
  8019f6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801a00:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a03:	0f b6 11             	movzbl (%ecx),%edx
  801a06:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a09:	89 f3                	mov    %esi,%ebx
  801a0b:	80 fb 09             	cmp    $0x9,%bl
  801a0e:	77 08                	ja     801a18 <strtol+0x8b>
			dig = *s - '0';
  801a10:	0f be d2             	movsbl %dl,%edx
  801a13:	83 ea 30             	sub    $0x30,%edx
  801a16:	eb 22                	jmp    801a3a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a18:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a1b:	89 f3                	mov    %esi,%ebx
  801a1d:	80 fb 19             	cmp    $0x19,%bl
  801a20:	77 08                	ja     801a2a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a22:	0f be d2             	movsbl %dl,%edx
  801a25:	83 ea 57             	sub    $0x57,%edx
  801a28:	eb 10                	jmp    801a3a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a2a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a2d:	89 f3                	mov    %esi,%ebx
  801a2f:	80 fb 19             	cmp    $0x19,%bl
  801a32:	77 16                	ja     801a4a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a34:	0f be d2             	movsbl %dl,%edx
  801a37:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a3a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a3d:	7d 0b                	jge    801a4a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a3f:	83 c1 01             	add    $0x1,%ecx
  801a42:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a46:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a48:	eb b9                	jmp    801a03 <strtol+0x76>

	if (endptr)
  801a4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a4e:	74 0d                	je     801a5d <strtol+0xd0>
		*endptr = (char *) s;
  801a50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a53:	89 0e                	mov    %ecx,(%esi)
  801a55:	eb 06                	jmp    801a5d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a57:	85 db                	test   %ebx,%ebx
  801a59:	74 98                	je     8019f3 <strtol+0x66>
  801a5b:	eb 9e                	jmp    8019fb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a5d:	89 c2                	mov    %eax,%edx
  801a5f:	f7 da                	neg    %edx
  801a61:	85 ff                	test   %edi,%edi
  801a63:	0f 45 c2             	cmovne %edx,%eax
}
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	8b 75 08             	mov    0x8(%ebp),%esi
  801a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a7d:	85 f6                	test   %esi,%esi
  801a7f:	74 06                	je     801a87 <ipc_recv+0x1c>
		*from_env_store = 0;
  801a81:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a87:	85 db                	test   %ebx,%ebx
  801a89:	74 06                	je     801a91 <ipc_recv+0x26>
		*perm_store = 0;
  801a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a91:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a93:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a98:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	50                   	push   %eax
  801a9f:	e8 72 e8 ff ff       	call   800316 <sys_ipc_recv>
  801aa4:	89 c7                	mov    %eax,%edi
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	79 14                	jns    801ac1 <ipc_recv+0x56>
		cprintf("im dead");
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	68 a0 22 80 00       	push   $0x8022a0
  801ab5:	e8 66 f6 ff ff       	call   801120 <cprintf>
		return r;
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	89 f8                	mov    %edi,%eax
  801abf:	eb 24                	jmp    801ae5 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ac1:	85 f6                	test   %esi,%esi
  801ac3:	74 0a                	je     801acf <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ac5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aca:	8b 40 74             	mov    0x74(%eax),%eax
  801acd:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	74 0a                	je     801add <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 40 78             	mov    0x78(%eax),%eax
  801adb:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801add:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5f                   	pop    %edi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	57                   	push   %edi
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801aff:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b06:	0f 44 d8             	cmove  %eax,%ebx
  801b09:	eb 1c                	jmp    801b27 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b0b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0e:	74 12                	je     801b22 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b10:	50                   	push   %eax
  801b11:	68 a8 22 80 00       	push   $0x8022a8
  801b16:	6a 4e                	push   $0x4e
  801b18:	68 b5 22 80 00       	push   $0x8022b5
  801b1d:	e8 25 f5 ff ff       	call   801047 <_panic>
		sys_yield();
  801b22:	e8 20 e6 ff ff       	call   800147 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b27:	ff 75 14             	pushl  0x14(%ebp)
  801b2a:	53                   	push   %ebx
  801b2b:	56                   	push   %esi
  801b2c:	57                   	push   %edi
  801b2d:	e8 c1 e7 ff ff       	call   8002f3 <sys_ipc_try_send>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 d2                	js     801b0b <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b55:	8b 52 50             	mov    0x50(%edx),%edx
  801b58:	39 ca                	cmp    %ecx,%edx
  801b5a:	75 0d                	jne    801b69 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b5c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b64:	8b 40 48             	mov    0x48(%eax),%eax
  801b67:	eb 0f                	jmp    801b78 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b69:	83 c0 01             	add    $0x1,%eax
  801b6c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b71:	75 d9                	jne    801b4c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b80:	89 d0                	mov    %edx,%eax
  801b82:	c1 e8 16             	shr    $0x16,%eax
  801b85:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b91:	f6 c1 01             	test   $0x1,%cl
  801b94:	74 1d                	je     801bb3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b96:	c1 ea 0c             	shr    $0xc,%edx
  801b99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba0:	f6 c2 01             	test   $0x1,%dl
  801ba3:	74 0e                	je     801bb3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba5:	c1 ea 0c             	shr    $0xc,%edx
  801ba8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801baf:	ef 
  801bb0:	0f b7 c0             	movzwl %ax,%eax
}
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    
  801bb5:	66 90                	xchg   %ax,%ax
  801bb7:	66 90                	xchg   %ax,%ax
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
