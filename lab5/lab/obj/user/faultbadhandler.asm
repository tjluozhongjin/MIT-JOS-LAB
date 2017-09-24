
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 6a 1e 80 00       	push   $0x801e6a
  80012f:	6a 23                	push   $0x23
  800131:	68 87 1e 80 00       	push   $0x801e87
  800136:	e8 27 0f 00 00       	call   801062 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 6a 1e 80 00       	push   $0x801e6a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 87 1e 80 00       	push   $0x801e87
  8001b7:	e8 a6 0e 00 00       	call   801062 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 6a 1e 80 00       	push   $0x801e6a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 87 1e 80 00       	push   $0x801e87
  8001f9:	e8 64 0e 00 00       	call   801062 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 6a 1e 80 00       	push   $0x801e6a
  800234:	6a 23                	push   $0x23
  800236:	68 87 1e 80 00       	push   $0x801e87
  80023b:	e8 22 0e 00 00       	call   801062 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 6a 1e 80 00       	push   $0x801e6a
  800276:	6a 23                	push   $0x23
  800278:	68 87 1e 80 00       	push   $0x801e87
  80027d:	e8 e0 0d 00 00       	call   801062 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 6a 1e 80 00       	push   $0x801e6a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 87 1e 80 00       	push   $0x801e87
  8002bf:	e8 9e 0d 00 00       	call   801062 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 6a 1e 80 00       	push   $0x801e6a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 87 1e 80 00       	push   $0x801e87
  800301:	e8 5c 0d 00 00       	call   801062 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 6a 1e 80 00       	push   $0x801e6a
  80035e:	6a 23                	push   $0x23
  800360:	68 87 1e 80 00       	push   $0x801e87
  800365:	e8 f8 0c 00 00       	call   801062 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 98 1e 80 00       	push   $0x801e98
  800479:	e8 bd 0c 00 00       	call   80113b <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 d9 1e 80 00       	push   $0x801ed9
  8006a3:	e8 93 0a 00 00       	call   80113b <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 f5 1e 80 00       	push   $0x801ef5
  800778:	e8 be 09 00 00       	call   80113b <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 b8 1e 80 00       	push   $0x801eb8
  80082d:	e8 09 09 00 00       	call   80113b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 e9 01 00 00       	call   800adf <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 1f 12 00 00       	call   801b5c <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 b0 11 00 00       	call   801b08 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 21 11 00 00       	call   801a86 <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 51 0d 00 00       	call   80173f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a1f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a24:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a2d:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a33:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a38:	50                   	push   %eax
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	68 08 50 80 00       	push   $0x805008
  800a41:	e8 8b 0e 00 00       	call   8018d1 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a50:	e8 cc fe ff ff       	call   800921 <fsipc>
            return r;

    return r;
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 40 0c             	mov    0xc(%eax),%eax
  800a65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6a:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7a:	e8 a2 fe ff ff       	call   800921 <fsipc>
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	85 c0                	test   %eax,%eax
  800a83:	78 51                	js     800ad6 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	73 19                	jae    800aa2 <devfile_read+0x4b>
  800a89:	68 24 1f 80 00       	push   $0x801f24
  800a8e:	68 2b 1f 80 00       	push   $0x801f2b
  800a93:	68 82 00 00 00       	push   $0x82
  800a98:	68 40 1f 80 00       	push   $0x801f40
  800a9d:	e8 c0 05 00 00       	call   801062 <_panic>
	assert(r <= PGSIZE);
  800aa2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa7:	7e 19                	jle    800ac2 <devfile_read+0x6b>
  800aa9:	68 4b 1f 80 00       	push   $0x801f4b
  800aae:	68 2b 1f 80 00       	push   $0x801f2b
  800ab3:	68 83 00 00 00       	push   $0x83
  800ab8:	68 40 1f 80 00       	push   $0x801f40
  800abd:	e8 a0 05 00 00       	call   801062 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac2:	83 ec 04             	sub    $0x4,%esp
  800ac5:	50                   	push   %eax
  800ac6:	68 00 50 80 00       	push   $0x805000
  800acb:	ff 75 0c             	pushl  0xc(%ebp)
  800ace:	e8 fe 0d 00 00       	call   8018d1 <memmove>
	return r;
  800ad3:	83 c4 10             	add    $0x10,%esp
}
  800ad6:	89 d8                	mov    %ebx,%eax
  800ad8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 20             	sub    $0x20,%esp
  800ae6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae9:	53                   	push   %ebx
  800aea:	e8 17 0c 00 00       	call   801706 <strlen>
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af7:	7f 67                	jg     800b60 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aff:	50                   	push   %eax
  800b00:	e8 94 f8 ff ff       	call   800399 <fd_alloc>
  800b05:	83 c4 10             	add    $0x10,%esp
		return r;
  800b08:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	78 57                	js     800b65 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	53                   	push   %ebx
  800b12:	68 00 50 80 00       	push   $0x805000
  800b17:	e8 23 0c 00 00       	call   80173f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	e8 f0 fd ff ff       	call   800921 <fsipc>
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	85 c0                	test   %eax,%eax
  800b38:	79 14                	jns    800b4e <open+0x6f>
		fd_close(fd, 0);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	6a 00                	push   $0x0
  800b3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b42:	e8 4a f9 ff ff       	call   800491 <fd_close>
		return r;
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	89 da                	mov    %ebx,%edx
  800b4c:	eb 17                	jmp    800b65 <open+0x86>
	}

	return fd2num(fd);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	ff 75 f4             	pushl  -0xc(%ebp)
  800b54:	e8 19 f8 ff ff       	call   800372 <fd2num>
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	eb 05                	jmp    800b65 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b60:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b65:	89 d0                	mov    %edx,%eax
  800b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7c:	e8 a0 fd ff ff       	call   800921 <fsipc>
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 ec f7 ff ff       	call   800382 <fd2data>
  800b96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b98:	83 c4 08             	add    $0x8,%esp
  800b9b:	68 57 1f 80 00       	push   $0x801f57
  800ba0:	53                   	push   %ebx
  800ba1:	e8 99 0b 00 00       	call   80173f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba6:	8b 46 04             	mov    0x4(%esi),%eax
  800ba9:	2b 06                	sub    (%esi),%eax
  800bab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb8:	00 00 00 
	stat->st_dev = &devpipe;
  800bbb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc2:	30 80 00 
	return 0;
}
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bdb:	53                   	push   %ebx
  800bdc:	6a 00                	push   $0x0
  800bde:	e8 23 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be3:	89 1c 24             	mov    %ebx,(%esp)
  800be6:	e8 97 f7 ff ff       	call   800382 <fd2data>
  800beb:	83 c4 08             	add    $0x8,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 00                	push   $0x0
  800bf1:	e8 10 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 1c             	sub    $0x1c,%esp
  800c04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c07:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c09:	a1 04 40 80 00       	mov    0x804004,%eax
  800c0e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	ff 75 e0             	pushl  -0x20(%ebp)
  800c17:	e8 79 0f 00 00       	call   801b95 <pageref>
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	89 3c 24             	mov    %edi,(%esp)
  800c21:	e8 6f 0f 00 00       	call   801b95 <pageref>
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	39 c3                	cmp    %eax,%ebx
  800c2b:	0f 94 c1             	sete   %cl
  800c2e:	0f b6 c9             	movzbl %cl,%ecx
  800c31:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c34:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c3a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3d:	39 ce                	cmp    %ecx,%esi
  800c3f:	74 1b                	je     800c5c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c41:	39 c3                	cmp    %eax,%ebx
  800c43:	75 c4                	jne    800c09 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c45:	8b 42 58             	mov    0x58(%edx),%eax
  800c48:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c4b:	50                   	push   %eax
  800c4c:	56                   	push   %esi
  800c4d:	68 5e 1f 80 00       	push   $0x801f5e
  800c52:	e8 e4 04 00 00       	call   80113b <cprintf>
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	eb ad                	jmp    800c09 <_pipeisclosed+0xe>
	}
}
  800c5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 28             	sub    $0x28,%esp
  800c70:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c73:	56                   	push   %esi
  800c74:	e8 09 f7 ff ff       	call   800382 <fd2data>
  800c79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c83:	eb 4b                	jmp    800cd0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c85:	89 da                	mov    %ebx,%edx
  800c87:	89 f0                	mov    %esi,%eax
  800c89:	e8 6d ff ff ff       	call   800bfb <_pipeisclosed>
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	75 48                	jne    800cda <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c92:	e8 cb f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c97:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9a:	8b 0b                	mov    (%ebx),%ecx
  800c9c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9f:	39 d0                	cmp    %edx,%eax
  800ca1:	73 e2                	jae    800c85 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800caa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	c1 fa 1f             	sar    $0x1f,%edx
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cba:	83 e2 1f             	and    $0x1f,%edx
  800cbd:	29 ca                	sub    %ecx,%edx
  800cbf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccd:	83 c7 01             	add    $0x1,%edi
  800cd0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd3:	75 c2                	jne    800c97 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd8:	eb 05                	jmp    800cdf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 18             	sub    $0x18,%esp
  800cf0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf3:	57                   	push   %edi
  800cf4:	e8 89 f6 ff ff       	call   800382 <fd2data>
  800cf9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	eb 3d                	jmp    800d42 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d05:	85 db                	test   %ebx,%ebx
  800d07:	74 04                	je     800d0d <devpipe_read+0x26>
				return i;
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	eb 44                	jmp    800d51 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	e8 e5 fe ff ff       	call   800bfb <_pipeisclosed>
  800d16:	85 c0                	test   %eax,%eax
  800d18:	75 32                	jne    800d4c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d1a:	e8 43 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d1f:	8b 06                	mov    (%esi),%eax
  800d21:	3b 46 04             	cmp    0x4(%esi),%eax
  800d24:	74 df                	je     800d05 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d26:	99                   	cltd   
  800d27:	c1 ea 1b             	shr    $0x1b,%edx
  800d2a:	01 d0                	add    %edx,%eax
  800d2c:	83 e0 1f             	and    $0x1f,%eax
  800d2f:	29 d0                	sub    %edx,%eax
  800d31:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d3c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3f:	83 c3 01             	add    $0x1,%ebx
  800d42:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d45:	75 d8                	jne    800d1f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	eb 05                	jmp    800d51 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d4c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d64:	50                   	push   %eax
  800d65:	e8 2f f6 ff ff       	call   800399 <fd_alloc>
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 2c 01 00 00    	js     800ea3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d77:	83 ec 04             	sub    $0x4,%esp
  800d7a:	68 07 04 00 00       	push   $0x407
  800d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d82:	6a 00                	push   $0x0
  800d84:	e8 f8 f3 ff ff       	call   800181 <sys_page_alloc>
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 0d 01 00 00    	js     800ea3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9c:	50                   	push   %eax
  800d9d:	e8 f7 f5 ff ff       	call   800399 <fd_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 e2 00 00 00    	js     800e91 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	68 07 04 00 00       	push   $0x407
  800db7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 c0 f3 ff ff       	call   800181 <sys_page_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 c3 00 00 00    	js     800e91 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd4:	e8 a9 f5 ff ff       	call   800382 <fd2data>
  800dd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 c4 0c             	add    $0xc,%esp
  800dde:	68 07 04 00 00       	push   $0x407
  800de3:	50                   	push   %eax
  800de4:	6a 00                	push   $0x0
  800de6:	e8 96 f3 ff ff       	call   800181 <sys_page_alloc>
  800deb:	89 c3                	mov    %eax,%ebx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	0f 88 89 00 00 00    	js     800e81 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfe:	e8 7f f5 ff ff       	call   800382 <fd2data>
  800e03:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0a:	50                   	push   %eax
  800e0b:	6a 00                	push   $0x0
  800e0d:	56                   	push   %esi
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 af f3 ff ff       	call   8001c4 <sys_page_map>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	78 55                	js     800e73 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e27:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	e8 1f f5 ff ff       	call   800372 <fd2num>
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e58:	83 c4 04             	add    $0x4,%esp
  800e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5e:	e8 0f f5 ff ff       	call   800372 <fd2num>
  800e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e66:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e71:	eb 30                	jmp    800ea3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	56                   	push   %esi
  800e77:	6a 00                	push   $0x0
  800e79:	e8 88 f3 ff ff       	call   800206 <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	ff 75 f0             	pushl  -0x10(%ebp)
  800e87:	6a 00                	push   $0x0
  800e89:	e8 78 f3 ff ff       	call   800206 <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	6a 00                	push   $0x0
  800e99:	e8 68 f3 ff ff       	call   800206 <sys_page_unmap>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea3:	89 d0                	mov    %edx,%eax
  800ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	ff 75 08             	pushl  0x8(%ebp)
  800eb9:	e8 2a f5 ff ff       	call   8003e8 <fd_lookup>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	78 18                	js     800edd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecb:	e8 b2 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed5:	e8 21 fd ff ff       	call   800bfb <_pipeisclosed>
  800eda:	83 c4 10             	add    $0x10,%esp
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eef:	68 76 1f 80 00       	push   $0x801f76
  800ef4:	ff 75 0c             	pushl  0xc(%ebp)
  800ef7:	e8 43 08 00 00       	call   80173f <strcpy>
	return 0;
}
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f14:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1a:	eb 2d                	jmp    800f49 <devcons_write+0x46>
		m = n - tot;
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f21:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f24:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f29:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	53                   	push   %ebx
  800f30:	03 45 0c             	add    0xc(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	57                   	push   %edi
  800f35:	e8 97 09 00 00       	call   8018d1 <memmove>
		sys_cputs(buf, m);
  800f3a:	83 c4 08             	add    $0x8,%esp
  800f3d:	53                   	push   %ebx
  800f3e:	57                   	push   %edi
  800f3f:	e8 81 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f44:	01 de                	add    %ebx,%esi
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f4e:	72 cc                	jb     800f1c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f67:	74 2a                	je     800f93 <devcons_read+0x3b>
  800f69:	eb 05                	jmp    800f70 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f6b:	e8 f2 f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f70:	e8 6e f1 ff ff       	call   8000e3 <sys_cgetc>
  800f75:	85 c0                	test   %eax,%eax
  800f77:	74 f2                	je     800f6b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 16                	js     800f93 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f7d:	83 f8 04             	cmp    $0x4,%eax
  800f80:	74 0c                	je     800f8e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f85:	88 02                	mov    %al,(%edx)
	return 1;
  800f87:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8c:	eb 05                	jmp    800f93 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa1:	6a 01                	push   $0x1
  800fa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	e8 19 f1 ff ff       	call   8000c5 <sys_cputs>
}
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <getchar>:

int
getchar(void)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb7:	6a 01                	push   $0x1
  800fb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 8a f6 ff ff       	call   80064e <read>
	if (r < 0)
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 0f                	js     800fda <getchar+0x29>
		return r;
	if (r < 1)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	7e 06                	jle    800fd5 <getchar+0x24>
		return -E_EOF;
	return c;
  800fcf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd3:	eb 05                	jmp    800fda <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fd5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 fa f3 ff ff       	call   8003e8 <fd_lookup>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 11                	js     801006 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ffe:	39 10                	cmp    %edx,(%eax)
  801000:	0f 94 c0             	sete   %al
  801003:	0f b6 c0             	movzbl %al,%eax
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <opencons>:

int
opencons(void)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	e8 82 f3 ff ff       	call   800399 <fd_alloc>
  801017:	83 c4 10             	add    $0x10,%esp
		return r;
  80101a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 3e                	js     80105e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	68 07 04 00 00       	push   $0x407
  801028:	ff 75 f4             	pushl  -0xc(%ebp)
  80102b:	6a 00                	push   $0x0
  80102d:	e8 4f f1 ff ff       	call   800181 <sys_page_alloc>
  801032:	83 c4 10             	add    $0x10,%esp
		return r;
  801035:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	78 23                	js     80105e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80103b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801044:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801049:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	50                   	push   %eax
  801054:	e8 19 f3 ff ff       	call   800372 <fd2num>
  801059:	89 c2                	mov    %eax,%edx
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	89 d0                	mov    %edx,%eax
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801067:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80106a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801070:	e8 ce f0 ff ff       	call   800143 <sys_getenvid>
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	ff 75 0c             	pushl  0xc(%ebp)
  80107b:	ff 75 08             	pushl  0x8(%ebp)
  80107e:	56                   	push   %esi
  80107f:	50                   	push   %eax
  801080:	68 84 1f 80 00       	push   $0x801f84
  801085:	e8 b1 00 00 00       	call   80113b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80108a:	83 c4 18             	add    $0x18,%esp
  80108d:	53                   	push   %ebx
  80108e:	ff 75 10             	pushl  0x10(%ebp)
  801091:	e8 54 00 00 00       	call   8010ea <vcprintf>
	cprintf("\n");
  801096:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  80109d:	e8 99 00 00 00       	call   80113b <cprintf>
  8010a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a5:	cc                   	int3   
  8010a6:	eb fd                	jmp    8010a5 <_panic+0x43>

008010a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b2:	8b 13                	mov    (%ebx),%edx
  8010b4:	8d 42 01             	lea    0x1(%edx),%eax
  8010b7:	89 03                	mov    %eax,(%ebx)
  8010b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c5:	75 1a                	jne    8010e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	68 ff 00 00 00       	push   $0xff
  8010cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d2:	50                   	push   %eax
  8010d3:	e8 ed ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010fa:	00 00 00 
	b.cnt = 0;
  8010fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801107:	ff 75 0c             	pushl  0xc(%ebp)
  80110a:	ff 75 08             	pushl  0x8(%ebp)
  80110d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	68 a8 10 80 00       	push   $0x8010a8
  801119:	e8 1a 01 00 00       	call   801238 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	e8 92 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801144:	50                   	push   %eax
  801145:	ff 75 08             	pushl  0x8(%ebp)
  801148:	e8 9d ff ff ff       	call   8010ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 1c             	sub    $0x1c,%esp
  801158:	89 c7                	mov    %eax,%edi
  80115a:	89 d6                	mov    %edx,%esi
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801165:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801168:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801170:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801173:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801176:	39 d3                	cmp    %edx,%ebx
  801178:	72 05                	jb     80117f <printnum+0x30>
  80117a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80117d:	77 45                	ja     8011c4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	ff 75 18             	pushl  0x18(%ebp)
  801185:	8b 45 14             	mov    0x14(%ebp),%eax
  801188:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80118b:	53                   	push   %ebx
  80118c:	ff 75 10             	pushl  0x10(%ebp)
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	ff 75 e4             	pushl  -0x1c(%ebp)
  801195:	ff 75 e0             	pushl  -0x20(%ebp)
  801198:	ff 75 dc             	pushl  -0x24(%ebp)
  80119b:	ff 75 d8             	pushl  -0x28(%ebp)
  80119e:	e8 2d 0a 00 00       	call   801bd0 <__udivdi3>
  8011a3:	83 c4 18             	add    $0x18,%esp
  8011a6:	52                   	push   %edx
  8011a7:	50                   	push   %eax
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	89 f8                	mov    %edi,%eax
  8011ac:	e8 9e ff ff ff       	call   80114f <printnum>
  8011b1:	83 c4 20             	add    $0x20,%esp
  8011b4:	eb 18                	jmp    8011ce <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	56                   	push   %esi
  8011ba:	ff 75 18             	pushl  0x18(%ebp)
  8011bd:	ff d7                	call   *%edi
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	eb 03                	jmp    8011c7 <printnum+0x78>
  8011c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c7:	83 eb 01             	sub    $0x1,%ebx
  8011ca:	85 db                	test   %ebx,%ebx
  8011cc:	7f e8                	jg     8011b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	56                   	push   %esi
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011db:	ff 75 dc             	pushl  -0x24(%ebp)
  8011de:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e1:	e8 1a 0b 00 00       	call   801d00 <__umoddi3>
  8011e6:	83 c4 14             	add    $0x14,%esp
  8011e9:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011f0:	50                   	push   %eax
  8011f1:	ff d7                	call   *%edi
}
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801204:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801208:	8b 10                	mov    (%eax),%edx
  80120a:	3b 50 04             	cmp    0x4(%eax),%edx
  80120d:	73 0a                	jae    801219 <sprintputch+0x1b>
		*b->buf++ = ch;
  80120f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801212:	89 08                	mov    %ecx,(%eax)
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	88 02                	mov    %al,(%edx)
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801221:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801224:	50                   	push   %eax
  801225:	ff 75 10             	pushl  0x10(%ebp)
  801228:	ff 75 0c             	pushl  0xc(%ebp)
  80122b:	ff 75 08             	pushl  0x8(%ebp)
  80122e:	e8 05 00 00 00       	call   801238 <vprintfmt>
	va_end(ap);
}
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	57                   	push   %edi
  80123c:	56                   	push   %esi
  80123d:	53                   	push   %ebx
  80123e:	83 ec 2c             	sub    $0x2c,%esp
  801241:	8b 75 08             	mov    0x8(%ebp),%esi
  801244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801247:	8b 7d 10             	mov    0x10(%ebp),%edi
  80124a:	eb 12                	jmp    80125e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80124c:	85 c0                	test   %eax,%eax
  80124e:	0f 84 42 04 00 00    	je     801696 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	53                   	push   %ebx
  801258:	50                   	push   %eax
  801259:	ff d6                	call   *%esi
  80125b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80125e:	83 c7 01             	add    $0x1,%edi
  801261:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801265:	83 f8 25             	cmp    $0x25,%eax
  801268:	75 e2                	jne    80124c <vprintfmt+0x14>
  80126a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80126e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801275:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80127c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801283:	b9 00 00 00 00       	mov    $0x0,%ecx
  801288:	eb 07                	jmp    801291 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80128d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801291:	8d 47 01             	lea    0x1(%edi),%eax
  801294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801297:	0f b6 07             	movzbl (%edi),%eax
  80129a:	0f b6 d0             	movzbl %al,%edx
  80129d:	83 e8 23             	sub    $0x23,%eax
  8012a0:	3c 55                	cmp    $0x55,%al
  8012a2:	0f 87 d3 03 00 00    	ja     80167b <vprintfmt+0x443>
  8012a8:	0f b6 c0             	movzbl %al,%eax
  8012ab:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  8012b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012b5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012b9:	eb d6                	jmp    801291 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012cd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012d3:	83 f9 09             	cmp    $0x9,%ecx
  8012d6:	77 3f                	ja     801317 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012db:	eb e9                	jmp    8012c6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e0:	8b 00                	mov    (%eax),%eax
  8012e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e8:	8d 40 04             	lea    0x4(%eax),%eax
  8012eb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f1:	eb 2a                	jmp    80131d <vprintfmt+0xe5>
  8012f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fd:	0f 49 d0             	cmovns %eax,%edx
  801300:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801306:	eb 89                	jmp    801291 <vprintfmt+0x59>
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80130b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801312:	e9 7a ff ff ff       	jmp    801291 <vprintfmt+0x59>
  801317:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80131a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80131d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801321:	0f 89 6a ff ff ff    	jns    801291 <vprintfmt+0x59>
				width = precision, precision = -1;
  801327:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80132a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80132d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801334:	e9 58 ff ff ff       	jmp    801291 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801339:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80133f:	e9 4d ff ff ff       	jmp    801291 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801344:	8b 45 14             	mov    0x14(%ebp),%eax
  801347:	8d 78 04             	lea    0x4(%eax),%edi
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	53                   	push   %ebx
  80134e:	ff 30                	pushl  (%eax)
  801350:	ff d6                	call   *%esi
			break;
  801352:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801355:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80135b:	e9 fe fe ff ff       	jmp    80125e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801360:	8b 45 14             	mov    0x14(%ebp),%eax
  801363:	8d 78 04             	lea    0x4(%eax),%edi
  801366:	8b 00                	mov    (%eax),%eax
  801368:	99                   	cltd   
  801369:	31 d0                	xor    %edx,%eax
  80136b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80136d:	83 f8 0f             	cmp    $0xf,%eax
  801370:	7f 0b                	jg     80137d <vprintfmt+0x145>
  801372:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801379:	85 d2                	test   %edx,%edx
  80137b:	75 1b                	jne    801398 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80137d:	50                   	push   %eax
  80137e:	68 bf 1f 80 00       	push   $0x801fbf
  801383:	53                   	push   %ebx
  801384:	56                   	push   %esi
  801385:	e8 91 fe ff ff       	call   80121b <printfmt>
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
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801393:	e9 c6 fe ff ff       	jmp    80125e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801398:	52                   	push   %edx
  801399:	68 3d 1f 80 00       	push   $0x801f3d
  80139e:	53                   	push   %ebx
  80139f:	56                   	push   %esi
  8013a0:	e8 76 fe ff ff       	call   80121b <printfmt>
  8013a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013a8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ae:	e9 ab fe ff ff       	jmp    80125e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b6:	83 c0 04             	add    $0x4,%eax
  8013b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c1:	85 ff                	test   %edi,%edi
  8013c3:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  8013c8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013cf:	0f 8e 94 00 00 00    	jle    801469 <vprintfmt+0x231>
  8013d5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d9:	0f 84 98 00 00 00    	je     801477 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	ff 75 d0             	pushl  -0x30(%ebp)
  8013e5:	57                   	push   %edi
  8013e6:	e8 33 03 00 00       	call   80171e <strnlen>
  8013eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ee:	29 c1                	sub    %eax,%ecx
  8013f0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801400:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801402:	eb 0f                	jmp    801413 <vprintfmt+0x1db>
					putch(padc, putdat);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	53                   	push   %ebx
  801408:	ff 75 e0             	pushl  -0x20(%ebp)
  80140b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140d:	83 ef 01             	sub    $0x1,%edi
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 ff                	test   %edi,%edi
  801415:	7f ed                	jg     801404 <vprintfmt+0x1cc>
  801417:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80141a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80141d:	85 c9                	test   %ecx,%ecx
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
  801424:	0f 49 c1             	cmovns %ecx,%eax
  801427:	29 c1                	sub    %eax,%ecx
  801429:	89 75 08             	mov    %esi,0x8(%ebp)
  80142c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80142f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801432:	89 cb                	mov    %ecx,%ebx
  801434:	eb 4d                	jmp    801483 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801436:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80143a:	74 1b                	je     801457 <vprintfmt+0x21f>
  80143c:	0f be c0             	movsbl %al,%eax
  80143f:	83 e8 20             	sub    $0x20,%eax
  801442:	83 f8 5e             	cmp    $0x5e,%eax
  801445:	76 10                	jbe    801457 <vprintfmt+0x21f>
					putch('?', putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	6a 3f                	push   $0x3f
  80144f:	ff 55 08             	call   *0x8(%ebp)
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb 0d                	jmp    801464 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	ff 75 0c             	pushl  0xc(%ebp)
  80145d:	52                   	push   %edx
  80145e:	ff 55 08             	call   *0x8(%ebp)
  801461:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801464:	83 eb 01             	sub    $0x1,%ebx
  801467:	eb 1a                	jmp    801483 <vprintfmt+0x24b>
  801469:	89 75 08             	mov    %esi,0x8(%ebp)
  80146c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80146f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801472:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801475:	eb 0c                	jmp    801483 <vprintfmt+0x24b>
  801477:	89 75 08             	mov    %esi,0x8(%ebp)
  80147a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801480:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801483:	83 c7 01             	add    $0x1,%edi
  801486:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80148a:	0f be d0             	movsbl %al,%edx
  80148d:	85 d2                	test   %edx,%edx
  80148f:	74 23                	je     8014b4 <vprintfmt+0x27c>
  801491:	85 f6                	test   %esi,%esi
  801493:	78 a1                	js     801436 <vprintfmt+0x1fe>
  801495:	83 ee 01             	sub    $0x1,%esi
  801498:	79 9c                	jns    801436 <vprintfmt+0x1fe>
  80149a:	89 df                	mov    %ebx,%edi
  80149c:	8b 75 08             	mov    0x8(%ebp),%esi
  80149f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a2:	eb 18                	jmp    8014bc <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	6a 20                	push   $0x20
  8014aa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ac:	83 ef 01             	sub    $0x1,%edi
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	eb 08                	jmp    8014bc <vprintfmt+0x284>
  8014b4:	89 df                	mov    %ebx,%edi
  8014b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bc:	85 ff                	test   %edi,%edi
  8014be:	7f e4                	jg     8014a4 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014c3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c9:	e9 90 fd ff ff       	jmp    80125e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ce:	83 f9 01             	cmp    $0x1,%ecx
  8014d1:	7e 19                	jle    8014ec <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8b 50 04             	mov    0x4(%eax),%edx
  8014d9:	8b 00                	mov    (%eax),%eax
  8014db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e4:	8d 40 08             	lea    0x8(%eax),%eax
  8014e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ea:	eb 38                	jmp    801524 <vprintfmt+0x2ec>
	else if (lflag)
  8014ec:	85 c9                	test   %ecx,%ecx
  8014ee:	74 1b                	je     80150b <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8b 00                	mov    (%eax),%eax
  8014f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f8:	89 c1                	mov    %eax,%ecx
  8014fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 40 04             	lea    0x4(%eax),%eax
  801506:	89 45 14             	mov    %eax,0x14(%ebp)
  801509:	eb 19                	jmp    801524 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80150b:	8b 45 14             	mov    0x14(%ebp),%eax
  80150e:	8b 00                	mov    (%eax),%eax
  801510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801513:	89 c1                	mov    %eax,%ecx
  801515:	c1 f9 1f             	sar    $0x1f,%ecx
  801518:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80151b:	8b 45 14             	mov    0x14(%ebp),%eax
  80151e:	8d 40 04             	lea    0x4(%eax),%eax
  801521:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80152a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80152f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801533:	0f 89 0e 01 00 00    	jns    801647 <vprintfmt+0x40f>
				putch('-', putdat);
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	53                   	push   %ebx
  80153d:	6a 2d                	push   $0x2d
  80153f:	ff d6                	call   *%esi
				num = -(long long) num;
  801541:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801544:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801547:	f7 da                	neg    %edx
  801549:	83 d1 00             	adc    $0x0,%ecx
  80154c:	f7 d9                	neg    %ecx
  80154e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801551:	b8 0a 00 00 00       	mov    $0xa,%eax
  801556:	e9 ec 00 00 00       	jmp    801647 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80155b:	83 f9 01             	cmp    $0x1,%ecx
  80155e:	7e 18                	jle    801578 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801560:	8b 45 14             	mov    0x14(%ebp),%eax
  801563:	8b 10                	mov    (%eax),%edx
  801565:	8b 48 04             	mov    0x4(%eax),%ecx
  801568:	8d 40 08             	lea    0x8(%eax),%eax
  80156b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80156e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801573:	e9 cf 00 00 00       	jmp    801647 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801578:	85 c9                	test   %ecx,%ecx
  80157a:	74 1a                	je     801596 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80157c:	8b 45 14             	mov    0x14(%ebp),%eax
  80157f:	8b 10                	mov    (%eax),%edx
  801581:	b9 00 00 00 00       	mov    $0x0,%ecx
  801586:	8d 40 04             	lea    0x4(%eax),%eax
  801589:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80158c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801591:	e9 b1 00 00 00       	jmp    801647 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801596:	8b 45 14             	mov    0x14(%ebp),%eax
  801599:	8b 10                	mov    (%eax),%edx
  80159b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a0:	8d 40 04             	lea    0x4(%eax),%eax
  8015a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8015a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015ab:	e9 97 00 00 00       	jmp    801647 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 58                	push   $0x58
  8015b6:	ff d6                	call   *%esi
			putch('X', putdat);
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	6a 58                	push   $0x58
  8015be:	ff d6                	call   *%esi
			putch('X', putdat);
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	6a 58                	push   $0x58
  8015c6:	ff d6                	call   *%esi
			break;
  8015c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015ce:	e9 8b fc ff ff       	jmp    80125e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	53                   	push   %ebx
  8015d7:	6a 30                	push   $0x30
  8015d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	53                   	push   %ebx
  8015df:	6a 78                	push   $0x78
  8015e1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e6:	8b 10                	mov    (%eax),%edx
  8015e8:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015ed:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015f0:	8d 40 04             	lea    0x4(%eax),%eax
  8015f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015fb:	eb 4a                	jmp    801647 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015fd:	83 f9 01             	cmp    $0x1,%ecx
  801600:	7e 15                	jle    801617 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801602:	8b 45 14             	mov    0x14(%ebp),%eax
  801605:	8b 10                	mov    (%eax),%edx
  801607:	8b 48 04             	mov    0x4(%eax),%ecx
  80160a:	8d 40 08             	lea    0x8(%eax),%eax
  80160d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801610:	b8 10 00 00 00       	mov    $0x10,%eax
  801615:	eb 30                	jmp    801647 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801617:	85 c9                	test   %ecx,%ecx
  801619:	74 17                	je     801632 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
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
  801630:	eb 15                	jmp    801647 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801632:	8b 45 14             	mov    0x14(%ebp),%eax
  801635:	8b 10                	mov    (%eax),%edx
  801637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80163c:	8d 40 04             	lea    0x4(%eax),%eax
  80163f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801642:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80164e:	57                   	push   %edi
  80164f:	ff 75 e0             	pushl  -0x20(%ebp)
  801652:	50                   	push   %eax
  801653:	51                   	push   %ecx
  801654:	52                   	push   %edx
  801655:	89 da                	mov    %ebx,%edx
  801657:	89 f0                	mov    %esi,%eax
  801659:	e8 f1 fa ff ff       	call   80114f <printnum>
			break;
  80165e:	83 c4 20             	add    $0x20,%esp
  801661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801664:	e9 f5 fb ff ff       	jmp    80125e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	53                   	push   %ebx
  80166d:	52                   	push   %edx
  80166e:	ff d6                	call   *%esi
			break;
  801670:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801676:	e9 e3 fb ff ff       	jmp    80125e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	53                   	push   %ebx
  80167f:	6a 25                	push   $0x25
  801681:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb 03                	jmp    80168b <vprintfmt+0x453>
  801688:	83 ef 01             	sub    $0x1,%edi
  80168b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80168f:	75 f7                	jne    801688 <vprintfmt+0x450>
  801691:	e9 c8 fb ff ff       	jmp    80125e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 18             	sub    $0x18,%esp
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	74 26                	je     8016e5 <vsnprintf+0x47>
  8016bf:	85 d2                	test   %edx,%edx
  8016c1:	7e 22                	jle    8016e5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016c3:	ff 75 14             	pushl  0x14(%ebp)
  8016c6:	ff 75 10             	pushl  0x10(%ebp)
  8016c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	68 fe 11 80 00       	push   $0x8011fe
  8016d2:	e8 61 fb ff ff       	call   801238 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	eb 05                	jmp    8016ea <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 10             	pushl  0x10(%ebp)
  8016f9:	ff 75 0c             	pushl  0xc(%ebp)
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 9a ff ff ff       	call   80169e <vsnprintf>
	va_end(ap);

	return rc;
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80170c:	b8 00 00 00 00       	mov    $0x0,%eax
  801711:	eb 03                	jmp    801716 <strlen+0x10>
		n++;
  801713:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801716:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80171a:	75 f7                	jne    801713 <strlen+0xd>
		n++;
	return n;
}
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801724:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
  80172c:	eb 03                	jmp    801731 <strnlen+0x13>
		n++;
  80172e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801731:	39 c2                	cmp    %eax,%edx
  801733:	74 08                	je     80173d <strnlen+0x1f>
  801735:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801739:	75 f3                	jne    80172e <strnlen+0x10>
  80173b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    

0080173f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	53                   	push   %ebx
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801749:	89 c2                	mov    %eax,%edx
  80174b:	83 c2 01             	add    $0x1,%edx
  80174e:	83 c1 01             	add    $0x1,%ecx
  801751:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801755:	88 5a ff             	mov    %bl,-0x1(%edx)
  801758:	84 db                	test   %bl,%bl
  80175a:	75 ef                	jne    80174b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80175c:	5b                   	pop    %ebx
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801766:	53                   	push   %ebx
  801767:	e8 9a ff ff ff       	call   801706 <strlen>
  80176c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80176f:	ff 75 0c             	pushl  0xc(%ebp)
  801772:	01 d8                	add    %ebx,%eax
  801774:	50                   	push   %eax
  801775:	e8 c5 ff ff ff       	call   80173f <strcpy>
	return dst;
}
  80177a:	89 d8                	mov    %ebx,%eax
  80177c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	8b 75 08             	mov    0x8(%ebp),%esi
  801789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178c:	89 f3                	mov    %esi,%ebx
  80178e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801791:	89 f2                	mov    %esi,%edx
  801793:	eb 0f                	jmp    8017a4 <strncpy+0x23>
		*dst++ = *src;
  801795:	83 c2 01             	add    $0x1,%edx
  801798:	0f b6 01             	movzbl (%ecx),%eax
  80179b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80179e:	80 39 01             	cmpb   $0x1,(%ecx)
  8017a1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017a4:	39 da                	cmp    %ebx,%edx
  8017a6:	75 ed                	jne    801795 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017a8:	89 f0                	mov    %esi,%eax
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8017b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8017bc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017be:	85 d2                	test   %edx,%edx
  8017c0:	74 21                	je     8017e3 <strlcpy+0x35>
  8017c2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017c6:	89 f2                	mov    %esi,%edx
  8017c8:	eb 09                	jmp    8017d3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017ca:	83 c2 01             	add    $0x1,%edx
  8017cd:	83 c1 01             	add    $0x1,%ecx
  8017d0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017d3:	39 c2                	cmp    %eax,%edx
  8017d5:	74 09                	je     8017e0 <strlcpy+0x32>
  8017d7:	0f b6 19             	movzbl (%ecx),%ebx
  8017da:	84 db                	test   %bl,%bl
  8017dc:	75 ec                	jne    8017ca <strlcpy+0x1c>
  8017de:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017e3:	29 f0                	sub    %esi,%eax
}
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017f2:	eb 06                	jmp    8017fa <strcmp+0x11>
		p++, q++;
  8017f4:	83 c1 01             	add    $0x1,%ecx
  8017f7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017fa:	0f b6 01             	movzbl (%ecx),%eax
  8017fd:	84 c0                	test   %al,%al
  8017ff:	74 04                	je     801805 <strcmp+0x1c>
  801801:	3a 02                	cmp    (%edx),%al
  801803:	74 ef                	je     8017f4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801805:	0f b6 c0             	movzbl %al,%eax
  801808:	0f b6 12             	movzbl (%edx),%edx
  80180b:	29 d0                	sub    %edx,%eax
}
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 55 0c             	mov    0xc(%ebp),%edx
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80181e:	eb 06                	jmp    801826 <strncmp+0x17>
		n--, p++, q++;
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801826:	39 d8                	cmp    %ebx,%eax
  801828:	74 15                	je     80183f <strncmp+0x30>
  80182a:	0f b6 08             	movzbl (%eax),%ecx
  80182d:	84 c9                	test   %cl,%cl
  80182f:	74 04                	je     801835 <strncmp+0x26>
  801831:	3a 0a                	cmp    (%edx),%cl
  801833:	74 eb                	je     801820 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801835:	0f b6 00             	movzbl (%eax),%eax
  801838:	0f b6 12             	movzbl (%edx),%edx
  80183b:	29 d0                	sub    %edx,%eax
  80183d:	eb 05                	jmp    801844 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801844:	5b                   	pop    %ebx
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801851:	eb 07                	jmp    80185a <strchr+0x13>
		if (*s == c)
  801853:	38 ca                	cmp    %cl,%dl
  801855:	74 0f                	je     801866 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801857:	83 c0 01             	add    $0x1,%eax
  80185a:	0f b6 10             	movzbl (%eax),%edx
  80185d:	84 d2                	test   %dl,%dl
  80185f:	75 f2                	jne    801853 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801872:	eb 03                	jmp    801877 <strfind+0xf>
  801874:	83 c0 01             	add    $0x1,%eax
  801877:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80187a:	38 ca                	cmp    %cl,%dl
  80187c:	74 04                	je     801882 <strfind+0x1a>
  80187e:	84 d2                	test   %dl,%dl
  801880:	75 f2                	jne    801874 <strfind+0xc>
			break;
	return (char *) s;
}
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	57                   	push   %edi
  801888:	56                   	push   %esi
  801889:	53                   	push   %ebx
  80188a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80188d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801890:	85 c9                	test   %ecx,%ecx
  801892:	74 36                	je     8018ca <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801894:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80189a:	75 28                	jne    8018c4 <memset+0x40>
  80189c:	f6 c1 03             	test   $0x3,%cl
  80189f:	75 23                	jne    8018c4 <memset+0x40>
		c &= 0xFF;
  8018a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018a5:	89 d3                	mov    %edx,%ebx
  8018a7:	c1 e3 08             	shl    $0x8,%ebx
  8018aa:	89 d6                	mov    %edx,%esi
  8018ac:	c1 e6 18             	shl    $0x18,%esi
  8018af:	89 d0                	mov    %edx,%eax
  8018b1:	c1 e0 10             	shl    $0x10,%eax
  8018b4:	09 f0                	or     %esi,%eax
  8018b6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018b8:	89 d8                	mov    %ebx,%eax
  8018ba:	09 d0                	or     %edx,%eax
  8018bc:	c1 e9 02             	shr    $0x2,%ecx
  8018bf:	fc                   	cld    
  8018c0:	f3 ab                	rep stos %eax,%es:(%edi)
  8018c2:	eb 06                	jmp    8018ca <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c7:	fc                   	cld    
  8018c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018ca:	89 f8                	mov    %edi,%eax
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5f                   	pop    %edi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	57                   	push   %edi
  8018d5:	56                   	push   %esi
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018df:	39 c6                	cmp    %eax,%esi
  8018e1:	73 35                	jae    801918 <memmove+0x47>
  8018e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018e6:	39 d0                	cmp    %edx,%eax
  8018e8:	73 2e                	jae    801918 <memmove+0x47>
		s += n;
		d += n;
  8018ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ed:	89 d6                	mov    %edx,%esi
  8018ef:	09 fe                	or     %edi,%esi
  8018f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018f7:	75 13                	jne    80190c <memmove+0x3b>
  8018f9:	f6 c1 03             	test   $0x3,%cl
  8018fc:	75 0e                	jne    80190c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018fe:	83 ef 04             	sub    $0x4,%edi
  801901:	8d 72 fc             	lea    -0x4(%edx),%esi
  801904:	c1 e9 02             	shr    $0x2,%ecx
  801907:	fd                   	std    
  801908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190a:	eb 09                	jmp    801915 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80190c:	83 ef 01             	sub    $0x1,%edi
  80190f:	8d 72 ff             	lea    -0x1(%edx),%esi
  801912:	fd                   	std    
  801913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801915:	fc                   	cld    
  801916:	eb 1d                	jmp    801935 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801918:	89 f2                	mov    %esi,%edx
  80191a:	09 c2                	or     %eax,%edx
  80191c:	f6 c2 03             	test   $0x3,%dl
  80191f:	75 0f                	jne    801930 <memmove+0x5f>
  801921:	f6 c1 03             	test   $0x3,%cl
  801924:	75 0a                	jne    801930 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801926:	c1 e9 02             	shr    $0x2,%ecx
  801929:	89 c7                	mov    %eax,%edi
  80192b:	fc                   	cld    
  80192c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80192e:	eb 05                	jmp    801935 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801930:	89 c7                	mov    %eax,%edi
  801932:	fc                   	cld    
  801933:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801935:	5e                   	pop    %esi
  801936:	5f                   	pop    %edi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80193c:	ff 75 10             	pushl  0x10(%ebp)
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	ff 75 08             	pushl  0x8(%ebp)
  801945:	e8 87 ff ff ff       	call   8018d1 <memmove>
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	8b 45 08             	mov    0x8(%ebp),%eax
  801954:	8b 55 0c             	mov    0xc(%ebp),%edx
  801957:	89 c6                	mov    %eax,%esi
  801959:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80195c:	eb 1a                	jmp    801978 <memcmp+0x2c>
		if (*s1 != *s2)
  80195e:	0f b6 08             	movzbl (%eax),%ecx
  801961:	0f b6 1a             	movzbl (%edx),%ebx
  801964:	38 d9                	cmp    %bl,%cl
  801966:	74 0a                	je     801972 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801968:	0f b6 c1             	movzbl %cl,%eax
  80196b:	0f b6 db             	movzbl %bl,%ebx
  80196e:	29 d8                	sub    %ebx,%eax
  801970:	eb 0f                	jmp    801981 <memcmp+0x35>
		s1++, s2++;
  801972:	83 c0 01             	add    $0x1,%eax
  801975:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801978:	39 f0                	cmp    %esi,%eax
  80197a:	75 e2                	jne    80195e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801981:	5b                   	pop    %ebx
  801982:	5e                   	pop    %esi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    

00801985 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	53                   	push   %ebx
  801989:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80198c:	89 c1                	mov    %eax,%ecx
  80198e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801991:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801995:	eb 0a                	jmp    8019a1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801997:	0f b6 10             	movzbl (%eax),%edx
  80199a:	39 da                	cmp    %ebx,%edx
  80199c:	74 07                	je     8019a5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80199e:	83 c0 01             	add    $0x1,%eax
  8019a1:	39 c8                	cmp    %ecx,%eax
  8019a3:	72 f2                	jb     801997 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019a5:	5b                   	pop    %ebx
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	57                   	push   %edi
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019b4:	eb 03                	jmp    8019b9 <strtol+0x11>
		s++;
  8019b6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019b9:	0f b6 01             	movzbl (%ecx),%eax
  8019bc:	3c 20                	cmp    $0x20,%al
  8019be:	74 f6                	je     8019b6 <strtol+0xe>
  8019c0:	3c 09                	cmp    $0x9,%al
  8019c2:	74 f2                	je     8019b6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019c4:	3c 2b                	cmp    $0x2b,%al
  8019c6:	75 0a                	jne    8019d2 <strtol+0x2a>
		s++;
  8019c8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d0:	eb 11                	jmp    8019e3 <strtol+0x3b>
  8019d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019d7:	3c 2d                	cmp    $0x2d,%al
  8019d9:	75 08                	jne    8019e3 <strtol+0x3b>
		s++, neg = 1;
  8019db:	83 c1 01             	add    $0x1,%ecx
  8019de:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019e3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019e9:	75 15                	jne    801a00 <strtol+0x58>
  8019eb:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ee:	75 10                	jne    801a00 <strtol+0x58>
  8019f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019f4:	75 7c                	jne    801a72 <strtol+0xca>
		s += 2, base = 16;
  8019f6:	83 c1 02             	add    $0x2,%ecx
  8019f9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019fe:	eb 16                	jmp    801a16 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a00:	85 db                	test   %ebx,%ebx
  801a02:	75 12                	jne    801a16 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a04:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a09:	80 39 30             	cmpb   $0x30,(%ecx)
  801a0c:	75 08                	jne    801a16 <strtol+0x6e>
		s++, base = 8;
  801a0e:	83 c1 01             	add    $0x1,%ecx
  801a11:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a1e:	0f b6 11             	movzbl (%ecx),%edx
  801a21:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a24:	89 f3                	mov    %esi,%ebx
  801a26:	80 fb 09             	cmp    $0x9,%bl
  801a29:	77 08                	ja     801a33 <strtol+0x8b>
			dig = *s - '0';
  801a2b:	0f be d2             	movsbl %dl,%edx
  801a2e:	83 ea 30             	sub    $0x30,%edx
  801a31:	eb 22                	jmp    801a55 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a33:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a36:	89 f3                	mov    %esi,%ebx
  801a38:	80 fb 19             	cmp    $0x19,%bl
  801a3b:	77 08                	ja     801a45 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a3d:	0f be d2             	movsbl %dl,%edx
  801a40:	83 ea 57             	sub    $0x57,%edx
  801a43:	eb 10                	jmp    801a55 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a45:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a48:	89 f3                	mov    %esi,%ebx
  801a4a:	80 fb 19             	cmp    $0x19,%bl
  801a4d:	77 16                	ja     801a65 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a4f:	0f be d2             	movsbl %dl,%edx
  801a52:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a55:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a58:	7d 0b                	jge    801a65 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a5a:	83 c1 01             	add    $0x1,%ecx
  801a5d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a61:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a63:	eb b9                	jmp    801a1e <strtol+0x76>

	if (endptr)
  801a65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a69:	74 0d                	je     801a78 <strtol+0xd0>
		*endptr = (char *) s;
  801a6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6e:	89 0e                	mov    %ecx,(%esi)
  801a70:	eb 06                	jmp    801a78 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	74 98                	je     801a0e <strtol+0x66>
  801a76:	eb 9e                	jmp    801a16 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a78:	89 c2                	mov    %eax,%edx
  801a7a:	f7 da                	neg    %edx
  801a7c:	85 ff                	test   %edi,%edi
  801a7e:	0f 45 c2             	cmovne %edx,%eax
}
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a98:	85 f6                	test   %esi,%esi
  801a9a:	74 06                	je     801aa2 <ipc_recv+0x1c>
		*from_env_store = 0;
  801a9c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801aa2:	85 db                	test   %ebx,%ebx
  801aa4:	74 06                	je     801aac <ipc_recv+0x26>
		*perm_store = 0;
  801aa6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801aac:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801aae:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801ab3:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	50                   	push   %eax
  801aba:	e8 72 e8 ff ff       	call   800331 <sys_ipc_recv>
  801abf:	89 c7                	mov    %eax,%edi
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	79 14                	jns    801adc <ipc_recv+0x56>
		cprintf("im dead");
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	68 a0 22 80 00       	push   $0x8022a0
  801ad0:	e8 66 f6 ff ff       	call   80113b <cprintf>
		return r;
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	89 f8                	mov    %edi,%eax
  801ada:	eb 24                	jmp    801b00 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801adc:	85 f6                	test   %esi,%esi
  801ade:	74 0a                	je     801aea <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ae0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae5:	8b 40 74             	mov    0x74(%eax),%eax
  801ae8:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801aea:	85 db                	test   %ebx,%ebx
  801aec:	74 0a                	je     801af8 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801aee:	a1 04 40 80 00       	mov    0x804004,%eax
  801af3:	8b 40 78             	mov    0x78(%eax),%eax
  801af6:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801af8:	a1 04 40 80 00       	mov    0x804004,%eax
  801afd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b03:	5b                   	pop    %ebx
  801b04:	5e                   	pop    %esi
  801b05:	5f                   	pop    %edi
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	57                   	push   %edi
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801b1a:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b21:	0f 44 d8             	cmove  %eax,%ebx
  801b24:	eb 1c                	jmp    801b42 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b26:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b29:	74 12                	je     801b3d <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b2b:	50                   	push   %eax
  801b2c:	68 a8 22 80 00       	push   $0x8022a8
  801b31:	6a 4e                	push   $0x4e
  801b33:	68 b5 22 80 00       	push   $0x8022b5
  801b38:	e8 25 f5 ff ff       	call   801062 <_panic>
		sys_yield();
  801b3d:	e8 20 e6 ff ff       	call   800162 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b42:	ff 75 14             	pushl  0x14(%ebp)
  801b45:	53                   	push   %ebx
  801b46:	56                   	push   %esi
  801b47:	57                   	push   %edi
  801b48:	e8 c1 e7 ff ff       	call   80030e <sys_ipc_try_send>
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	78 d2                	js     801b26 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b57:	5b                   	pop    %ebx
  801b58:	5e                   	pop    %esi
  801b59:	5f                   	pop    %edi
  801b5a:	5d                   	pop    %ebp
  801b5b:	c3                   	ret    

00801b5c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b67:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b70:	8b 52 50             	mov    0x50(%edx),%edx
  801b73:	39 ca                	cmp    %ecx,%edx
  801b75:	75 0d                	jne    801b84 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b7f:	8b 40 48             	mov    0x48(%eax),%eax
  801b82:	eb 0f                	jmp    801b93 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b84:	83 c0 01             	add    $0x1,%eax
  801b87:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8c:	75 d9                	jne    801b67 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9b:	89 d0                	mov    %edx,%eax
  801b9d:	c1 e8 16             	shr    $0x16,%eax
  801ba0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bac:	f6 c1 01             	test   $0x1,%cl
  801baf:	74 1d                	je     801bce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb1:	c1 ea 0c             	shr    $0xc,%edx
  801bb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbb:	f6 c2 01             	test   $0x1,%dl
  801bbe:	74 0e                	je     801bce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc0:	c1 ea 0c             	shr    $0xc,%edx
  801bc3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bca:	ef 
  801bcb:	0f b7 c0             	movzwl %ax,%eax
}
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
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
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
