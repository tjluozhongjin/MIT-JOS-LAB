
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 4a 1e 80 00       	push   $0x801e4a
  800104:	6a 23                	push   $0x23
  800106:	68 67 1e 80 00       	push   $0x801e67
  80010b:	e8 27 0f 00 00       	call   801037 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 4a 1e 80 00       	push   $0x801e4a
  800185:	6a 23                	push   $0x23
  800187:	68 67 1e 80 00       	push   $0x801e67
  80018c:	e8 a6 0e 00 00       	call   801037 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 4a 1e 80 00       	push   $0x801e4a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 67 1e 80 00       	push   $0x801e67
  8001ce:	e8 64 0e 00 00       	call   801037 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 4a 1e 80 00       	push   $0x801e4a
  800209:	6a 23                	push   $0x23
  80020b:	68 67 1e 80 00       	push   $0x801e67
  800210:	e8 22 0e 00 00       	call   801037 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 4a 1e 80 00       	push   $0x801e4a
  80024b:	6a 23                	push   $0x23
  80024d:	68 67 1e 80 00       	push   $0x801e67
  800252:	e8 e0 0d 00 00       	call   801037 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 4a 1e 80 00       	push   $0x801e4a
  80028d:	6a 23                	push   $0x23
  80028f:	68 67 1e 80 00       	push   $0x801e67
  800294:	e8 9e 0d 00 00       	call   801037 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 4a 1e 80 00       	push   $0x801e4a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 67 1e 80 00       	push   $0x801e67
  8002d6:	e8 5c 0d 00 00       	call   801037 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 4a 1e 80 00       	push   $0x801e4a
  800333:	6a 23                	push   $0x23
  800335:	68 67 1e 80 00       	push   $0x801e67
  80033a:	e8 f8 0c 00 00       	call   801037 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 78 1e 80 00       	push   $0x801e78
  80044e:	e8 bd 0c 00 00       	call   801110 <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 b9 1e 80 00       	push   $0x801eb9
  800678:	e8 93 0a 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 d5 1e 80 00       	push   $0x801ed5
  80074d:	e8 be 09 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 98 1e 80 00       	push   $0x801e98
  800802:	e8 09 09 00 00       	call   801110 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 e9 01 00 00       	call   800ab4 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 1f 12 00 00       	call   801b31 <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 b0 11 00 00       	call   801add <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 21 11 00 00       	call   801a5b <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 51 0d 00 00       	call   801714 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f9:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 52 0c             	mov    0xc(%edx),%edx
  800a02:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a08:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	68 08 50 80 00       	push   $0x805008
  800a16:	e8 8b 0e 00 00       	call   8018a6 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 04 00 00 00       	mov    $0x4,%eax
  800a25:	e8 cc fe ff ff       	call   8008f6 <fsipc>
            return r;

    return r;
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3f:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4f:	e8 a2 fe ff ff       	call   8008f6 <fsipc>
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	85 c0                	test   %eax,%eax
  800a58:	78 51                	js     800aab <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 19                	jae    800a77 <devfile_read+0x4b>
  800a5e:	68 04 1f 80 00       	push   $0x801f04
  800a63:	68 0b 1f 80 00       	push   $0x801f0b
  800a68:	68 82 00 00 00       	push   $0x82
  800a6d:	68 20 1f 80 00       	push   $0x801f20
  800a72:	e8 c0 05 00 00       	call   801037 <_panic>
	assert(r <= PGSIZE);
  800a77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7c:	7e 19                	jle    800a97 <devfile_read+0x6b>
  800a7e:	68 2b 1f 80 00       	push   $0x801f2b
  800a83:	68 0b 1f 80 00       	push   $0x801f0b
  800a88:	68 83 00 00 00       	push   $0x83
  800a8d:	68 20 1f 80 00       	push   $0x801f20
  800a92:	e8 a0 05 00 00       	call   801037 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a97:	83 ec 04             	sub    $0x4,%esp
  800a9a:	50                   	push   %eax
  800a9b:	68 00 50 80 00       	push   $0x805000
  800aa0:	ff 75 0c             	pushl  0xc(%ebp)
  800aa3:	e8 fe 0d 00 00       	call   8018a6 <memmove>
	return r;
  800aa8:	83 c4 10             	add    $0x10,%esp
}
  800aab:	89 d8                	mov    %ebx,%eax
  800aad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 20             	sub    $0x20,%esp
  800abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800abe:	53                   	push   %ebx
  800abf:	e8 17 0c 00 00       	call   8016db <strlen>
  800ac4:	83 c4 10             	add    $0x10,%esp
  800ac7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800acc:	7f 67                	jg     800b35 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad4:	50                   	push   %eax
  800ad5:	e8 94 f8 ff ff       	call   80036e <fd_alloc>
  800ada:	83 c4 10             	add    $0x10,%esp
		return r;
  800add:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	78 57                	js     800b3a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	53                   	push   %ebx
  800ae7:	68 00 50 80 00       	push   $0x805000
  800aec:	e8 23 0c 00 00       	call   801714 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afc:	b8 01 00 00 00       	mov    $0x1,%eax
  800b01:	e8 f0 fd ff ff       	call   8008f6 <fsipc>
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	79 14                	jns    800b23 <open+0x6f>
		fd_close(fd, 0);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	6a 00                	push   $0x0
  800b14:	ff 75 f4             	pushl  -0xc(%ebp)
  800b17:	e8 4a f9 ff ff       	call   800466 <fd_close>
		return r;
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	89 da                	mov    %ebx,%edx
  800b21:	eb 17                	jmp    800b3a <open+0x86>
	}

	return fd2num(fd);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	ff 75 f4             	pushl  -0xc(%ebp)
  800b29:	e8 19 f8 ff ff       	call   800347 <fd2num>
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	83 c4 10             	add    $0x10,%esp
  800b33:	eb 05                	jmp    800b3a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b35:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b3a:	89 d0                	mov    %edx,%eax
  800b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b51:	e8 a0 fd ff ff       	call   8008f6 <fsipc>
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	ff 75 08             	pushl  0x8(%ebp)
  800b66:	e8 ec f7 ff ff       	call   800357 <fd2data>
  800b6b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6d:	83 c4 08             	add    $0x8,%esp
  800b70:	68 37 1f 80 00       	push   $0x801f37
  800b75:	53                   	push   %ebx
  800b76:	e8 99 0b 00 00       	call   801714 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7b:	8b 46 04             	mov    0x4(%esi),%eax
  800b7e:	2b 06                	sub    (%esi),%eax
  800b80:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b86:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8d:	00 00 00 
	stat->st_dev = &devpipe;
  800b90:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b97:	30 80 00 
	return 0;
}
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb0:	53                   	push   %ebx
  800bb1:	6a 00                	push   $0x0
  800bb3:	e8 23 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb8:	89 1c 24             	mov    %ebx,(%esp)
  800bbb:	e8 97 f7 ff ff       	call   800357 <fd2data>
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 00                	push   $0x0
  800bc6:	e8 10 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800bcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 1c             	sub    $0x1c,%esp
  800bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bde:	a1 04 40 80 00       	mov    0x804004,%eax
  800be3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	ff 75 e0             	pushl  -0x20(%ebp)
  800bec:	e8 79 0f 00 00       	call   801b6a <pageref>
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 3c 24             	mov    %edi,(%esp)
  800bf6:	e8 6f 0f 00 00       	call   801b6a <pageref>
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	39 c3                	cmp    %eax,%ebx
  800c00:	0f 94 c1             	sete   %cl
  800c03:	0f b6 c9             	movzbl %cl,%ecx
  800c06:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c09:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c12:	39 ce                	cmp    %ecx,%esi
  800c14:	74 1b                	je     800c31 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c16:	39 c3                	cmp    %eax,%ebx
  800c18:	75 c4                	jne    800bde <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1a:	8b 42 58             	mov    0x58(%edx),%eax
  800c1d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c20:	50                   	push   %eax
  800c21:	56                   	push   %esi
  800c22:	68 3e 1f 80 00       	push   $0x801f3e
  800c27:	e8 e4 04 00 00       	call   801110 <cprintf>
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	eb ad                	jmp    800bde <_pipeisclosed+0xe>
	}
}
  800c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 28             	sub    $0x28,%esp
  800c45:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c48:	56                   	push   %esi
  800c49:	e8 09 f7 ff ff       	call   800357 <fd2data>
  800c4e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
  800c58:	eb 4b                	jmp    800ca5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5a:	89 da                	mov    %ebx,%edx
  800c5c:	89 f0                	mov    %esi,%eax
  800c5e:	e8 6d ff ff ff       	call   800bd0 <_pipeisclosed>
  800c63:	85 c0                	test   %eax,%eax
  800c65:	75 48                	jne    800caf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c67:	e8 cb f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6f:	8b 0b                	mov    (%ebx),%ecx
  800c71:	8d 51 20             	lea    0x20(%ecx),%edx
  800c74:	39 d0                	cmp    %edx,%eax
  800c76:	73 e2                	jae    800c5a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	c1 fa 1f             	sar    $0x1f,%edx
  800c87:	89 d1                	mov    %edx,%ecx
  800c89:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8f:	83 e2 1f             	and    $0x1f,%edx
  800c92:	29 ca                	sub    %ecx,%edx
  800c94:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c98:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9c:	83 c0 01             	add    $0x1,%eax
  800c9f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca2:	83 c7 01             	add    $0x1,%edi
  800ca5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca8:	75 c2                	jne    800c6c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800caa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cad:	eb 05                	jmp    800cb4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 18             	sub    $0x18,%esp
  800cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc8:	57                   	push   %edi
  800cc9:	e8 89 f6 ff ff       	call   800357 <fd2data>
  800cce:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	eb 3d                	jmp    800d17 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cda:	85 db                	test   %ebx,%ebx
  800cdc:	74 04                	je     800ce2 <devpipe_read+0x26>
				return i;
  800cde:	89 d8                	mov    %ebx,%eax
  800ce0:	eb 44                	jmp    800d26 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	e8 e5 fe ff ff       	call   800bd0 <_pipeisclosed>
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	75 32                	jne    800d21 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cef:	e8 43 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf4:	8b 06                	mov    (%esi),%eax
  800cf6:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf9:	74 df                	je     800cda <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfb:	99                   	cltd   
  800cfc:	c1 ea 1b             	shr    $0x1b,%edx
  800cff:	01 d0                	add    %edx,%eax
  800d01:	83 e0 1f             	and    $0x1f,%eax
  800d04:	29 d0                	sub    %edx,%eax
  800d06:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d11:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d14:	83 c3 01             	add    $0x1,%ebx
  800d17:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1a:	75 d8                	jne    800cf4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1f:	eb 05                	jmp    800d26 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d21:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d39:	50                   	push   %eax
  800d3a:	e8 2f f6 ff ff       	call   80036e <fd_alloc>
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	89 c2                	mov    %eax,%edx
  800d44:	85 c0                	test   %eax,%eax
  800d46:	0f 88 2c 01 00 00    	js     800e78 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4c:	83 ec 04             	sub    $0x4,%esp
  800d4f:	68 07 04 00 00       	push   $0x407
  800d54:	ff 75 f4             	pushl  -0xc(%ebp)
  800d57:	6a 00                	push   $0x0
  800d59:	e8 f8 f3 ff ff       	call   800156 <sys_page_alloc>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	85 c0                	test   %eax,%eax
  800d65:	0f 88 0d 01 00 00    	js     800e78 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d71:	50                   	push   %eax
  800d72:	e8 f7 f5 ff ff       	call   80036e <fd_alloc>
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 e2 00 00 00    	js     800e66 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	68 07 04 00 00       	push   $0x407
  800d8c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 c0 f3 ff ff       	call   800156 <sys_page_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 c3 00 00 00    	js     800e66 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	ff 75 f4             	pushl  -0xc(%ebp)
  800da9:	e8 a9 f5 ff ff       	call   800357 <fd2data>
  800dae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db0:	83 c4 0c             	add    $0xc,%esp
  800db3:	68 07 04 00 00       	push   $0x407
  800db8:	50                   	push   %eax
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 96 f3 ff ff       	call   800156 <sys_page_alloc>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	0f 88 89 00 00 00    	js     800e56 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd3:	e8 7f f5 ff ff       	call   800357 <fd2data>
  800dd8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ddf:	50                   	push   %eax
  800de0:	6a 00                	push   $0x0
  800de2:	56                   	push   %esi
  800de3:	6a 00                	push   $0x0
  800de5:	e8 af f3 ff ff       	call   800199 <sys_page_map>
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	83 c4 20             	add    $0x20,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 55                	js     800e48 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e01:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e11:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e16:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	ff 75 f4             	pushl  -0xc(%ebp)
  800e23:	e8 1f f5 ff ff       	call   800347 <fd2num>
  800e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2d:	83 c4 04             	add    $0x4,%esp
  800e30:	ff 75 f0             	pushl  -0x10(%ebp)
  800e33:	e8 0f f5 ff ff       	call   800347 <fd2num>
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	eb 30                	jmp    800e78 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	56                   	push   %esi
  800e4c:	6a 00                	push   $0x0
  800e4e:	e8 88 f3 ff ff       	call   8001db <sys_page_unmap>
  800e53:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5c:	6a 00                	push   $0x0
  800e5e:	e8 78 f3 ff ff       	call   8001db <sys_page_unmap>
  800e63:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 68 f3 ff ff       	call   8001db <sys_page_unmap>
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e78:	89 d0                	mov    %edx,%eax
  800e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8a:	50                   	push   %eax
  800e8b:	ff 75 08             	pushl  0x8(%ebp)
  800e8e:	e8 2a f5 ff ff       	call   8003bd <fd_lookup>
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 18                	js     800eb2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea0:	e8 b2 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eaa:	e8 21 fd ff ff       	call   800bd0 <_pipeisclosed>
  800eaf:	83 c4 10             	add    $0x10,%esp
}
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec4:	68 56 1f 80 00       	push   $0x801f56
  800ec9:	ff 75 0c             	pushl  0xc(%ebp)
  800ecc:	e8 43 08 00 00       	call   801714 <strcpy>
	return 0;
}
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eef:	eb 2d                	jmp    800f1e <devcons_write+0x46>
		m = n - tot;
  800ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800efe:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	53                   	push   %ebx
  800f05:	03 45 0c             	add    0xc(%ebp),%eax
  800f08:	50                   	push   %eax
  800f09:	57                   	push   %edi
  800f0a:	e8 97 09 00 00       	call   8018a6 <memmove>
		sys_cputs(buf, m);
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	53                   	push   %ebx
  800f13:	57                   	push   %edi
  800f14:	e8 81 f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f19:	01 de                	add    %ebx,%esi
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f23:	72 cc                	jb     800ef1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3c:	74 2a                	je     800f68 <devcons_read+0x3b>
  800f3e:	eb 05                	jmp    800f45 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f40:	e8 f2 f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f45:	e8 6e f1 ff ff       	call   8000b8 <sys_cgetc>
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	74 f2                	je     800f40 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 16                	js     800f68 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f52:	83 f8 04             	cmp    $0x4,%eax
  800f55:	74 0c                	je     800f63 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5a:	88 02                	mov    %al,(%edx)
	return 1;
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	eb 05                	jmp    800f68 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f76:	6a 01                	push   $0x1
  800f78:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	e8 19 f1 ff ff       	call   80009a <sys_cputs>
}
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <getchar>:

int
getchar(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8c:	6a 01                	push   $0x1
  800f8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	6a 00                	push   $0x0
  800f94:	e8 8a f6 ff ff       	call   800623 <read>
	if (r < 0)
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 0f                	js     800faf <getchar+0x29>
		return r;
	if (r < 1)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	7e 06                	jle    800faa <getchar+0x24>
		return -E_EOF;
	return c;
  800fa4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa8:	eb 05                	jmp    800faf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800faa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	e8 fa f3 ff ff       	call   8003bd <fd_lookup>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 11                	js     800fdb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd3:	39 10                	cmp    %edx,(%eax)
  800fd5:	0f 94 c0             	sete   %al
  800fd8:	0f b6 c0             	movzbl %al,%eax
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <opencons>:

int
opencons(void)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	e8 82 f3 ff ff       	call   80036e <fd_alloc>
  800fec:	83 c4 10             	add    $0x10,%esp
		return r;
  800fef:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 3e                	js     801033 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff5:	83 ec 04             	sub    $0x4,%esp
  800ff8:	68 07 04 00 00       	push   $0x407
  800ffd:	ff 75 f4             	pushl  -0xc(%ebp)
  801000:	6a 00                	push   $0x0
  801002:	e8 4f f1 ff ff       	call   800156 <sys_page_alloc>
  801007:	83 c4 10             	add    $0x10,%esp
		return r;
  80100a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 23                	js     801033 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801010:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801019:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	50                   	push   %eax
  801029:	e8 19 f3 ff ff       	call   800347 <fd2num>
  80102e:	89 c2                	mov    %eax,%edx
  801030:	83 c4 10             	add    $0x10,%esp
}
  801033:	89 d0                	mov    %edx,%eax
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801045:	e8 ce f0 ff ff       	call   800118 <sys_getenvid>
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	ff 75 0c             	pushl  0xc(%ebp)
  801050:	ff 75 08             	pushl  0x8(%ebp)
  801053:	56                   	push   %esi
  801054:	50                   	push   %eax
  801055:	68 64 1f 80 00       	push   $0x801f64
  80105a:	e8 b1 00 00 00       	call   801110 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105f:	83 c4 18             	add    $0x18,%esp
  801062:	53                   	push   %ebx
  801063:	ff 75 10             	pushl  0x10(%ebp)
  801066:	e8 54 00 00 00       	call   8010bf <vcprintf>
	cprintf("\n");
  80106b:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  801072:	e8 99 00 00 00       	call   801110 <cprintf>
  801077:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107a:	cc                   	int3   
  80107b:	eb fd                	jmp    80107a <_panic+0x43>

0080107d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	53                   	push   %ebx
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801087:	8b 13                	mov    (%ebx),%edx
  801089:	8d 42 01             	lea    0x1(%edx),%eax
  80108c:	89 03                	mov    %eax,(%ebx)
  80108e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801091:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801095:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109a:	75 1a                	jne    8010b6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	68 ff 00 00 00       	push   $0xff
  8010a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a7:	50                   	push   %eax
  8010a8:	e8 ed ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010cf:	00 00 00 
	b.cnt = 0;
  8010d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010dc:	ff 75 0c             	pushl  0xc(%ebp)
  8010df:	ff 75 08             	pushl  0x8(%ebp)
  8010e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	68 7d 10 80 00       	push   $0x80107d
  8010ee:	e8 1a 01 00 00       	call   80120d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801102:	50                   	push   %eax
  801103:	e8 92 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801108:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801116:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801119:	50                   	push   %eax
  80111a:	ff 75 08             	pushl  0x8(%ebp)
  80111d:	e8 9d ff ff ff       	call   8010bf <vcprintf>
	va_end(ap);

	return cnt;
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	83 ec 1c             	sub    $0x1c,%esp
  80112d:	89 c7                	mov    %eax,%edi
  80112f:	89 d6                	mov    %edx,%esi
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
  801137:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
  801145:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801148:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114b:	39 d3                	cmp    %edx,%ebx
  80114d:	72 05                	jb     801154 <printnum+0x30>
  80114f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801152:	77 45                	ja     801199 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	ff 75 18             	pushl  0x18(%ebp)
  80115a:	8b 45 14             	mov    0x14(%ebp),%eax
  80115d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801160:	53                   	push   %ebx
  801161:	ff 75 10             	pushl  0x10(%ebp)
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116a:	ff 75 e0             	pushl  -0x20(%ebp)
  80116d:	ff 75 dc             	pushl  -0x24(%ebp)
  801170:	ff 75 d8             	pushl  -0x28(%ebp)
  801173:	e8 38 0a 00 00       	call   801bb0 <__udivdi3>
  801178:	83 c4 18             	add    $0x18,%esp
  80117b:	52                   	push   %edx
  80117c:	50                   	push   %eax
  80117d:	89 f2                	mov    %esi,%edx
  80117f:	89 f8                	mov    %edi,%eax
  801181:	e8 9e ff ff ff       	call   801124 <printnum>
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	eb 18                	jmp    8011a3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	56                   	push   %esi
  80118f:	ff 75 18             	pushl  0x18(%ebp)
  801192:	ff d7                	call   *%edi
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	eb 03                	jmp    80119c <printnum+0x78>
  801199:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119c:	83 eb 01             	sub    $0x1,%ebx
  80119f:	85 db                	test   %ebx,%ebx
  8011a1:	7f e8                	jg     80118b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	56                   	push   %esi
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b6:	e8 25 0b 00 00       	call   801ce0 <__umoddi3>
  8011bb:	83 c4 14             	add    $0x14,%esp
  8011be:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011c5:	50                   	push   %eax
  8011c6:	ff d7                	call   *%edi
}
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011dd:	8b 10                	mov    (%eax),%edx
  8011df:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e2:	73 0a                	jae    8011ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e7:	89 08                	mov    %ecx,(%eax)
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	88 02                	mov    %al,(%edx)
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 05 00 00 00       	call   80120d <vprintfmt>
	va_end(ap);
}
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 2c             	sub    $0x2c,%esp
  801216:	8b 75 08             	mov    0x8(%ebp),%esi
  801219:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80121f:	eb 12                	jmp    801233 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801221:	85 c0                	test   %eax,%eax
  801223:	0f 84 42 04 00 00    	je     80166b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	ff d6                	call   *%esi
  801230:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801233:	83 c7 01             	add    $0x1,%edi
  801236:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80123a:	83 f8 25             	cmp    $0x25,%eax
  80123d:	75 e2                	jne    801221 <vprintfmt+0x14>
  80123f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801243:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80124a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801251:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801258:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125d:	eb 07                	jmp    801266 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801262:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	8d 47 01             	lea    0x1(%edi),%eax
  801269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126c:	0f b6 07             	movzbl (%edi),%eax
  80126f:	0f b6 d0             	movzbl %al,%edx
  801272:	83 e8 23             	sub    $0x23,%eax
  801275:	3c 55                	cmp    $0x55,%al
  801277:	0f 87 d3 03 00 00    	ja     801650 <vprintfmt+0x443>
  80127d:	0f b6 c0             	movzbl %al,%eax
  801280:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801287:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80128a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80128e:	eb d6                	jmp    801266 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801290:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
  801298:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80129e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012a2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012a5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012a8:	83 f9 09             	cmp    $0x9,%ecx
  8012ab:	77 3f                	ja     8012ec <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b0:	eb e9                	jmp    80129b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b5:	8b 00                	mov    (%eax),%eax
  8012b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bd:	8d 40 04             	lea    0x4(%eax),%eax
  8012c0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012c6:	eb 2a                	jmp    8012f2 <vprintfmt+0xe5>
  8012c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d2:	0f 49 d0             	cmovns %eax,%edx
  8012d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012db:	eb 89                	jmp    801266 <vprintfmt+0x59>
  8012dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e7:	e9 7a ff ff ff       	jmp    801266 <vprintfmt+0x59>
  8012ec:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ef:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012f6:	0f 89 6a ff ff ff    	jns    801266 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801302:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801309:	e9 58 ff ff ff       	jmp    801266 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80130e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801314:	e9 4d ff ff ff       	jmp    801266 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801319:	8b 45 14             	mov    0x14(%ebp),%eax
  80131c:	8d 78 04             	lea    0x4(%eax),%edi
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	53                   	push   %ebx
  801323:	ff 30                	pushl  (%eax)
  801325:	ff d6                	call   *%esi
			break;
  801327:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80132a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801330:	e9 fe fe ff ff       	jmp    801233 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801335:	8b 45 14             	mov    0x14(%ebp),%eax
  801338:	8d 78 04             	lea    0x4(%eax),%edi
  80133b:	8b 00                	mov    (%eax),%eax
  80133d:	99                   	cltd   
  80133e:	31 d0                	xor    %edx,%eax
  801340:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801342:	83 f8 0f             	cmp    $0xf,%eax
  801345:	7f 0b                	jg     801352 <vprintfmt+0x145>
  801347:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80134e:	85 d2                	test   %edx,%edx
  801350:	75 1b                	jne    80136d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801352:	50                   	push   %eax
  801353:	68 9f 1f 80 00       	push   $0x801f9f
  801358:	53                   	push   %ebx
  801359:	56                   	push   %esi
  80135a:	e8 91 fe ff ff       	call   8011f0 <printfmt>
  80135f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801362:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801368:	e9 c6 fe ff ff       	jmp    801233 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80136d:	52                   	push   %edx
  80136e:	68 1d 1f 80 00       	push   $0x801f1d
  801373:	53                   	push   %ebx
  801374:	56                   	push   %esi
  801375:	e8 76 fe ff ff       	call   8011f0 <printfmt>
  80137a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80137d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801383:	e9 ab fe ff ff       	jmp    801233 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801388:	8b 45 14             	mov    0x14(%ebp),%eax
  80138b:	83 c0 04             	add    $0x4,%eax
  80138e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801391:	8b 45 14             	mov    0x14(%ebp),%eax
  801394:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801396:	85 ff                	test   %edi,%edi
  801398:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  80139d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a4:	0f 8e 94 00 00 00    	jle    80143e <vprintfmt+0x231>
  8013aa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ae:	0f 84 98 00 00 00    	je     80144c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8013ba:	57                   	push   %edi
  8013bb:	e8 33 03 00 00       	call   8016f3 <strnlen>
  8013c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c3:	29 c1                	sub    %eax,%ecx
  8013c5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013c8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013cb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d7:	eb 0f                	jmp    8013e8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e2:	83 ef 01             	sub    $0x1,%edi
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 ff                	test   %edi,%edi
  8013ea:	7f ed                	jg     8013d9 <vprintfmt+0x1cc>
  8013ec:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ef:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013f2:	85 c9                	test   %ecx,%ecx
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f9:	0f 49 c1             	cmovns %ecx,%eax
  8013fc:	29 c1                	sub    %eax,%ecx
  8013fe:	89 75 08             	mov    %esi,0x8(%ebp)
  801401:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801404:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801407:	89 cb                	mov    %ecx,%ebx
  801409:	eb 4d                	jmp    801458 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80140f:	74 1b                	je     80142c <vprintfmt+0x21f>
  801411:	0f be c0             	movsbl %al,%eax
  801414:	83 e8 20             	sub    $0x20,%eax
  801417:	83 f8 5e             	cmp    $0x5e,%eax
  80141a:	76 10                	jbe    80142c <vprintfmt+0x21f>
					putch('?', putdat);
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	ff 75 0c             	pushl  0xc(%ebp)
  801422:	6a 3f                	push   $0x3f
  801424:	ff 55 08             	call   *0x8(%ebp)
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	eb 0d                	jmp    801439 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	52                   	push   %edx
  801433:	ff 55 08             	call   *0x8(%ebp)
  801436:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801439:	83 eb 01             	sub    $0x1,%ebx
  80143c:	eb 1a                	jmp    801458 <vprintfmt+0x24b>
  80143e:	89 75 08             	mov    %esi,0x8(%ebp)
  801441:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801444:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801447:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144a:	eb 0c                	jmp    801458 <vprintfmt+0x24b>
  80144c:	89 75 08             	mov    %esi,0x8(%ebp)
  80144f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801452:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801455:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801458:	83 c7 01             	add    $0x1,%edi
  80145b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80145f:	0f be d0             	movsbl %al,%edx
  801462:	85 d2                	test   %edx,%edx
  801464:	74 23                	je     801489 <vprintfmt+0x27c>
  801466:	85 f6                	test   %esi,%esi
  801468:	78 a1                	js     80140b <vprintfmt+0x1fe>
  80146a:	83 ee 01             	sub    $0x1,%esi
  80146d:	79 9c                	jns    80140b <vprintfmt+0x1fe>
  80146f:	89 df                	mov    %ebx,%edi
  801471:	8b 75 08             	mov    0x8(%ebp),%esi
  801474:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801477:	eb 18                	jmp    801491 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	53                   	push   %ebx
  80147d:	6a 20                	push   $0x20
  80147f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801481:	83 ef 01             	sub    $0x1,%edi
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	eb 08                	jmp    801491 <vprintfmt+0x284>
  801489:	89 df                	mov    %ebx,%edi
  80148b:	8b 75 08             	mov    0x8(%ebp),%esi
  80148e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801491:	85 ff                	test   %edi,%edi
  801493:	7f e4                	jg     801479 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801495:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801498:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80149e:	e9 90 fd ff ff       	jmp    801233 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a3:	83 f9 01             	cmp    $0x1,%ecx
  8014a6:	7e 19                	jle    8014c1 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ab:	8b 50 04             	mov    0x4(%eax),%edx
  8014ae:	8b 00                	mov    (%eax),%eax
  8014b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b9:	8d 40 08             	lea    0x8(%eax),%eax
  8014bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8014bf:	eb 38                	jmp    8014f9 <vprintfmt+0x2ec>
	else if (lflag)
  8014c1:	85 c9                	test   %ecx,%ecx
  8014c3:	74 1b                	je     8014e0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c8:	8b 00                	mov    (%eax),%eax
  8014ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cd:	89 c1                	mov    %eax,%ecx
  8014cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d8:	8d 40 04             	lea    0x4(%eax),%eax
  8014db:	89 45 14             	mov    %eax,0x14(%ebp)
  8014de:	eb 19                	jmp    8014f9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e3:	8b 00                	mov    (%eax),%eax
  8014e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e8:	89 c1                	mov    %eax,%ecx
  8014ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8d 40 04             	lea    0x4(%eax),%eax
  8014f6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014ff:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801504:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801508:	0f 89 0e 01 00 00    	jns    80161c <vprintfmt+0x40f>
				putch('-', putdat);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	53                   	push   %ebx
  801512:	6a 2d                	push   $0x2d
  801514:	ff d6                	call   *%esi
				num = -(long long) num;
  801516:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801519:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80151c:	f7 da                	neg    %edx
  80151e:	83 d1 00             	adc    $0x0,%ecx
  801521:	f7 d9                	neg    %ecx
  801523:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801526:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152b:	e9 ec 00 00 00       	jmp    80161c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801530:	83 f9 01             	cmp    $0x1,%ecx
  801533:	7e 18                	jle    80154d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8b 10                	mov    (%eax),%edx
  80153a:	8b 48 04             	mov    0x4(%eax),%ecx
  80153d:	8d 40 08             	lea    0x8(%eax),%eax
  801540:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801543:	b8 0a 00 00 00       	mov    $0xa,%eax
  801548:	e9 cf 00 00 00       	jmp    80161c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80154d:	85 c9                	test   %ecx,%ecx
  80154f:	74 1a                	je     80156b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801551:	8b 45 14             	mov    0x14(%ebp),%eax
  801554:	8b 10                	mov    (%eax),%edx
  801556:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155b:	8d 40 04             	lea    0x4(%eax),%eax
  80155e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801561:	b8 0a 00 00 00       	mov    $0xa,%eax
  801566:	e9 b1 00 00 00       	jmp    80161c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80156b:	8b 45 14             	mov    0x14(%ebp),%eax
  80156e:	8b 10                	mov    (%eax),%edx
  801570:	b9 00 00 00 00       	mov    $0x0,%ecx
  801575:	8d 40 04             	lea    0x4(%eax),%eax
  801578:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80157b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801580:	e9 97 00 00 00       	jmp    80161c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 58                	push   $0x58
  80158b:	ff d6                	call   *%esi
			putch('X', putdat);
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 58                	push   $0x58
  801593:	ff d6                	call   *%esi
			putch('X', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 58                	push   $0x58
  80159b:	ff d6                	call   *%esi
			break;
  80159d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015a3:	e9 8b fc ff ff       	jmp    801233 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	6a 30                	push   $0x30
  8015ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 78                	push   $0x78
  8015b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bb:	8b 10                	mov    (%eax),%edx
  8015bd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c2:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c5:	8d 40 04             	lea    0x4(%eax),%eax
  8015c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d0:	eb 4a                	jmp    80161c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d2:	83 f9 01             	cmp    $0x1,%ecx
  8015d5:	7e 15                	jle    8015ec <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015da:	8b 10                	mov    (%eax),%edx
  8015dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8015df:	8d 40 08             	lea    0x8(%eax),%eax
  8015e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015e5:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ea:	eb 30                	jmp    80161c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015ec:	85 c9                	test   %ecx,%ecx
  8015ee:	74 17                	je     801607 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f3:	8b 10                	mov    (%eax),%edx
  8015f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fa:	8d 40 04             	lea    0x4(%eax),%eax
  8015fd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801600:	b8 10 00 00 00       	mov    $0x10,%eax
  801605:	eb 15                	jmp    80161c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801607:	8b 45 14             	mov    0x14(%ebp),%eax
  80160a:	8b 10                	mov    (%eax),%edx
  80160c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801611:	8d 40 04             	lea    0x4(%eax),%eax
  801614:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801617:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801623:	57                   	push   %edi
  801624:	ff 75 e0             	pushl  -0x20(%ebp)
  801627:	50                   	push   %eax
  801628:	51                   	push   %ecx
  801629:	52                   	push   %edx
  80162a:	89 da                	mov    %ebx,%edx
  80162c:	89 f0                	mov    %esi,%eax
  80162e:	e8 f1 fa ff ff       	call   801124 <printnum>
			break;
  801633:	83 c4 20             	add    $0x20,%esp
  801636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801639:	e9 f5 fb ff ff       	jmp    801233 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	53                   	push   %ebx
  801642:	52                   	push   %edx
  801643:	ff d6                	call   *%esi
			break;
  801645:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164b:	e9 e3 fb ff ff       	jmp    801233 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	6a 25                	push   $0x25
  801656:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb 03                	jmp    801660 <vprintfmt+0x453>
  80165d:	83 ef 01             	sub    $0x1,%edi
  801660:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801664:	75 f7                	jne    80165d <vprintfmt+0x450>
  801666:	e9 c8 fb ff ff       	jmp    801233 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 18             	sub    $0x18,%esp
  801679:	8b 45 08             	mov    0x8(%ebp),%eax
  80167c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80167f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801682:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801686:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801689:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801690:	85 c0                	test   %eax,%eax
  801692:	74 26                	je     8016ba <vsnprintf+0x47>
  801694:	85 d2                	test   %edx,%edx
  801696:	7e 22                	jle    8016ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801698:	ff 75 14             	pushl  0x14(%ebp)
  80169b:	ff 75 10             	pushl  0x10(%ebp)
  80169e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	68 d3 11 80 00       	push   $0x8011d3
  8016a7:	e8 61 fb ff ff       	call   80120d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	eb 05                	jmp    8016bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ca:	50                   	push   %eax
  8016cb:	ff 75 10             	pushl  0x10(%ebp)
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 9a ff ff ff       	call   801673 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e6:	eb 03                	jmp    8016eb <strlen+0x10>
		n++;
  8016e8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ef:	75 f7                	jne    8016e8 <strlen+0xd>
		n++;
	return n;
}
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801701:	eb 03                	jmp    801706 <strnlen+0x13>
		n++;
  801703:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801706:	39 c2                	cmp    %eax,%edx
  801708:	74 08                	je     801712 <strnlen+0x1f>
  80170a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80170e:	75 f3                	jne    801703 <strnlen+0x10>
  801710:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	53                   	push   %ebx
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80171e:	89 c2                	mov    %eax,%edx
  801720:	83 c2 01             	add    $0x1,%edx
  801723:	83 c1 01             	add    $0x1,%ecx
  801726:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80172a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80172d:	84 db                	test   %bl,%bl
  80172f:	75 ef                	jne    801720 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801731:	5b                   	pop    %ebx
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173b:	53                   	push   %ebx
  80173c:	e8 9a ff ff ff       	call   8016db <strlen>
  801741:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	01 d8                	add    %ebx,%eax
  801749:	50                   	push   %eax
  80174a:	e8 c5 ff ff ff       	call   801714 <strcpy>
	return dst;
}
  80174f:	89 d8                	mov    %ebx,%eax
  801751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	8b 75 08             	mov    0x8(%ebp),%esi
  80175e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801761:	89 f3                	mov    %esi,%ebx
  801763:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801766:	89 f2                	mov    %esi,%edx
  801768:	eb 0f                	jmp    801779 <strncpy+0x23>
		*dst++ = *src;
  80176a:	83 c2 01             	add    $0x1,%edx
  80176d:	0f b6 01             	movzbl (%ecx),%eax
  801770:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801773:	80 39 01             	cmpb   $0x1,(%ecx)
  801776:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801779:	39 da                	cmp    %ebx,%edx
  80177b:	75 ed                	jne    80176a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80177d:	89 f0                	mov    %esi,%eax
  80177f:	5b                   	pop    %ebx
  801780:	5e                   	pop    %esi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
  801788:	8b 75 08             	mov    0x8(%ebp),%esi
  80178b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178e:	8b 55 10             	mov    0x10(%ebp),%edx
  801791:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801793:	85 d2                	test   %edx,%edx
  801795:	74 21                	je     8017b8 <strlcpy+0x35>
  801797:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179b:	89 f2                	mov    %esi,%edx
  80179d:	eb 09                	jmp    8017a8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80179f:	83 c2 01             	add    $0x1,%edx
  8017a2:	83 c1 01             	add    $0x1,%ecx
  8017a5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a8:	39 c2                	cmp    %eax,%edx
  8017aa:	74 09                	je     8017b5 <strlcpy+0x32>
  8017ac:	0f b6 19             	movzbl (%ecx),%ebx
  8017af:	84 db                	test   %bl,%bl
  8017b1:	75 ec                	jne    80179f <strlcpy+0x1c>
  8017b3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b8:	29 f0                	sub    %esi,%eax
}
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c7:	eb 06                	jmp    8017cf <strcmp+0x11>
		p++, q++;
  8017c9:	83 c1 01             	add    $0x1,%ecx
  8017cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017cf:	0f b6 01             	movzbl (%ecx),%eax
  8017d2:	84 c0                	test   %al,%al
  8017d4:	74 04                	je     8017da <strcmp+0x1c>
  8017d6:	3a 02                	cmp    (%edx),%al
  8017d8:	74 ef                	je     8017c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017da:	0f b6 c0             	movzbl %al,%eax
  8017dd:	0f b6 12             	movzbl (%edx),%edx
  8017e0:	29 d0                	sub    %edx,%eax
}
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f3:	eb 06                	jmp    8017fb <strncmp+0x17>
		n--, p++, q++;
  8017f5:	83 c0 01             	add    $0x1,%eax
  8017f8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017fb:	39 d8                	cmp    %ebx,%eax
  8017fd:	74 15                	je     801814 <strncmp+0x30>
  8017ff:	0f b6 08             	movzbl (%eax),%ecx
  801802:	84 c9                	test   %cl,%cl
  801804:	74 04                	je     80180a <strncmp+0x26>
  801806:	3a 0a                	cmp    (%edx),%cl
  801808:	74 eb                	je     8017f5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180a:	0f b6 00             	movzbl (%eax),%eax
  80180d:	0f b6 12             	movzbl (%edx),%edx
  801810:	29 d0                	sub    %edx,%eax
  801812:	eb 05                	jmp    801819 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801819:	5b                   	pop    %ebx
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801826:	eb 07                	jmp    80182f <strchr+0x13>
		if (*s == c)
  801828:	38 ca                	cmp    %cl,%dl
  80182a:	74 0f                	je     80183b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80182c:	83 c0 01             	add    $0x1,%eax
  80182f:	0f b6 10             	movzbl (%eax),%edx
  801832:	84 d2                	test   %dl,%dl
  801834:	75 f2                	jne    801828 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801847:	eb 03                	jmp    80184c <strfind+0xf>
  801849:	83 c0 01             	add    $0x1,%eax
  80184c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80184f:	38 ca                	cmp    %cl,%dl
  801851:	74 04                	je     801857 <strfind+0x1a>
  801853:	84 d2                	test   %dl,%dl
  801855:	75 f2                	jne    801849 <strfind+0xc>
			break;
	return (char *) s;
}
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	57                   	push   %edi
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801862:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801865:	85 c9                	test   %ecx,%ecx
  801867:	74 36                	je     80189f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801869:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80186f:	75 28                	jne    801899 <memset+0x40>
  801871:	f6 c1 03             	test   $0x3,%cl
  801874:	75 23                	jne    801899 <memset+0x40>
		c &= 0xFF;
  801876:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187a:	89 d3                	mov    %edx,%ebx
  80187c:	c1 e3 08             	shl    $0x8,%ebx
  80187f:	89 d6                	mov    %edx,%esi
  801881:	c1 e6 18             	shl    $0x18,%esi
  801884:	89 d0                	mov    %edx,%eax
  801886:	c1 e0 10             	shl    $0x10,%eax
  801889:	09 f0                	or     %esi,%eax
  80188b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80188d:	89 d8                	mov    %ebx,%eax
  80188f:	09 d0                	or     %edx,%eax
  801891:	c1 e9 02             	shr    $0x2,%ecx
  801894:	fc                   	cld    
  801895:	f3 ab                	rep stos %eax,%es:(%edi)
  801897:	eb 06                	jmp    80189f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189c:	fc                   	cld    
  80189d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80189f:	89 f8                	mov    %edi,%eax
  8018a1:	5b                   	pop    %ebx
  8018a2:	5e                   	pop    %esi
  8018a3:	5f                   	pop    %edi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	57                   	push   %edi
  8018aa:	56                   	push   %esi
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b4:	39 c6                	cmp    %eax,%esi
  8018b6:	73 35                	jae    8018ed <memmove+0x47>
  8018b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018bb:	39 d0                	cmp    %edx,%eax
  8018bd:	73 2e                	jae    8018ed <memmove+0x47>
		s += n;
		d += n;
  8018bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c2:	89 d6                	mov    %edx,%esi
  8018c4:	09 fe                	or     %edi,%esi
  8018c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018cc:	75 13                	jne    8018e1 <memmove+0x3b>
  8018ce:	f6 c1 03             	test   $0x3,%cl
  8018d1:	75 0e                	jne    8018e1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d3:	83 ef 04             	sub    $0x4,%edi
  8018d6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d9:	c1 e9 02             	shr    $0x2,%ecx
  8018dc:	fd                   	std    
  8018dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018df:	eb 09                	jmp    8018ea <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e1:	83 ef 01             	sub    $0x1,%edi
  8018e4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e7:	fd                   	std    
  8018e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ea:	fc                   	cld    
  8018eb:	eb 1d                	jmp    80190a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ed:	89 f2                	mov    %esi,%edx
  8018ef:	09 c2                	or     %eax,%edx
  8018f1:	f6 c2 03             	test   $0x3,%dl
  8018f4:	75 0f                	jne    801905 <memmove+0x5f>
  8018f6:	f6 c1 03             	test   $0x3,%cl
  8018f9:	75 0a                	jne    801905 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018fb:	c1 e9 02             	shr    $0x2,%ecx
  8018fe:	89 c7                	mov    %eax,%edi
  801900:	fc                   	cld    
  801901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801903:	eb 05                	jmp    80190a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801905:	89 c7                	mov    %eax,%edi
  801907:	fc                   	cld    
  801908:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801911:	ff 75 10             	pushl  0x10(%ebp)
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	ff 75 08             	pushl  0x8(%ebp)
  80191a:	e8 87 ff ff ff       	call   8018a6 <memmove>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192c:	89 c6                	mov    %eax,%esi
  80192e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801931:	eb 1a                	jmp    80194d <memcmp+0x2c>
		if (*s1 != *s2)
  801933:	0f b6 08             	movzbl (%eax),%ecx
  801936:	0f b6 1a             	movzbl (%edx),%ebx
  801939:	38 d9                	cmp    %bl,%cl
  80193b:	74 0a                	je     801947 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80193d:	0f b6 c1             	movzbl %cl,%eax
  801940:	0f b6 db             	movzbl %bl,%ebx
  801943:	29 d8                	sub    %ebx,%eax
  801945:	eb 0f                	jmp    801956 <memcmp+0x35>
		s1++, s2++;
  801947:	83 c0 01             	add    $0x1,%eax
  80194a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80194d:	39 f0                	cmp    %esi,%eax
  80194f:	75 e2                	jne    801933 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801951:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801961:	89 c1                	mov    %eax,%ecx
  801963:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801966:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196a:	eb 0a                	jmp    801976 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196c:	0f b6 10             	movzbl (%eax),%edx
  80196f:	39 da                	cmp    %ebx,%edx
  801971:	74 07                	je     80197a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801973:	83 c0 01             	add    $0x1,%eax
  801976:	39 c8                	cmp    %ecx,%eax
  801978:	72 f2                	jb     80196c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197a:	5b                   	pop    %ebx
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	57                   	push   %edi
  801981:	56                   	push   %esi
  801982:	53                   	push   %ebx
  801983:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801986:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801989:	eb 03                	jmp    80198e <strtol+0x11>
		s++;
  80198b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198e:	0f b6 01             	movzbl (%ecx),%eax
  801991:	3c 20                	cmp    $0x20,%al
  801993:	74 f6                	je     80198b <strtol+0xe>
  801995:	3c 09                	cmp    $0x9,%al
  801997:	74 f2                	je     80198b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801999:	3c 2b                	cmp    $0x2b,%al
  80199b:	75 0a                	jne    8019a7 <strtol+0x2a>
		s++;
  80199d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a5:	eb 11                	jmp    8019b8 <strtol+0x3b>
  8019a7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019ac:	3c 2d                	cmp    $0x2d,%al
  8019ae:	75 08                	jne    8019b8 <strtol+0x3b>
		s++, neg = 1;
  8019b0:	83 c1 01             	add    $0x1,%ecx
  8019b3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019be:	75 15                	jne    8019d5 <strtol+0x58>
  8019c0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c3:	75 10                	jne    8019d5 <strtol+0x58>
  8019c5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c9:	75 7c                	jne    801a47 <strtol+0xca>
		s += 2, base = 16;
  8019cb:	83 c1 02             	add    $0x2,%ecx
  8019ce:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d3:	eb 16                	jmp    8019eb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d5:	85 db                	test   %ebx,%ebx
  8019d7:	75 12                	jne    8019eb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019de:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e1:	75 08                	jne    8019eb <strtol+0x6e>
		s++, base = 8;
  8019e3:	83 c1 01             	add    $0x1,%ecx
  8019e6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f3:	0f b6 11             	movzbl (%ecx),%edx
  8019f6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f9:	89 f3                	mov    %esi,%ebx
  8019fb:	80 fb 09             	cmp    $0x9,%bl
  8019fe:	77 08                	ja     801a08 <strtol+0x8b>
			dig = *s - '0';
  801a00:	0f be d2             	movsbl %dl,%edx
  801a03:	83 ea 30             	sub    $0x30,%edx
  801a06:	eb 22                	jmp    801a2a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a08:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0b:	89 f3                	mov    %esi,%ebx
  801a0d:	80 fb 19             	cmp    $0x19,%bl
  801a10:	77 08                	ja     801a1a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a12:	0f be d2             	movsbl %dl,%edx
  801a15:	83 ea 57             	sub    $0x57,%edx
  801a18:	eb 10                	jmp    801a2a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1d:	89 f3                	mov    %esi,%ebx
  801a1f:	80 fb 19             	cmp    $0x19,%bl
  801a22:	77 16                	ja     801a3a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a24:	0f be d2             	movsbl %dl,%edx
  801a27:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a2d:	7d 0b                	jge    801a3a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a2f:	83 c1 01             	add    $0x1,%ecx
  801a32:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a36:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a38:	eb b9                	jmp    8019f3 <strtol+0x76>

	if (endptr)
  801a3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a3e:	74 0d                	je     801a4d <strtol+0xd0>
		*endptr = (char *) s;
  801a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a43:	89 0e                	mov    %ecx,(%esi)
  801a45:	eb 06                	jmp    801a4d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	74 98                	je     8019e3 <strtol+0x66>
  801a4b:	eb 9e                	jmp    8019eb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a4d:	89 c2                	mov    %eax,%edx
  801a4f:	f7 da                	neg    %edx
  801a51:	85 ff                	test   %edi,%edi
  801a53:	0f 45 c2             	cmovne %edx,%eax
}
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	57                   	push   %edi
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	8b 75 08             	mov    0x8(%ebp),%esi
  801a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a6d:	85 f6                	test   %esi,%esi
  801a6f:	74 06                	je     801a77 <ipc_recv+0x1c>
		*from_env_store = 0;
  801a71:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a77:	85 db                	test   %ebx,%ebx
  801a79:	74 06                	je     801a81 <ipc_recv+0x26>
		*perm_store = 0;
  801a7b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a81:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a83:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a88:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	50                   	push   %eax
  801a8f:	e8 72 e8 ff ff       	call   800306 <sys_ipc_recv>
  801a94:	89 c7                	mov    %eax,%edi
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	79 14                	jns    801ab1 <ipc_recv+0x56>
		cprintf("im dead");
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	68 80 22 80 00       	push   $0x802280
  801aa5:	e8 66 f6 ff ff       	call   801110 <cprintf>
		return r;
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	89 f8                	mov    %edi,%eax
  801aaf:	eb 24                	jmp    801ad5 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ab1:	85 f6                	test   %esi,%esi
  801ab3:	74 0a                	je     801abf <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ab5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aba:	8b 40 74             	mov    0x74(%eax),%eax
  801abd:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801abf:	85 db                	test   %ebx,%ebx
  801ac1:	74 0a                	je     801acd <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ac3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac8:	8b 40 78             	mov    0x78(%eax),%eax
  801acb:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801acd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801aef:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801af1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801af6:	0f 44 d8             	cmove  %eax,%ebx
  801af9:	eb 1c                	jmp    801b17 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801afb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afe:	74 12                	je     801b12 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b00:	50                   	push   %eax
  801b01:	68 88 22 80 00       	push   $0x802288
  801b06:	6a 4e                	push   $0x4e
  801b08:	68 95 22 80 00       	push   $0x802295
  801b0d:	e8 25 f5 ff ff       	call   801037 <_panic>
		sys_yield();
  801b12:	e8 20 e6 ff ff       	call   800137 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b17:	ff 75 14             	pushl  0x14(%ebp)
  801b1a:	53                   	push   %ebx
  801b1b:	56                   	push   %esi
  801b1c:	57                   	push   %edi
  801b1d:	e8 c1 e7 ff ff       	call   8002e3 <sys_ipc_try_send>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 d2                	js     801afb <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5f                   	pop    %edi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b3c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b3f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b45:	8b 52 50             	mov    0x50(%edx),%edx
  801b48:	39 ca                	cmp    %ecx,%edx
  801b4a:	75 0d                	jne    801b59 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b4c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b54:	8b 40 48             	mov    0x48(%eax),%eax
  801b57:	eb 0f                	jmp    801b68 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b59:	83 c0 01             	add    $0x1,%eax
  801b5c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b61:	75 d9                	jne    801b3c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	c1 e8 16             	shr    $0x16,%eax
  801b75:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b81:	f6 c1 01             	test   $0x1,%cl
  801b84:	74 1d                	je     801ba3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b86:	c1 ea 0c             	shr    $0xc,%edx
  801b89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b90:	f6 c2 01             	test   $0x1,%dl
  801b93:	74 0e                	je     801ba3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b95:	c1 ea 0c             	shr    $0xc,%edx
  801b98:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b9f:	ef 
  801ba0:	0f b7 c0             	movzwl %ax,%eax
}
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    
  801ba5:	66 90                	xchg   %ax,%ax
  801ba7:	66 90                	xchg   %ax,%ax
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
