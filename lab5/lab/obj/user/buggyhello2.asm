
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 78 1e 80 00       	push   $0x801e78
  800118:	6a 23                	push   $0x23
  80011a:	68 95 1e 80 00       	push   $0x801e95
  80011f:	e8 27 0f 00 00       	call   80104b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 78 1e 80 00       	push   $0x801e78
  800199:	6a 23                	push   $0x23
  80019b:	68 95 1e 80 00       	push   $0x801e95
  8001a0:	e8 a6 0e 00 00       	call   80104b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 78 1e 80 00       	push   $0x801e78
  8001db:	6a 23                	push   $0x23
  8001dd:	68 95 1e 80 00       	push   $0x801e95
  8001e2:	e8 64 0e 00 00       	call   80104b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 78 1e 80 00       	push   $0x801e78
  80021d:	6a 23                	push   $0x23
  80021f:	68 95 1e 80 00       	push   $0x801e95
  800224:	e8 22 0e 00 00       	call   80104b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 78 1e 80 00       	push   $0x801e78
  80025f:	6a 23                	push   $0x23
  800261:	68 95 1e 80 00       	push   $0x801e95
  800266:	e8 e0 0d 00 00       	call   80104b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 78 1e 80 00       	push   $0x801e78
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 95 1e 80 00       	push   $0x801e95
  8002a8:	e8 9e 0d 00 00       	call   80104b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 78 1e 80 00       	push   $0x801e78
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 95 1e 80 00       	push   $0x801e95
  8002ea:	e8 5c 0d 00 00       	call   80104b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 78 1e 80 00       	push   $0x801e78
  800347:	6a 23                	push   $0x23
  800349:	68 95 1e 80 00       	push   $0x801e95
  80034e:	e8 f8 0c 00 00       	call   80104b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba 20 1f 80 00       	mov    $0x801f20,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 a4 1e 80 00       	push   $0x801ea4
  800462:	e8 bd 0c 00 00       	call   801124 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 e5 1e 80 00       	push   $0x801ee5
  80068c:	e8 93 0a 00 00       	call   801124 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 01 1f 80 00       	push   $0x801f01
  800761:	e8 be 09 00 00       	call   801124 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 c4 1e 80 00       	push   $0x801ec4
  800816:	e8 09 09 00 00       	call   801124 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 e9 01 00 00       	call   800ac8 <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 1f 12 00 00       	call   801b45 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 b0 11 00 00       	call   801af1 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 21 11 00 00       	call   801a6f <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 51 0d 00 00       	call   801728 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
  800a03:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a08:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a0d:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a10:	8b 55 08             	mov    0x8(%ebp),%edx
  800a13:	8b 52 0c             	mov    0xc(%edx),%edx
  800a16:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a1c:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a21:	50                   	push   %eax
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	68 08 50 80 00       	push   $0x805008
  800a2a:	e8 8b 0e 00 00       	call   8018ba <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 04 00 00 00       	mov    $0x4,%eax
  800a39:	e8 cc fe ff ff       	call   80090a <fsipc>
            return r;

    return r;
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a63:	e8 a2 fe ff ff       	call   80090a <fsipc>
  800a68:	89 c3                	mov    %eax,%ebx
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	78 51                	js     800abf <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a6e:	39 c6                	cmp    %eax,%esi
  800a70:	73 19                	jae    800a8b <devfile_read+0x4b>
  800a72:	68 30 1f 80 00       	push   $0x801f30
  800a77:	68 37 1f 80 00       	push   $0x801f37
  800a7c:	68 82 00 00 00       	push   $0x82
  800a81:	68 4c 1f 80 00       	push   $0x801f4c
  800a86:	e8 c0 05 00 00       	call   80104b <_panic>
	assert(r <= PGSIZE);
  800a8b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a90:	7e 19                	jle    800aab <devfile_read+0x6b>
  800a92:	68 57 1f 80 00       	push   $0x801f57
  800a97:	68 37 1f 80 00       	push   $0x801f37
  800a9c:	68 83 00 00 00       	push   $0x83
  800aa1:	68 4c 1f 80 00       	push   $0x801f4c
  800aa6:	e8 a0 05 00 00       	call   80104b <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aab:	83 ec 04             	sub    $0x4,%esp
  800aae:	50                   	push   %eax
  800aaf:	68 00 50 80 00       	push   $0x805000
  800ab4:	ff 75 0c             	pushl  0xc(%ebp)
  800ab7:	e8 fe 0d 00 00       	call   8018ba <memmove>
	return r;
  800abc:	83 c4 10             	add    $0x10,%esp
}
  800abf:	89 d8                	mov    %ebx,%eax
  800ac1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	53                   	push   %ebx
  800acc:	83 ec 20             	sub    $0x20,%esp
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ad2:	53                   	push   %ebx
  800ad3:	e8 17 0c 00 00       	call   8016ef <strlen>
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae0:	7f 67                	jg     800b49 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae8:	50                   	push   %eax
  800ae9:	e8 94 f8 ff ff       	call   800382 <fd_alloc>
  800aee:	83 c4 10             	add    $0x10,%esp
		return r;
  800af1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	78 57                	js     800b4e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af7:	83 ec 08             	sub    $0x8,%esp
  800afa:	53                   	push   %ebx
  800afb:	68 00 50 80 00       	push   $0x805000
  800b00:	e8 23 0c 00 00       	call   801728 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b10:	b8 01 00 00 00       	mov    $0x1,%eax
  800b15:	e8 f0 fd ff ff       	call   80090a <fsipc>
  800b1a:	89 c3                	mov    %eax,%ebx
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	79 14                	jns    800b37 <open+0x6f>
		fd_close(fd, 0);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	6a 00                	push   $0x0
  800b28:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2b:	e8 4a f9 ff ff       	call   80047a <fd_close>
		return r;
  800b30:	83 c4 10             	add    $0x10,%esp
  800b33:	89 da                	mov    %ebx,%edx
  800b35:	eb 17                	jmp    800b4e <open+0x86>
	}

	return fd2num(fd);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3d:	e8 19 f8 ff ff       	call   80035b <fd2num>
  800b42:	89 c2                	mov    %eax,%edx
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	eb 05                	jmp    800b4e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b49:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b4e:	89 d0                	mov    %edx,%eax
  800b50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 08 00 00 00       	mov    $0x8,%eax
  800b65:	e8 a0 fd ff ff       	call   80090a <fsipc>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	ff 75 08             	pushl  0x8(%ebp)
  800b7a:	e8 ec f7 ff ff       	call   80036b <fd2data>
  800b7f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b81:	83 c4 08             	add    $0x8,%esp
  800b84:	68 63 1f 80 00       	push   $0x801f63
  800b89:	53                   	push   %ebx
  800b8a:	e8 99 0b 00 00       	call   801728 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b8f:	8b 46 04             	mov    0x4(%esi),%eax
  800b92:	2b 06                	sub    (%esi),%eax
  800b94:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b9a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba1:	00 00 00 
	stat->st_dev = &devpipe;
  800ba4:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bab:	30 80 00 
	return 0;
}
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc4:	53                   	push   %ebx
  800bc5:	6a 00                	push   $0x0
  800bc7:	e8 23 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bcc:	89 1c 24             	mov    %ebx,(%esp)
  800bcf:	e8 97 f7 ff ff       	call   80036b <fd2data>
  800bd4:	83 c4 08             	add    $0x8,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 00                	push   $0x0
  800bda:	e8 10 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 1c             	sub    $0x1c,%esp
  800bed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bf0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bf2:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	ff 75 e0             	pushl  -0x20(%ebp)
  800c00:	e8 79 0f 00 00       	call   801b7e <pageref>
  800c05:	89 c3                	mov    %eax,%ebx
  800c07:	89 3c 24             	mov    %edi,(%esp)
  800c0a:	e8 6f 0f 00 00       	call   801b7e <pageref>
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	39 c3                	cmp    %eax,%ebx
  800c14:	0f 94 c1             	sete   %cl
  800c17:	0f b6 c9             	movzbl %cl,%ecx
  800c1a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c1d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c23:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c26:	39 ce                	cmp    %ecx,%esi
  800c28:	74 1b                	je     800c45 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c2a:	39 c3                	cmp    %eax,%ebx
  800c2c:	75 c4                	jne    800bf2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c2e:	8b 42 58             	mov    0x58(%edx),%eax
  800c31:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c34:	50                   	push   %eax
  800c35:	56                   	push   %esi
  800c36:	68 6a 1f 80 00       	push   $0x801f6a
  800c3b:	e8 e4 04 00 00       	call   801124 <cprintf>
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	eb ad                	jmp    800bf2 <_pipeisclosed+0xe>
	}
}
  800c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 28             	sub    $0x28,%esp
  800c59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c5c:	56                   	push   %esi
  800c5d:	e8 09 f7 ff ff       	call   80036b <fd2data>
  800c62:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6c:	eb 4b                	jmp    800cb9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c6e:	89 da                	mov    %ebx,%edx
  800c70:	89 f0                	mov    %esi,%eax
  800c72:	e8 6d ff ff ff       	call   800be4 <_pipeisclosed>
  800c77:	85 c0                	test   %eax,%eax
  800c79:	75 48                	jne    800cc3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c7b:	e8 cb f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c80:	8b 43 04             	mov    0x4(%ebx),%eax
  800c83:	8b 0b                	mov    (%ebx),%ecx
  800c85:	8d 51 20             	lea    0x20(%ecx),%edx
  800c88:	39 d0                	cmp    %edx,%eax
  800c8a:	73 e2                	jae    800c6e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c96:	89 c2                	mov    %eax,%edx
  800c98:	c1 fa 1f             	sar    $0x1f,%edx
  800c9b:	89 d1                	mov    %edx,%ecx
  800c9d:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca3:	83 e2 1f             	and    $0x1f,%edx
  800ca6:	29 ca                	sub    %ecx,%edx
  800ca8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb0:	83 c0 01             	add    $0x1,%eax
  800cb3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb6:	83 c7 01             	add    $0x1,%edi
  800cb9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cbc:	75 c2                	jne    800c80 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc1:	eb 05                	jmp    800cc8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 18             	sub    $0x18,%esp
  800cd9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cdc:	57                   	push   %edi
  800cdd:	e8 89 f6 ff ff       	call   80036b <fd2data>
  800ce2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce4:	83 c4 10             	add    $0x10,%esp
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	eb 3d                	jmp    800d2b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cee:	85 db                	test   %ebx,%ebx
  800cf0:	74 04                	je     800cf6 <devpipe_read+0x26>
				return i;
  800cf2:	89 d8                	mov    %ebx,%eax
  800cf4:	eb 44                	jmp    800d3a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf6:	89 f2                	mov    %esi,%edx
  800cf8:	89 f8                	mov    %edi,%eax
  800cfa:	e8 e5 fe ff ff       	call   800be4 <_pipeisclosed>
  800cff:	85 c0                	test   %eax,%eax
  800d01:	75 32                	jne    800d35 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d03:	e8 43 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d08:	8b 06                	mov    (%esi),%eax
  800d0a:	3b 46 04             	cmp    0x4(%esi),%eax
  800d0d:	74 df                	je     800cee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0f:	99                   	cltd   
  800d10:	c1 ea 1b             	shr    $0x1b,%edx
  800d13:	01 d0                	add    %edx,%eax
  800d15:	83 e0 1f             	and    $0x1f,%eax
  800d18:	29 d0                	sub    %edx,%eax
  800d1a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d25:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d28:	83 c3 01             	add    $0x1,%ebx
  800d2b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d2e:	75 d8                	jne    800d08 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d30:	8b 45 10             	mov    0x10(%ebp),%eax
  800d33:	eb 05                	jmp    800d3a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4d:	50                   	push   %eax
  800d4e:	e8 2f f6 ff ff       	call   800382 <fd_alloc>
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	89 c2                	mov    %eax,%edx
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	0f 88 2c 01 00 00    	js     800e8c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 07 04 00 00       	push   $0x407
  800d68:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 f8 f3 ff ff       	call   80016a <sys_page_alloc>
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	89 c2                	mov    %eax,%edx
  800d77:	85 c0                	test   %eax,%eax
  800d79:	0f 88 0d 01 00 00    	js     800e8c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d85:	50                   	push   %eax
  800d86:	e8 f7 f5 ff ff       	call   800382 <fd_alloc>
  800d8b:	89 c3                	mov    %eax,%ebx
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	85 c0                	test   %eax,%eax
  800d92:	0f 88 e2 00 00 00    	js     800e7a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d98:	83 ec 04             	sub    $0x4,%esp
  800d9b:	68 07 04 00 00       	push   $0x407
  800da0:	ff 75 f0             	pushl  -0x10(%ebp)
  800da3:	6a 00                	push   $0x0
  800da5:	e8 c0 f3 ff ff       	call   80016a <sys_page_alloc>
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	85 c0                	test   %eax,%eax
  800db1:	0f 88 c3 00 00 00    	js     800e7a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbd:	e8 a9 f5 ff ff       	call   80036b <fd2data>
  800dc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc4:	83 c4 0c             	add    $0xc,%esp
  800dc7:	68 07 04 00 00       	push   $0x407
  800dcc:	50                   	push   %eax
  800dcd:	6a 00                	push   $0x0
  800dcf:	e8 96 f3 ff ff       	call   80016a <sys_page_alloc>
  800dd4:	89 c3                	mov    %eax,%ebx
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	0f 88 89 00 00 00    	js     800e6a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	ff 75 f0             	pushl  -0x10(%ebp)
  800de7:	e8 7f f5 ff ff       	call   80036b <fd2data>
  800dec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df3:	50                   	push   %eax
  800df4:	6a 00                	push   $0x0
  800df6:	56                   	push   %esi
  800df7:	6a 00                	push   $0x0
  800df9:	e8 af f3 ff ff       	call   8001ad <sys_page_map>
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	83 c4 20             	add    $0x20,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	78 55                	js     800e5c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e07:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e1c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	ff 75 f4             	pushl  -0xc(%ebp)
  800e37:	e8 1f f5 ff ff       	call   80035b <fd2num>
  800e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e41:	83 c4 04             	add    $0x4,%esp
  800e44:	ff 75 f0             	pushl  -0x10(%ebp)
  800e47:	e8 0f f5 ff ff       	call   80035b <fd2num>
  800e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5a:	eb 30                	jmp    800e8c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	56                   	push   %esi
  800e60:	6a 00                	push   $0x0
  800e62:	e8 88 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e67:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e70:	6a 00                	push   $0x0
  800e72:	e8 78 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e77:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e80:	6a 00                	push   $0x0
  800e82:	e8 68 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e8c:	89 d0                	mov    %edx,%eax
  800e8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9e:	50                   	push   %eax
  800e9f:	ff 75 08             	pushl  0x8(%ebp)
  800ea2:	e8 2a f5 ff ff       	call   8003d1 <fd_lookup>
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 18                	js     800ec6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eae:	83 ec 0c             	sub    $0xc,%esp
  800eb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb4:	e8 b2 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800eb9:	89 c2                	mov    %eax,%edx
  800ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebe:	e8 21 fd ff ff       	call   800be4 <_pipeisclosed>
  800ec3:	83 c4 10             	add    $0x10,%esp
}
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed8:	68 82 1f 80 00       	push   $0x801f82
  800edd:	ff 75 0c             	pushl  0xc(%ebp)
  800ee0:	e8 43 08 00 00       	call   801728 <strcpy>
	return 0;
}
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f03:	eb 2d                	jmp    800f32 <devcons_write+0x46>
		m = n - tot;
  800f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f08:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f0a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f0d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f12:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	53                   	push   %ebx
  800f19:	03 45 0c             	add    0xc(%ebp),%eax
  800f1c:	50                   	push   %eax
  800f1d:	57                   	push   %edi
  800f1e:	e8 97 09 00 00       	call   8018ba <memmove>
		sys_cputs(buf, m);
  800f23:	83 c4 08             	add    $0x8,%esp
  800f26:	53                   	push   %ebx
  800f27:	57                   	push   %edi
  800f28:	e8 81 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2d:	01 de                	add    %ebx,%esi
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	89 f0                	mov    %esi,%eax
  800f34:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f37:	72 cc                	jb     800f05 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f50:	74 2a                	je     800f7c <devcons_read+0x3b>
  800f52:	eb 05                	jmp    800f59 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f54:	e8 f2 f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f59:	e8 6e f1 ff ff       	call   8000cc <sys_cgetc>
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	74 f2                	je     800f54 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 16                	js     800f7c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f66:	83 f8 04             	cmp    $0x4,%eax
  800f69:	74 0c                	je     800f77 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6e:	88 02                	mov    %al,(%edx)
	return 1;
  800f70:	b8 01 00 00 00       	mov    $0x1,%eax
  800f75:	eb 05                	jmp    800f7c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f8a:	6a 01                	push   $0x1
  800f8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	e8 19 f1 ff ff       	call   8000ae <sys_cputs>
}
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <getchar>:

int
getchar(void)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa0:	6a 01                	push   $0x1
  800fa2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 8a f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 0f                	js     800fc3 <getchar+0x29>
		return r;
	if (r < 1)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7e 06                	jle    800fbe <getchar+0x24>
		return -E_EOF;
	return c;
  800fb8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fbc:	eb 05                	jmp    800fc3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fbe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fce:	50                   	push   %eax
  800fcf:	ff 75 08             	pushl  0x8(%ebp)
  800fd2:	e8 fa f3 ff ff       	call   8003d1 <fd_lookup>
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 11                	js     800fef <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fe7:	39 10                	cmp    %edx,(%eax)
  800fe9:	0f 94 c0             	sete   %al
  800fec:	0f b6 c0             	movzbl %al,%eax
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <opencons>:

int
opencons(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	e8 82 f3 ff ff       	call   800382 <fd_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 3e                	js     801047 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	68 07 04 00 00       	push   $0x407
  801011:	ff 75 f4             	pushl  -0xc(%ebp)
  801014:	6a 00                	push   $0x0
  801016:	e8 4f f1 ff ff       	call   80016a <sys_page_alloc>
  80101b:	83 c4 10             	add    $0x10,%esp
		return r;
  80101e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801020:	85 c0                	test   %eax,%eax
  801022:	78 23                	js     801047 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801024:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801032:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	50                   	push   %eax
  80103d:	e8 19 f3 ff ff       	call   80035b <fd2num>
  801042:	89 c2                	mov    %eax,%edx
  801044:	83 c4 10             	add    $0x10,%esp
}
  801047:	89 d0                	mov    %edx,%eax
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801050:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801053:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801059:	e8 ce f0 ff ff       	call   80012c <sys_getenvid>
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	ff 75 0c             	pushl  0xc(%ebp)
  801064:	ff 75 08             	pushl  0x8(%ebp)
  801067:	56                   	push   %esi
  801068:	50                   	push   %eax
  801069:	68 90 1f 80 00       	push   $0x801f90
  80106e:	e8 b1 00 00 00       	call   801124 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801073:	83 c4 18             	add    $0x18,%esp
  801076:	53                   	push   %ebx
  801077:	ff 75 10             	pushl  0x10(%ebp)
  80107a:	e8 54 00 00 00       	call   8010d3 <vcprintf>
	cprintf("\n");
  80107f:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  801086:	e8 99 00 00 00       	call   801124 <cprintf>
  80108b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108e:	cc                   	int3   
  80108f:	eb fd                	jmp    80108e <_panic+0x43>

00801091 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	53                   	push   %ebx
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109b:	8b 13                	mov    (%ebx),%edx
  80109d:	8d 42 01             	lea    0x1(%edx),%eax
  8010a0:	89 03                	mov    %eax,(%ebx)
  8010a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ae:	75 1a                	jne    8010ca <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	68 ff 00 00 00       	push   $0xff
  8010b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8010bb:	50                   	push   %eax
  8010bc:	e8 ed ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e3:	00 00 00 
	b.cnt = 0;
  8010e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f0:	ff 75 0c             	pushl  0xc(%ebp)
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	68 91 10 80 00       	push   $0x801091
  801102:	e8 1a 01 00 00       	call   801221 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801107:	83 c4 08             	add    $0x8,%esp
  80110a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801110:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	e8 92 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80111c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80112a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80112d:	50                   	push   %eax
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	e8 9d ff ff ff       	call   8010d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	83 ec 1c             	sub    $0x1c,%esp
  801141:	89 c7                	mov    %eax,%edi
  801143:	89 d6                	mov    %edx,%esi
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80114e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801151:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801154:	bb 00 00 00 00       	mov    $0x0,%ebx
  801159:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80115c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80115f:	39 d3                	cmp    %edx,%ebx
  801161:	72 05                	jb     801168 <printnum+0x30>
  801163:	39 45 10             	cmp    %eax,0x10(%ebp)
  801166:	77 45                	ja     8011ad <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	ff 75 18             	pushl  0x18(%ebp)
  80116e:	8b 45 14             	mov    0x14(%ebp),%eax
  801171:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801174:	53                   	push   %ebx
  801175:	ff 75 10             	pushl  0x10(%ebp)
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117e:	ff 75 e0             	pushl  -0x20(%ebp)
  801181:	ff 75 dc             	pushl  -0x24(%ebp)
  801184:	ff 75 d8             	pushl  -0x28(%ebp)
  801187:	e8 34 0a 00 00       	call   801bc0 <__udivdi3>
  80118c:	83 c4 18             	add    $0x18,%esp
  80118f:	52                   	push   %edx
  801190:	50                   	push   %eax
  801191:	89 f2                	mov    %esi,%edx
  801193:	89 f8                	mov    %edi,%eax
  801195:	e8 9e ff ff ff       	call   801138 <printnum>
  80119a:	83 c4 20             	add    $0x20,%esp
  80119d:	eb 18                	jmp    8011b7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	56                   	push   %esi
  8011a3:	ff 75 18             	pushl  0x18(%ebp)
  8011a6:	ff d7                	call   *%edi
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	eb 03                	jmp    8011b0 <printnum+0x78>
  8011ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b0:	83 eb 01             	sub    $0x1,%ebx
  8011b3:	85 db                	test   %ebx,%ebx
  8011b5:	7f e8                	jg     80119f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	56                   	push   %esi
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ca:	e8 21 0b 00 00       	call   801cf0 <__umoddi3>
  8011cf:	83 c4 14             	add    $0x14,%esp
  8011d2:	0f be 80 b3 1f 80 00 	movsbl 0x801fb3(%eax),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff d7                	call   *%edi
}
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011f1:	8b 10                	mov    (%eax),%edx
  8011f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f6:	73 0a                	jae    801202 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011fb:	89 08                	mov    %ecx,(%eax)
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	88 02                	mov    %al,(%edx)
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80120a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80120d:	50                   	push   %eax
  80120e:	ff 75 10             	pushl  0x10(%ebp)
  801211:	ff 75 0c             	pushl  0xc(%ebp)
  801214:	ff 75 08             	pushl  0x8(%ebp)
  801217:	e8 05 00 00 00       	call   801221 <vprintfmt>
	va_end(ap);
}
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	57                   	push   %edi
  801225:	56                   	push   %esi
  801226:	53                   	push   %ebx
  801227:	83 ec 2c             	sub    $0x2c,%esp
  80122a:	8b 75 08             	mov    0x8(%ebp),%esi
  80122d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801230:	8b 7d 10             	mov    0x10(%ebp),%edi
  801233:	eb 12                	jmp    801247 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801235:	85 c0                	test   %eax,%eax
  801237:	0f 84 42 04 00 00    	je     80167f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	53                   	push   %ebx
  801241:	50                   	push   %eax
  801242:	ff d6                	call   *%esi
  801244:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801247:	83 c7 01             	add    $0x1,%edi
  80124a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80124e:	83 f8 25             	cmp    $0x25,%eax
  801251:	75 e2                	jne    801235 <vprintfmt+0x14>
  801253:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801257:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80125e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801265:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80126c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801271:	eb 07                	jmp    80127a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801273:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801276:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80127a:	8d 47 01             	lea    0x1(%edi),%eax
  80127d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801280:	0f b6 07             	movzbl (%edi),%eax
  801283:	0f b6 d0             	movzbl %al,%edx
  801286:	83 e8 23             	sub    $0x23,%eax
  801289:	3c 55                	cmp    $0x55,%al
  80128b:	0f 87 d3 03 00 00    	ja     801664 <vprintfmt+0x443>
  801291:	0f b6 c0             	movzbl %al,%eax
  801294:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  80129b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80129e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012a2:	eb d6                	jmp    80127a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012b6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012b9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012bc:	83 f9 09             	cmp    $0x9,%ecx
  8012bf:	77 3f                	ja     801300 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012c4:	eb e9                	jmp    8012af <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c9:	8b 00                	mov    (%eax),%eax
  8012cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d1:	8d 40 04             	lea    0x4(%eax),%eax
  8012d4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012da:	eb 2a                	jmp    801306 <vprintfmt+0xe5>
  8012dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e6:	0f 49 d0             	cmovns %eax,%edx
  8012e9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ef:	eb 89                	jmp    80127a <vprintfmt+0x59>
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012fb:	e9 7a ff ff ff       	jmp    80127a <vprintfmt+0x59>
  801300:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801303:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801306:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80130a:	0f 89 6a ff ff ff    	jns    80127a <vprintfmt+0x59>
				width = precision, precision = -1;
  801310:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801313:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801316:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80131d:	e9 58 ff ff ff       	jmp    80127a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801322:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801328:	e9 4d ff ff ff       	jmp    80127a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80132d:	8b 45 14             	mov    0x14(%ebp),%eax
  801330:	8d 78 04             	lea    0x4(%eax),%edi
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	53                   	push   %ebx
  801337:	ff 30                	pushl  (%eax)
  801339:	ff d6                	call   *%esi
			break;
  80133b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80133e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801344:	e9 fe fe ff ff       	jmp    801247 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801349:	8b 45 14             	mov    0x14(%ebp),%eax
  80134c:	8d 78 04             	lea    0x4(%eax),%edi
  80134f:	8b 00                	mov    (%eax),%eax
  801351:	99                   	cltd   
  801352:	31 d0                	xor    %edx,%eax
  801354:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801356:	83 f8 0f             	cmp    $0xf,%eax
  801359:	7f 0b                	jg     801366 <vprintfmt+0x145>
  80135b:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  801362:	85 d2                	test   %edx,%edx
  801364:	75 1b                	jne    801381 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801366:	50                   	push   %eax
  801367:	68 cb 1f 80 00       	push   $0x801fcb
  80136c:	53                   	push   %ebx
  80136d:	56                   	push   %esi
  80136e:	e8 91 fe ff ff       	call   801204 <printfmt>
  801373:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801376:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80137c:	e9 c6 fe ff ff       	jmp    801247 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801381:	52                   	push   %edx
  801382:	68 49 1f 80 00       	push   $0x801f49
  801387:	53                   	push   %ebx
  801388:	56                   	push   %esi
  801389:	e8 76 fe ff ff       	call   801204 <printfmt>
  80138e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801391:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801397:	e9 ab fe ff ff       	jmp    801247 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80139c:	8b 45 14             	mov    0x14(%ebp),%eax
  80139f:	83 c0 04             	add    $0x4,%eax
  8013a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013aa:	85 ff                	test   %edi,%edi
  8013ac:	b8 c4 1f 80 00       	mov    $0x801fc4,%eax
  8013b1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b8:	0f 8e 94 00 00 00    	jle    801452 <vprintfmt+0x231>
  8013be:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013c2:	0f 84 98 00 00 00    	je     801460 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ce:	57                   	push   %edi
  8013cf:	e8 33 03 00 00       	call   801707 <strnlen>
  8013d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013d7:	29 c1                	sub    %eax,%ecx
  8013d9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013dc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013eb:	eb 0f                	jmp    8013fc <vprintfmt+0x1db>
					putch(padc, putdat);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8013f4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f6:	83 ef 01             	sub    $0x1,%edi
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 ff                	test   %edi,%edi
  8013fe:	7f ed                	jg     8013ed <vprintfmt+0x1cc>
  801400:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801403:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801406:	85 c9                	test   %ecx,%ecx
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
  80140d:	0f 49 c1             	cmovns %ecx,%eax
  801410:	29 c1                	sub    %eax,%ecx
  801412:	89 75 08             	mov    %esi,0x8(%ebp)
  801415:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801418:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80141b:	89 cb                	mov    %ecx,%ebx
  80141d:	eb 4d                	jmp    80146c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80141f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801423:	74 1b                	je     801440 <vprintfmt+0x21f>
  801425:	0f be c0             	movsbl %al,%eax
  801428:	83 e8 20             	sub    $0x20,%eax
  80142b:	83 f8 5e             	cmp    $0x5e,%eax
  80142e:	76 10                	jbe    801440 <vprintfmt+0x21f>
					putch('?', putdat);
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 0c             	pushl  0xc(%ebp)
  801436:	6a 3f                	push   $0x3f
  801438:	ff 55 08             	call   *0x8(%ebp)
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	eb 0d                	jmp    80144d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	ff 75 0c             	pushl  0xc(%ebp)
  801446:	52                   	push   %edx
  801447:	ff 55 08             	call   *0x8(%ebp)
  80144a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80144d:	83 eb 01             	sub    $0x1,%ebx
  801450:	eb 1a                	jmp    80146c <vprintfmt+0x24b>
  801452:	89 75 08             	mov    %esi,0x8(%ebp)
  801455:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801458:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145e:	eb 0c                	jmp    80146c <vprintfmt+0x24b>
  801460:	89 75 08             	mov    %esi,0x8(%ebp)
  801463:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801466:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801469:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80146c:	83 c7 01             	add    $0x1,%edi
  80146f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801473:	0f be d0             	movsbl %al,%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	74 23                	je     80149d <vprintfmt+0x27c>
  80147a:	85 f6                	test   %esi,%esi
  80147c:	78 a1                	js     80141f <vprintfmt+0x1fe>
  80147e:	83 ee 01             	sub    $0x1,%esi
  801481:	79 9c                	jns    80141f <vprintfmt+0x1fe>
  801483:	89 df                	mov    %ebx,%edi
  801485:	8b 75 08             	mov    0x8(%ebp),%esi
  801488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148b:	eb 18                	jmp    8014a5 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	53                   	push   %ebx
  801491:	6a 20                	push   $0x20
  801493:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801495:	83 ef 01             	sub    $0x1,%edi
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb 08                	jmp    8014a5 <vprintfmt+0x284>
  80149d:	89 df                	mov    %ebx,%edi
  80149f:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a5:	85 ff                	test   %edi,%edi
  8014a7:	7f e4                	jg     80148d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014ac:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014b2:	e9 90 fd ff ff       	jmp    801247 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b7:	83 f9 01             	cmp    $0x1,%ecx
  8014ba:	7e 19                	jle    8014d5 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8b 50 04             	mov    0x4(%eax),%edx
  8014c2:	8b 00                	mov    (%eax),%eax
  8014c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cd:	8d 40 08             	lea    0x8(%eax),%eax
  8014d0:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d3:	eb 38                	jmp    80150d <vprintfmt+0x2ec>
	else if (lflag)
  8014d5:	85 c9                	test   %ecx,%ecx
  8014d7:	74 1b                	je     8014f4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dc:	8b 00                	mov    (%eax),%eax
  8014de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e1:	89 c1                	mov    %eax,%ecx
  8014e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ec:	8d 40 04             	lea    0x4(%eax),%eax
  8014ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f2:	eb 19                	jmp    80150d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f7:	8b 00                	mov    (%eax),%eax
  8014f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fc:	89 c1                	mov    %eax,%ecx
  8014fe:	c1 f9 1f             	sar    $0x1f,%ecx
  801501:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801504:	8b 45 14             	mov    0x14(%ebp),%eax
  801507:	8d 40 04             	lea    0x4(%eax),%eax
  80150a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80150d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801510:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801513:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801518:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80151c:	0f 89 0e 01 00 00    	jns    801630 <vprintfmt+0x40f>
				putch('-', putdat);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	53                   	push   %ebx
  801526:	6a 2d                	push   $0x2d
  801528:	ff d6                	call   *%esi
				num = -(long long) num;
  80152a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80152d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801530:	f7 da                	neg    %edx
  801532:	83 d1 00             	adc    $0x0,%ecx
  801535:	f7 d9                	neg    %ecx
  801537:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80153a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153f:	e9 ec 00 00 00       	jmp    801630 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801544:	83 f9 01             	cmp    $0x1,%ecx
  801547:	7e 18                	jle    801561 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801549:	8b 45 14             	mov    0x14(%ebp),%eax
  80154c:	8b 10                	mov    (%eax),%edx
  80154e:	8b 48 04             	mov    0x4(%eax),%ecx
  801551:	8d 40 08             	lea    0x8(%eax),%eax
  801554:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801557:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155c:	e9 cf 00 00 00       	jmp    801630 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801561:	85 c9                	test   %ecx,%ecx
  801563:	74 1a                	je     80157f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801565:	8b 45 14             	mov    0x14(%ebp),%eax
  801568:	8b 10                	mov    (%eax),%edx
  80156a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156f:	8d 40 04             	lea    0x4(%eax),%eax
  801572:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801575:	b8 0a 00 00 00       	mov    $0xa,%eax
  80157a:	e9 b1 00 00 00       	jmp    801630 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80157f:	8b 45 14             	mov    0x14(%ebp),%eax
  801582:	8b 10                	mov    (%eax),%edx
  801584:	b9 00 00 00 00       	mov    $0x0,%ecx
  801589:	8d 40 04             	lea    0x4(%eax),%eax
  80158c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80158f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801594:	e9 97 00 00 00       	jmp    801630 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	6a 58                	push   $0x58
  80159f:	ff d6                	call   *%esi
			putch('X', putdat);
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	6a 58                	push   $0x58
  8015a7:	ff d6                	call   *%esi
			putch('X', putdat);
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	6a 58                	push   $0x58
  8015af:	ff d6                	call   *%esi
			break;
  8015b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015b7:	e9 8b fc ff ff       	jmp    801247 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	6a 30                	push   $0x30
  8015c2:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	6a 78                	push   $0x78
  8015ca:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cf:	8b 10                	mov    (%eax),%edx
  8015d1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015d9:	8d 40 04             	lea    0x4(%eax),%eax
  8015dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015df:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015e4:	eb 4a                	jmp    801630 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015e6:	83 f9 01             	cmp    $0x1,%ecx
  8015e9:	7e 15                	jle    801600 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ee:	8b 10                	mov    (%eax),%edx
  8015f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8015f3:	8d 40 08             	lea    0x8(%eax),%eax
  8015f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fe:	eb 30                	jmp    801630 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801600:	85 c9                	test   %ecx,%ecx
  801602:	74 17                	je     80161b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801604:	8b 45 14             	mov    0x14(%ebp),%eax
  801607:	8b 10                	mov    (%eax),%edx
  801609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160e:	8d 40 04             	lea    0x4(%eax),%eax
  801611:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801614:	b8 10 00 00 00       	mov    $0x10,%eax
  801619:	eb 15                	jmp    801630 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80161b:	8b 45 14             	mov    0x14(%ebp),%eax
  80161e:	8b 10                	mov    (%eax),%edx
  801620:	b9 00 00 00 00       	mov    $0x0,%ecx
  801625:	8d 40 04             	lea    0x4(%eax),%eax
  801628:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80162b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801637:	57                   	push   %edi
  801638:	ff 75 e0             	pushl  -0x20(%ebp)
  80163b:	50                   	push   %eax
  80163c:	51                   	push   %ecx
  80163d:	52                   	push   %edx
  80163e:	89 da                	mov    %ebx,%edx
  801640:	89 f0                	mov    %esi,%eax
  801642:	e8 f1 fa ff ff       	call   801138 <printnum>
			break;
  801647:	83 c4 20             	add    $0x20,%esp
  80164a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80164d:	e9 f5 fb ff ff       	jmp    801247 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	53                   	push   %ebx
  801656:	52                   	push   %edx
  801657:	ff d6                	call   *%esi
			break;
  801659:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80165f:	e9 e3 fb ff ff       	jmp    801247 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	53                   	push   %ebx
  801668:	6a 25                	push   $0x25
  80166a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	eb 03                	jmp    801674 <vprintfmt+0x453>
  801671:	83 ef 01             	sub    $0x1,%edi
  801674:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801678:	75 f7                	jne    801671 <vprintfmt+0x450>
  80167a:	e9 c8 fb ff ff       	jmp    801247 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80167f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 18             	sub    $0x18,%esp
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801693:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801696:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80169a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80169d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	74 26                	je     8016ce <vsnprintf+0x47>
  8016a8:	85 d2                	test   %edx,%edx
  8016aa:	7e 22                	jle    8016ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016ac:	ff 75 14             	pushl  0x14(%ebp)
  8016af:	ff 75 10             	pushl  0x10(%ebp)
  8016b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016b5:	50                   	push   %eax
  8016b6:	68 e7 11 80 00       	push   $0x8011e7
  8016bb:	e8 61 fb ff ff       	call   801221 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	eb 05                	jmp    8016d3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016de:	50                   	push   %eax
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	ff 75 08             	pushl  0x8(%ebp)
  8016e8:	e8 9a ff ff ff       	call   801687 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fa:	eb 03                	jmp    8016ff <strlen+0x10>
		n++;
  8016fc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801703:	75 f7                	jne    8016fc <strlen+0xd>
		n++;
	return n;
}
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801710:	ba 00 00 00 00       	mov    $0x0,%edx
  801715:	eb 03                	jmp    80171a <strnlen+0x13>
		n++;
  801717:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80171a:	39 c2                	cmp    %eax,%edx
  80171c:	74 08                	je     801726 <strnlen+0x1f>
  80171e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801722:	75 f3                	jne    801717 <strnlen+0x10>
  801724:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801732:	89 c2                	mov    %eax,%edx
  801734:	83 c2 01             	add    $0x1,%edx
  801737:	83 c1 01             	add    $0x1,%ecx
  80173a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80173e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801741:	84 db                	test   %bl,%bl
  801743:	75 ef                	jne    801734 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801745:	5b                   	pop    %ebx
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80174f:	53                   	push   %ebx
  801750:	e8 9a ff ff ff       	call   8016ef <strlen>
  801755:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	01 d8                	add    %ebx,%eax
  80175d:	50                   	push   %eax
  80175e:	e8 c5 ff ff ff       	call   801728 <strcpy>
	return dst;
}
  801763:	89 d8                	mov    %ebx,%eax
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
  80176f:	8b 75 08             	mov    0x8(%ebp),%esi
  801772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801775:	89 f3                	mov    %esi,%ebx
  801777:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177a:	89 f2                	mov    %esi,%edx
  80177c:	eb 0f                	jmp    80178d <strncpy+0x23>
		*dst++ = *src;
  80177e:	83 c2 01             	add    $0x1,%edx
  801781:	0f b6 01             	movzbl (%ecx),%eax
  801784:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801787:	80 39 01             	cmpb   $0x1,(%ecx)
  80178a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80178d:	39 da                	cmp    %ebx,%edx
  80178f:	75 ed                	jne    80177e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801791:	89 f0                	mov    %esi,%eax
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	56                   	push   %esi
  80179b:	53                   	push   %ebx
  80179c:	8b 75 08             	mov    0x8(%ebp),%esi
  80179f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a2:	8b 55 10             	mov    0x10(%ebp),%edx
  8017a5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017a7:	85 d2                	test   %edx,%edx
  8017a9:	74 21                	je     8017cc <strlcpy+0x35>
  8017ab:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017af:	89 f2                	mov    %esi,%edx
  8017b1:	eb 09                	jmp    8017bc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017b3:	83 c2 01             	add    $0x1,%edx
  8017b6:	83 c1 01             	add    $0x1,%ecx
  8017b9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017bc:	39 c2                	cmp    %eax,%edx
  8017be:	74 09                	je     8017c9 <strlcpy+0x32>
  8017c0:	0f b6 19             	movzbl (%ecx),%ebx
  8017c3:	84 db                	test   %bl,%bl
  8017c5:	75 ec                	jne    8017b3 <strlcpy+0x1c>
  8017c7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017c9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017cc:	29 f0                	sub    %esi,%eax
}
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017db:	eb 06                	jmp    8017e3 <strcmp+0x11>
		p++, q++;
  8017dd:	83 c1 01             	add    $0x1,%ecx
  8017e0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017e3:	0f b6 01             	movzbl (%ecx),%eax
  8017e6:	84 c0                	test   %al,%al
  8017e8:	74 04                	je     8017ee <strcmp+0x1c>
  8017ea:	3a 02                	cmp    (%edx),%al
  8017ec:	74 ef                	je     8017dd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ee:	0f b6 c0             	movzbl %al,%eax
  8017f1:	0f b6 12             	movzbl (%edx),%edx
  8017f4:	29 d0                	sub    %edx,%eax
}
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801802:	89 c3                	mov    %eax,%ebx
  801804:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801807:	eb 06                	jmp    80180f <strncmp+0x17>
		n--, p++, q++;
  801809:	83 c0 01             	add    $0x1,%eax
  80180c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80180f:	39 d8                	cmp    %ebx,%eax
  801811:	74 15                	je     801828 <strncmp+0x30>
  801813:	0f b6 08             	movzbl (%eax),%ecx
  801816:	84 c9                	test   %cl,%cl
  801818:	74 04                	je     80181e <strncmp+0x26>
  80181a:	3a 0a                	cmp    (%edx),%cl
  80181c:	74 eb                	je     801809 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80181e:	0f b6 00             	movzbl (%eax),%eax
  801821:	0f b6 12             	movzbl (%edx),%edx
  801824:	29 d0                	sub    %edx,%eax
  801826:	eb 05                	jmp    80182d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80182d:	5b                   	pop    %ebx
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183a:	eb 07                	jmp    801843 <strchr+0x13>
		if (*s == c)
  80183c:	38 ca                	cmp    %cl,%dl
  80183e:	74 0f                	je     80184f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801840:	83 c0 01             	add    $0x1,%eax
  801843:	0f b6 10             	movzbl (%eax),%edx
  801846:	84 d2                	test   %dl,%dl
  801848:	75 f2                	jne    80183c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80185b:	eb 03                	jmp    801860 <strfind+0xf>
  80185d:	83 c0 01             	add    $0x1,%eax
  801860:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801863:	38 ca                	cmp    %cl,%dl
  801865:	74 04                	je     80186b <strfind+0x1a>
  801867:	84 d2                	test   %dl,%dl
  801869:	75 f2                	jne    80185d <strfind+0xc>
			break;
	return (char *) s;
}
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	57                   	push   %edi
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
  801873:	8b 7d 08             	mov    0x8(%ebp),%edi
  801876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801879:	85 c9                	test   %ecx,%ecx
  80187b:	74 36                	je     8018b3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80187d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801883:	75 28                	jne    8018ad <memset+0x40>
  801885:	f6 c1 03             	test   $0x3,%cl
  801888:	75 23                	jne    8018ad <memset+0x40>
		c &= 0xFF;
  80188a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80188e:	89 d3                	mov    %edx,%ebx
  801890:	c1 e3 08             	shl    $0x8,%ebx
  801893:	89 d6                	mov    %edx,%esi
  801895:	c1 e6 18             	shl    $0x18,%esi
  801898:	89 d0                	mov    %edx,%eax
  80189a:	c1 e0 10             	shl    $0x10,%eax
  80189d:	09 f0                	or     %esi,%eax
  80189f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018a1:	89 d8                	mov    %ebx,%eax
  8018a3:	09 d0                	or     %edx,%eax
  8018a5:	c1 e9 02             	shr    $0x2,%ecx
  8018a8:	fc                   	cld    
  8018a9:	f3 ab                	rep stos %eax,%es:(%edi)
  8018ab:	eb 06                	jmp    8018b3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b0:	fc                   	cld    
  8018b1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018b3:	89 f8                	mov    %edi,%eax
  8018b5:	5b                   	pop    %ebx
  8018b6:	5e                   	pop    %esi
  8018b7:	5f                   	pop    %edi
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	57                   	push   %edi
  8018be:	56                   	push   %esi
  8018bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c8:	39 c6                	cmp    %eax,%esi
  8018ca:	73 35                	jae    801901 <memmove+0x47>
  8018cc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018cf:	39 d0                	cmp    %edx,%eax
  8018d1:	73 2e                	jae    801901 <memmove+0x47>
		s += n;
		d += n;
  8018d3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d6:	89 d6                	mov    %edx,%esi
  8018d8:	09 fe                	or     %edi,%esi
  8018da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018e0:	75 13                	jne    8018f5 <memmove+0x3b>
  8018e2:	f6 c1 03             	test   $0x3,%cl
  8018e5:	75 0e                	jne    8018f5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018e7:	83 ef 04             	sub    $0x4,%edi
  8018ea:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ed:	c1 e9 02             	shr    $0x2,%ecx
  8018f0:	fd                   	std    
  8018f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f3:	eb 09                	jmp    8018fe <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018f5:	83 ef 01             	sub    $0x1,%edi
  8018f8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018fb:	fd                   	std    
  8018fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018fe:	fc                   	cld    
  8018ff:	eb 1d                	jmp    80191e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801901:	89 f2                	mov    %esi,%edx
  801903:	09 c2                	or     %eax,%edx
  801905:	f6 c2 03             	test   $0x3,%dl
  801908:	75 0f                	jne    801919 <memmove+0x5f>
  80190a:	f6 c1 03             	test   $0x3,%cl
  80190d:	75 0a                	jne    801919 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80190f:	c1 e9 02             	shr    $0x2,%ecx
  801912:	89 c7                	mov    %eax,%edi
  801914:	fc                   	cld    
  801915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801917:	eb 05                	jmp    80191e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801919:	89 c7                	mov    %eax,%edi
  80191b:	fc                   	cld    
  80191c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80191e:	5e                   	pop    %esi
  80191f:	5f                   	pop    %edi
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801925:	ff 75 10             	pushl  0x10(%ebp)
  801928:	ff 75 0c             	pushl  0xc(%ebp)
  80192b:	ff 75 08             	pushl  0x8(%ebp)
  80192e:	e8 87 ff ff ff       	call   8018ba <memmove>
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
  80193d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801940:	89 c6                	mov    %eax,%esi
  801942:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801945:	eb 1a                	jmp    801961 <memcmp+0x2c>
		if (*s1 != *s2)
  801947:	0f b6 08             	movzbl (%eax),%ecx
  80194a:	0f b6 1a             	movzbl (%edx),%ebx
  80194d:	38 d9                	cmp    %bl,%cl
  80194f:	74 0a                	je     80195b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801951:	0f b6 c1             	movzbl %cl,%eax
  801954:	0f b6 db             	movzbl %bl,%ebx
  801957:	29 d8                	sub    %ebx,%eax
  801959:	eb 0f                	jmp    80196a <memcmp+0x35>
		s1++, s2++;
  80195b:	83 c0 01             	add    $0x1,%eax
  80195e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801961:	39 f0                	cmp    %esi,%eax
  801963:	75 e2                	jne    801947 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	53                   	push   %ebx
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801975:	89 c1                	mov    %eax,%ecx
  801977:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80197a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197e:	eb 0a                	jmp    80198a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801980:	0f b6 10             	movzbl (%eax),%edx
  801983:	39 da                	cmp    %ebx,%edx
  801985:	74 07                	je     80198e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801987:	83 c0 01             	add    $0x1,%eax
  80198a:	39 c8                	cmp    %ecx,%eax
  80198c:	72 f2                	jb     801980 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80198e:	5b                   	pop    %ebx
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	57                   	push   %edi
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80199d:	eb 03                	jmp    8019a2 <strtol+0x11>
		s++;
  80199f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019a2:	0f b6 01             	movzbl (%ecx),%eax
  8019a5:	3c 20                	cmp    $0x20,%al
  8019a7:	74 f6                	je     80199f <strtol+0xe>
  8019a9:	3c 09                	cmp    $0x9,%al
  8019ab:	74 f2                	je     80199f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019ad:	3c 2b                	cmp    $0x2b,%al
  8019af:	75 0a                	jne    8019bb <strtol+0x2a>
		s++;
  8019b1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b9:	eb 11                	jmp    8019cc <strtol+0x3b>
  8019bb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019c0:	3c 2d                	cmp    $0x2d,%al
  8019c2:	75 08                	jne    8019cc <strtol+0x3b>
		s++, neg = 1;
  8019c4:	83 c1 01             	add    $0x1,%ecx
  8019c7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019cc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019d2:	75 15                	jne    8019e9 <strtol+0x58>
  8019d4:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d7:	75 10                	jne    8019e9 <strtol+0x58>
  8019d9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019dd:	75 7c                	jne    801a5b <strtol+0xca>
		s += 2, base = 16;
  8019df:	83 c1 02             	add    $0x2,%ecx
  8019e2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e7:	eb 16                	jmp    8019ff <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019e9:	85 db                	test   %ebx,%ebx
  8019eb:	75 12                	jne    8019ff <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ed:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019f5:	75 08                	jne    8019ff <strtol+0x6e>
		s++, base = 8;
  8019f7:	83 c1 01             	add    $0x1,%ecx
  8019fa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801a04:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a07:	0f b6 11             	movzbl (%ecx),%edx
  801a0a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a0d:	89 f3                	mov    %esi,%ebx
  801a0f:	80 fb 09             	cmp    $0x9,%bl
  801a12:	77 08                	ja     801a1c <strtol+0x8b>
			dig = *s - '0';
  801a14:	0f be d2             	movsbl %dl,%edx
  801a17:	83 ea 30             	sub    $0x30,%edx
  801a1a:	eb 22                	jmp    801a3e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a1c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a1f:	89 f3                	mov    %esi,%ebx
  801a21:	80 fb 19             	cmp    $0x19,%bl
  801a24:	77 08                	ja     801a2e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a26:	0f be d2             	movsbl %dl,%edx
  801a29:	83 ea 57             	sub    $0x57,%edx
  801a2c:	eb 10                	jmp    801a3e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a2e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a31:	89 f3                	mov    %esi,%ebx
  801a33:	80 fb 19             	cmp    $0x19,%bl
  801a36:	77 16                	ja     801a4e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a38:	0f be d2             	movsbl %dl,%edx
  801a3b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a3e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a41:	7d 0b                	jge    801a4e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a43:	83 c1 01             	add    $0x1,%ecx
  801a46:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a4a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a4c:	eb b9                	jmp    801a07 <strtol+0x76>

	if (endptr)
  801a4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a52:	74 0d                	je     801a61 <strtol+0xd0>
		*endptr = (char *) s;
  801a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a57:	89 0e                	mov    %ecx,(%esi)
  801a59:	eb 06                	jmp    801a61 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a5b:	85 db                	test   %ebx,%ebx
  801a5d:	74 98                	je     8019f7 <strtol+0x66>
  801a5f:	eb 9e                	jmp    8019ff <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a61:	89 c2                	mov    %eax,%edx
  801a63:	f7 da                	neg    %edx
  801a65:	85 ff                	test   %edi,%edi
  801a67:	0f 45 c2             	cmovne %edx,%eax
}
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	57                   	push   %edi
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a81:	85 f6                	test   %esi,%esi
  801a83:	74 06                	je     801a8b <ipc_recv+0x1c>
		*from_env_store = 0;
  801a85:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a8b:	85 db                	test   %ebx,%ebx
  801a8d:	74 06                	je     801a95 <ipc_recv+0x26>
		*perm_store = 0;
  801a8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a95:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a97:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a9c:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	50                   	push   %eax
  801aa3:	e8 72 e8 ff ff       	call   80031a <sys_ipc_recv>
  801aa8:	89 c7                	mov    %eax,%edi
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	79 14                	jns    801ac5 <ipc_recv+0x56>
		cprintf("im dead");
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	68 c0 22 80 00       	push   $0x8022c0
  801ab9:	e8 66 f6 ff ff       	call   801124 <cprintf>
		return r;
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	eb 24                	jmp    801ae9 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ac5:	85 f6                	test   %esi,%esi
  801ac7:	74 0a                	je     801ad3 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 40 74             	mov    0x74(%eax),%eax
  801ad1:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ad3:	85 db                	test   %ebx,%ebx
  801ad5:	74 0a                	je     801ae1 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ad7:	a1 04 40 80 00       	mov    0x804004,%eax
  801adc:	8b 40 78             	mov    0x78(%eax),%eax
  801adf:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801ae1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	57                   	push   %edi
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801b03:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b0a:	0f 44 d8             	cmove  %eax,%ebx
  801b0d:	eb 1c                	jmp    801b2b <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b12:	74 12                	je     801b26 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b14:	50                   	push   %eax
  801b15:	68 c8 22 80 00       	push   $0x8022c8
  801b1a:	6a 4e                	push   $0x4e
  801b1c:	68 d5 22 80 00       	push   $0x8022d5
  801b21:	e8 25 f5 ff ff       	call   80104b <_panic>
		sys_yield();
  801b26:	e8 20 e6 ff ff       	call   80014b <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b2b:	ff 75 14             	pushl  0x14(%ebp)
  801b2e:	53                   	push   %ebx
  801b2f:	56                   	push   %esi
  801b30:	57                   	push   %edi
  801b31:	e8 c1 e7 ff ff       	call   8002f7 <sys_ipc_try_send>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 d2                	js     801b0f <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b50:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b53:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b59:	8b 52 50             	mov    0x50(%edx),%edx
  801b5c:	39 ca                	cmp    %ecx,%edx
  801b5e:	75 0d                	jne    801b6d <ipc_find_env+0x28>
			return envs[i].env_id;
  801b60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b68:	8b 40 48             	mov    0x48(%eax),%eax
  801b6b:	eb 0f                	jmp    801b7c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6d:	83 c0 01             	add    $0x1,%eax
  801b70:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b75:	75 d9                	jne    801b50 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b84:	89 d0                	mov    %edx,%eax
  801b86:	c1 e8 16             	shr    $0x16,%eax
  801b89:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b95:	f6 c1 01             	test   $0x1,%cl
  801b98:	74 1d                	je     801bb7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9a:	c1 ea 0c             	shr    $0xc,%edx
  801b9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba4:	f6 c2 01             	test   $0x1,%dl
  801ba7:	74 0e                	je     801bb7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba9:	c1 ea 0c             	shr    $0xc,%edx
  801bac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb3:	ef 
  801bb4:	0f b7 c0             	movzwl %ax,%eax
}
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
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
