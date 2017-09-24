
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 4a 1e 80 00       	push   $0x801e4a
  800103:	6a 23                	push   $0x23
  800105:	68 67 1e 80 00       	push   $0x801e67
  80010a:	e8 27 0f 00 00       	call   801036 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 4a 1e 80 00       	push   $0x801e4a
  800184:	6a 23                	push   $0x23
  800186:	68 67 1e 80 00       	push   $0x801e67
  80018b:	e8 a6 0e 00 00       	call   801036 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 4a 1e 80 00       	push   $0x801e4a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 67 1e 80 00       	push   $0x801e67
  8001cd:	e8 64 0e 00 00       	call   801036 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 4a 1e 80 00       	push   $0x801e4a
  800208:	6a 23                	push   $0x23
  80020a:	68 67 1e 80 00       	push   $0x801e67
  80020f:	e8 22 0e 00 00       	call   801036 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 4a 1e 80 00       	push   $0x801e4a
  80024a:	6a 23                	push   $0x23
  80024c:	68 67 1e 80 00       	push   $0x801e67
  800251:	e8 e0 0d 00 00       	call   801036 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 4a 1e 80 00       	push   $0x801e4a
  80028c:	6a 23                	push   $0x23
  80028e:	68 67 1e 80 00       	push   $0x801e67
  800293:	e8 9e 0d 00 00       	call   801036 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 4a 1e 80 00       	push   $0x801e4a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 67 1e 80 00       	push   $0x801e67
  8002d5:	e8 5c 0d 00 00       	call   801036 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 4a 1e 80 00       	push   $0x801e4a
  800332:	6a 23                	push   $0x23
  800334:	68 67 1e 80 00       	push   $0x801e67
  800339:	e8 f8 0c 00 00       	call   801036 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 78 1e 80 00       	push   $0x801e78
  80044d:	e8 bd 0c 00 00       	call   80110f <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 b9 1e 80 00       	push   $0x801eb9
  800677:	e8 93 0a 00 00       	call   80110f <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 d5 1e 80 00       	push   $0x801ed5
  80074c:	e8 be 09 00 00       	call   80110f <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 98 1e 80 00       	push   $0x801e98
  800801:	e8 09 09 00 00       	call   80110f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 e9 01 00 00       	call   800ab3 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 1f 12 00 00       	call   801b30 <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 b0 11 00 00       	call   801adc <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 21 11 00 00       	call   801a5a <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 51 0d 00 00       	call   801713 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 0c             	sub    $0xc,%esp
  8009eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f8:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fe:	8b 52 0c             	mov    0xc(%edx),%edx
  800a01:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a07:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a0c:	50                   	push   %eax
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	68 08 50 80 00       	push   $0x805008
  800a15:	e8 8b 0e 00 00       	call   8018a5 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a24:	e8 cc fe ff ff       	call   8008f5 <fsipc>
            return r;

    return r;
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	e8 a2 fe ff ff       	call   8008f5 <fsipc>
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 51                	js     800aaa <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 19                	jae    800a76 <devfile_read+0x4b>
  800a5d:	68 04 1f 80 00       	push   $0x801f04
  800a62:	68 0b 1f 80 00       	push   $0x801f0b
  800a67:	68 82 00 00 00       	push   $0x82
  800a6c:	68 20 1f 80 00       	push   $0x801f20
  800a71:	e8 c0 05 00 00       	call   801036 <_panic>
	assert(r <= PGSIZE);
  800a76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7b:	7e 19                	jle    800a96 <devfile_read+0x6b>
  800a7d:	68 2b 1f 80 00       	push   $0x801f2b
  800a82:	68 0b 1f 80 00       	push   $0x801f0b
  800a87:	68 83 00 00 00       	push   $0x83
  800a8c:	68 20 1f 80 00       	push   $0x801f20
  800a91:	e8 a0 05 00 00       	call   801036 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a96:	83 ec 04             	sub    $0x4,%esp
  800a99:	50                   	push   %eax
  800a9a:	68 00 50 80 00       	push   $0x805000
  800a9f:	ff 75 0c             	pushl  0xc(%ebp)
  800aa2:	e8 fe 0d 00 00       	call   8018a5 <memmove>
	return r;
  800aa7:	83 c4 10             	add    $0x10,%esp
}
  800aaa:	89 d8                	mov    %ebx,%eax
  800aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 20             	sub    $0x20,%esp
  800aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800abd:	53                   	push   %ebx
  800abe:	e8 17 0c 00 00       	call   8016da <strlen>
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800acb:	7f 67                	jg     800b34 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800acd:	83 ec 0c             	sub    $0xc,%esp
  800ad0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad3:	50                   	push   %eax
  800ad4:	e8 94 f8 ff ff       	call   80036d <fd_alloc>
  800ad9:	83 c4 10             	add    $0x10,%esp
		return r;
  800adc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	78 57                	js     800b39 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	53                   	push   %ebx
  800ae6:	68 00 50 80 00       	push   $0x805000
  800aeb:	e8 23 0c 00 00       	call   801713 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	e8 f0 fd ff ff       	call   8008f5 <fsipc>
  800b05:	89 c3                	mov    %eax,%ebx
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	79 14                	jns    800b22 <open+0x6f>
		fd_close(fd, 0);
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	6a 00                	push   $0x0
  800b13:	ff 75 f4             	pushl  -0xc(%ebp)
  800b16:	e8 4a f9 ff ff       	call   800465 <fd_close>
		return r;
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	89 da                	mov    %ebx,%edx
  800b20:	eb 17                	jmp    800b39 <open+0x86>
	}

	return fd2num(fd);
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	ff 75 f4             	pushl  -0xc(%ebp)
  800b28:	e8 19 f8 ff ff       	call   800346 <fd2num>
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	83 c4 10             	add    $0x10,%esp
  800b32:	eb 05                	jmp    800b39 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b34:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b39:	89 d0                	mov    %edx,%eax
  800b3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b50:	e8 a0 fd ff ff       	call   8008f5 <fsipc>
}
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	ff 75 08             	pushl  0x8(%ebp)
  800b65:	e8 ec f7 ff ff       	call   800356 <fd2data>
  800b6a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6c:	83 c4 08             	add    $0x8,%esp
  800b6f:	68 37 1f 80 00       	push   $0x801f37
  800b74:	53                   	push   %ebx
  800b75:	e8 99 0b 00 00       	call   801713 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7a:	8b 46 04             	mov    0x4(%esi),%eax
  800b7d:	2b 06                	sub    (%esi),%eax
  800b7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b85:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8c:	00 00 00 
	stat->st_dev = &devpipe;
  800b8f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b96:	30 80 00 
	return 0;
}
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800baf:	53                   	push   %ebx
  800bb0:	6a 00                	push   $0x0
  800bb2:	e8 23 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb7:	89 1c 24             	mov    %ebx,(%esp)
  800bba:	e8 97 f7 ff ff       	call   800356 <fd2data>
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 00                	push   $0x0
  800bc5:	e8 10 f6 ff ff       	call   8001da <sys_page_unmap>
}
  800bca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 1c             	sub    $0x1c,%esp
  800bd8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bdd:	a1 04 40 80 00       	mov    0x804004,%eax
  800be2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	ff 75 e0             	pushl  -0x20(%ebp)
  800beb:	e8 79 0f 00 00       	call   801b69 <pageref>
  800bf0:	89 c3                	mov    %eax,%ebx
  800bf2:	89 3c 24             	mov    %edi,(%esp)
  800bf5:	e8 6f 0f 00 00       	call   801b69 <pageref>
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	39 c3                	cmp    %eax,%ebx
  800bff:	0f 94 c1             	sete   %cl
  800c02:	0f b6 c9             	movzbl %cl,%ecx
  800c05:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c08:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c11:	39 ce                	cmp    %ecx,%esi
  800c13:	74 1b                	je     800c30 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c15:	39 c3                	cmp    %eax,%ebx
  800c17:	75 c4                	jne    800bdd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c19:	8b 42 58             	mov    0x58(%edx),%eax
  800c1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1f:	50                   	push   %eax
  800c20:	56                   	push   %esi
  800c21:	68 3e 1f 80 00       	push   $0x801f3e
  800c26:	e8 e4 04 00 00       	call   80110f <cprintf>
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	eb ad                	jmp    800bdd <_pipeisclosed+0xe>
	}
}
  800c30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 28             	sub    $0x28,%esp
  800c44:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c47:	56                   	push   %esi
  800c48:	e8 09 f7 ff ff       	call   800356 <fd2data>
  800c4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	bf 00 00 00 00       	mov    $0x0,%edi
  800c57:	eb 4b                	jmp    800ca4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c59:	89 da                	mov    %ebx,%edx
  800c5b:	89 f0                	mov    %esi,%eax
  800c5d:	e8 6d ff ff ff       	call   800bcf <_pipeisclosed>
  800c62:	85 c0                	test   %eax,%eax
  800c64:	75 48                	jne    800cae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c66:	e8 cb f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6e:	8b 0b                	mov    (%ebx),%ecx
  800c70:	8d 51 20             	lea    0x20(%ecx),%edx
  800c73:	39 d0                	cmp    %edx,%eax
  800c75:	73 e2                	jae    800c59 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c81:	89 c2                	mov    %eax,%edx
  800c83:	c1 fa 1f             	sar    $0x1f,%edx
  800c86:	89 d1                	mov    %edx,%ecx
  800c88:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8e:	83 e2 1f             	and    $0x1f,%edx
  800c91:	29 ca                	sub    %ecx,%edx
  800c93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9b:	83 c0 01             	add    $0x1,%eax
  800c9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca1:	83 c7 01             	add    $0x1,%edi
  800ca4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca7:	75 c2                	jne    800c6b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cac:	eb 05                	jmp    800cb3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 18             	sub    $0x18,%esp
  800cc4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc7:	57                   	push   %edi
  800cc8:	e8 89 f6 ff ff       	call   800356 <fd2data>
  800ccd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccf:	83 c4 10             	add    $0x10,%esp
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	eb 3d                	jmp    800d16 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd9:	85 db                	test   %ebx,%ebx
  800cdb:	74 04                	je     800ce1 <devpipe_read+0x26>
				return i;
  800cdd:	89 d8                	mov    %ebx,%eax
  800cdf:	eb 44                	jmp    800d25 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce1:	89 f2                	mov    %esi,%edx
  800ce3:	89 f8                	mov    %edi,%eax
  800ce5:	e8 e5 fe ff ff       	call   800bcf <_pipeisclosed>
  800cea:	85 c0                	test   %eax,%eax
  800cec:	75 32                	jne    800d20 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cee:	e8 43 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf3:	8b 06                	mov    (%esi),%eax
  800cf5:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf8:	74 df                	je     800cd9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfa:	99                   	cltd   
  800cfb:	c1 ea 1b             	shr    $0x1b,%edx
  800cfe:	01 d0                	add    %edx,%eax
  800d00:	83 e0 1f             	and    $0x1f,%eax
  800d03:	29 d0                	sub    %edx,%eax
  800d05:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d10:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d13:	83 c3 01             	add    $0x1,%ebx
  800d16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d19:	75 d8                	jne    800cf3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1e:	eb 05                	jmp    800d25 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d38:	50                   	push   %eax
  800d39:	e8 2f f6 ff ff       	call   80036d <fd_alloc>
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	89 c2                	mov    %eax,%edx
  800d43:	85 c0                	test   %eax,%eax
  800d45:	0f 88 2c 01 00 00    	js     800e77 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	68 07 04 00 00       	push   $0x407
  800d53:	ff 75 f4             	pushl  -0xc(%ebp)
  800d56:	6a 00                	push   $0x0
  800d58:	e8 f8 f3 ff ff       	call   800155 <sys_page_alloc>
  800d5d:	83 c4 10             	add    $0x10,%esp
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	85 c0                	test   %eax,%eax
  800d64:	0f 88 0d 01 00 00    	js     800e77 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d70:	50                   	push   %eax
  800d71:	e8 f7 f5 ff ff       	call   80036d <fd_alloc>
  800d76:	89 c3                	mov    %eax,%ebx
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	0f 88 e2 00 00 00    	js     800e65 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	68 07 04 00 00       	push   $0x407
  800d8b:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8e:	6a 00                	push   $0x0
  800d90:	e8 c0 f3 ff ff       	call   800155 <sys_page_alloc>
  800d95:	89 c3                	mov    %eax,%ebx
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	0f 88 c3 00 00 00    	js     800e65 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	ff 75 f4             	pushl  -0xc(%ebp)
  800da8:	e8 a9 f5 ff ff       	call   800356 <fd2data>
  800dad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 c4 0c             	add    $0xc,%esp
  800db2:	68 07 04 00 00       	push   $0x407
  800db7:	50                   	push   %eax
  800db8:	6a 00                	push   $0x0
  800dba:	e8 96 f3 ff ff       	call   800155 <sys_page_alloc>
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	0f 88 89 00 00 00    	js     800e55 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd2:	e8 7f f5 ff ff       	call   800356 <fd2data>
  800dd7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dde:	50                   	push   %eax
  800ddf:	6a 00                	push   $0x0
  800de1:	56                   	push   %esi
  800de2:	6a 00                	push   $0x0
  800de4:	e8 af f3 ff ff       	call   800198 <sys_page_map>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	83 c4 20             	add    $0x20,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	78 55                	js     800e47 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e10:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e15:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e22:	e8 1f f5 ff ff       	call   800346 <fd2num>
  800e27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2c:	83 c4 04             	add    $0x4,%esp
  800e2f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e32:	e8 0f f5 ff ff       	call   800346 <fd2num>
  800e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	ba 00 00 00 00       	mov    $0x0,%edx
  800e45:	eb 30                	jmp    800e77 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	56                   	push   %esi
  800e4b:	6a 00                	push   $0x0
  800e4d:	e8 88 f3 ff ff       	call   8001da <sys_page_unmap>
  800e52:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 78 f3 ff ff       	call   8001da <sys_page_unmap>
  800e62:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 68 f3 ff ff       	call   8001da <sys_page_unmap>
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e77:	89 d0                	mov    %edx,%eax
  800e79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e89:	50                   	push   %eax
  800e8a:	ff 75 08             	pushl  0x8(%ebp)
  800e8d:	e8 2a f5 ff ff       	call   8003bc <fd_lookup>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 18                	js     800eb1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9f:	e8 b2 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea9:	e8 21 fd ff ff       	call   800bcf <_pipeisclosed>
  800eae:	83 c4 10             	add    $0x10,%esp
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec3:	68 56 1f 80 00       	push   $0x801f56
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	e8 43 08 00 00       	call   801713 <strcpy>
	return 0;
}
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eee:	eb 2d                	jmp    800f1d <devcons_write+0x46>
		m = n - tot;
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800efd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	53                   	push   %ebx
  800f04:	03 45 0c             	add    0xc(%ebp),%eax
  800f07:	50                   	push   %eax
  800f08:	57                   	push   %edi
  800f09:	e8 97 09 00 00       	call   8018a5 <memmove>
		sys_cputs(buf, m);
  800f0e:	83 c4 08             	add    $0x8,%esp
  800f11:	53                   	push   %ebx
  800f12:	57                   	push   %edi
  800f13:	e8 81 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f18:	01 de                	add    %ebx,%esi
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	89 f0                	mov    %esi,%eax
  800f1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f22:	72 cc                	jb     800ef0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f27:	5b                   	pop    %ebx
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3b:	74 2a                	je     800f67 <devcons_read+0x3b>
  800f3d:	eb 05                	jmp    800f44 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3f:	e8 f2 f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f44:	e8 6e f1 ff ff       	call   8000b7 <sys_cgetc>
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	74 f2                	je     800f3f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 16                	js     800f67 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f51:	83 f8 04             	cmp    $0x4,%eax
  800f54:	74 0c                	je     800f62 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f59:	88 02                	mov    %al,(%edx)
	return 1;
  800f5b:	b8 01 00 00 00       	mov    $0x1,%eax
  800f60:	eb 05                	jmp    800f67 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f75:	6a 01                	push   $0x1
  800f77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7a:	50                   	push   %eax
  800f7b:	e8 19 f1 ff ff       	call   800099 <sys_cputs>
}
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <getchar>:

int
getchar(void)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8b:	6a 01                	push   $0x1
  800f8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f90:	50                   	push   %eax
  800f91:	6a 00                	push   $0x0
  800f93:	e8 8a f6 ff ff       	call   800622 <read>
	if (r < 0)
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 0f                	js     800fae <getchar+0x29>
		return r;
	if (r < 1)
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	7e 06                	jle    800fa9 <getchar+0x24>
		return -E_EOF;
	return c;
  800fa3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa7:	eb 05                	jmp    800fae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	ff 75 08             	pushl  0x8(%ebp)
  800fbd:	e8 fa f3 ff ff       	call   8003bc <fd_lookup>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 11                	js     800fda <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd2:	39 10                	cmp    %edx,(%eax)
  800fd4:	0f 94 c0             	sete   %al
  800fd7:	0f b6 c0             	movzbl %al,%eax
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <opencons>:

int
opencons(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	e8 82 f3 ff ff       	call   80036d <fd_alloc>
  800feb:	83 c4 10             	add    $0x10,%esp
		return r;
  800fee:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 3e                	js     801032 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	68 07 04 00 00       	push   $0x407
  800ffc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fff:	6a 00                	push   $0x0
  801001:	e8 4f f1 ff ff       	call   800155 <sys_page_alloc>
  801006:	83 c4 10             	add    $0x10,%esp
		return r;
  801009:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 23                	js     801032 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80100f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	50                   	push   %eax
  801028:	e8 19 f3 ff ff       	call   800346 <fd2num>
  80102d:	89 c2                	mov    %eax,%edx
  80102f:	83 c4 10             	add    $0x10,%esp
}
  801032:	89 d0                	mov    %edx,%eax
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801044:	e8 ce f0 ff ff       	call   800117 <sys_getenvid>
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	ff 75 0c             	pushl  0xc(%ebp)
  80104f:	ff 75 08             	pushl  0x8(%ebp)
  801052:	56                   	push   %esi
  801053:	50                   	push   %eax
  801054:	68 64 1f 80 00       	push   $0x801f64
  801059:	e8 b1 00 00 00       	call   80110f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105e:	83 c4 18             	add    $0x18,%esp
  801061:	53                   	push   %ebx
  801062:	ff 75 10             	pushl  0x10(%ebp)
  801065:	e8 54 00 00 00       	call   8010be <vcprintf>
	cprintf("\n");
  80106a:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  801071:	e8 99 00 00 00       	call   80110f <cprintf>
  801076:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801079:	cc                   	int3   
  80107a:	eb fd                	jmp    801079 <_panic+0x43>

0080107c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	53                   	push   %ebx
  801080:	83 ec 04             	sub    $0x4,%esp
  801083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801086:	8b 13                	mov    (%ebx),%edx
  801088:	8d 42 01             	lea    0x1(%edx),%eax
  80108b:	89 03                	mov    %eax,(%ebx)
  80108d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801090:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801094:	3d ff 00 00 00       	cmp    $0xff,%eax
  801099:	75 1a                	jne    8010b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109b:	83 ec 08             	sub    $0x8,%esp
  80109e:	68 ff 00 00 00       	push   $0xff
  8010a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a6:	50                   	push   %eax
  8010a7:	e8 ed ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ce:	00 00 00 
	b.cnt = 0;
  8010d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010db:	ff 75 0c             	pushl  0xc(%ebp)
  8010de:	ff 75 08             	pushl  0x8(%ebp)
  8010e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e7:	50                   	push   %eax
  8010e8:	68 7c 10 80 00       	push   $0x80107c
  8010ed:	e8 1a 01 00 00       	call   80120c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801101:	50                   	push   %eax
  801102:	e8 92 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801107:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801115:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801118:	50                   	push   %eax
  801119:	ff 75 08             	pushl  0x8(%ebp)
  80111c:	e8 9d ff ff ff       	call   8010be <vcprintf>
	va_end(ap);

	return cnt;
}
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 1c             	sub    $0x1c,%esp
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	89 d6                	mov    %edx,%esi
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	8b 55 0c             	mov    0xc(%ebp),%edx
  801136:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801139:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801144:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801147:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114a:	39 d3                	cmp    %edx,%ebx
  80114c:	72 05                	jb     801153 <printnum+0x30>
  80114e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801151:	77 45                	ja     801198 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	ff 75 18             	pushl  0x18(%ebp)
  801159:	8b 45 14             	mov    0x14(%ebp),%eax
  80115c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115f:	53                   	push   %ebx
  801160:	ff 75 10             	pushl  0x10(%ebp)
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	ff 75 e4             	pushl  -0x1c(%ebp)
  801169:	ff 75 e0             	pushl  -0x20(%ebp)
  80116c:	ff 75 dc             	pushl  -0x24(%ebp)
  80116f:	ff 75 d8             	pushl  -0x28(%ebp)
  801172:	e8 39 0a 00 00       	call   801bb0 <__udivdi3>
  801177:	83 c4 18             	add    $0x18,%esp
  80117a:	52                   	push   %edx
  80117b:	50                   	push   %eax
  80117c:	89 f2                	mov    %esi,%edx
  80117e:	89 f8                	mov    %edi,%eax
  801180:	e8 9e ff ff ff       	call   801123 <printnum>
  801185:	83 c4 20             	add    $0x20,%esp
  801188:	eb 18                	jmp    8011a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	56                   	push   %esi
  80118e:	ff 75 18             	pushl  0x18(%ebp)
  801191:	ff d7                	call   *%edi
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	eb 03                	jmp    80119b <printnum+0x78>
  801198:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119b:	83 eb 01             	sub    $0x1,%ebx
  80119e:	85 db                	test   %ebx,%ebx
  8011a0:	7f e8                	jg     80118a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	56                   	push   %esi
  8011a6:	83 ec 04             	sub    $0x4,%esp
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8011af:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b5:	e8 26 0b 00 00       	call   801ce0 <__umoddi3>
  8011ba:	83 c4 14             	add    $0x14,%esp
  8011bd:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011c4:	50                   	push   %eax
  8011c5:	ff d7                	call   *%edi
}
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011dc:	8b 10                	mov    (%eax),%edx
  8011de:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e1:	73 0a                	jae    8011ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e6:	89 08                	mov    %ecx,(%eax)
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011eb:	88 02                	mov    %al,(%edx)
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 10             	pushl  0x10(%ebp)
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	ff 75 08             	pushl  0x8(%ebp)
  801202:	e8 05 00 00 00       	call   80120c <vprintfmt>
	va_end(ap);
}
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	83 ec 2c             	sub    $0x2c,%esp
  801215:	8b 75 08             	mov    0x8(%ebp),%esi
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80121e:	eb 12                	jmp    801232 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 84 42 04 00 00    	je     80166a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	53                   	push   %ebx
  80122c:	50                   	push   %eax
  80122d:	ff d6                	call   *%esi
  80122f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801232:	83 c7 01             	add    $0x1,%edi
  801235:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801239:	83 f8 25             	cmp    $0x25,%eax
  80123c:	75 e2                	jne    801220 <vprintfmt+0x14>
  80123e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801242:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801249:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801250:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801257:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125c:	eb 07                	jmp    801265 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801261:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801265:	8d 47 01             	lea    0x1(%edi),%eax
  801268:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126b:	0f b6 07             	movzbl (%edi),%eax
  80126e:	0f b6 d0             	movzbl %al,%edx
  801271:	83 e8 23             	sub    $0x23,%eax
  801274:	3c 55                	cmp    $0x55,%al
  801276:	0f 87 d3 03 00 00    	ja     80164f <vprintfmt+0x443>
  80127c:	0f b6 c0             	movzbl %al,%eax
  80127f:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801286:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801289:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80128d:	eb d6                	jmp    801265 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80129d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012a7:	83 f9 09             	cmp    $0x9,%ecx
  8012aa:	77 3f                	ja     8012eb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012af:	eb e9                	jmp    80129a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b4:	8b 00                	mov    (%eax),%eax
  8012b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bc:	8d 40 04             	lea    0x4(%eax),%eax
  8012bf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012c5:	eb 2a                	jmp    8012f1 <vprintfmt+0xe5>
  8012c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	0f 49 d0             	cmovns %eax,%edx
  8012d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012da:	eb 89                	jmp    801265 <vprintfmt+0x59>
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e6:	e9 7a ff ff ff       	jmp    801265 <vprintfmt+0x59>
  8012eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012f5:	0f 89 6a ff ff ff    	jns    801265 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801308:	e9 58 ff ff ff       	jmp    801265 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80130d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801313:	e9 4d ff ff ff       	jmp    801265 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801318:	8b 45 14             	mov    0x14(%ebp),%eax
  80131b:	8d 78 04             	lea    0x4(%eax),%edi
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	53                   	push   %ebx
  801322:	ff 30                	pushl  (%eax)
  801324:	ff d6                	call   *%esi
			break;
  801326:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801329:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80132f:	e9 fe fe ff ff       	jmp    801232 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801334:	8b 45 14             	mov    0x14(%ebp),%eax
  801337:	8d 78 04             	lea    0x4(%eax),%edi
  80133a:	8b 00                	mov    (%eax),%eax
  80133c:	99                   	cltd   
  80133d:	31 d0                	xor    %edx,%eax
  80133f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801341:	83 f8 0f             	cmp    $0xf,%eax
  801344:	7f 0b                	jg     801351 <vprintfmt+0x145>
  801346:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80134d:	85 d2                	test   %edx,%edx
  80134f:	75 1b                	jne    80136c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801351:	50                   	push   %eax
  801352:	68 9f 1f 80 00       	push   $0x801f9f
  801357:	53                   	push   %ebx
  801358:	56                   	push   %esi
  801359:	e8 91 fe ff ff       	call   8011ef <printfmt>
  80135e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801361:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801367:	e9 c6 fe ff ff       	jmp    801232 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80136c:	52                   	push   %edx
  80136d:	68 1d 1f 80 00       	push   $0x801f1d
  801372:	53                   	push   %ebx
  801373:	56                   	push   %esi
  801374:	e8 76 fe ff ff       	call   8011ef <printfmt>
  801379:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80137c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801382:	e9 ab fe ff ff       	jmp    801232 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801387:	8b 45 14             	mov    0x14(%ebp),%eax
  80138a:	83 c0 04             	add    $0x4,%eax
  80138d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801390:	8b 45 14             	mov    0x14(%ebp),%eax
  801393:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801395:	85 ff                	test   %edi,%edi
  801397:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  80139c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80139f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a3:	0f 8e 94 00 00 00    	jle    80143d <vprintfmt+0x231>
  8013a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ad:	0f 84 98 00 00 00    	je     80144b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b9:	57                   	push   %edi
  8013ba:	e8 33 03 00 00       	call   8016f2 <strnlen>
  8013bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c2:	29 c1                	sub    %eax,%ecx
  8013c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d6:	eb 0f                	jmp    8013e7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	53                   	push   %ebx
  8013dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8013df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e1:	83 ef 01             	sub    $0x1,%edi
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 ff                	test   %edi,%edi
  8013e9:	7f ed                	jg     8013d8 <vprintfmt+0x1cc>
  8013eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013f1:	85 c9                	test   %ecx,%ecx
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f8:	0f 49 c1             	cmovns %ecx,%eax
  8013fb:	29 c1                	sub    %eax,%ecx
  8013fd:	89 75 08             	mov    %esi,0x8(%ebp)
  801400:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801403:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801406:	89 cb                	mov    %ecx,%ebx
  801408:	eb 4d                	jmp    801457 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80140e:	74 1b                	je     80142b <vprintfmt+0x21f>
  801410:	0f be c0             	movsbl %al,%eax
  801413:	83 e8 20             	sub    $0x20,%eax
  801416:	83 f8 5e             	cmp    $0x5e,%eax
  801419:	76 10                	jbe    80142b <vprintfmt+0x21f>
					putch('?', putdat);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	ff 75 0c             	pushl  0xc(%ebp)
  801421:	6a 3f                	push   $0x3f
  801423:	ff 55 08             	call   *0x8(%ebp)
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	eb 0d                	jmp    801438 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	ff 75 0c             	pushl  0xc(%ebp)
  801431:	52                   	push   %edx
  801432:	ff 55 08             	call   *0x8(%ebp)
  801435:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801438:	83 eb 01             	sub    $0x1,%ebx
  80143b:	eb 1a                	jmp    801457 <vprintfmt+0x24b>
  80143d:	89 75 08             	mov    %esi,0x8(%ebp)
  801440:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801443:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801446:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801449:	eb 0c                	jmp    801457 <vprintfmt+0x24b>
  80144b:	89 75 08             	mov    %esi,0x8(%ebp)
  80144e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801451:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801454:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801457:	83 c7 01             	add    $0x1,%edi
  80145a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80145e:	0f be d0             	movsbl %al,%edx
  801461:	85 d2                	test   %edx,%edx
  801463:	74 23                	je     801488 <vprintfmt+0x27c>
  801465:	85 f6                	test   %esi,%esi
  801467:	78 a1                	js     80140a <vprintfmt+0x1fe>
  801469:	83 ee 01             	sub    $0x1,%esi
  80146c:	79 9c                	jns    80140a <vprintfmt+0x1fe>
  80146e:	89 df                	mov    %ebx,%edi
  801470:	8b 75 08             	mov    0x8(%ebp),%esi
  801473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801476:	eb 18                	jmp    801490 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	53                   	push   %ebx
  80147c:	6a 20                	push   $0x20
  80147e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801480:	83 ef 01             	sub    $0x1,%edi
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	eb 08                	jmp    801490 <vprintfmt+0x284>
  801488:	89 df                	mov    %ebx,%edi
  80148a:	8b 75 08             	mov    0x8(%ebp),%esi
  80148d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801490:	85 ff                	test   %edi,%edi
  801492:	7f e4                	jg     801478 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801494:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801497:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80149d:	e9 90 fd ff ff       	jmp    801232 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a2:	83 f9 01             	cmp    $0x1,%ecx
  8014a5:	7e 19                	jle    8014c0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014aa:	8b 50 04             	mov    0x4(%eax),%edx
  8014ad:	8b 00                	mov    (%eax),%eax
  8014af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b8:	8d 40 08             	lea    0x8(%eax),%eax
  8014bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8014be:	eb 38                	jmp    8014f8 <vprintfmt+0x2ec>
	else if (lflag)
  8014c0:	85 c9                	test   %ecx,%ecx
  8014c2:	74 1b                	je     8014df <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8b 00                	mov    (%eax),%eax
  8014c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cc:	89 c1                	mov    %eax,%ecx
  8014ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d7:	8d 40 04             	lea    0x4(%eax),%eax
  8014da:	89 45 14             	mov    %eax,0x14(%ebp)
  8014dd:	eb 19                	jmp    8014f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014df:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e2:	8b 00                	mov    (%eax),%eax
  8014e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e7:	89 c1                	mov    %eax,%ecx
  8014e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f2:	8d 40 04             	lea    0x4(%eax),%eax
  8014f5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801503:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801507:	0f 89 0e 01 00 00    	jns    80161b <vprintfmt+0x40f>
				putch('-', putdat);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	53                   	push   %ebx
  801511:	6a 2d                	push   $0x2d
  801513:	ff d6                	call   *%esi
				num = -(long long) num;
  801515:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801518:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80151b:	f7 da                	neg    %edx
  80151d:	83 d1 00             	adc    $0x0,%ecx
  801520:	f7 d9                	neg    %ecx
  801522:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801525:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152a:	e9 ec 00 00 00       	jmp    80161b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80152f:	83 f9 01             	cmp    $0x1,%ecx
  801532:	7e 18                	jle    80154c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801534:	8b 45 14             	mov    0x14(%ebp),%eax
  801537:	8b 10                	mov    (%eax),%edx
  801539:	8b 48 04             	mov    0x4(%eax),%ecx
  80153c:	8d 40 08             	lea    0x8(%eax),%eax
  80153f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801542:	b8 0a 00 00 00       	mov    $0xa,%eax
  801547:	e9 cf 00 00 00       	jmp    80161b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80154c:	85 c9                	test   %ecx,%ecx
  80154e:	74 1a                	je     80156a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801550:	8b 45 14             	mov    0x14(%ebp),%eax
  801553:	8b 10                	mov    (%eax),%edx
  801555:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155a:	8d 40 04             	lea    0x4(%eax),%eax
  80155d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801560:	b8 0a 00 00 00       	mov    $0xa,%eax
  801565:	e9 b1 00 00 00       	jmp    80161b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80156a:	8b 45 14             	mov    0x14(%ebp),%eax
  80156d:	8b 10                	mov    (%eax),%edx
  80156f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801574:	8d 40 04             	lea    0x4(%eax),%eax
  801577:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80157a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80157f:	e9 97 00 00 00       	jmp    80161b <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	53                   	push   %ebx
  801588:	6a 58                	push   $0x58
  80158a:	ff d6                	call   *%esi
			putch('X', putdat);
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	53                   	push   %ebx
  801590:	6a 58                	push   $0x58
  801592:	ff d6                	call   *%esi
			putch('X', putdat);
  801594:	83 c4 08             	add    $0x8,%esp
  801597:	53                   	push   %ebx
  801598:	6a 58                	push   $0x58
  80159a:	ff d6                	call   *%esi
			break;
  80159c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015a2:	e9 8b fc ff ff       	jmp    801232 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	6a 30                	push   $0x30
  8015ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 78                	push   $0x78
  8015b5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ba:	8b 10                	mov    (%eax),%edx
  8015bc:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c1:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c4:	8d 40 04             	lea    0x4(%eax),%eax
  8015c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015cf:	eb 4a                	jmp    80161b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d1:	83 f9 01             	cmp    $0x1,%ecx
  8015d4:	7e 15                	jle    8015eb <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d9:	8b 10                	mov    (%eax),%edx
  8015db:	8b 48 04             	mov    0x4(%eax),%ecx
  8015de:	8d 40 08             	lea    0x8(%eax),%eax
  8015e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e9:	eb 30                	jmp    80161b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015eb:	85 c9                	test   %ecx,%ecx
  8015ed:	74 17                	je     801606 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f2:	8b 10                	mov    (%eax),%edx
  8015f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f9:	8d 40 04             	lea    0x4(%eax),%eax
  8015fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015ff:	b8 10 00 00 00       	mov    $0x10,%eax
  801604:	eb 15                	jmp    80161b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801606:	8b 45 14             	mov    0x14(%ebp),%eax
  801609:	8b 10                	mov    (%eax),%edx
  80160b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801610:	8d 40 04             	lea    0x4(%eax),%eax
  801613:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801616:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801622:	57                   	push   %edi
  801623:	ff 75 e0             	pushl  -0x20(%ebp)
  801626:	50                   	push   %eax
  801627:	51                   	push   %ecx
  801628:	52                   	push   %edx
  801629:	89 da                	mov    %ebx,%edx
  80162b:	89 f0                	mov    %esi,%eax
  80162d:	e8 f1 fa ff ff       	call   801123 <printnum>
			break;
  801632:	83 c4 20             	add    $0x20,%esp
  801635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801638:	e9 f5 fb ff ff       	jmp    801232 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	53                   	push   %ebx
  801641:	52                   	push   %edx
  801642:	ff d6                	call   *%esi
			break;
  801644:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164a:	e9 e3 fb ff ff       	jmp    801232 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	53                   	push   %ebx
  801653:	6a 25                	push   $0x25
  801655:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 03                	jmp    80165f <vprintfmt+0x453>
  80165c:	83 ef 01             	sub    $0x1,%edi
  80165f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801663:	75 f7                	jne    80165c <vprintfmt+0x450>
  801665:	e9 c8 fb ff ff       	jmp    801232 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 18             	sub    $0x18,%esp
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80167e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801681:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801685:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80168f:	85 c0                	test   %eax,%eax
  801691:	74 26                	je     8016b9 <vsnprintf+0x47>
  801693:	85 d2                	test   %edx,%edx
  801695:	7e 22                	jle    8016b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801697:	ff 75 14             	pushl  0x14(%ebp)
  80169a:	ff 75 10             	pushl  0x10(%ebp)
  80169d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	68 d2 11 80 00       	push   $0x8011d2
  8016a6:	e8 61 fb ff ff       	call   80120c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	eb 05                	jmp    8016be <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c9:	50                   	push   %eax
  8016ca:	ff 75 10             	pushl  0x10(%ebp)
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 9a ff ff ff       	call   801672 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e5:	eb 03                	jmp    8016ea <strlen+0x10>
		n++;
  8016e7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ee:	75 f7                	jne    8016e7 <strlen+0xd>
		n++;
	return n;
}
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801700:	eb 03                	jmp    801705 <strnlen+0x13>
		n++;
  801702:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801705:	39 c2                	cmp    %eax,%edx
  801707:	74 08                	je     801711 <strnlen+0x1f>
  801709:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80170d:	75 f3                	jne    801702 <strnlen+0x10>
  80170f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	8b 45 08             	mov    0x8(%ebp),%eax
  80171a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	83 c2 01             	add    $0x1,%edx
  801722:	83 c1 01             	add    $0x1,%ecx
  801725:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801729:	88 5a ff             	mov    %bl,-0x1(%edx)
  80172c:	84 db                	test   %bl,%bl
  80172e:	75 ef                	jne    80171f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801730:	5b                   	pop    %ebx
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173a:	53                   	push   %ebx
  80173b:	e8 9a ff ff ff       	call   8016da <strlen>
  801740:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801743:	ff 75 0c             	pushl  0xc(%ebp)
  801746:	01 d8                	add    %ebx,%eax
  801748:	50                   	push   %eax
  801749:	e8 c5 ff ff ff       	call   801713 <strcpy>
	return dst;
}
  80174e:	89 d8                	mov    %ebx,%eax
  801750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	8b 75 08             	mov    0x8(%ebp),%esi
  80175d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801760:	89 f3                	mov    %esi,%ebx
  801762:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801765:	89 f2                	mov    %esi,%edx
  801767:	eb 0f                	jmp    801778 <strncpy+0x23>
		*dst++ = *src;
  801769:	83 c2 01             	add    $0x1,%edx
  80176c:	0f b6 01             	movzbl (%ecx),%eax
  80176f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801772:	80 39 01             	cmpb   $0x1,(%ecx)
  801775:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801778:	39 da                	cmp    %ebx,%edx
  80177a:	75 ed                	jne    801769 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80177c:	89 f0                	mov    %esi,%eax
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	8b 75 08             	mov    0x8(%ebp),%esi
  80178a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178d:	8b 55 10             	mov    0x10(%ebp),%edx
  801790:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801792:	85 d2                	test   %edx,%edx
  801794:	74 21                	je     8017b7 <strlcpy+0x35>
  801796:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179a:	89 f2                	mov    %esi,%edx
  80179c:	eb 09                	jmp    8017a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80179e:	83 c2 01             	add    $0x1,%edx
  8017a1:	83 c1 01             	add    $0x1,%ecx
  8017a4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a7:	39 c2                	cmp    %eax,%edx
  8017a9:	74 09                	je     8017b4 <strlcpy+0x32>
  8017ab:	0f b6 19             	movzbl (%ecx),%ebx
  8017ae:	84 db                	test   %bl,%bl
  8017b0:	75 ec                	jne    80179e <strlcpy+0x1c>
  8017b2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b7:	29 f0                	sub    %esi,%eax
}
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c6:	eb 06                	jmp    8017ce <strcmp+0x11>
		p++, q++;
  8017c8:	83 c1 01             	add    $0x1,%ecx
  8017cb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017ce:	0f b6 01             	movzbl (%ecx),%eax
  8017d1:	84 c0                	test   %al,%al
  8017d3:	74 04                	je     8017d9 <strcmp+0x1c>
  8017d5:	3a 02                	cmp    (%edx),%al
  8017d7:	74 ef                	je     8017c8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d9:	0f b6 c0             	movzbl %al,%eax
  8017dc:	0f b6 12             	movzbl (%edx),%edx
  8017df:	29 d0                	sub    %edx,%eax
}
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	53                   	push   %ebx
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f2:	eb 06                	jmp    8017fa <strncmp+0x17>
		n--, p++, q++;
  8017f4:	83 c0 01             	add    $0x1,%eax
  8017f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017fa:	39 d8                	cmp    %ebx,%eax
  8017fc:	74 15                	je     801813 <strncmp+0x30>
  8017fe:	0f b6 08             	movzbl (%eax),%ecx
  801801:	84 c9                	test   %cl,%cl
  801803:	74 04                	je     801809 <strncmp+0x26>
  801805:	3a 0a                	cmp    (%edx),%cl
  801807:	74 eb                	je     8017f4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801809:	0f b6 00             	movzbl (%eax),%eax
  80180c:	0f b6 12             	movzbl (%edx),%edx
  80180f:	29 d0                	sub    %edx,%eax
  801811:	eb 05                	jmp    801818 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801818:	5b                   	pop    %ebx
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801825:	eb 07                	jmp    80182e <strchr+0x13>
		if (*s == c)
  801827:	38 ca                	cmp    %cl,%dl
  801829:	74 0f                	je     80183a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80182b:	83 c0 01             	add    $0x1,%eax
  80182e:	0f b6 10             	movzbl (%eax),%edx
  801831:	84 d2                	test   %dl,%dl
  801833:	75 f2                	jne    801827 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801846:	eb 03                	jmp    80184b <strfind+0xf>
  801848:	83 c0 01             	add    $0x1,%eax
  80184b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80184e:	38 ca                	cmp    %cl,%dl
  801850:	74 04                	je     801856 <strfind+0x1a>
  801852:	84 d2                	test   %dl,%dl
  801854:	75 f2                	jne    801848 <strfind+0xc>
			break;
	return (char *) s;
}
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	57                   	push   %edi
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801861:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801864:	85 c9                	test   %ecx,%ecx
  801866:	74 36                	je     80189e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801868:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80186e:	75 28                	jne    801898 <memset+0x40>
  801870:	f6 c1 03             	test   $0x3,%cl
  801873:	75 23                	jne    801898 <memset+0x40>
		c &= 0xFF;
  801875:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801879:	89 d3                	mov    %edx,%ebx
  80187b:	c1 e3 08             	shl    $0x8,%ebx
  80187e:	89 d6                	mov    %edx,%esi
  801880:	c1 e6 18             	shl    $0x18,%esi
  801883:	89 d0                	mov    %edx,%eax
  801885:	c1 e0 10             	shl    $0x10,%eax
  801888:	09 f0                	or     %esi,%eax
  80188a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80188c:	89 d8                	mov    %ebx,%eax
  80188e:	09 d0                	or     %edx,%eax
  801890:	c1 e9 02             	shr    $0x2,%ecx
  801893:	fc                   	cld    
  801894:	f3 ab                	rep stos %eax,%es:(%edi)
  801896:	eb 06                	jmp    80189e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801898:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189b:	fc                   	cld    
  80189c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80189e:	89 f8                	mov    %edi,%eax
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	57                   	push   %edi
  8018a9:	56                   	push   %esi
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b3:	39 c6                	cmp    %eax,%esi
  8018b5:	73 35                	jae    8018ec <memmove+0x47>
  8018b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018ba:	39 d0                	cmp    %edx,%eax
  8018bc:	73 2e                	jae    8018ec <memmove+0x47>
		s += n;
		d += n;
  8018be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c1:	89 d6                	mov    %edx,%esi
  8018c3:	09 fe                	or     %edi,%esi
  8018c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018cb:	75 13                	jne    8018e0 <memmove+0x3b>
  8018cd:	f6 c1 03             	test   $0x3,%cl
  8018d0:	75 0e                	jne    8018e0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d2:	83 ef 04             	sub    $0x4,%edi
  8018d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d8:	c1 e9 02             	shr    $0x2,%ecx
  8018db:	fd                   	std    
  8018dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018de:	eb 09                	jmp    8018e9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e0:	83 ef 01             	sub    $0x1,%edi
  8018e3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e6:	fd                   	std    
  8018e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e9:	fc                   	cld    
  8018ea:	eb 1d                	jmp    801909 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ec:	89 f2                	mov    %esi,%edx
  8018ee:	09 c2                	or     %eax,%edx
  8018f0:	f6 c2 03             	test   $0x3,%dl
  8018f3:	75 0f                	jne    801904 <memmove+0x5f>
  8018f5:	f6 c1 03             	test   $0x3,%cl
  8018f8:	75 0a                	jne    801904 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018fa:	c1 e9 02             	shr    $0x2,%ecx
  8018fd:	89 c7                	mov    %eax,%edi
  8018ff:	fc                   	cld    
  801900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801902:	eb 05                	jmp    801909 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801904:	89 c7                	mov    %eax,%edi
  801906:	fc                   	cld    
  801907:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801909:	5e                   	pop    %esi
  80190a:	5f                   	pop    %edi
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    

0080190d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801910:	ff 75 10             	pushl  0x10(%ebp)
  801913:	ff 75 0c             	pushl  0xc(%ebp)
  801916:	ff 75 08             	pushl  0x8(%ebp)
  801919:	e8 87 ff ff ff       	call   8018a5 <memmove>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192b:	89 c6                	mov    %eax,%esi
  80192d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801930:	eb 1a                	jmp    80194c <memcmp+0x2c>
		if (*s1 != *s2)
  801932:	0f b6 08             	movzbl (%eax),%ecx
  801935:	0f b6 1a             	movzbl (%edx),%ebx
  801938:	38 d9                	cmp    %bl,%cl
  80193a:	74 0a                	je     801946 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80193c:	0f b6 c1             	movzbl %cl,%eax
  80193f:	0f b6 db             	movzbl %bl,%ebx
  801942:	29 d8                	sub    %ebx,%eax
  801944:	eb 0f                	jmp    801955 <memcmp+0x35>
		s1++, s2++;
  801946:	83 c0 01             	add    $0x1,%eax
  801949:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80194c:	39 f0                	cmp    %esi,%eax
  80194e:	75 e2                	jne    801932 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5d                   	pop    %ebp
  801958:	c3                   	ret    

00801959 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	53                   	push   %ebx
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801960:	89 c1                	mov    %eax,%ecx
  801962:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801965:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801969:	eb 0a                	jmp    801975 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196b:	0f b6 10             	movzbl (%eax),%edx
  80196e:	39 da                	cmp    %ebx,%edx
  801970:	74 07                	je     801979 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801972:	83 c0 01             	add    $0x1,%eax
  801975:	39 c8                	cmp    %ecx,%eax
  801977:	72 f2                	jb     80196b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801979:	5b                   	pop    %ebx
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	57                   	push   %edi
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801985:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801988:	eb 03                	jmp    80198d <strtol+0x11>
		s++;
  80198a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198d:	0f b6 01             	movzbl (%ecx),%eax
  801990:	3c 20                	cmp    $0x20,%al
  801992:	74 f6                	je     80198a <strtol+0xe>
  801994:	3c 09                	cmp    $0x9,%al
  801996:	74 f2                	je     80198a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801998:	3c 2b                	cmp    $0x2b,%al
  80199a:	75 0a                	jne    8019a6 <strtol+0x2a>
		s++;
  80199c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80199f:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a4:	eb 11                	jmp    8019b7 <strtol+0x3b>
  8019a6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019ab:	3c 2d                	cmp    $0x2d,%al
  8019ad:	75 08                	jne    8019b7 <strtol+0x3b>
		s++, neg = 1;
  8019af:	83 c1 01             	add    $0x1,%ecx
  8019b2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019bd:	75 15                	jne    8019d4 <strtol+0x58>
  8019bf:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c2:	75 10                	jne    8019d4 <strtol+0x58>
  8019c4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c8:	75 7c                	jne    801a46 <strtol+0xca>
		s += 2, base = 16;
  8019ca:	83 c1 02             	add    $0x2,%ecx
  8019cd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d2:	eb 16                	jmp    8019ea <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d4:	85 db                	test   %ebx,%ebx
  8019d6:	75 12                	jne    8019ea <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019dd:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e0:	75 08                	jne    8019ea <strtol+0x6e>
		s++, base = 8;
  8019e2:	83 c1 01             	add    $0x1,%ecx
  8019e5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ef:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f2:	0f b6 11             	movzbl (%ecx),%edx
  8019f5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f8:	89 f3                	mov    %esi,%ebx
  8019fa:	80 fb 09             	cmp    $0x9,%bl
  8019fd:	77 08                	ja     801a07 <strtol+0x8b>
			dig = *s - '0';
  8019ff:	0f be d2             	movsbl %dl,%edx
  801a02:	83 ea 30             	sub    $0x30,%edx
  801a05:	eb 22                	jmp    801a29 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a07:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0a:	89 f3                	mov    %esi,%ebx
  801a0c:	80 fb 19             	cmp    $0x19,%bl
  801a0f:	77 08                	ja     801a19 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a11:	0f be d2             	movsbl %dl,%edx
  801a14:	83 ea 57             	sub    $0x57,%edx
  801a17:	eb 10                	jmp    801a29 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a19:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1c:	89 f3                	mov    %esi,%ebx
  801a1e:	80 fb 19             	cmp    $0x19,%bl
  801a21:	77 16                	ja     801a39 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a23:	0f be d2             	movsbl %dl,%edx
  801a26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a29:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a2c:	7d 0b                	jge    801a39 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a2e:	83 c1 01             	add    $0x1,%ecx
  801a31:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a37:	eb b9                	jmp    8019f2 <strtol+0x76>

	if (endptr)
  801a39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a3d:	74 0d                	je     801a4c <strtol+0xd0>
		*endptr = (char *) s;
  801a3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a42:	89 0e                	mov    %ecx,(%esi)
  801a44:	eb 06                	jmp    801a4c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a46:	85 db                	test   %ebx,%ebx
  801a48:	74 98                	je     8019e2 <strtol+0x66>
  801a4a:	eb 9e                	jmp    8019ea <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a4c:	89 c2                	mov    %eax,%edx
  801a4e:	f7 da                	neg    %edx
  801a50:	85 ff                	test   %edi,%edi
  801a52:	0f 45 c2             	cmovne %edx,%eax
}
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5f                   	pop    %edi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	57                   	push   %edi
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	8b 75 08             	mov    0x8(%ebp),%esi
  801a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a6c:	85 f6                	test   %esi,%esi
  801a6e:	74 06                	je     801a76 <ipc_recv+0x1c>
		*from_env_store = 0;
  801a70:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a76:	85 db                	test   %ebx,%ebx
  801a78:	74 06                	je     801a80 <ipc_recv+0x26>
		*perm_store = 0;
  801a7a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a80:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a82:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a87:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	50                   	push   %eax
  801a8e:	e8 72 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a93:	89 c7                	mov    %eax,%edi
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	79 14                	jns    801ab0 <ipc_recv+0x56>
		cprintf("im dead");
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	68 80 22 80 00       	push   $0x802280
  801aa4:	e8 66 f6 ff ff       	call   80110f <cprintf>
		return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	89 f8                	mov    %edi,%eax
  801aae:	eb 24                	jmp    801ad4 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ab0:	85 f6                	test   %esi,%esi
  801ab2:	74 0a                	je     801abe <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ab4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab9:	8b 40 74             	mov    0x74(%eax),%eax
  801abc:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	74 0a                	je     801acc <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 40 78             	mov    0x78(%eax),%eax
  801aca:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5f                   	pop    %edi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    

00801adc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	57                   	push   %edi
  801ae0:	56                   	push   %esi
  801ae1:	53                   	push   %ebx
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801aee:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801af5:	0f 44 d8             	cmove  %eax,%ebx
  801af8:	eb 1c                	jmp    801b16 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801afa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afd:	74 12                	je     801b11 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801aff:	50                   	push   %eax
  801b00:	68 88 22 80 00       	push   $0x802288
  801b05:	6a 4e                	push   $0x4e
  801b07:	68 95 22 80 00       	push   $0x802295
  801b0c:	e8 25 f5 ff ff       	call   801036 <_panic>
		sys_yield();
  801b11:	e8 20 e6 ff ff       	call   800136 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b16:	ff 75 14             	pushl  0x14(%ebp)
  801b19:	53                   	push   %ebx
  801b1a:	56                   	push   %esi
  801b1b:	57                   	push   %edi
  801b1c:	e8 c1 e7 ff ff       	call   8002e2 <sys_ipc_try_send>
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 d2                	js     801afa <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b3b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b3e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b44:	8b 52 50             	mov    0x50(%edx),%edx
  801b47:	39 ca                	cmp    %ecx,%edx
  801b49:	75 0d                	jne    801b58 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b4b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b53:	8b 40 48             	mov    0x48(%eax),%eax
  801b56:	eb 0f                	jmp    801b67 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b58:	83 c0 01             	add    $0x1,%eax
  801b5b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b60:	75 d9                	jne    801b3b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6f:	89 d0                	mov    %edx,%eax
  801b71:	c1 e8 16             	shr    $0x16,%eax
  801b74:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b80:	f6 c1 01             	test   $0x1,%cl
  801b83:	74 1d                	je     801ba2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b85:	c1 ea 0c             	shr    $0xc,%edx
  801b88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b8f:	f6 c2 01             	test   $0x1,%dl
  801b92:	74 0e                	je     801ba2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b94:	c1 ea 0c             	shr    $0xc,%edx
  801b97:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b9e:	ef 
  801b9f:	0f b7 c0             	movzwl %ax,%eax
}
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    
  801ba4:	66 90                	xchg   %ax,%ax
  801ba6:	66 90                	xchg   %ax,%ax
  801ba8:	66 90                	xchg   %ax,%ax
  801baa:	66 90                	xchg   %ax,%ax
  801bac:	66 90                	xchg   %ax,%ax
  801bae:	66 90                	xchg   %ax,%ax

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
