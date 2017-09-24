
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 4a 1e 80 00       	push   $0x801e4a
  800108:	6a 23                	push   $0x23
  80010a:	68 67 1e 80 00       	push   $0x801e67
  80010f:	e8 27 0f 00 00       	call   80103b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 4a 1e 80 00       	push   $0x801e4a
  800189:	6a 23                	push   $0x23
  80018b:	68 67 1e 80 00       	push   $0x801e67
  800190:	e8 a6 0e 00 00       	call   80103b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 4a 1e 80 00       	push   $0x801e4a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 67 1e 80 00       	push   $0x801e67
  8001d2:	e8 64 0e 00 00       	call   80103b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 4a 1e 80 00       	push   $0x801e4a
  80020d:	6a 23                	push   $0x23
  80020f:	68 67 1e 80 00       	push   $0x801e67
  800214:	e8 22 0e 00 00       	call   80103b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 4a 1e 80 00       	push   $0x801e4a
  80024f:	6a 23                	push   $0x23
  800251:	68 67 1e 80 00       	push   $0x801e67
  800256:	e8 e0 0d 00 00       	call   80103b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 4a 1e 80 00       	push   $0x801e4a
  800291:	6a 23                	push   $0x23
  800293:	68 67 1e 80 00       	push   $0x801e67
  800298:	e8 9e 0d 00 00       	call   80103b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 4a 1e 80 00       	push   $0x801e4a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 67 1e 80 00       	push   $0x801e67
  8002da:	e8 5c 0d 00 00       	call   80103b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 4a 1e 80 00       	push   $0x801e4a
  800337:	6a 23                	push   $0x23
  800339:	68 67 1e 80 00       	push   $0x801e67
  80033e:	e8 f8 0c 00 00       	call   80103b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 78 1e 80 00       	push   $0x801e78
  800452:	e8 bd 0c 00 00       	call   801114 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 b9 1e 80 00       	push   $0x801eb9
  80067c:	e8 93 0a 00 00       	call   801114 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 d5 1e 80 00       	push   $0x801ed5
  800751:	e8 be 09 00 00       	call   801114 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 98 1e 80 00       	push   $0x801e98
  800806:	e8 09 09 00 00       	call   801114 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 e9 01 00 00       	call   800ab8 <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 1f 12 00 00       	call   801b35 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 b0 11 00 00       	call   801ae1 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 21 11 00 00       	call   801a5f <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 51 0d 00 00       	call   801718 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
  8009f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009fd:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a00:	8b 55 08             	mov    0x8(%ebp),%edx
  800a03:	8b 52 0c             	mov    0xc(%edx),%edx
  800a06:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a0c:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a11:	50                   	push   %eax
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	68 08 50 80 00       	push   $0x805008
  800a1a:	e8 8b 0e 00 00       	call   8018aa <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a24:	b8 04 00 00 00       	mov    $0x4,%eax
  800a29:	e8 cc fe ff ff       	call   8008fa <fsipc>
            return r;

    return r;
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a43:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a53:	e8 a2 fe ff ff       	call   8008fa <fsipc>
  800a58:	89 c3                	mov    %eax,%ebx
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	78 51                	js     800aaf <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a5e:	39 c6                	cmp    %eax,%esi
  800a60:	73 19                	jae    800a7b <devfile_read+0x4b>
  800a62:	68 04 1f 80 00       	push   $0x801f04
  800a67:	68 0b 1f 80 00       	push   $0x801f0b
  800a6c:	68 82 00 00 00       	push   $0x82
  800a71:	68 20 1f 80 00       	push   $0x801f20
  800a76:	e8 c0 05 00 00       	call   80103b <_panic>
	assert(r <= PGSIZE);
  800a7b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a80:	7e 19                	jle    800a9b <devfile_read+0x6b>
  800a82:	68 2b 1f 80 00       	push   $0x801f2b
  800a87:	68 0b 1f 80 00       	push   $0x801f0b
  800a8c:	68 83 00 00 00       	push   $0x83
  800a91:	68 20 1f 80 00       	push   $0x801f20
  800a96:	e8 a0 05 00 00       	call   80103b <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9b:	83 ec 04             	sub    $0x4,%esp
  800a9e:	50                   	push   %eax
  800a9f:	68 00 50 80 00       	push   $0x805000
  800aa4:	ff 75 0c             	pushl  0xc(%ebp)
  800aa7:	e8 fe 0d 00 00       	call   8018aa <memmove>
	return r;
  800aac:	83 c4 10             	add    $0x10,%esp
}
  800aaf:	89 d8                	mov    %ebx,%eax
  800ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	53                   	push   %ebx
  800abc:	83 ec 20             	sub    $0x20,%esp
  800abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac2:	53                   	push   %ebx
  800ac3:	e8 17 0c 00 00       	call   8016df <strlen>
  800ac8:	83 c4 10             	add    $0x10,%esp
  800acb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad0:	7f 67                	jg     800b39 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad2:	83 ec 0c             	sub    $0xc,%esp
  800ad5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad8:	50                   	push   %eax
  800ad9:	e8 94 f8 ff ff       	call   800372 <fd_alloc>
  800ade:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	78 57                	js     800b3e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae7:	83 ec 08             	sub    $0x8,%esp
  800aea:	53                   	push   %ebx
  800aeb:	68 00 50 80 00       	push   $0x805000
  800af0:	e8 23 0c 00 00       	call   801718 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b00:	b8 01 00 00 00       	mov    $0x1,%eax
  800b05:	e8 f0 fd ff ff       	call   8008fa <fsipc>
  800b0a:	89 c3                	mov    %eax,%ebx
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	79 14                	jns    800b27 <open+0x6f>
		fd_close(fd, 0);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	6a 00                	push   $0x0
  800b18:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1b:	e8 4a f9 ff ff       	call   80046a <fd_close>
		return r;
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	89 da                	mov    %ebx,%edx
  800b25:	eb 17                	jmp    800b3e <open+0x86>
	}

	return fd2num(fd);
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2d:	e8 19 f8 ff ff       	call   80034b <fd2num>
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	83 c4 10             	add    $0x10,%esp
  800b37:	eb 05                	jmp    800b3e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b39:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b3e:	89 d0                	mov    %edx,%eax
  800b40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 08 00 00 00       	mov    $0x8,%eax
  800b55:	e8 a0 fd ff ff       	call   8008fa <fsipc>
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 08             	pushl  0x8(%ebp)
  800b6a:	e8 ec f7 ff ff       	call   80035b <fd2data>
  800b6f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b71:	83 c4 08             	add    $0x8,%esp
  800b74:	68 37 1f 80 00       	push   $0x801f37
  800b79:	53                   	push   %ebx
  800b7a:	e8 99 0b 00 00       	call   801718 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7f:	8b 46 04             	mov    0x4(%esi),%eax
  800b82:	2b 06                	sub    (%esi),%eax
  800b84:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b91:	00 00 00 
	stat->st_dev = &devpipe;
  800b94:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b9b:	30 80 00 
	return 0;
}
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb4:	53                   	push   %ebx
  800bb5:	6a 00                	push   $0x0
  800bb7:	e8 23 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bbc:	89 1c 24             	mov    %ebx,(%esp)
  800bbf:	e8 97 f7 ff ff       	call   80035b <fd2data>
  800bc4:	83 c4 08             	add    $0x8,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 00                	push   $0x0
  800bca:	e8 10 f6 ff ff       	call   8001df <sys_page_unmap>
}
  800bcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 1c             	sub    $0x1c,%esp
  800bdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be2:	a1 04 40 80 00       	mov    0x804004,%eax
  800be7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf0:	e8 79 0f 00 00       	call   801b6e <pageref>
  800bf5:	89 c3                	mov    %eax,%ebx
  800bf7:	89 3c 24             	mov    %edi,(%esp)
  800bfa:	e8 6f 0f 00 00       	call   801b6e <pageref>
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	39 c3                	cmp    %eax,%ebx
  800c04:	0f 94 c1             	sete   %cl
  800c07:	0f b6 c9             	movzbl %cl,%ecx
  800c0a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c0d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c13:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c16:	39 ce                	cmp    %ecx,%esi
  800c18:	74 1b                	je     800c35 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c1a:	39 c3                	cmp    %eax,%ebx
  800c1c:	75 c4                	jne    800be2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1e:	8b 42 58             	mov    0x58(%edx),%eax
  800c21:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c24:	50                   	push   %eax
  800c25:	56                   	push   %esi
  800c26:	68 3e 1f 80 00       	push   $0x801f3e
  800c2b:	e8 e4 04 00 00       	call   801114 <cprintf>
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	eb ad                	jmp    800be2 <_pipeisclosed+0xe>
	}
}
  800c35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 28             	sub    $0x28,%esp
  800c49:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4c:	56                   	push   %esi
  800c4d:	e8 09 f7 ff ff       	call   80035b <fd2data>
  800c52:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c54:	83 c4 10             	add    $0x10,%esp
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5c:	eb 4b                	jmp    800ca9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5e:	89 da                	mov    %ebx,%edx
  800c60:	89 f0                	mov    %esi,%eax
  800c62:	e8 6d ff ff ff       	call   800bd4 <_pipeisclosed>
  800c67:	85 c0                	test   %eax,%eax
  800c69:	75 48                	jne    800cb3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c6b:	e8 cb f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c70:	8b 43 04             	mov    0x4(%ebx),%eax
  800c73:	8b 0b                	mov    (%ebx),%ecx
  800c75:	8d 51 20             	lea    0x20(%ecx),%edx
  800c78:	39 d0                	cmp    %edx,%eax
  800c7a:	73 e2                	jae    800c5e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c83:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c86:	89 c2                	mov    %eax,%edx
  800c88:	c1 fa 1f             	sar    $0x1f,%edx
  800c8b:	89 d1                	mov    %edx,%ecx
  800c8d:	c1 e9 1b             	shr    $0x1b,%ecx
  800c90:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c93:	83 e2 1f             	and    $0x1f,%edx
  800c96:	29 ca                	sub    %ecx,%edx
  800c98:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca0:	83 c0 01             	add    $0x1,%eax
  800ca3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca6:	83 c7 01             	add    $0x1,%edi
  800ca9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cac:	75 c2                	jne    800c70 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb1:	eb 05                	jmp    800cb8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 18             	sub    $0x18,%esp
  800cc9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ccc:	57                   	push   %edi
  800ccd:	e8 89 f6 ff ff       	call   80035b <fd2data>
  800cd2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	eb 3d                	jmp    800d1b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cde:	85 db                	test   %ebx,%ebx
  800ce0:	74 04                	je     800ce6 <devpipe_read+0x26>
				return i;
  800ce2:	89 d8                	mov    %ebx,%eax
  800ce4:	eb 44                	jmp    800d2a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce6:	89 f2                	mov    %esi,%edx
  800ce8:	89 f8                	mov    %edi,%eax
  800cea:	e8 e5 fe ff ff       	call   800bd4 <_pipeisclosed>
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	75 32                	jne    800d25 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf3:	e8 43 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf8:	8b 06                	mov    (%esi),%eax
  800cfa:	3b 46 04             	cmp    0x4(%esi),%eax
  800cfd:	74 df                	je     800cde <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cff:	99                   	cltd   
  800d00:	c1 ea 1b             	shr    $0x1b,%edx
  800d03:	01 d0                	add    %edx,%eax
  800d05:	83 e0 1f             	and    $0x1f,%eax
  800d08:	29 d0                	sub    %edx,%eax
  800d0a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d15:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d18:	83 c3 01             	add    $0x1,%ebx
  800d1b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1e:	75 d8                	jne    800cf8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d20:	8b 45 10             	mov    0x10(%ebp),%eax
  800d23:	eb 05                	jmp    800d2a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3d:	50                   	push   %eax
  800d3e:	e8 2f f6 ff ff       	call   800372 <fd_alloc>
  800d43:	83 c4 10             	add    $0x10,%esp
  800d46:	89 c2                	mov    %eax,%edx
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	0f 88 2c 01 00 00    	js     800e7c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 07 04 00 00       	push   $0x407
  800d58:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5b:	6a 00                	push   $0x0
  800d5d:	e8 f8 f3 ff ff       	call   80015a <sys_page_alloc>
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	89 c2                	mov    %eax,%edx
  800d67:	85 c0                	test   %eax,%eax
  800d69:	0f 88 0d 01 00 00    	js     800e7c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d75:	50                   	push   %eax
  800d76:	e8 f7 f5 ff ff       	call   800372 <fd_alloc>
  800d7b:	89 c3                	mov    %eax,%ebx
  800d7d:	83 c4 10             	add    $0x10,%esp
  800d80:	85 c0                	test   %eax,%eax
  800d82:	0f 88 e2 00 00 00    	js     800e6a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d88:	83 ec 04             	sub    $0x4,%esp
  800d8b:	68 07 04 00 00       	push   $0x407
  800d90:	ff 75 f0             	pushl  -0x10(%ebp)
  800d93:	6a 00                	push   $0x0
  800d95:	e8 c0 f3 ff ff       	call   80015a <sys_page_alloc>
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	0f 88 c3 00 00 00    	js     800e6a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dad:	e8 a9 f5 ff ff       	call   80035b <fd2data>
  800db2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db4:	83 c4 0c             	add    $0xc,%esp
  800db7:	68 07 04 00 00       	push   $0x407
  800dbc:	50                   	push   %eax
  800dbd:	6a 00                	push   $0x0
  800dbf:	e8 96 f3 ff ff       	call   80015a <sys_page_alloc>
  800dc4:	89 c3                	mov    %eax,%ebx
  800dc6:	83 c4 10             	add    $0x10,%esp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	0f 88 89 00 00 00    	js     800e5a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd7:	e8 7f f5 ff ff       	call   80035b <fd2data>
  800ddc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de3:	50                   	push   %eax
  800de4:	6a 00                	push   $0x0
  800de6:	56                   	push   %esi
  800de7:	6a 00                	push   $0x0
  800de9:	e8 af f3 ff ff       	call   80019d <sys_page_map>
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	83 c4 20             	add    $0x20,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 55                	js     800e4c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e00:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e05:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e15:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e21:	83 ec 0c             	sub    $0xc,%esp
  800e24:	ff 75 f4             	pushl  -0xc(%ebp)
  800e27:	e8 1f f5 ff ff       	call   80034b <fd2num>
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e31:	83 c4 04             	add    $0x4,%esp
  800e34:	ff 75 f0             	pushl  -0x10(%ebp)
  800e37:	e8 0f f5 ff ff       	call   80034b <fd2num>
  800e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4a:	eb 30                	jmp    800e7c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4c:	83 ec 08             	sub    $0x8,%esp
  800e4f:	56                   	push   %esi
  800e50:	6a 00                	push   $0x0
  800e52:	e8 88 f3 ff ff       	call   8001df <sys_page_unmap>
  800e57:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e60:	6a 00                	push   $0x0
  800e62:	e8 78 f3 ff ff       	call   8001df <sys_page_unmap>
  800e67:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e70:	6a 00                	push   $0x0
  800e72:	e8 68 f3 ff ff       	call   8001df <sys_page_unmap>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7c:	89 d0                	mov    %edx,%eax
  800e7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8e:	50                   	push   %eax
  800e8f:	ff 75 08             	pushl  0x8(%ebp)
  800e92:	e8 2a f5 ff ff       	call   8003c1 <fd_lookup>
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	78 18                	js     800eb6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea4:	e8 b2 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eae:	e8 21 fd ff ff       	call   800bd4 <_pipeisclosed>
  800eb3:	83 c4 10             	add    $0x10,%esp
}
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec8:	68 56 1f 80 00       	push   $0x801f56
  800ecd:	ff 75 0c             	pushl  0xc(%ebp)
  800ed0:	e8 43 08 00 00       	call   801718 <strcpy>
	return 0;
}
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef3:	eb 2d                	jmp    800f22 <devcons_write+0x46>
		m = n - tot;
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800efa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800efd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f02:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	53                   	push   %ebx
  800f09:	03 45 0c             	add    0xc(%ebp),%eax
  800f0c:	50                   	push   %eax
  800f0d:	57                   	push   %edi
  800f0e:	e8 97 09 00 00       	call   8018aa <memmove>
		sys_cputs(buf, m);
  800f13:	83 c4 08             	add    $0x8,%esp
  800f16:	53                   	push   %ebx
  800f17:	57                   	push   %edi
  800f18:	e8 81 f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1d:	01 de                	add    %ebx,%esi
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	89 f0                	mov    %esi,%eax
  800f24:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f27:	72 cc                	jb     800ef5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f40:	74 2a                	je     800f6c <devcons_read+0x3b>
  800f42:	eb 05                	jmp    800f49 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f44:	e8 f2 f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f49:	e8 6e f1 ff ff       	call   8000bc <sys_cgetc>
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	74 f2                	je     800f44 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 16                	js     800f6c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f56:	83 f8 04             	cmp    $0x4,%eax
  800f59:	74 0c                	je     800f67 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5e:	88 02                	mov    %al,(%edx)
	return 1;
  800f60:	b8 01 00 00 00       	mov    $0x1,%eax
  800f65:	eb 05                	jmp    800f6c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f74:	8b 45 08             	mov    0x8(%ebp),%eax
  800f77:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f7a:	6a 01                	push   $0x1
  800f7c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	e8 19 f1 ff ff       	call   80009e <sys_cputs>
}
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    

00800f8a <getchar>:

int
getchar(void)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f90:	6a 01                	push   $0x1
  800f92:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	6a 00                	push   $0x0
  800f98:	e8 8a f6 ff ff       	call   800627 <read>
	if (r < 0)
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 0f                	js     800fb3 <getchar+0x29>
		return r;
	if (r < 1)
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	7e 06                	jle    800fae <getchar+0x24>
		return -E_EOF;
	return c;
  800fa8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fac:	eb 05                	jmp    800fb3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbe:	50                   	push   %eax
  800fbf:	ff 75 08             	pushl  0x8(%ebp)
  800fc2:	e8 fa f3 ff ff       	call   8003c1 <fd_lookup>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 11                	js     800fdf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd7:	39 10                	cmp    %edx,(%eax)
  800fd9:	0f 94 c0             	sete   %al
  800fdc:	0f b6 c0             	movzbl %al,%eax
}
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <opencons>:

int
opencons(void)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	e8 82 f3 ff ff       	call   800372 <fd_alloc>
  800ff0:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 3e                	js     801037 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	68 07 04 00 00       	push   $0x407
  801001:	ff 75 f4             	pushl  -0xc(%ebp)
  801004:	6a 00                	push   $0x0
  801006:	e8 4f f1 ff ff       	call   80015a <sys_page_alloc>
  80100b:	83 c4 10             	add    $0x10,%esp
		return r;
  80100e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801010:	85 c0                	test   %eax,%eax
  801012:	78 23                	js     801037 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801014:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801022:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	50                   	push   %eax
  80102d:	e8 19 f3 ff ff       	call   80034b <fd2num>
  801032:	89 c2                	mov    %eax,%edx
  801034:	83 c4 10             	add    $0x10,%esp
}
  801037:	89 d0                	mov    %edx,%eax
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801040:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801043:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801049:	e8 ce f0 ff ff       	call   80011c <sys_getenvid>
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	ff 75 0c             	pushl  0xc(%ebp)
  801054:	ff 75 08             	pushl  0x8(%ebp)
  801057:	56                   	push   %esi
  801058:	50                   	push   %eax
  801059:	68 64 1f 80 00       	push   $0x801f64
  80105e:	e8 b1 00 00 00       	call   801114 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801063:	83 c4 18             	add    $0x18,%esp
  801066:	53                   	push   %ebx
  801067:	ff 75 10             	pushl  0x10(%ebp)
  80106a:	e8 54 00 00 00       	call   8010c3 <vcprintf>
	cprintf("\n");
  80106f:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  801076:	e8 99 00 00 00       	call   801114 <cprintf>
  80107b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107e:	cc                   	int3   
  80107f:	eb fd                	jmp    80107e <_panic+0x43>

00801081 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	53                   	push   %ebx
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108b:	8b 13                	mov    (%ebx),%edx
  80108d:	8d 42 01             	lea    0x1(%edx),%eax
  801090:	89 03                	mov    %eax,(%ebx)
  801092:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801095:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801099:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109e:	75 1a                	jne    8010ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	68 ff 00 00 00       	push   $0xff
  8010a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ab:	50                   	push   %eax
  8010ac:	e8 ed ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d3:	00 00 00 
	b.cnt = 0;
  8010d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e0:	ff 75 0c             	pushl  0xc(%ebp)
  8010e3:	ff 75 08             	pushl  0x8(%ebp)
  8010e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	68 81 10 80 00       	push   $0x801081
  8010f2:	e8 1a 01 00 00       	call   801211 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f7:	83 c4 08             	add    $0x8,%esp
  8010fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801100:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801106:	50                   	push   %eax
  801107:	e8 92 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80110c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80111a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80111d:	50                   	push   %eax
  80111e:	ff 75 08             	pushl  0x8(%ebp)
  801121:	e8 9d ff ff ff       	call   8010c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	53                   	push   %ebx
  80112e:	83 ec 1c             	sub    $0x1c,%esp
  801131:	89 c7                	mov    %eax,%edi
  801133:	89 d6                	mov    %edx,%esi
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801141:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801144:	bb 00 00 00 00       	mov    $0x0,%ebx
  801149:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114f:	39 d3                	cmp    %edx,%ebx
  801151:	72 05                	jb     801158 <printnum+0x30>
  801153:	39 45 10             	cmp    %eax,0x10(%ebp)
  801156:	77 45                	ja     80119d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	ff 75 18             	pushl  0x18(%ebp)
  80115e:	8b 45 14             	mov    0x14(%ebp),%eax
  801161:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801164:	53                   	push   %ebx
  801165:	ff 75 10             	pushl  0x10(%ebp)
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116e:	ff 75 e0             	pushl  -0x20(%ebp)
  801171:	ff 75 dc             	pushl  -0x24(%ebp)
  801174:	ff 75 d8             	pushl  -0x28(%ebp)
  801177:	e8 34 0a 00 00       	call   801bb0 <__udivdi3>
  80117c:	83 c4 18             	add    $0x18,%esp
  80117f:	52                   	push   %edx
  801180:	50                   	push   %eax
  801181:	89 f2                	mov    %esi,%edx
  801183:	89 f8                	mov    %edi,%eax
  801185:	e8 9e ff ff ff       	call   801128 <printnum>
  80118a:	83 c4 20             	add    $0x20,%esp
  80118d:	eb 18                	jmp    8011a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	56                   	push   %esi
  801193:	ff 75 18             	pushl  0x18(%ebp)
  801196:	ff d7                	call   *%edi
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	eb 03                	jmp    8011a0 <printnum+0x78>
  80119d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a0:	83 eb 01             	sub    $0x1,%ebx
  8011a3:	85 db                	test   %ebx,%ebx
  8011a5:	7f e8                	jg     80118f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	56                   	push   %esi
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ba:	e8 21 0b 00 00       	call   801ce0 <__umoddi3>
  8011bf:	83 c4 14             	add    $0x14,%esp
  8011c2:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff d7                	call   *%edi
}
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e1:	8b 10                	mov    (%eax),%edx
  8011e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e6:	73 0a                	jae    8011f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011eb:	89 08                	mov    %ecx,(%eax)
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f0:	88 02                	mov    %al,(%edx)
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011fd:	50                   	push   %eax
  8011fe:	ff 75 10             	pushl  0x10(%ebp)
  801201:	ff 75 0c             	pushl  0xc(%ebp)
  801204:	ff 75 08             	pushl  0x8(%ebp)
  801207:	e8 05 00 00 00       	call   801211 <vprintfmt>
	va_end(ap);
}
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 2c             	sub    $0x2c,%esp
  80121a:	8b 75 08             	mov    0x8(%ebp),%esi
  80121d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801220:	8b 7d 10             	mov    0x10(%ebp),%edi
  801223:	eb 12                	jmp    801237 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801225:	85 c0                	test   %eax,%eax
  801227:	0f 84 42 04 00 00    	je     80166f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	53                   	push   %ebx
  801231:	50                   	push   %eax
  801232:	ff d6                	call   *%esi
  801234:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801237:	83 c7 01             	add    $0x1,%edi
  80123a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80123e:	83 f8 25             	cmp    $0x25,%eax
  801241:	75 e2                	jne    801225 <vprintfmt+0x14>
  801243:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801247:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80124e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801255:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80125c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801261:	eb 07                	jmp    80126a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801263:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801266:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126a:	8d 47 01             	lea    0x1(%edi),%eax
  80126d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801270:	0f b6 07             	movzbl (%edi),%eax
  801273:	0f b6 d0             	movzbl %al,%edx
  801276:	83 e8 23             	sub    $0x23,%eax
  801279:	3c 55                	cmp    $0x55,%al
  80127b:	0f 87 d3 03 00 00    	ja     801654 <vprintfmt+0x443>
  801281:	0f b6 c0             	movzbl %al,%eax
  801284:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80128b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80128e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801292:	eb d6                	jmp    80126a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801294:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
  80129c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012ac:	83 f9 09             	cmp    $0x9,%ecx
  8012af:	77 3f                	ja     8012f0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b4:	eb e9                	jmp    80129f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b9:	8b 00                	mov    (%eax),%eax
  8012bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012be:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c1:	8d 40 04             	lea    0x4(%eax),%eax
  8012c4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012ca:	eb 2a                	jmp    8012f6 <vprintfmt+0xe5>
  8012cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d6:	0f 49 d0             	cmovns %eax,%edx
  8012d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012df:	eb 89                	jmp    80126a <vprintfmt+0x59>
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012eb:	e9 7a ff ff ff       	jmp    80126a <vprintfmt+0x59>
  8012f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012fa:	0f 89 6a ff ff ff    	jns    80126a <vprintfmt+0x59>
				width = precision, precision = -1;
  801300:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801303:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801306:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130d:	e9 58 ff ff ff       	jmp    80126a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801312:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801318:	e9 4d ff ff ff       	jmp    80126a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80131d:	8b 45 14             	mov    0x14(%ebp),%eax
  801320:	8d 78 04             	lea    0x4(%eax),%edi
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	53                   	push   %ebx
  801327:	ff 30                	pushl  (%eax)
  801329:	ff d6                	call   *%esi
			break;
  80132b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80132e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801334:	e9 fe fe ff ff       	jmp    801237 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801339:	8b 45 14             	mov    0x14(%ebp),%eax
  80133c:	8d 78 04             	lea    0x4(%eax),%edi
  80133f:	8b 00                	mov    (%eax),%eax
  801341:	99                   	cltd   
  801342:	31 d0                	xor    %edx,%eax
  801344:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801346:	83 f8 0f             	cmp    $0xf,%eax
  801349:	7f 0b                	jg     801356 <vprintfmt+0x145>
  80134b:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  801352:	85 d2                	test   %edx,%edx
  801354:	75 1b                	jne    801371 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801356:	50                   	push   %eax
  801357:	68 9f 1f 80 00       	push   $0x801f9f
  80135c:	53                   	push   %ebx
  80135d:	56                   	push   %esi
  80135e:	e8 91 fe ff ff       	call   8011f4 <printfmt>
  801363:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801366:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80136c:	e9 c6 fe ff ff       	jmp    801237 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801371:	52                   	push   %edx
  801372:	68 1d 1f 80 00       	push   $0x801f1d
  801377:	53                   	push   %ebx
  801378:	56                   	push   %esi
  801379:	e8 76 fe ff ff       	call   8011f4 <printfmt>
  80137e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801381:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801387:	e9 ab fe ff ff       	jmp    801237 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138c:	8b 45 14             	mov    0x14(%ebp),%eax
  80138f:	83 c0 04             	add    $0x4,%eax
  801392:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801395:	8b 45 14             	mov    0x14(%ebp),%eax
  801398:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80139a:	85 ff                	test   %edi,%edi
  80139c:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  8013a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a8:	0f 8e 94 00 00 00    	jle    801442 <vprintfmt+0x231>
  8013ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b2:	0f 84 98 00 00 00    	je     801450 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8013be:	57                   	push   %edi
  8013bf:	e8 33 03 00 00       	call   8016f7 <strnlen>
  8013c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c7:	29 c1                	sub    %eax,%ecx
  8013c9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013db:	eb 0f                	jmp    8013ec <vprintfmt+0x1db>
					putch(padc, putdat);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e6:	83 ef 01             	sub    $0x1,%edi
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 ff                	test   %edi,%edi
  8013ee:	7f ed                	jg     8013dd <vprintfmt+0x1cc>
  8013f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013f6:	85 c9                	test   %ecx,%ecx
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	0f 49 c1             	cmovns %ecx,%eax
  801400:	29 c1                	sub    %eax,%ecx
  801402:	89 75 08             	mov    %esi,0x8(%ebp)
  801405:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801408:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80140b:	89 cb                	mov    %ecx,%ebx
  80140d:	eb 4d                	jmp    80145c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801413:	74 1b                	je     801430 <vprintfmt+0x21f>
  801415:	0f be c0             	movsbl %al,%eax
  801418:	83 e8 20             	sub    $0x20,%eax
  80141b:	83 f8 5e             	cmp    $0x5e,%eax
  80141e:	76 10                	jbe    801430 <vprintfmt+0x21f>
					putch('?', putdat);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 0c             	pushl  0xc(%ebp)
  801426:	6a 3f                	push   $0x3f
  801428:	ff 55 08             	call   *0x8(%ebp)
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	eb 0d                	jmp    80143d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 0c             	pushl  0xc(%ebp)
  801436:	52                   	push   %edx
  801437:	ff 55 08             	call   *0x8(%ebp)
  80143a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143d:	83 eb 01             	sub    $0x1,%ebx
  801440:	eb 1a                	jmp    80145c <vprintfmt+0x24b>
  801442:	89 75 08             	mov    %esi,0x8(%ebp)
  801445:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801448:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144e:	eb 0c                	jmp    80145c <vprintfmt+0x24b>
  801450:	89 75 08             	mov    %esi,0x8(%ebp)
  801453:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801456:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801459:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145c:	83 c7 01             	add    $0x1,%edi
  80145f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801463:	0f be d0             	movsbl %al,%edx
  801466:	85 d2                	test   %edx,%edx
  801468:	74 23                	je     80148d <vprintfmt+0x27c>
  80146a:	85 f6                	test   %esi,%esi
  80146c:	78 a1                	js     80140f <vprintfmt+0x1fe>
  80146e:	83 ee 01             	sub    $0x1,%esi
  801471:	79 9c                	jns    80140f <vprintfmt+0x1fe>
  801473:	89 df                	mov    %ebx,%edi
  801475:	8b 75 08             	mov    0x8(%ebp),%esi
  801478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147b:	eb 18                	jmp    801495 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	53                   	push   %ebx
  801481:	6a 20                	push   $0x20
  801483:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801485:	83 ef 01             	sub    $0x1,%edi
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 08                	jmp    801495 <vprintfmt+0x284>
  80148d:	89 df                	mov    %ebx,%edi
  80148f:	8b 75 08             	mov    0x8(%ebp),%esi
  801492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801495:	85 ff                	test   %edi,%edi
  801497:	7f e4                	jg     80147d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801499:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80149c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a2:	e9 90 fd ff ff       	jmp    801237 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a7:	83 f9 01             	cmp    $0x1,%ecx
  8014aa:	7e 19                	jle    8014c5 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8014af:	8b 50 04             	mov    0x4(%eax),%edx
  8014b2:	8b 00                	mov    (%eax),%eax
  8014b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bd:	8d 40 08             	lea    0x8(%eax),%eax
  8014c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c3:	eb 38                	jmp    8014fd <vprintfmt+0x2ec>
	else if (lflag)
  8014c5:	85 c9                	test   %ecx,%ecx
  8014c7:	74 1b                	je     8014e4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cc:	8b 00                	mov    (%eax),%eax
  8014ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d1:	89 c1                	mov    %eax,%ecx
  8014d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dc:	8d 40 04             	lea    0x4(%eax),%eax
  8014df:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e2:	eb 19                	jmp    8014fd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8b 00                	mov    (%eax),%eax
  8014e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ec:	89 c1                	mov    %eax,%ecx
  8014ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f7:	8d 40 04             	lea    0x4(%eax),%eax
  8014fa:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801500:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801503:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801508:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80150c:	0f 89 0e 01 00 00    	jns    801620 <vprintfmt+0x40f>
				putch('-', putdat);
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	53                   	push   %ebx
  801516:	6a 2d                	push   $0x2d
  801518:	ff d6                	call   *%esi
				num = -(long long) num;
  80151a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80151d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801520:	f7 da                	neg    %edx
  801522:	83 d1 00             	adc    $0x0,%ecx
  801525:	f7 d9                	neg    %ecx
  801527:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80152a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152f:	e9 ec 00 00 00       	jmp    801620 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801534:	83 f9 01             	cmp    $0x1,%ecx
  801537:	7e 18                	jle    801551 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801539:	8b 45 14             	mov    0x14(%ebp),%eax
  80153c:	8b 10                	mov    (%eax),%edx
  80153e:	8b 48 04             	mov    0x4(%eax),%ecx
  801541:	8d 40 08             	lea    0x8(%eax),%eax
  801544:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154c:	e9 cf 00 00 00       	jmp    801620 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801551:	85 c9                	test   %ecx,%ecx
  801553:	74 1a                	je     80156f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801555:	8b 45 14             	mov    0x14(%ebp),%eax
  801558:	8b 10                	mov    (%eax),%edx
  80155a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155f:	8d 40 04             	lea    0x4(%eax),%eax
  801562:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801565:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156a:	e9 b1 00 00 00       	jmp    801620 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8b 10                	mov    (%eax),%edx
  801574:	b9 00 00 00 00       	mov    $0x0,%ecx
  801579:	8d 40 04             	lea    0x4(%eax),%eax
  80157c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80157f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801584:	e9 97 00 00 00       	jmp    801620 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 58                	push   $0x58
  80158f:	ff d6                	call   *%esi
			putch('X', putdat);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 58                	push   $0x58
  801597:	ff d6                	call   *%esi
			putch('X', putdat);
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	6a 58                	push   $0x58
  80159f:	ff d6                	call   *%esi
			break;
  8015a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015a7:	e9 8b fc ff ff       	jmp    801237 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	6a 30                	push   $0x30
  8015b2:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	6a 78                	push   $0x78
  8015ba:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bf:	8b 10                	mov    (%eax),%edx
  8015c1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c9:	8d 40 04             	lea    0x4(%eax),%eax
  8015cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d4:	eb 4a                	jmp    801620 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d6:	83 f9 01             	cmp    $0x1,%ecx
  8015d9:	7e 15                	jle    8015f0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015db:	8b 45 14             	mov    0x14(%ebp),%eax
  8015de:	8b 10                	mov    (%eax),%edx
  8015e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e3:	8d 40 08             	lea    0x8(%eax),%eax
  8015e6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ee:	eb 30                	jmp    801620 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f0:	85 c9                	test   %ecx,%ecx
  8015f2:	74 17                	je     80160b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f7:	8b 10                	mov    (%eax),%edx
  8015f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fe:	8d 40 04             	lea    0x4(%eax),%eax
  801601:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801604:	b8 10 00 00 00       	mov    $0x10,%eax
  801609:	eb 15                	jmp    801620 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8b 10                	mov    (%eax),%edx
  801610:	b9 00 00 00 00       	mov    $0x0,%ecx
  801615:	8d 40 04             	lea    0x4(%eax),%eax
  801618:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801627:	57                   	push   %edi
  801628:	ff 75 e0             	pushl  -0x20(%ebp)
  80162b:	50                   	push   %eax
  80162c:	51                   	push   %ecx
  80162d:	52                   	push   %edx
  80162e:	89 da                	mov    %ebx,%edx
  801630:	89 f0                	mov    %esi,%eax
  801632:	e8 f1 fa ff ff       	call   801128 <printnum>
			break;
  801637:	83 c4 20             	add    $0x20,%esp
  80163a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163d:	e9 f5 fb ff ff       	jmp    801237 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	53                   	push   %ebx
  801646:	52                   	push   %edx
  801647:	ff d6                	call   *%esi
			break;
  801649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164f:	e9 e3 fb ff ff       	jmp    801237 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	53                   	push   %ebx
  801658:	6a 25                	push   $0x25
  80165a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 03                	jmp    801664 <vprintfmt+0x453>
  801661:	83 ef 01             	sub    $0x1,%edi
  801664:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801668:	75 f7                	jne    801661 <vprintfmt+0x450>
  80166a:	e9 c8 fb ff ff       	jmp    801237 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 18             	sub    $0x18,%esp
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801686:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80168a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80168d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801694:	85 c0                	test   %eax,%eax
  801696:	74 26                	je     8016be <vsnprintf+0x47>
  801698:	85 d2                	test   %edx,%edx
  80169a:	7e 22                	jle    8016be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80169c:	ff 75 14             	pushl  0x14(%ebp)
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	68 d7 11 80 00       	push   $0x8011d7
  8016ab:	e8 61 fb ff ff       	call   801211 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 05                	jmp    8016c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 10             	pushl  0x10(%ebp)
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 9a ff ff ff       	call   801677 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ea:	eb 03                	jmp    8016ef <strlen+0x10>
		n++;
  8016ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f3:	75 f7                	jne    8016ec <strlen+0xd>
		n++;
	return n;
}
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	eb 03                	jmp    80170a <strnlen+0x13>
		n++;
  801707:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170a:	39 c2                	cmp    %eax,%edx
  80170c:	74 08                	je     801716 <strnlen+0x1f>
  80170e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801712:	75 f3                	jne    801707 <strnlen+0x10>
  801714:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801722:	89 c2                	mov    %eax,%edx
  801724:	83 c2 01             	add    $0x1,%edx
  801727:	83 c1 01             	add    $0x1,%ecx
  80172a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80172e:	88 5a ff             	mov    %bl,-0x1(%edx)
  801731:	84 db                	test   %bl,%bl
  801733:	75 ef                	jne    801724 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801735:	5b                   	pop    %ebx
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	53                   	push   %ebx
  80173c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173f:	53                   	push   %ebx
  801740:	e8 9a ff ff ff       	call   8016df <strlen>
  801745:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801748:	ff 75 0c             	pushl  0xc(%ebp)
  80174b:	01 d8                	add    %ebx,%eax
  80174d:	50                   	push   %eax
  80174e:	e8 c5 ff ff ff       	call   801718 <strcpy>
	return dst;
}
  801753:	89 d8                	mov    %ebx,%eax
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	8b 75 08             	mov    0x8(%ebp),%esi
  801762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801765:	89 f3                	mov    %esi,%ebx
  801767:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176a:	89 f2                	mov    %esi,%edx
  80176c:	eb 0f                	jmp    80177d <strncpy+0x23>
		*dst++ = *src;
  80176e:	83 c2 01             	add    $0x1,%edx
  801771:	0f b6 01             	movzbl (%ecx),%eax
  801774:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801777:	80 39 01             	cmpb   $0x1,(%ecx)
  80177a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177d:	39 da                	cmp    %ebx,%edx
  80177f:	75 ed                	jne    80176e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801781:	89 f0                	mov    %esi,%eax
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	8b 75 08             	mov    0x8(%ebp),%esi
  80178f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801792:	8b 55 10             	mov    0x10(%ebp),%edx
  801795:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801797:	85 d2                	test   %edx,%edx
  801799:	74 21                	je     8017bc <strlcpy+0x35>
  80179b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179f:	89 f2                	mov    %esi,%edx
  8017a1:	eb 09                	jmp    8017ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a3:	83 c2 01             	add    $0x1,%edx
  8017a6:	83 c1 01             	add    $0x1,%ecx
  8017a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017ac:	39 c2                	cmp    %eax,%edx
  8017ae:	74 09                	je     8017b9 <strlcpy+0x32>
  8017b0:	0f b6 19             	movzbl (%ecx),%ebx
  8017b3:	84 db                	test   %bl,%bl
  8017b5:	75 ec                	jne    8017a3 <strlcpy+0x1c>
  8017b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017bc:	29 f0                	sub    %esi,%eax
}
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017cb:	eb 06                	jmp    8017d3 <strcmp+0x11>
		p++, q++;
  8017cd:	83 c1 01             	add    $0x1,%ecx
  8017d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d3:	0f b6 01             	movzbl (%ecx),%eax
  8017d6:	84 c0                	test   %al,%al
  8017d8:	74 04                	je     8017de <strcmp+0x1c>
  8017da:	3a 02                	cmp    (%edx),%al
  8017dc:	74 ef                	je     8017cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017de:	0f b6 c0             	movzbl %al,%eax
  8017e1:	0f b6 12             	movzbl (%edx),%edx
  8017e4:	29 d0                	sub    %edx,%eax
}
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f2:	89 c3                	mov    %eax,%ebx
  8017f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f7:	eb 06                	jmp    8017ff <strncmp+0x17>
		n--, p++, q++;
  8017f9:	83 c0 01             	add    $0x1,%eax
  8017fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ff:	39 d8                	cmp    %ebx,%eax
  801801:	74 15                	je     801818 <strncmp+0x30>
  801803:	0f b6 08             	movzbl (%eax),%ecx
  801806:	84 c9                	test   %cl,%cl
  801808:	74 04                	je     80180e <strncmp+0x26>
  80180a:	3a 0a                	cmp    (%edx),%cl
  80180c:	74 eb                	je     8017f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180e:	0f b6 00             	movzbl (%eax),%eax
  801811:	0f b6 12             	movzbl (%edx),%edx
  801814:	29 d0                	sub    %edx,%eax
  801816:	eb 05                	jmp    80181d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80181d:	5b                   	pop    %ebx
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182a:	eb 07                	jmp    801833 <strchr+0x13>
		if (*s == c)
  80182c:	38 ca                	cmp    %cl,%dl
  80182e:	74 0f                	je     80183f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801830:	83 c0 01             	add    $0x1,%eax
  801833:	0f b6 10             	movzbl (%eax),%edx
  801836:	84 d2                	test   %dl,%dl
  801838:	75 f2                	jne    80182c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184b:	eb 03                	jmp    801850 <strfind+0xf>
  80184d:	83 c0 01             	add    $0x1,%eax
  801850:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801853:	38 ca                	cmp    %cl,%dl
  801855:	74 04                	je     80185b <strfind+0x1a>
  801857:	84 d2                	test   %dl,%dl
  801859:	75 f2                	jne    80184d <strfind+0xc>
			break;
	return (char *) s;
}
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	57                   	push   %edi
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 7d 08             	mov    0x8(%ebp),%edi
  801866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801869:	85 c9                	test   %ecx,%ecx
  80186b:	74 36                	je     8018a3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801873:	75 28                	jne    80189d <memset+0x40>
  801875:	f6 c1 03             	test   $0x3,%cl
  801878:	75 23                	jne    80189d <memset+0x40>
		c &= 0xFF;
  80187a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187e:	89 d3                	mov    %edx,%ebx
  801880:	c1 e3 08             	shl    $0x8,%ebx
  801883:	89 d6                	mov    %edx,%esi
  801885:	c1 e6 18             	shl    $0x18,%esi
  801888:	89 d0                	mov    %edx,%eax
  80188a:	c1 e0 10             	shl    $0x10,%eax
  80188d:	09 f0                	or     %esi,%eax
  80188f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801891:	89 d8                	mov    %ebx,%eax
  801893:	09 d0                	or     %edx,%eax
  801895:	c1 e9 02             	shr    $0x2,%ecx
  801898:	fc                   	cld    
  801899:	f3 ab                	rep stos %eax,%es:(%edi)
  80189b:	eb 06                	jmp    8018a3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	fc                   	cld    
  8018a1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a3:	89 f8                	mov    %edi,%eax
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b8:	39 c6                	cmp    %eax,%esi
  8018ba:	73 35                	jae    8018f1 <memmove+0x47>
  8018bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018bf:	39 d0                	cmp    %edx,%eax
  8018c1:	73 2e                	jae    8018f1 <memmove+0x47>
		s += n;
		d += n;
  8018c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c6:	89 d6                	mov    %edx,%esi
  8018c8:	09 fe                	or     %edi,%esi
  8018ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d0:	75 13                	jne    8018e5 <memmove+0x3b>
  8018d2:	f6 c1 03             	test   $0x3,%cl
  8018d5:	75 0e                	jne    8018e5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d7:	83 ef 04             	sub    $0x4,%edi
  8018da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018dd:	c1 e9 02             	shr    $0x2,%ecx
  8018e0:	fd                   	std    
  8018e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e3:	eb 09                	jmp    8018ee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e5:	83 ef 01             	sub    $0x1,%edi
  8018e8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018eb:	fd                   	std    
  8018ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ee:	fc                   	cld    
  8018ef:	eb 1d                	jmp    80190e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f1:	89 f2                	mov    %esi,%edx
  8018f3:	09 c2                	or     %eax,%edx
  8018f5:	f6 c2 03             	test   $0x3,%dl
  8018f8:	75 0f                	jne    801909 <memmove+0x5f>
  8018fa:	f6 c1 03             	test   $0x3,%cl
  8018fd:	75 0a                	jne    801909 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ff:	c1 e9 02             	shr    $0x2,%ecx
  801902:	89 c7                	mov    %eax,%edi
  801904:	fc                   	cld    
  801905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801907:	eb 05                	jmp    80190e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801909:	89 c7                	mov    %eax,%edi
  80190b:	fc                   	cld    
  80190c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190e:	5e                   	pop    %esi
  80190f:	5f                   	pop    %edi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801915:	ff 75 10             	pushl  0x10(%ebp)
  801918:	ff 75 0c             	pushl  0xc(%ebp)
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 87 ff ff ff       	call   8018aa <memmove>
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801930:	89 c6                	mov    %eax,%esi
  801932:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801935:	eb 1a                	jmp    801951 <memcmp+0x2c>
		if (*s1 != *s2)
  801937:	0f b6 08             	movzbl (%eax),%ecx
  80193a:	0f b6 1a             	movzbl (%edx),%ebx
  80193d:	38 d9                	cmp    %bl,%cl
  80193f:	74 0a                	je     80194b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801941:	0f b6 c1             	movzbl %cl,%eax
  801944:	0f b6 db             	movzbl %bl,%ebx
  801947:	29 d8                	sub    %ebx,%eax
  801949:	eb 0f                	jmp    80195a <memcmp+0x35>
		s1++, s2++;
  80194b:	83 c0 01             	add    $0x1,%eax
  80194e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801951:	39 f0                	cmp    %esi,%eax
  801953:	75 e2                	jne    801937 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801965:	89 c1                	mov    %eax,%ecx
  801967:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80196a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196e:	eb 0a                	jmp    80197a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801970:	0f b6 10             	movzbl (%eax),%edx
  801973:	39 da                	cmp    %ebx,%edx
  801975:	74 07                	je     80197e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801977:	83 c0 01             	add    $0x1,%eax
  80197a:	39 c8                	cmp    %ecx,%eax
  80197c:	72 f2                	jb     801970 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197e:	5b                   	pop    %ebx
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	57                   	push   %edi
  801985:	56                   	push   %esi
  801986:	53                   	push   %ebx
  801987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198d:	eb 03                	jmp    801992 <strtol+0x11>
		s++;
  80198f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801992:	0f b6 01             	movzbl (%ecx),%eax
  801995:	3c 20                	cmp    $0x20,%al
  801997:	74 f6                	je     80198f <strtol+0xe>
  801999:	3c 09                	cmp    $0x9,%al
  80199b:	74 f2                	je     80198f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199d:	3c 2b                	cmp    $0x2b,%al
  80199f:	75 0a                	jne    8019ab <strtol+0x2a>
		s++;
  8019a1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a9:	eb 11                	jmp    8019bc <strtol+0x3b>
  8019ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b0:	3c 2d                	cmp    $0x2d,%al
  8019b2:	75 08                	jne    8019bc <strtol+0x3b>
		s++, neg = 1;
  8019b4:	83 c1 01             	add    $0x1,%ecx
  8019b7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c2:	75 15                	jne    8019d9 <strtol+0x58>
  8019c4:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c7:	75 10                	jne    8019d9 <strtol+0x58>
  8019c9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019cd:	75 7c                	jne    801a4b <strtol+0xca>
		s += 2, base = 16;
  8019cf:	83 c1 02             	add    $0x2,%ecx
  8019d2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d7:	eb 16                	jmp    8019ef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d9:	85 db                	test   %ebx,%ebx
  8019db:	75 12                	jne    8019ef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019dd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e5:	75 08                	jne    8019ef <strtol+0x6e>
		s++, base = 8;
  8019e7:	83 c1 01             	add    $0x1,%ecx
  8019ea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f7:	0f b6 11             	movzbl (%ecx),%edx
  8019fa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fd:	89 f3                	mov    %esi,%ebx
  8019ff:	80 fb 09             	cmp    $0x9,%bl
  801a02:	77 08                	ja     801a0c <strtol+0x8b>
			dig = *s - '0';
  801a04:	0f be d2             	movsbl %dl,%edx
  801a07:	83 ea 30             	sub    $0x30,%edx
  801a0a:	eb 22                	jmp    801a2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0f:	89 f3                	mov    %esi,%ebx
  801a11:	80 fb 19             	cmp    $0x19,%bl
  801a14:	77 08                	ja     801a1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a16:	0f be d2             	movsbl %dl,%edx
  801a19:	83 ea 57             	sub    $0x57,%edx
  801a1c:	eb 10                	jmp    801a2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a21:	89 f3                	mov    %esi,%ebx
  801a23:	80 fb 19             	cmp    $0x19,%bl
  801a26:	77 16                	ja     801a3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a28:	0f be d2             	movsbl %dl,%edx
  801a2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a31:	7d 0b                	jge    801a3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a33:	83 c1 01             	add    $0x1,%ecx
  801a36:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a3c:	eb b9                	jmp    8019f7 <strtol+0x76>

	if (endptr)
  801a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a42:	74 0d                	je     801a51 <strtol+0xd0>
		*endptr = (char *) s;
  801a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a47:	89 0e                	mov    %ecx,(%esi)
  801a49:	eb 06                	jmp    801a51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4b:	85 db                	test   %ebx,%ebx
  801a4d:	74 98                	je     8019e7 <strtol+0x66>
  801a4f:	eb 9e                	jmp    8019ef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a51:	89 c2                	mov    %eax,%edx
  801a53:	f7 da                	neg    %edx
  801a55:	85 ff                	test   %edi,%edi
  801a57:	0f 45 c2             	cmovne %edx,%eax
}
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a71:	85 f6                	test   %esi,%esi
  801a73:	74 06                	je     801a7b <ipc_recv+0x1c>
		*from_env_store = 0;
  801a75:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a7b:	85 db                	test   %ebx,%ebx
  801a7d:	74 06                	je     801a85 <ipc_recv+0x26>
		*perm_store = 0;
  801a7f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a85:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a87:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a8c:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	50                   	push   %eax
  801a93:	e8 72 e8 ff ff       	call   80030a <sys_ipc_recv>
  801a98:	89 c7                	mov    %eax,%edi
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 14                	jns    801ab5 <ipc_recv+0x56>
		cprintf("im dead");
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	68 80 22 80 00       	push   $0x802280
  801aa9:	e8 66 f6 ff ff       	call   801114 <cprintf>
		return r;
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	89 f8                	mov    %edi,%eax
  801ab3:	eb 24                	jmp    801ad9 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ab5:	85 f6                	test   %esi,%esi
  801ab7:	74 0a                	je     801ac3 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ab9:	a1 04 40 80 00       	mov    0x804004,%eax
  801abe:	8b 40 74             	mov    0x74(%eax),%eax
  801ac1:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ac3:	85 db                	test   %ebx,%ebx
  801ac5:	74 0a                	je     801ad1 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 40 78             	mov    0x78(%eax),%eax
  801acf:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801ad1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	57                   	push   %edi
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aed:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801af3:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801af5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801afa:	0f 44 d8             	cmove  %eax,%ebx
  801afd:	eb 1c                	jmp    801b1b <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801aff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b02:	74 12                	je     801b16 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b04:	50                   	push   %eax
  801b05:	68 88 22 80 00       	push   $0x802288
  801b0a:	6a 4e                	push   $0x4e
  801b0c:	68 95 22 80 00       	push   $0x802295
  801b11:	e8 25 f5 ff ff       	call   80103b <_panic>
		sys_yield();
  801b16:	e8 20 e6 ff ff       	call   80013b <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b1b:	ff 75 14             	pushl  0x14(%ebp)
  801b1e:	53                   	push   %ebx
  801b1f:	56                   	push   %esi
  801b20:	57                   	push   %edi
  801b21:	e8 c1 e7 ff ff       	call   8002e7 <sys_ipc_try_send>
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 d2                	js     801aff <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5f                   	pop    %edi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b40:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b49:	8b 52 50             	mov    0x50(%edx),%edx
  801b4c:	39 ca                	cmp    %ecx,%edx
  801b4e:	75 0d                	jne    801b5d <ipc_find_env+0x28>
			return envs[i].env_id;
  801b50:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b53:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b58:	8b 40 48             	mov    0x48(%eax),%eax
  801b5b:	eb 0f                	jmp    801b6c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b5d:	83 c0 01             	add    $0x1,%eax
  801b60:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b65:	75 d9                	jne    801b40 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b74:	89 d0                	mov    %edx,%eax
  801b76:	c1 e8 16             	shr    $0x16,%eax
  801b79:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b85:	f6 c1 01             	test   $0x1,%cl
  801b88:	74 1d                	je     801ba7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b8a:	c1 ea 0c             	shr    $0xc,%edx
  801b8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b94:	f6 c2 01             	test   $0x1,%dl
  801b97:	74 0e                	je     801ba7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b99:	c1 ea 0c             	shr    $0xc,%edx
  801b9c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba3:	ef 
  801ba4:	0f b7 c0             	movzwl %ax,%eax
}
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    
  801ba9:	66 90                	xchg   %ax,%ax
  801bab:	66 90                	xchg   %ax,%ax
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
