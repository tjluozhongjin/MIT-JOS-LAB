
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 4a 1e 80 00       	push   $0x801e4a
  80010c:	6a 23                	push   $0x23
  80010e:	68 67 1e 80 00       	push   $0x801e67
  800113:	e8 27 0f 00 00       	call   80103f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 4a 1e 80 00       	push   $0x801e4a
  80018d:	6a 23                	push   $0x23
  80018f:	68 67 1e 80 00       	push   $0x801e67
  800194:	e8 a6 0e 00 00       	call   80103f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 4a 1e 80 00       	push   $0x801e4a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 67 1e 80 00       	push   $0x801e67
  8001d6:	e8 64 0e 00 00       	call   80103f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 4a 1e 80 00       	push   $0x801e4a
  800211:	6a 23                	push   $0x23
  800213:	68 67 1e 80 00       	push   $0x801e67
  800218:	e8 22 0e 00 00       	call   80103f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 4a 1e 80 00       	push   $0x801e4a
  800253:	6a 23                	push   $0x23
  800255:	68 67 1e 80 00       	push   $0x801e67
  80025a:	e8 e0 0d 00 00       	call   80103f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 4a 1e 80 00       	push   $0x801e4a
  800295:	6a 23                	push   $0x23
  800297:	68 67 1e 80 00       	push   $0x801e67
  80029c:	e8 9e 0d 00 00       	call   80103f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 4a 1e 80 00       	push   $0x801e4a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 67 1e 80 00       	push   $0x801e67
  8002de:	e8 5c 0d 00 00       	call   80103f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 4a 1e 80 00       	push   $0x801e4a
  80033b:	6a 23                	push   $0x23
  80033d:	68 67 1e 80 00       	push   $0x801e67
  800342:	e8 f8 0c 00 00       	call   80103f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 78 1e 80 00       	push   $0x801e78
  800456:	e8 bd 0c 00 00       	call   801118 <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 b9 1e 80 00       	push   $0x801eb9
  800680:	e8 93 0a 00 00       	call   801118 <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 d5 1e 80 00       	push   $0x801ed5
  800755:	e8 be 09 00 00       	call   801118 <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 98 1e 80 00       	push   $0x801e98
  80080a:	e8 09 09 00 00       	call   801118 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 e9 01 00 00       	call   800abc <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 1f 12 00 00       	call   801b39 <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 b0 11 00 00       	call   801ae5 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 21 11 00 00       	call   801a63 <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 51 0d 00 00       	call   80171c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009fc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a01:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 52 0c             	mov    0xc(%edx),%edx
  800a0a:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a10:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a15:	50                   	push   %eax
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	68 08 50 80 00       	push   $0x805008
  800a1e:	e8 8b 0e 00 00       	call   8018ae <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a23:	ba 00 00 00 00       	mov    $0x0,%edx
  800a28:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2d:	e8 cc fe ff ff       	call   8008fe <fsipc>
            return r;

    return r;
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a47:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 03 00 00 00       	mov    $0x3,%eax
  800a57:	e8 a2 fe ff ff       	call   8008fe <fsipc>
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	78 51                	js     800ab3 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 19                	jae    800a7f <devfile_read+0x4b>
  800a66:	68 04 1f 80 00       	push   $0x801f04
  800a6b:	68 0b 1f 80 00       	push   $0x801f0b
  800a70:	68 82 00 00 00       	push   $0x82
  800a75:	68 20 1f 80 00       	push   $0x801f20
  800a7a:	e8 c0 05 00 00       	call   80103f <_panic>
	assert(r <= PGSIZE);
  800a7f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a84:	7e 19                	jle    800a9f <devfile_read+0x6b>
  800a86:	68 2b 1f 80 00       	push   $0x801f2b
  800a8b:	68 0b 1f 80 00       	push   $0x801f0b
  800a90:	68 83 00 00 00       	push   $0x83
  800a95:	68 20 1f 80 00       	push   $0x801f20
  800a9a:	e8 a0 05 00 00       	call   80103f <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9f:	83 ec 04             	sub    $0x4,%esp
  800aa2:	50                   	push   %eax
  800aa3:	68 00 50 80 00       	push   $0x805000
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	e8 fe 0d 00 00       	call   8018ae <memmove>
	return r;
  800ab0:	83 c4 10             	add    $0x10,%esp
}
  800ab3:	89 d8                	mov    %ebx,%eax
  800ab5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 20             	sub    $0x20,%esp
  800ac3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac6:	53                   	push   %ebx
  800ac7:	e8 17 0c 00 00       	call   8016e3 <strlen>
  800acc:	83 c4 10             	add    $0x10,%esp
  800acf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad4:	7f 67                	jg     800b3d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800adc:	50                   	push   %eax
  800add:	e8 94 f8 ff ff       	call   800376 <fd_alloc>
  800ae2:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	78 57                	js     800b42 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	53                   	push   %ebx
  800aef:	68 00 50 80 00       	push   $0x805000
  800af4:	e8 23 0c 00 00       	call   80171c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b04:	b8 01 00 00 00       	mov    $0x1,%eax
  800b09:	e8 f0 fd ff ff       	call   8008fe <fsipc>
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	85 c0                	test   %eax,%eax
  800b15:	79 14                	jns    800b2b <open+0x6f>
		fd_close(fd, 0);
  800b17:	83 ec 08             	sub    $0x8,%esp
  800b1a:	6a 00                	push   $0x0
  800b1c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1f:	e8 4a f9 ff ff       	call   80046e <fd_close>
		return r;
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	89 da                	mov    %ebx,%edx
  800b29:	eb 17                	jmp    800b42 <open+0x86>
	}

	return fd2num(fd);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b31:	e8 19 f8 ff ff       	call   80034f <fd2num>
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	83 c4 10             	add    $0x10,%esp
  800b3b:	eb 05                	jmp    800b42 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b3d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b42:	89 d0                	mov    %edx,%eax
  800b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b54:	b8 08 00 00 00       	mov    $0x8,%eax
  800b59:	e8 a0 fd ff ff       	call   8008fe <fsipc>
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b68:	83 ec 0c             	sub    $0xc,%esp
  800b6b:	ff 75 08             	pushl  0x8(%ebp)
  800b6e:	e8 ec f7 ff ff       	call   80035f <fd2data>
  800b73:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b75:	83 c4 08             	add    $0x8,%esp
  800b78:	68 37 1f 80 00       	push   $0x801f37
  800b7d:	53                   	push   %ebx
  800b7e:	e8 99 0b 00 00       	call   80171c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b83:	8b 46 04             	mov    0x4(%esi),%eax
  800b86:	2b 06                	sub    (%esi),%eax
  800b88:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b95:	00 00 00 
	stat->st_dev = &devpipe;
  800b98:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b9f:	30 80 00 
	return 0;
}
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb8:	53                   	push   %ebx
  800bb9:	6a 00                	push   $0x0
  800bbb:	e8 23 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc0:	89 1c 24             	mov    %ebx,(%esp)
  800bc3:	e8 97 f7 ff ff       	call   80035f <fd2data>
  800bc8:	83 c4 08             	add    $0x8,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 00                	push   $0x0
  800bce:	e8 10 f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 1c             	sub    $0x1c,%esp
  800be1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be6:	a1 04 40 80 00       	mov    0x804004,%eax
  800beb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf4:	e8 79 0f 00 00       	call   801b72 <pageref>
  800bf9:	89 c3                	mov    %eax,%ebx
  800bfb:	89 3c 24             	mov    %edi,(%esp)
  800bfe:	e8 6f 0f 00 00       	call   801b72 <pageref>
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	39 c3                	cmp    %eax,%ebx
  800c08:	0f 94 c1             	sete   %cl
  800c0b:	0f b6 c9             	movzbl %cl,%ecx
  800c0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c11:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c17:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1a:	39 ce                	cmp    %ecx,%esi
  800c1c:	74 1b                	je     800c39 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c1e:	39 c3                	cmp    %eax,%ebx
  800c20:	75 c4                	jne    800be6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c22:	8b 42 58             	mov    0x58(%edx),%eax
  800c25:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c28:	50                   	push   %eax
  800c29:	56                   	push   %esi
  800c2a:	68 3e 1f 80 00       	push   $0x801f3e
  800c2f:	e8 e4 04 00 00       	call   801118 <cprintf>
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	eb ad                	jmp    800be6 <_pipeisclosed+0xe>
	}
}
  800c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 28             	sub    $0x28,%esp
  800c4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c50:	56                   	push   %esi
  800c51:	e8 09 f7 ff ff       	call   80035f <fd2data>
  800c56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c60:	eb 4b                	jmp    800cad <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c62:	89 da                	mov    %ebx,%edx
  800c64:	89 f0                	mov    %esi,%eax
  800c66:	e8 6d ff ff ff       	call   800bd8 <_pipeisclosed>
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	75 48                	jne    800cb7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c6f:	e8 cb f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c74:	8b 43 04             	mov    0x4(%ebx),%eax
  800c77:	8b 0b                	mov    (%ebx),%ecx
  800c79:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7c:	39 d0                	cmp    %edx,%eax
  800c7e:	73 e2                	jae    800c62 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c87:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8a:	89 c2                	mov    %eax,%edx
  800c8c:	c1 fa 1f             	sar    $0x1f,%edx
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	c1 e9 1b             	shr    $0x1b,%ecx
  800c94:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c97:	83 e2 1f             	and    $0x1f,%edx
  800c9a:	29 ca                	sub    %ecx,%edx
  800c9c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca4:	83 c0 01             	add    $0x1,%eax
  800ca7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800caa:	83 c7 01             	add    $0x1,%edi
  800cad:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb0:	75 c2                	jne    800c74 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	eb 05                	jmp    800cbc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 18             	sub    $0x18,%esp
  800ccd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd0:	57                   	push   %edi
  800cd1:	e8 89 f6 ff ff       	call   80035f <fd2data>
  800cd6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	eb 3d                	jmp    800d1f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce2:	85 db                	test   %ebx,%ebx
  800ce4:	74 04                	je     800cea <devpipe_read+0x26>
				return i;
  800ce6:	89 d8                	mov    %ebx,%eax
  800ce8:	eb 44                	jmp    800d2e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cea:	89 f2                	mov    %esi,%edx
  800cec:	89 f8                	mov    %edi,%eax
  800cee:	e8 e5 fe ff ff       	call   800bd8 <_pipeisclosed>
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	75 32                	jne    800d29 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf7:	e8 43 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cfc:	8b 06                	mov    (%esi),%eax
  800cfe:	3b 46 04             	cmp    0x4(%esi),%eax
  800d01:	74 df                	je     800ce2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d03:	99                   	cltd   
  800d04:	c1 ea 1b             	shr    $0x1b,%edx
  800d07:	01 d0                	add    %edx,%eax
  800d09:	83 e0 1f             	and    $0x1f,%eax
  800d0c:	29 d0                	sub    %edx,%eax
  800d0e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d19:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1c:	83 c3 01             	add    $0x1,%ebx
  800d1f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d22:	75 d8                	jne    800cfc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d24:	8b 45 10             	mov    0x10(%ebp),%eax
  800d27:	eb 05                	jmp    800d2e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d41:	50                   	push   %eax
  800d42:	e8 2f f6 ff ff       	call   800376 <fd_alloc>
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	89 c2                	mov    %eax,%edx
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	0f 88 2c 01 00 00    	js     800e80 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	68 07 04 00 00       	push   $0x407
  800d5c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5f:	6a 00                	push   $0x0
  800d61:	e8 f8 f3 ff ff       	call   80015e <sys_page_alloc>
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	0f 88 0d 01 00 00    	js     800e80 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d79:	50                   	push   %eax
  800d7a:	e8 f7 f5 ff ff       	call   800376 <fd_alloc>
  800d7f:	89 c3                	mov    %eax,%ebx
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	85 c0                	test   %eax,%eax
  800d86:	0f 88 e2 00 00 00    	js     800e6e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8c:	83 ec 04             	sub    $0x4,%esp
  800d8f:	68 07 04 00 00       	push   $0x407
  800d94:	ff 75 f0             	pushl  -0x10(%ebp)
  800d97:	6a 00                	push   $0x0
  800d99:	e8 c0 f3 ff ff       	call   80015e <sys_page_alloc>
  800d9e:	89 c3                	mov    %eax,%ebx
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	0f 88 c3 00 00 00    	js     800e6e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	ff 75 f4             	pushl  -0xc(%ebp)
  800db1:	e8 a9 f5 ff ff       	call   80035f <fd2data>
  800db6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db8:	83 c4 0c             	add    $0xc,%esp
  800dbb:	68 07 04 00 00       	push   $0x407
  800dc0:	50                   	push   %eax
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 96 f3 ff ff       	call   80015e <sys_page_alloc>
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	83 c4 10             	add    $0x10,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	0f 88 89 00 00 00    	js     800e5e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddb:	e8 7f f5 ff ff       	call   80035f <fd2data>
  800de0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de7:	50                   	push   %eax
  800de8:	6a 00                	push   $0x0
  800dea:	56                   	push   %esi
  800deb:	6a 00                	push   $0x0
  800ded:	e8 af f3 ff ff       	call   8001a1 <sys_page_map>
  800df2:	89 c3                	mov    %eax,%ebx
  800df4:	83 c4 20             	add    $0x20,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	78 55                	js     800e50 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e04:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e19:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2b:	e8 1f f5 ff ff       	call   80034f <fd2num>
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e35:	83 c4 04             	add    $0x4,%esp
  800e38:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3b:	e8 0f f5 ff ff       	call   80034f <fd2num>
  800e40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e43:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4e:	eb 30                	jmp    800e80 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	56                   	push   %esi
  800e54:	6a 00                	push   $0x0
  800e56:	e8 88 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e5b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e5e:	83 ec 08             	sub    $0x8,%esp
  800e61:	ff 75 f0             	pushl  -0x10(%ebp)
  800e64:	6a 00                	push   $0x0
  800e66:	e8 78 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e6b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e6e:	83 ec 08             	sub    $0x8,%esp
  800e71:	ff 75 f4             	pushl  -0xc(%ebp)
  800e74:	6a 00                	push   $0x0
  800e76:	e8 68 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e80:	89 d0                	mov    %edx,%eax
  800e82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e92:	50                   	push   %eax
  800e93:	ff 75 08             	pushl  0x8(%ebp)
  800e96:	e8 2a f5 ff ff       	call   8003c5 <fd_lookup>
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	78 18                	js     800eba <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea8:	e8 b2 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb2:	e8 21 fd ff ff       	call   800bd8 <_pipeisclosed>
  800eb7:	83 c4 10             	add    $0x10,%esp
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ecc:	68 56 1f 80 00       	push   $0x801f56
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	e8 43 08 00 00       	call   80171c <strcpy>
	return 0;
}
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eec:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef7:	eb 2d                	jmp    800f26 <devcons_write+0x46>
		m = n - tot;
  800ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800efe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f01:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f06:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f09:	83 ec 04             	sub    $0x4,%esp
  800f0c:	53                   	push   %ebx
  800f0d:	03 45 0c             	add    0xc(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	57                   	push   %edi
  800f12:	e8 97 09 00 00       	call   8018ae <memmove>
		sys_cputs(buf, m);
  800f17:	83 c4 08             	add    $0x8,%esp
  800f1a:	53                   	push   %ebx
  800f1b:	57                   	push   %edi
  800f1c:	e8 81 f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f21:	01 de                	add    %ebx,%esi
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	89 f0                	mov    %esi,%eax
  800f28:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2b:	72 cc                	jb     800ef9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f44:	74 2a                	je     800f70 <devcons_read+0x3b>
  800f46:	eb 05                	jmp    800f4d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f48:	e8 f2 f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f4d:	e8 6e f1 ff ff       	call   8000c0 <sys_cgetc>
  800f52:	85 c0                	test   %eax,%eax
  800f54:	74 f2                	je     800f48 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 16                	js     800f70 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f5a:	83 f8 04             	cmp    $0x4,%eax
  800f5d:	74 0c                	je     800f6b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f62:	88 02                	mov    %al,(%edx)
	return 1;
  800f64:	b8 01 00 00 00       	mov    $0x1,%eax
  800f69:	eb 05                	jmp    800f70 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f7e:	6a 01                	push   $0x1
  800f80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	e8 19 f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <getchar>:

int
getchar(void)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f94:	6a 01                	push   $0x1
  800f96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f99:	50                   	push   %eax
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 8a f6 ff ff       	call   80062b <read>
	if (r < 0)
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 0f                	js     800fb7 <getchar+0x29>
		return r;
	if (r < 1)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 06                	jle    800fb2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb0:	eb 05                	jmp    800fb7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	ff 75 08             	pushl  0x8(%ebp)
  800fc6:	e8 fa f3 ff ff       	call   8003c5 <fd_lookup>
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 11                	js     800fe3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdb:	39 10                	cmp    %edx,(%eax)
  800fdd:	0f 94 c0             	sete   %al
  800fe0:	0f b6 c0             	movzbl %al,%eax
}
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <opencons>:

int
opencons(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	e8 82 f3 ff ff       	call   800376 <fd_alloc>
  800ff4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 3e                	js     80103b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ffd:	83 ec 04             	sub    $0x4,%esp
  801000:	68 07 04 00 00       	push   $0x407
  801005:	ff 75 f4             	pushl  -0xc(%ebp)
  801008:	6a 00                	push   $0x0
  80100a:	e8 4f f1 ff ff       	call   80015e <sys_page_alloc>
  80100f:	83 c4 10             	add    $0x10,%esp
		return r;
  801012:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801014:	85 c0                	test   %eax,%eax
  801016:	78 23                	js     80103b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801018:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801021:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801023:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801026:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	50                   	push   %eax
  801031:	e8 19 f3 ff ff       	call   80034f <fd2num>
  801036:	89 c2                	mov    %eax,%edx
  801038:	83 c4 10             	add    $0x10,%esp
}
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	c9                   	leave  
  80103e:	c3                   	ret    

0080103f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801044:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801047:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104d:	e8 ce f0 ff ff       	call   800120 <sys_getenvid>
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	ff 75 0c             	pushl  0xc(%ebp)
  801058:	ff 75 08             	pushl  0x8(%ebp)
  80105b:	56                   	push   %esi
  80105c:	50                   	push   %eax
  80105d:	68 64 1f 80 00       	push   $0x801f64
  801062:	e8 b1 00 00 00       	call   801118 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801067:	83 c4 18             	add    $0x18,%esp
  80106a:	53                   	push   %ebx
  80106b:	ff 75 10             	pushl  0x10(%ebp)
  80106e:	e8 54 00 00 00       	call   8010c7 <vcprintf>
	cprintf("\n");
  801073:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  80107a:	e8 99 00 00 00       	call   801118 <cprintf>
  80107f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801082:	cc                   	int3   
  801083:	eb fd                	jmp    801082 <_panic+0x43>

00801085 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	53                   	push   %ebx
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108f:	8b 13                	mov    (%ebx),%edx
  801091:	8d 42 01             	lea    0x1(%edx),%eax
  801094:	89 03                	mov    %eax,(%ebx)
  801096:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801099:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a2:	75 1a                	jne    8010be <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	68 ff 00 00 00       	push   $0xff
  8010ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8010af:	50                   	push   %eax
  8010b0:	e8 ed ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010bb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d7:	00 00 00 
	b.cnt = 0;
  8010da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e4:	ff 75 0c             	pushl  0xc(%ebp)
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f0:	50                   	push   %eax
  8010f1:	68 85 10 80 00       	push   $0x801085
  8010f6:	e8 1a 01 00 00       	call   801215 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fb:	83 c4 08             	add    $0x8,%esp
  8010fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801104:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	e8 92 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801110:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80111e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801121:	50                   	push   %eax
  801122:	ff 75 08             	pushl  0x8(%ebp)
  801125:	e8 9d ff ff ff       	call   8010c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 1c             	sub    $0x1c,%esp
  801135:	89 c7                	mov    %eax,%edi
  801137:	89 d6                	mov    %edx,%esi
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801142:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801145:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801148:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801150:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801153:	39 d3                	cmp    %edx,%ebx
  801155:	72 05                	jb     80115c <printnum+0x30>
  801157:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115a:	77 45                	ja     8011a1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	ff 75 18             	pushl  0x18(%ebp)
  801162:	8b 45 14             	mov    0x14(%ebp),%eax
  801165:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801168:	53                   	push   %ebx
  801169:	ff 75 10             	pushl  0x10(%ebp)
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801172:	ff 75 e0             	pushl  -0x20(%ebp)
  801175:	ff 75 dc             	pushl  -0x24(%ebp)
  801178:	ff 75 d8             	pushl  -0x28(%ebp)
  80117b:	e8 30 0a 00 00       	call   801bb0 <__udivdi3>
  801180:	83 c4 18             	add    $0x18,%esp
  801183:	52                   	push   %edx
  801184:	50                   	push   %eax
  801185:	89 f2                	mov    %esi,%edx
  801187:	89 f8                	mov    %edi,%eax
  801189:	e8 9e ff ff ff       	call   80112c <printnum>
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	eb 18                	jmp    8011ab <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	56                   	push   %esi
  801197:	ff 75 18             	pushl  0x18(%ebp)
  80119a:	ff d7                	call   *%edi
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	eb 03                	jmp    8011a4 <printnum+0x78>
  8011a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a4:	83 eb 01             	sub    $0x1,%ebx
  8011a7:	85 db                	test   %ebx,%ebx
  8011a9:	7f e8                	jg     801193 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	56                   	push   %esi
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011be:	e8 1d 0b 00 00       	call   801ce0 <__umoddi3>
  8011c3:	83 c4 14             	add    $0x14,%esp
  8011c6:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011cd:	50                   	push   %eax
  8011ce:	ff d7                	call   *%edi
}
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e5:	8b 10                	mov    (%eax),%edx
  8011e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ea:	73 0a                	jae    8011f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ef:	89 08                	mov    %ecx,(%eax)
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	88 02                	mov    %al,(%edx)
}
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801201:	50                   	push   %eax
  801202:	ff 75 10             	pushl  0x10(%ebp)
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	ff 75 08             	pushl  0x8(%ebp)
  80120b:	e8 05 00 00 00       	call   801215 <vprintfmt>
	va_end(ap);
}
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 2c             	sub    $0x2c,%esp
  80121e:	8b 75 08             	mov    0x8(%ebp),%esi
  801221:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801224:	8b 7d 10             	mov    0x10(%ebp),%edi
  801227:	eb 12                	jmp    80123b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801229:	85 c0                	test   %eax,%eax
  80122b:	0f 84 42 04 00 00    	je     801673 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	53                   	push   %ebx
  801235:	50                   	push   %eax
  801236:	ff d6                	call   *%esi
  801238:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123b:	83 c7 01             	add    $0x1,%edi
  80123e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801242:	83 f8 25             	cmp    $0x25,%eax
  801245:	75 e2                	jne    801229 <vprintfmt+0x14>
  801247:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80124b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801252:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801259:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801260:	b9 00 00 00 00       	mov    $0x0,%ecx
  801265:	eb 07                	jmp    80126e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801267:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80126a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126e:	8d 47 01             	lea    0x1(%edi),%eax
  801271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801274:	0f b6 07             	movzbl (%edi),%eax
  801277:	0f b6 d0             	movzbl %al,%edx
  80127a:	83 e8 23             	sub    $0x23,%eax
  80127d:	3c 55                	cmp    $0x55,%al
  80127f:	0f 87 d3 03 00 00    	ja     801658 <vprintfmt+0x443>
  801285:	0f b6 c0             	movzbl %al,%eax
  801288:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80128f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801292:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801296:	eb d6                	jmp    80126e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012aa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012ad:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b0:	83 f9 09             	cmp    $0x9,%ecx
  8012b3:	77 3f                	ja     8012f4 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b8:	eb e9                	jmp    8012a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bd:	8b 00                	mov    (%eax),%eax
  8012bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c5:	8d 40 04             	lea    0x4(%eax),%eax
  8012c8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012ce:	eb 2a                	jmp    8012fa <vprintfmt+0xe5>
  8012d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012da:	0f 49 d0             	cmovns %eax,%edx
  8012dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e3:	eb 89                	jmp    80126e <vprintfmt+0x59>
  8012e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ef:	e9 7a ff ff ff       	jmp    80126e <vprintfmt+0x59>
  8012f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012fe:	0f 89 6a ff ff ff    	jns    80126e <vprintfmt+0x59>
				width = precision, precision = -1;
  801304:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801307:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80130a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801311:	e9 58 ff ff ff       	jmp    80126e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801316:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80131c:	e9 4d ff ff ff       	jmp    80126e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801321:	8b 45 14             	mov    0x14(%ebp),%eax
  801324:	8d 78 04             	lea    0x4(%eax),%edi
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	53                   	push   %ebx
  80132b:	ff 30                	pushl  (%eax)
  80132d:	ff d6                	call   *%esi
			break;
  80132f:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801332:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801338:	e9 fe fe ff ff       	jmp    80123b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133d:	8b 45 14             	mov    0x14(%ebp),%eax
  801340:	8d 78 04             	lea    0x4(%eax),%edi
  801343:	8b 00                	mov    (%eax),%eax
  801345:	99                   	cltd   
  801346:	31 d0                	xor    %edx,%eax
  801348:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134a:	83 f8 0f             	cmp    $0xf,%eax
  80134d:	7f 0b                	jg     80135a <vprintfmt+0x145>
  80134f:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  801356:	85 d2                	test   %edx,%edx
  801358:	75 1b                	jne    801375 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80135a:	50                   	push   %eax
  80135b:	68 9f 1f 80 00       	push   $0x801f9f
  801360:	53                   	push   %ebx
  801361:	56                   	push   %esi
  801362:	e8 91 fe ff ff       	call   8011f8 <printfmt>
  801367:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801370:	e9 c6 fe ff ff       	jmp    80123b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801375:	52                   	push   %edx
  801376:	68 1d 1f 80 00       	push   $0x801f1d
  80137b:	53                   	push   %ebx
  80137c:	56                   	push   %esi
  80137d:	e8 76 fe ff ff       	call   8011f8 <printfmt>
  801382:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801385:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80138b:	e9 ab fe ff ff       	jmp    80123b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801390:	8b 45 14             	mov    0x14(%ebp),%eax
  801393:	83 c0 04             	add    $0x4,%eax
  801396:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801399:	8b 45 14             	mov    0x14(%ebp),%eax
  80139c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80139e:	85 ff                	test   %edi,%edi
  8013a0:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  8013a5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ac:	0f 8e 94 00 00 00    	jle    801446 <vprintfmt+0x231>
  8013b2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b6:	0f 84 98 00 00 00    	je     801454 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c2:	57                   	push   %edi
  8013c3:	e8 33 03 00 00       	call   8016fb <strnlen>
  8013c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013cb:	29 c1                	sub    %eax,%ecx
  8013cd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013da:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013dd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013df:	eb 0f                	jmp    8013f0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	53                   	push   %ebx
  8013e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ea:	83 ef 01             	sub    $0x1,%edi
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 ff                	test   %edi,%edi
  8013f2:	7f ed                	jg     8013e1 <vprintfmt+0x1cc>
  8013f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013fa:	85 c9                	test   %ecx,%ecx
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	0f 49 c1             	cmovns %ecx,%eax
  801404:	29 c1                	sub    %eax,%ecx
  801406:	89 75 08             	mov    %esi,0x8(%ebp)
  801409:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80140c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80140f:	89 cb                	mov    %ecx,%ebx
  801411:	eb 4d                	jmp    801460 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801413:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801417:	74 1b                	je     801434 <vprintfmt+0x21f>
  801419:	0f be c0             	movsbl %al,%eax
  80141c:	83 e8 20             	sub    $0x20,%eax
  80141f:	83 f8 5e             	cmp    $0x5e,%eax
  801422:	76 10                	jbe    801434 <vprintfmt+0x21f>
					putch('?', putdat);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	ff 75 0c             	pushl  0xc(%ebp)
  80142a:	6a 3f                	push   $0x3f
  80142c:	ff 55 08             	call   *0x8(%ebp)
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	eb 0d                	jmp    801441 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	ff 75 0c             	pushl  0xc(%ebp)
  80143a:	52                   	push   %edx
  80143b:	ff 55 08             	call   *0x8(%ebp)
  80143e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801441:	83 eb 01             	sub    $0x1,%ebx
  801444:	eb 1a                	jmp    801460 <vprintfmt+0x24b>
  801446:	89 75 08             	mov    %esi,0x8(%ebp)
  801449:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801452:	eb 0c                	jmp    801460 <vprintfmt+0x24b>
  801454:	89 75 08             	mov    %esi,0x8(%ebp)
  801457:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801460:	83 c7 01             	add    $0x1,%edi
  801463:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801467:	0f be d0             	movsbl %al,%edx
  80146a:	85 d2                	test   %edx,%edx
  80146c:	74 23                	je     801491 <vprintfmt+0x27c>
  80146e:	85 f6                	test   %esi,%esi
  801470:	78 a1                	js     801413 <vprintfmt+0x1fe>
  801472:	83 ee 01             	sub    $0x1,%esi
  801475:	79 9c                	jns    801413 <vprintfmt+0x1fe>
  801477:	89 df                	mov    %ebx,%edi
  801479:	8b 75 08             	mov    0x8(%ebp),%esi
  80147c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147f:	eb 18                	jmp    801499 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	53                   	push   %ebx
  801485:	6a 20                	push   $0x20
  801487:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801489:	83 ef 01             	sub    $0x1,%edi
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	eb 08                	jmp    801499 <vprintfmt+0x284>
  801491:	89 df                	mov    %ebx,%edi
  801493:	8b 75 08             	mov    0x8(%ebp),%esi
  801496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801499:	85 ff                	test   %edi,%edi
  80149b:	7f e4                	jg     801481 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80149d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014a0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a6:	e9 90 fd ff ff       	jmp    80123b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ab:	83 f9 01             	cmp    $0x1,%ecx
  8014ae:	7e 19                	jle    8014c9 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b3:	8b 50 04             	mov    0x4(%eax),%edx
  8014b6:	8b 00                	mov    (%eax),%eax
  8014b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8d 40 08             	lea    0x8(%eax),%eax
  8014c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c7:	eb 38                	jmp    801501 <vprintfmt+0x2ec>
	else if (lflag)
  8014c9:	85 c9                	test   %ecx,%ecx
  8014cb:	74 1b                	je     8014e8 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d0:	8b 00                	mov    (%eax),%eax
  8014d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d5:	89 c1                	mov    %eax,%ecx
  8014d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e0:	8d 40 04             	lea    0x4(%eax),%eax
  8014e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e6:	eb 19                	jmp    801501 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8b 00                	mov    (%eax),%eax
  8014ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f0:	89 c1                	mov    %eax,%ecx
  8014f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fb:	8d 40 04             	lea    0x4(%eax),%eax
  8014fe:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801501:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801507:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80150c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801510:	0f 89 0e 01 00 00    	jns    801624 <vprintfmt+0x40f>
				putch('-', putdat);
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	53                   	push   %ebx
  80151a:	6a 2d                	push   $0x2d
  80151c:	ff d6                	call   *%esi
				num = -(long long) num;
  80151e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801521:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801524:	f7 da                	neg    %edx
  801526:	83 d1 00             	adc    $0x0,%ecx
  801529:	f7 d9                	neg    %ecx
  80152b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80152e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801533:	e9 ec 00 00 00       	jmp    801624 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801538:	83 f9 01             	cmp    $0x1,%ecx
  80153b:	7e 18                	jle    801555 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80153d:	8b 45 14             	mov    0x14(%ebp),%eax
  801540:	8b 10                	mov    (%eax),%edx
  801542:	8b 48 04             	mov    0x4(%eax),%ecx
  801545:	8d 40 08             	lea    0x8(%eax),%eax
  801548:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80154b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801550:	e9 cf 00 00 00       	jmp    801624 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801555:	85 c9                	test   %ecx,%ecx
  801557:	74 1a                	je     801573 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801559:	8b 45 14             	mov    0x14(%ebp),%eax
  80155c:	8b 10                	mov    (%eax),%edx
  80155e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801563:	8d 40 04             	lea    0x4(%eax),%eax
  801566:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156e:	e9 b1 00 00 00       	jmp    801624 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8b 10                	mov    (%eax),%edx
  801578:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157d:	8d 40 04             	lea    0x4(%eax),%eax
  801580:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801583:	b8 0a 00 00 00       	mov    $0xa,%eax
  801588:	e9 97 00 00 00       	jmp    801624 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 58                	push   $0x58
  801593:	ff d6                	call   *%esi
			putch('X', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 58                	push   $0x58
  80159b:	ff d6                	call   *%esi
			putch('X', putdat);
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	6a 58                	push   $0x58
  8015a3:	ff d6                	call   *%esi
			break;
  8015a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015ab:	e9 8b fc ff ff       	jmp    80123b <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 30                	push   $0x30
  8015b6:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	6a 78                	push   $0x78
  8015be:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c3:	8b 10                	mov    (%eax),%edx
  8015c5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015ca:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cd:	8d 40 04             	lea    0x4(%eax),%eax
  8015d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d8:	eb 4a                	jmp    801624 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015da:	83 f9 01             	cmp    $0x1,%ecx
  8015dd:	7e 15                	jle    8015f4 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015df:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e2:	8b 10                	mov    (%eax),%edx
  8015e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e7:	8d 40 08             	lea    0x8(%eax),%eax
  8015ea:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f2:	eb 30                	jmp    801624 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f4:	85 c9                	test   %ecx,%ecx
  8015f6:	74 17                	je     80160f <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fb:	8b 10                	mov    (%eax),%edx
  8015fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801602:	8d 40 04             	lea    0x4(%eax),%eax
  801605:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801608:	b8 10 00 00 00       	mov    $0x10,%eax
  80160d:	eb 15                	jmp    801624 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80160f:	8b 45 14             	mov    0x14(%ebp),%eax
  801612:	8b 10                	mov    (%eax),%edx
  801614:	b9 00 00 00 00       	mov    $0x0,%ecx
  801619:	8d 40 04             	lea    0x4(%eax),%eax
  80161c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801624:	83 ec 0c             	sub    $0xc,%esp
  801627:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80162b:	57                   	push   %edi
  80162c:	ff 75 e0             	pushl  -0x20(%ebp)
  80162f:	50                   	push   %eax
  801630:	51                   	push   %ecx
  801631:	52                   	push   %edx
  801632:	89 da                	mov    %ebx,%edx
  801634:	89 f0                	mov    %esi,%eax
  801636:	e8 f1 fa ff ff       	call   80112c <printnum>
			break;
  80163b:	83 c4 20             	add    $0x20,%esp
  80163e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801641:	e9 f5 fb ff ff       	jmp    80123b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	53                   	push   %ebx
  80164a:	52                   	push   %edx
  80164b:	ff d6                	call   *%esi
			break;
  80164d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801653:	e9 e3 fb ff ff       	jmp    80123b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	53                   	push   %ebx
  80165c:	6a 25                	push   $0x25
  80165e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	eb 03                	jmp    801668 <vprintfmt+0x453>
  801665:	83 ef 01             	sub    $0x1,%edi
  801668:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80166c:	75 f7                	jne    801665 <vprintfmt+0x450>
  80166e:	e9 c8 fb ff ff       	jmp    80123b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801676:	5b                   	pop    %ebx
  801677:	5e                   	pop    %esi
  801678:	5f                   	pop    %edi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 18             	sub    $0x18,%esp
  801681:	8b 45 08             	mov    0x8(%ebp),%eax
  801684:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801687:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80168a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80168e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801698:	85 c0                	test   %eax,%eax
  80169a:	74 26                	je     8016c2 <vsnprintf+0x47>
  80169c:	85 d2                	test   %edx,%edx
  80169e:	7e 22                	jle    8016c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a0:	ff 75 14             	pushl  0x14(%ebp)
  8016a3:	ff 75 10             	pushl  0x10(%ebp)
  8016a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	68 db 11 80 00       	push   $0x8011db
  8016af:	e8 61 fb ff ff       	call   801215 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb 05                	jmp    8016c7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d2:	50                   	push   %eax
  8016d3:	ff 75 10             	pushl  0x10(%ebp)
  8016d6:	ff 75 0c             	pushl  0xc(%ebp)
  8016d9:	ff 75 08             	pushl  0x8(%ebp)
  8016dc:	e8 9a ff ff ff       	call   80167b <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ee:	eb 03                	jmp    8016f3 <strlen+0x10>
		n++;
  8016f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f7:	75 f7                	jne    8016f0 <strlen+0xd>
		n++;
	return n;
}
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801701:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	eb 03                	jmp    80170e <strnlen+0x13>
		n++;
  80170b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170e:	39 c2                	cmp    %eax,%edx
  801710:	74 08                	je     80171a <strnlen+0x1f>
  801712:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801716:	75 f3                	jne    80170b <strnlen+0x10>
  801718:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801726:	89 c2                	mov    %eax,%edx
  801728:	83 c2 01             	add    $0x1,%edx
  80172b:	83 c1 01             	add    $0x1,%ecx
  80172e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801732:	88 5a ff             	mov    %bl,-0x1(%edx)
  801735:	84 db                	test   %bl,%bl
  801737:	75 ef                	jne    801728 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801739:	5b                   	pop    %ebx
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801743:	53                   	push   %ebx
  801744:	e8 9a ff ff ff       	call   8016e3 <strlen>
  801749:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	01 d8                	add    %ebx,%eax
  801751:	50                   	push   %eax
  801752:	e8 c5 ff ff ff       	call   80171c <strcpy>
	return dst;
}
  801757:	89 d8                	mov    %ebx,%eax
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	8b 75 08             	mov    0x8(%ebp),%esi
  801766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801769:	89 f3                	mov    %esi,%ebx
  80176b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176e:	89 f2                	mov    %esi,%edx
  801770:	eb 0f                	jmp    801781 <strncpy+0x23>
		*dst++ = *src;
  801772:	83 c2 01             	add    $0x1,%edx
  801775:	0f b6 01             	movzbl (%ecx),%eax
  801778:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80177b:	80 39 01             	cmpb   $0x1,(%ecx)
  80177e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801781:	39 da                	cmp    %ebx,%edx
  801783:	75 ed                	jne    801772 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801785:	89 f0                	mov    %esi,%eax
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	8b 75 08             	mov    0x8(%ebp),%esi
  801793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801796:	8b 55 10             	mov    0x10(%ebp),%edx
  801799:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80179b:	85 d2                	test   %edx,%edx
  80179d:	74 21                	je     8017c0 <strlcpy+0x35>
  80179f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a3:	89 f2                	mov    %esi,%edx
  8017a5:	eb 09                	jmp    8017b0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a7:	83 c2 01             	add    $0x1,%edx
  8017aa:	83 c1 01             	add    $0x1,%ecx
  8017ad:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017b0:	39 c2                	cmp    %eax,%edx
  8017b2:	74 09                	je     8017bd <strlcpy+0x32>
  8017b4:	0f b6 19             	movzbl (%ecx),%ebx
  8017b7:	84 db                	test   %bl,%bl
  8017b9:	75 ec                	jne    8017a7 <strlcpy+0x1c>
  8017bb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c0:	29 f0                	sub    %esi,%eax
}
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017cf:	eb 06                	jmp    8017d7 <strcmp+0x11>
		p++, q++;
  8017d1:	83 c1 01             	add    $0x1,%ecx
  8017d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d7:	0f b6 01             	movzbl (%ecx),%eax
  8017da:	84 c0                	test   %al,%al
  8017dc:	74 04                	je     8017e2 <strcmp+0x1c>
  8017de:	3a 02                	cmp    (%edx),%al
  8017e0:	74 ef                	je     8017d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e2:	0f b6 c0             	movzbl %al,%eax
  8017e5:	0f b6 12             	movzbl (%edx),%edx
  8017e8:	29 d0                	sub    %edx,%eax
}
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f6:	89 c3                	mov    %eax,%ebx
  8017f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017fb:	eb 06                	jmp    801803 <strncmp+0x17>
		n--, p++, q++;
  8017fd:	83 c0 01             	add    $0x1,%eax
  801800:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801803:	39 d8                	cmp    %ebx,%eax
  801805:	74 15                	je     80181c <strncmp+0x30>
  801807:	0f b6 08             	movzbl (%eax),%ecx
  80180a:	84 c9                	test   %cl,%cl
  80180c:	74 04                	je     801812 <strncmp+0x26>
  80180e:	3a 0a                	cmp    (%edx),%cl
  801810:	74 eb                	je     8017fd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801812:	0f b6 00             	movzbl (%eax),%eax
  801815:	0f b6 12             	movzbl (%edx),%edx
  801818:	29 d0                	sub    %edx,%eax
  80181a:	eb 05                	jmp    801821 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80181c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182e:	eb 07                	jmp    801837 <strchr+0x13>
		if (*s == c)
  801830:	38 ca                	cmp    %cl,%dl
  801832:	74 0f                	je     801843 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801834:	83 c0 01             	add    $0x1,%eax
  801837:	0f b6 10             	movzbl (%eax),%edx
  80183a:	84 d2                	test   %dl,%dl
  80183c:	75 f2                	jne    801830 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184f:	eb 03                	jmp    801854 <strfind+0xf>
  801851:	83 c0 01             	add    $0x1,%eax
  801854:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801857:	38 ca                	cmp    %cl,%dl
  801859:	74 04                	je     80185f <strfind+0x1a>
  80185b:	84 d2                	test   %dl,%dl
  80185d:	75 f2                	jne    801851 <strfind+0xc>
			break;
	return (char *) s;
}
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    

00801861 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	57                   	push   %edi
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80186d:	85 c9                	test   %ecx,%ecx
  80186f:	74 36                	je     8018a7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801871:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801877:	75 28                	jne    8018a1 <memset+0x40>
  801879:	f6 c1 03             	test   $0x3,%cl
  80187c:	75 23                	jne    8018a1 <memset+0x40>
		c &= 0xFF;
  80187e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801882:	89 d3                	mov    %edx,%ebx
  801884:	c1 e3 08             	shl    $0x8,%ebx
  801887:	89 d6                	mov    %edx,%esi
  801889:	c1 e6 18             	shl    $0x18,%esi
  80188c:	89 d0                	mov    %edx,%eax
  80188e:	c1 e0 10             	shl    $0x10,%eax
  801891:	09 f0                	or     %esi,%eax
  801893:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801895:	89 d8                	mov    %ebx,%eax
  801897:	09 d0                	or     %edx,%eax
  801899:	c1 e9 02             	shr    $0x2,%ecx
  80189c:	fc                   	cld    
  80189d:	f3 ab                	rep stos %eax,%es:(%edi)
  80189f:	eb 06                	jmp    8018a7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a4:	fc                   	cld    
  8018a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a7:	89 f8                	mov    %edi,%eax
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5f                   	pop    %edi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	57                   	push   %edi
  8018b2:	56                   	push   %esi
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018bc:	39 c6                	cmp    %eax,%esi
  8018be:	73 35                	jae    8018f5 <memmove+0x47>
  8018c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c3:	39 d0                	cmp    %edx,%eax
  8018c5:	73 2e                	jae    8018f5 <memmove+0x47>
		s += n;
		d += n;
  8018c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ca:	89 d6                	mov    %edx,%esi
  8018cc:	09 fe                	or     %edi,%esi
  8018ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d4:	75 13                	jne    8018e9 <memmove+0x3b>
  8018d6:	f6 c1 03             	test   $0x3,%cl
  8018d9:	75 0e                	jne    8018e9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018db:	83 ef 04             	sub    $0x4,%edi
  8018de:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e1:	c1 e9 02             	shr    $0x2,%ecx
  8018e4:	fd                   	std    
  8018e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e7:	eb 09                	jmp    8018f2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e9:	83 ef 01             	sub    $0x1,%edi
  8018ec:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ef:	fd                   	std    
  8018f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f2:	fc                   	cld    
  8018f3:	eb 1d                	jmp    801912 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f5:	89 f2                	mov    %esi,%edx
  8018f7:	09 c2                	or     %eax,%edx
  8018f9:	f6 c2 03             	test   $0x3,%dl
  8018fc:	75 0f                	jne    80190d <memmove+0x5f>
  8018fe:	f6 c1 03             	test   $0x3,%cl
  801901:	75 0a                	jne    80190d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801903:	c1 e9 02             	shr    $0x2,%ecx
  801906:	89 c7                	mov    %eax,%edi
  801908:	fc                   	cld    
  801909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190b:	eb 05                	jmp    801912 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190d:	89 c7                	mov    %eax,%edi
  80190f:	fc                   	cld    
  801910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801912:	5e                   	pop    %esi
  801913:	5f                   	pop    %edi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801919:	ff 75 10             	pushl  0x10(%ebp)
  80191c:	ff 75 0c             	pushl  0xc(%ebp)
  80191f:	ff 75 08             	pushl  0x8(%ebp)
  801922:	e8 87 ff ff ff       	call   8018ae <memmove>
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	56                   	push   %esi
  80192d:	53                   	push   %ebx
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 55 0c             	mov    0xc(%ebp),%edx
  801934:	89 c6                	mov    %eax,%esi
  801936:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801939:	eb 1a                	jmp    801955 <memcmp+0x2c>
		if (*s1 != *s2)
  80193b:	0f b6 08             	movzbl (%eax),%ecx
  80193e:	0f b6 1a             	movzbl (%edx),%ebx
  801941:	38 d9                	cmp    %bl,%cl
  801943:	74 0a                	je     80194f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801945:	0f b6 c1             	movzbl %cl,%eax
  801948:	0f b6 db             	movzbl %bl,%ebx
  80194b:	29 d8                	sub    %ebx,%eax
  80194d:	eb 0f                	jmp    80195e <memcmp+0x35>
		s1++, s2++;
  80194f:	83 c0 01             	add    $0x1,%eax
  801952:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801955:	39 f0                	cmp    %esi,%eax
  801957:	75 e2                	jne    80193b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801969:	89 c1                	mov    %eax,%ecx
  80196b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80196e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801972:	eb 0a                	jmp    80197e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801974:	0f b6 10             	movzbl (%eax),%edx
  801977:	39 da                	cmp    %ebx,%edx
  801979:	74 07                	je     801982 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197b:	83 c0 01             	add    $0x1,%eax
  80197e:	39 c8                	cmp    %ecx,%eax
  801980:	72 f2                	jb     801974 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801982:	5b                   	pop    %ebx
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    

00801985 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	57                   	push   %edi
  801989:	56                   	push   %esi
  80198a:	53                   	push   %ebx
  80198b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801991:	eb 03                	jmp    801996 <strtol+0x11>
		s++;
  801993:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801996:	0f b6 01             	movzbl (%ecx),%eax
  801999:	3c 20                	cmp    $0x20,%al
  80199b:	74 f6                	je     801993 <strtol+0xe>
  80199d:	3c 09                	cmp    $0x9,%al
  80199f:	74 f2                	je     801993 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a1:	3c 2b                	cmp    $0x2b,%al
  8019a3:	75 0a                	jne    8019af <strtol+0x2a>
		s++;
  8019a5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ad:	eb 11                	jmp    8019c0 <strtol+0x3b>
  8019af:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b4:	3c 2d                	cmp    $0x2d,%al
  8019b6:	75 08                	jne    8019c0 <strtol+0x3b>
		s++, neg = 1;
  8019b8:	83 c1 01             	add    $0x1,%ecx
  8019bb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c6:	75 15                	jne    8019dd <strtol+0x58>
  8019c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cb:	75 10                	jne    8019dd <strtol+0x58>
  8019cd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d1:	75 7c                	jne    801a4f <strtol+0xca>
		s += 2, base = 16;
  8019d3:	83 c1 02             	add    $0x2,%ecx
  8019d6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019db:	eb 16                	jmp    8019f3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019dd:	85 db                	test   %ebx,%ebx
  8019df:	75 12                	jne    8019f3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e9:	75 08                	jne    8019f3 <strtol+0x6e>
		s++, base = 8;
  8019eb:	83 c1 01             	add    $0x1,%ecx
  8019ee:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019fb:	0f b6 11             	movzbl (%ecx),%edx
  8019fe:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a01:	89 f3                	mov    %esi,%ebx
  801a03:	80 fb 09             	cmp    $0x9,%bl
  801a06:	77 08                	ja     801a10 <strtol+0x8b>
			dig = *s - '0';
  801a08:	0f be d2             	movsbl %dl,%edx
  801a0b:	83 ea 30             	sub    $0x30,%edx
  801a0e:	eb 22                	jmp    801a32 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a10:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a13:	89 f3                	mov    %esi,%ebx
  801a15:	80 fb 19             	cmp    $0x19,%bl
  801a18:	77 08                	ja     801a22 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a1a:	0f be d2             	movsbl %dl,%edx
  801a1d:	83 ea 57             	sub    $0x57,%edx
  801a20:	eb 10                	jmp    801a32 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a22:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a25:	89 f3                	mov    %esi,%ebx
  801a27:	80 fb 19             	cmp    $0x19,%bl
  801a2a:	77 16                	ja     801a42 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a2c:	0f be d2             	movsbl %dl,%edx
  801a2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a32:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a35:	7d 0b                	jge    801a42 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a37:	83 c1 01             	add    $0x1,%ecx
  801a3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a3e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a40:	eb b9                	jmp    8019fb <strtol+0x76>

	if (endptr)
  801a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a46:	74 0d                	je     801a55 <strtol+0xd0>
		*endptr = (char *) s;
  801a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4b:	89 0e                	mov    %ecx,(%esi)
  801a4d:	eb 06                	jmp    801a55 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4f:	85 db                	test   %ebx,%ebx
  801a51:	74 98                	je     8019eb <strtol+0x66>
  801a53:	eb 9e                	jmp    8019f3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a55:	89 c2                	mov    %eax,%edx
  801a57:	f7 da                	neg    %edx
  801a59:	85 ff                	test   %edi,%edi
  801a5b:	0f 45 c2             	cmovne %edx,%eax
}
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	5f                   	pop    %edi
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	57                   	push   %edi
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	83 ec 0c             	sub    $0xc,%esp
  801a6c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a75:	85 f6                	test   %esi,%esi
  801a77:	74 06                	je     801a7f <ipc_recv+0x1c>
		*from_env_store = 0;
  801a79:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a7f:	85 db                	test   %ebx,%ebx
  801a81:	74 06                	je     801a89 <ipc_recv+0x26>
		*perm_store = 0;
  801a83:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a89:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a8b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a90:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	50                   	push   %eax
  801a97:	e8 72 e8 ff ff       	call   80030e <sys_ipc_recv>
  801a9c:	89 c7                	mov    %eax,%edi
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	79 14                	jns    801ab9 <ipc_recv+0x56>
		cprintf("im dead");
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	68 80 22 80 00       	push   $0x802280
  801aad:	e8 66 f6 ff ff       	call   801118 <cprintf>
		return r;
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	89 f8                	mov    %edi,%eax
  801ab7:	eb 24                	jmp    801add <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ab9:	85 f6                	test   %esi,%esi
  801abb:	74 0a                	je     801ac7 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801abd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac2:	8b 40 74             	mov    0x74(%eax),%eax
  801ac5:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ac7:	85 db                	test   %ebx,%ebx
  801ac9:	74 0a                	je     801ad5 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801acb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad0:	8b 40 78             	mov    0x78(%eax),%eax
  801ad3:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801ad5:	a1 04 40 80 00       	mov    0x804004,%eax
  801ada:	8b 40 70             	mov    0x70(%eax),%eax
}
  801add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5f                   	pop    %edi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	57                   	push   %edi
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801af7:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801afe:	0f 44 d8             	cmove  %eax,%ebx
  801b01:	eb 1c                	jmp    801b1f <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b06:	74 12                	je     801b1a <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b08:	50                   	push   %eax
  801b09:	68 88 22 80 00       	push   $0x802288
  801b0e:	6a 4e                	push   $0x4e
  801b10:	68 95 22 80 00       	push   $0x802295
  801b15:	e8 25 f5 ff ff       	call   80103f <_panic>
		sys_yield();
  801b1a:	e8 20 e6 ff ff       	call   80013f <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b1f:	ff 75 14             	pushl  0x14(%ebp)
  801b22:	53                   	push   %ebx
  801b23:	56                   	push   %esi
  801b24:	57                   	push   %edi
  801b25:	e8 c1 e7 ff ff       	call   8002eb <sys_ipc_try_send>
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 d2                	js     801b03 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b44:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b47:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b4d:	8b 52 50             	mov    0x50(%edx),%edx
  801b50:	39 ca                	cmp    %ecx,%edx
  801b52:	75 0d                	jne    801b61 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b54:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b57:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5c:	8b 40 48             	mov    0x48(%eax),%eax
  801b5f:	eb 0f                	jmp    801b70 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b61:	83 c0 01             	add    $0x1,%eax
  801b64:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b69:	75 d9                	jne    801b44 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b78:	89 d0                	mov    %edx,%eax
  801b7a:	c1 e8 16             	shr    $0x16,%eax
  801b7d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b89:	f6 c1 01             	test   $0x1,%cl
  801b8c:	74 1d                	je     801bab <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b8e:	c1 ea 0c             	shr    $0xc,%edx
  801b91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b98:	f6 c2 01             	test   $0x1,%dl
  801b9b:	74 0e                	je     801bab <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b9d:	c1 ea 0c             	shr    $0xc,%edx
  801ba0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba7:	ef 
  801ba8:	0f b7 c0             	movzwl %ax,%eax
}
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    
  801bad:	66 90                	xchg   %ax,%ax
  801baf:	90                   	nop

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
